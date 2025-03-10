const std = @import("std");
const mem = std.mem;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = Token.ValueType;
const OperatorType = Token.OperatorType;

const Position = @import("Position.zig");

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");

const AssignStatement = @import("../AST/AssignStatement.zig");
const Linkage = AssignStatement.Linkage;

const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprData = ExprNs.ExprData;

const BinaryExpr = @import("../AST/BinaryExpr.zig");

const ParameterExpr = @import("../AST/ParameterExpr.zig");

const FunctionDecl = @import("../AST/FunctionDecl.zig");
const ReturnStatement = @import("../AST/ReturnStatement.zig");
const FunctionCall = @import("../AST/FunctionCall.zig");

const Stmt = @import("../AST/Stmt.zig").Stmt;

const Block = @import("../AST/Block.zig");

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
    const tok = try self.next(&[_]TokenKind{ TokenKind.Int, TokenKind.Float, TokenKind.Ident, TokenKind.LParen, TokenKind.Null });

    switch (tok.kind) {
        TokenKind.Int, TokenKind.Float, TokenKind.Null => return Expr.init_literal(tok, self.allocator),
        TokenKind.Ident => {
            if (self.peek(&[_]TokenKind{TokenKind.LParen})) {
                _ = try self.next(&[_]TokenKind{TokenKind.LParen});

                var args = std.ArrayList(Expr).init(self.allocator);
                while (!self.peek(&[_]TokenKind{TokenKind.RParen})) {
                    const arg = self.parseExpr() catch {
                        for (args.items) |a| {
                            a.deinit();
                        }
                        args.deinit();
                        return error.NotGood;
                    };

                    args.append(arg) catch {
                        for (args.items) |a| {
                            a.deinit();
                        }
                        args.deinit();
                        return error.NotGood;
                    };

                    if (self.peek(&[_]TokenKind{TokenKind.Comma})) {
                        _ = try self.next(&[_]TokenKind{TokenKind.Comma});
                    }
                }

                _ = try self.next(&[_]TokenKind{TokenKind.RParen});

                return Expr.init_function_call(tok, args, tok.pos, self.allocator);
            }

            return Expr.init_variable(tok, self.allocator);
        },
        TokenKind.LParen => {
            const expr = self.parseExpr() catch {
                return error.NotGood;
            };

            _ = try self.next(&[_]TokenKind{TokenKind.RParen});

            return expr;
        },
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
            TokenKind.Star => OperatorType.Star,
            TokenKind.Slash => OperatorType.Slash,
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
            TokenKind.Plus => OperatorType.Plus,
            TokenKind.Minus => OperatorType.Minus,
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

pub fn parseAssignStmt(self: *Self, constant: bool, linkage: Linkage) ParseStatus!AssignStatement {
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

    const assign = try self.next(&[_]TokenKind{TokenKind.Assign});
    const value = try self.parseExpr();

    return AssignStatement.init(
        ident,
        ty,
        value,
        constant,
        assign.data.?.Assign,
        true,
        linkage,
    );
}

fn parseBlock(self: *Self) ParseStatus!Block {
    const lbrace = try self.next(&[_]TokenKind{TokenKind.LBrace});

    var stmts = std.ArrayList(Stmt).init(self.allocator);
    while (!self.peek(&[_]TokenKind{TokenKind.RBrace})) {
        const stmt = self.parseStatement() catch {
            for (stmts.items) |s| {
                s.deinit();
            }
            stmts.deinit();
            return error.NotGood;
        };

        stmts.append(stmt) catch {
            for (stmts.items) |s| {
                s.deinit();
            }
            stmts.deinit();
            return error.NotGood;
        };
    }

    const rbrance = self.next(&[_]TokenKind{TokenKind.RBrace}) catch {
        for (stmts.items) |stmt| {
            stmt.deinit();
        }

        stmts.deinit();
        return error.NotGood;
    };

    var pos = lbrace.pos;
    pos.end = rbrance.pos.end;

    return Block.init(stmts, pos);
}

pub fn parseStatement(self: *Self) ParseStatus!Stmt {
    const tl_expected = [_]TokenKind{ TokenKind.Let, TokenKind.Const, TokenKind.Ident, TokenKind.Return };
    const tok = try self.next(&tl_expected);

    switch (tok.kind) {
        TokenKind.Const => {
            const stmt = self.parseAssignStmt(true, .Internal) catch {
                self.sync(&tl_expected);
                return error.NotGood;
            };
            return Stmt.init_assign(stmt);
        },
        TokenKind.Let => {
            const stmt = self.parseAssignStmt(false, .Internal) catch {
                self.sync(&tl_expected);
                return error.NotGood;
            };
            return Stmt.init_assign(stmt);
        },
        TokenKind.Ident => {
            if (self.peek(&[_]TokenKind{TokenKind.Assign})) {
                const assign = self.next(&[_]TokenKind{TokenKind.Assign}) catch {
                    self.sync(&tl_expected);
                    return error.NotGood;
                };

                const value = self.parseExpr() catch {
                    self.sync(&tl_expected);
                    return error.NotGood;
                };

                return Stmt.init_assign(AssignStatement.init(
                    tok,
                    ValueType.Untyped,
                    value,
                    false,
                    assign.data.?.Assign,
                    false,
                    .Internal,
                ));
            } else if (self.peek(&[_]TokenKind{TokenKind.LParen})) {
                _ = try self.next(&[_]TokenKind{TokenKind.LParen});

                var args = std.ArrayList(Expr).init(self.allocator);
                while (!self.peek(&[_]TokenKind{TokenKind.RParen})) {
                    const arg = self.parseExpr() catch {
                        for (args.items) |a| {
                            a.deinit();
                        }
                        args.deinit();
                        return error.NotGood;
                    };

                    args.append(arg) catch {
                        for (args.items) |a| {
                            a.deinit();
                        }
                        args.deinit();
                        return error.NotGood;
                    };

                    if (self.peek(&[_]TokenKind{TokenKind.Comma})) {
                        _ = try self.next(&[_]TokenKind{TokenKind.Comma});
                    }
                }

                _ = try self.next(&[_]TokenKind{TokenKind.RParen});

                return Stmt.init_function_call(FunctionCall.init(tok, args, tok.pos));
            } else {
                try self.errs.append(ParseError.init_unexpected_token(tok, &tl_expected));
                return error.NotGood;
            }
        },
        TokenKind.Return => {
            const value = self.parseExpr() catch {
                self.sync(&tl_expected);
                return error.NotGood;
            };

            return Stmt.init_return(ReturnStatement.init(value, tok.pos));
        },

        else => unreachable,
    }
}

fn parseFunctionDecl(self: *Self, linkage: Linkage) ParseStatus!FunctionDecl {
    const name = try self.next(&[_]TokenKind{TokenKind.Ident});
    _ = try self.next(&[_]TokenKind{TokenKind.LParen});
    var params = std.ArrayList(ParameterExpr).init(self.allocator);
    while (self.peek(&[_]TokenKind{TokenKind.Ident})) {
        const param = self.next(&[_]TokenKind{TokenKind.Ident}) catch {
            params.deinit();
            return error.NotGood;
        };
        _ = self.next(&[_]TokenKind{TokenKind.Colon}) catch {
            params.deinit();
            return error.NotGood;
        };
        const ptype = self.next(&[_]TokenKind{TokenKind.Type}) catch {
            params.deinit();
            return error.NotGood;
        };

        var pos = param.pos;
        pos.end = ptype.pos.end;

        params.append(ParameterExpr.init(param, pos, ptype.data.?.Type)) catch {
            params.deinit();
            return error.NotGood;
        };
        if (self.peek(&[_]TokenKind{TokenKind.Comma})) {
            _ = self.next(&[_]TokenKind{TokenKind.Comma}) catch {
                params.deinit();
                return error.NotGood;
            };
        }
    }

    _ = self.next(&[_]TokenKind{TokenKind.RParen}) catch {
        params.deinit();
        return error.NotGood;
    };
    const ftype = self.next(&[_]TokenKind{TokenKind.Type}) catch {
        params.deinit();
        return error.NotGood;
    };

    var final_pos = name.pos;
    final_pos.end = ftype.pos.end;

    var body: ?Block = null;
    if (self.peek(&[_]TokenKind{TokenKind.LBrace})) {
        body = self.parseBlock() catch {
            params.deinit();
            return error.NotGood;
        };
    }

    return FunctionDecl.init(name, ftype.data.?.Type, params, body, final_pos, linkage);
}

fn parse_tl(self: *Self, linkage: Linkage) ParseStatus!void {
    const tl_expected = [_]TokenKind{ TokenKind.Let, TokenKind.Const, TokenKind.Func, TokenKind.EOF };
    const tok = self.next(&tl_expected) catch {
        self.sync(&tl_expected);
        return error.NotGood;
    };

    if (tok.kind == TokenKind.EOF) {
        return;
    }

    switch (tok.kind) {
        TokenKind.Let, TokenKind.Const => {
            if (linkage == .External) {
                unreachable;
            }

            const constant = if (tok.kind == TokenKind.Const) true else false;
            const stmt = self.parseAssignStmt(constant, linkage) catch {
                self.sync(&tl_expected);
                return error.NotGood;
            };

            self.ast.pushGlobal(stmt) catch {
                return error.NotGood;
            };
        },
        TokenKind.Func => {
            const func = self.parseFunctionDecl(linkage) catch {
                self.sync(&tl_expected);
                return error.NotGood;
            };

            self.ast.pushFunction(func) catch {
                return error.NotGood;
            };
        },
        else => unreachable,
    }
}

pub fn parse(self: *Self) ParseStatus!void {
    var hasErr = false;

    const tl_expected = [_]TokenKind{ TokenKind.Let, TokenKind.Const, TokenKind.Pub, TokenKind.Extern, TokenKind.Func, TokenKind.EOF };
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
            TokenKind.Let, TokenKind.Const => {
                const constant = if (tok.kind == TokenKind.Const) true else false;
                const stmt = self.parseAssignStmt(constant, .Internal) catch {
                    self.sync(&tl_expected);
                    return error.NotGood;
                };

                self.ast.pushGlobal(stmt) catch {
                    return error.NotGood;
                };
            },
            TokenKind.Pub, TokenKind.Extern => self.parse_tl(if (tok.kind == TokenKind.Pub) .Public else .External) catch {
                hasErr = true;
                self.sync(&tl_expected);
                continue;
            },
            TokenKind.Func => {
                const func = self.parseFunctionDecl(.Internal) catch {
                    hasErr = true;
                    self.sync(&tl_expected);
                    continue;
                };

                self.ast.pushFunction(func) catch {
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

pub fn getErrs(self: *const Self) *const []ParseError {
    return &self.errs.items;
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
    try std.testing.expectEqual(ValueType.I32, stmt.type);

    const expr = stmt.value;
    try std.testing.expectEqual(ExprData.Literal, @as(ExprData, expr.data.*));
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
    try std.testing.expectEqual(ExprData.Binary, @as(ExprData, expr.data.*));
    try std.testing.expectEqual(OperatorType.Add, expr.data.Binary.op);

    const mul = expr.data.Binary.lhs;
    try std.testing.expectEqual(ExprData.Binary, @as(ExprData, mul.data.*));
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

    try std.testing.expectEqual(ValueType.I32, parser.ast.globals.items[0].type);
    try std.testing.expectEqual(ValueType.F32, parser.ast.globals.items[1].type);
    try std.testing.expectEqual(ValueType.Untyped, parser.ast.globals.items[2].type);
}

test "parser - function" {
    const source =
        \\func add(a: int, b: int) int {
        \\}
    ;
    var lexer = Lexer.init(source);
    var parser = Self.init(&lexer, std.testing.allocator);
    defer parser.deinit();

    try parser.parse();
    try std.testing.expectEqual(@as(usize, 1), parser.ast.functions.items.len);

    const func = parser.ast.functions.items[0];
    try std.testing.expectEqualStrings("add", func.name.lexeme);
    try std.testing.expectEqual(ValueType.I32, func.ret_type);

    try std.testing.expectEqual(@as(usize, 2), func.params.items.len);
    try std.testing.expectEqualStrings("a", func.params.items[0].ident.lexeme);
    try std.testing.expectEqual(ValueType.I32, func.params.items[0].type);
    try std.testing.expectEqualStrings("b", func.params.items[1].ident.lexeme);
    try std.testing.expectEqual(ValueType.I32, func.params.items[1].type);
}
