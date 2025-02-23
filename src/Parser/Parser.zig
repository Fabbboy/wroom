const std = @import("std");
const mem = std.mem;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = Token.ValueType;

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");

const AssignStatement = @import("../AST/AssignStatement.zig");
const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprKind = ExprNs.ExprKind;

const BinaryExpr = @import("../AST/BinaryExpr.zig");
const OperatorType = BinaryExpr.OperatorType;

const Error = @import("Error.zig");
const ParseError = Error.ParseError;
const ParseStatus = Error.ParseStatus;
const MAX_EXPECTED_KINDS = Error.MAX_EXPECTED_KINDS;

const Self = @This();

allocator: mem.Allocator,
lexer: *Lexer,
ast: Ast,
errs: std.ArrayList(ParseError),

pub fn init(lexer: *Lexer, allocator: mem.Allocator) Self {
    return Self{
        .lexer = lexer,
        .ast = Ast.init(allocator),
        .allocator = allocator,
        .errs = std.ArrayList(ParseError).init(allocator),
    };
}

fn next(self: *Self, expected: []const TokenKind) ParseStatus!Token {
    if (expected.len > MAX_EXPECTED_KINDS) {
        @panic("Too many expected kinds");
    }

    const tok = self.lexer.next();
    if (tok.kind == TokenKind.Invalid) {
        try self.errs.append(ParseError.init_lexer_error(tok));
        return error.NotGood;
    }

    if (expected.len == 0) {
        return tok;
    }

    for (expected) |kind| {
        if (tok.kind == kind) {
            return tok;
        }
    }

    try self.errs.append(ParseError.init_unexpected_token(tok, expected));
    return error.NotGood;
}

fn peek(self: *const Self, expected: []const TokenKind) bool {
    if (expected.len > MAX_EXPECTED_KINDS) {
        @panic("Too many expected kinds");
    }

    const tok = self.lexer.peek();
    if (tok.kind == TokenKind.Invalid) {
        return false;
    }

    if (expected.len == 0) {
        return true;
    }

    for (expected) |kind| {
        if (tok.kind == kind) {
            return true;
        }
    }

    return false;
}

fn sync(self: *Self, expected: []const TokenKind) void {
    while (true) {
        const tok = self.lexer.peek();
        if (tok.kind == TokenKind.Invalid) {
            return;
        }

        for (expected) |kind| {
            if (tok.kind == kind) {
                return;
            }
        }

        _ = self.lexer.next();
    }
}

fn parseFactor(self: *Self) ParseStatus!Expr {
    const tok = try self.next(&[_]TokenKind{ TokenKind.Int, TokenKind.Float });

    switch (tok.kind) {
        TokenKind.Int, TokenKind.Float => return Expr.init_literal(tok, self.allocator),
        else => unreachable,
    }
}

fn parseTerm(self: *Self) ParseStatus!Expr {
    const lhs = try self.parseFactor();

    if (self.peek(&[_]TokenKind{ TokenKind.Star, TokenKind.Slash })) {
        const op = self.next(&[_]TokenKind{ TokenKind.Star, TokenKind.Slash }) catch |err| {
            lhs.deinit();
            return err;
        };
        const fin_op = switch (op.kind) {
            TokenKind.Star => OperatorType.Mul,
            TokenKind.Slash => OperatorType.Div,
            else => unreachable,
        };

        const rhs = self.parseTerm() catch |err| {
            lhs.deinit();
            return err;
        };

        return Expr.init_binary(lhs, rhs, fin_op, self.allocator);
    }

    return lhs;
}

fn parseExpr(self: *Self) ParseStatus!Expr {
    const lhs = try self.parseTerm();

    if (self.peek(&[_]TokenKind{ TokenKind.Plus, TokenKind.Minus })) {
        const op = self.next(&[_]TokenKind{ TokenKind.Plus, TokenKind.Minus }) catch |err| {
            lhs.deinit();
            return err;
        };
        const fin_op = switch (op.kind) {
            TokenKind.Plus => OperatorType.Add,
            TokenKind.Minus => OperatorType.Sub,
            else => unreachable,
        };

        const rhs = self.parseExpr() catch |err| {
            lhs.deinit();
            return err;
        };

        return Expr.init_binary(lhs, rhs, fin_op, self.allocator);
    }

    return lhs;
}

