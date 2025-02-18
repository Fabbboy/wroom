const std = @import("std");
const mem = std.mem;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");

const AssignStatement = @import("../AST/AssignStatement.zig");
const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ValueType = ExprNs.ValueType;

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
    _ = try self.next(&[_]TokenKind{TokenKind.Assign});

    const ty = ValueType.Untyped;
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