pub fn parseAssignStmt(self: *Self) ParseStatus!AssignStatement {
    const ident = try self.next(&[_]TokenKind{TokenKind.Ident});

    var ty = ValueType.Untyped;
    if (self.peek(&[_]TokenKind{TokenKind.Colon})) {
        _ = try self.next(&[_]TokenKind{TokenKind.Colon});

        const tyTok = try self.next(&[_]TokenKind{TokenKind.Type});
        if (tyTok.data) |data| {
            switch (data) {
                TokenKind.Type => {
                    ty = tyTok.data.?.Type;
                },
                else => unreachable,
            }
        } else {
            unreachable;
        }
    }

    _ = try self.next(&[_]TokenKind{TokenKind.Assign});
    const value = try self.parseExpr();

    return AssignStatement.init(ident, ty, value);
}

pub fn parse(self: *Self) ParseStatus!void {
    var hasErr = false;

    const tl_expected = [_]TokenKind{ TokenKind.Let, TokenKind.EOF };
    while (true) {
        const tok = self.next(&tl_expected) catch {
            hasErr = true;
            self.sync(&tl_expected);
            continue;
        };

        if (tok.kind == TokenKind.EOF) {
            break;
        }

        switch (tok.kind) {
            TokenKind.Let => {
                const stmt = self.parseAssignStmt() catch {
                    hasErr = true;
                    self.sync(&tl_expected);
                    continue;
                };

                self.ast.pushGlobal(stmt) catch {
                    continue;
                };
            },
            else => unreachable,
        }
    }

    if (hasErr) {
        return error.NotGood;
    }

    return;
}

pub fn getAst(self: *Self) *Ast {
    return &self.ast;
}

pub fn getErrs(self: *const Self) *const std.ArrayList(ParseError) {
    return &self.errs;
}

pub fn deinit(self: *Self) void {
    self.ast.deinit();
    self.errs.deinit();
}

test "parser - simple assignment" {
    const source = "let x: int = 42";
    var lexer = Lexer.init(source);
    var parser = Self.init(&lexer, std.testing.allocator);
    defer parser.deinit();

    try parser.parse();
    try std.testing.expectEqual(@as(usize, 1), parser.ast.globals.items.len);

    const stmt = parser.ast.globals.items[0];
    try std.testing.expectEqual(TokenKind.Ident, stmt.ident.kind);
    try std.testing.expectEqualStrings("x", stmt.ident.lexeme);
    try std.testing.expectEqual(ValueType.Int, stmt.type);

    const expr = stmt.value;
    try std.testing.expectEqual(ExprKind.Literal, @as(ExprKind, expr.data.*));
    try std.testing.expectEqualStrings("42", expr.data.Literal.val.lexeme);
}

test "parser - binary expressions" {
    const source = "let calc = 2 * 3 + 4";
    var lexer = Lexer.init(source);
    var parser = Self.init(&lexer, std.testing.allocator);
    defer parser.deinit();

    try parser.parse();
    try std.testing.expectEqual(@as(usize, 1), parser.ast.globals.items.len);

    const stmt = parser.ast.globals.items[0];
    try std.testing.expectEqualStrings("calc", stmt.ident.lexeme);
    try std.testing.expectEqual(ValueType.Untyped, stmt.type);

    const expr = stmt.value;
    try std.testing.expectEqual(ExprKind.Binary, @as(ExprKind, expr.data.*));
    try std.testing.expectEqual(OperatorType.Add, expr.data.Binary.op);

    const mul = expr.data.Binary.lhs;
    try std.testing.expectEqual(ExprKind.Binary, @as(ExprKind, mul.data.*));
    try std.testing.expectEqual(OperatorType.Mul, mul.data.Binary.op);
}

test "parser - error handling" {
    const source = "let 123 = 42";
    var lexer = Lexer.init(source);
    var parser = Self.init(&lexer, std.testing.allocator);
    defer parser.deinit();

    try std.testing.expectError(error.NotGood, parser.parse());
    try std.testing.expectEqual(@as(usize, 1), parser.errs.items.len);

    const err = parser.errs.items[0];
    switch (err) {
        .UnexpectedToken => |e| {
            try std.testing.expectEqual(TokenKind.Int, e.got.kind);
            try std.testing.expectEqual(TokenKind.Ident, e.expected[0]);
        },
        else => try std.testing.expect(false),
    }
}

test "parser - multiple declarations" {
    const source =
        \\let x: int = 1
        \\let y: float = 2.5
        \\let z = 3
    ;
    var lexer = Lexer.init(source);
    var parser = Self.init(&lexer, std.testing.allocator);
    defer parser.deinit();

    try parser.parse();
    try std.testing.expectEqual(@as(usize, 3), parser.ast.globals.items.len);

    try std.testing.expectEqual(ValueType.Int, parser.ast.globals.items[0].type);
    try std.testing.expectEqual(ValueType.Float, parser.ast.globals.items[1].type);
    try std.testing.expectEqual(ValueType.Untyped, parser.ast.globals.items[2].type);
}
