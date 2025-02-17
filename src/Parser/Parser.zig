const std = @import("std");
const mem = std.mem;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");
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

pub fn parse(self: *Self) ParseStatus!void {
    const tl_expected = [_]TokenKind{ TokenKind.Let, TokenKind.EOF };
    while (true) {
        const tok = self.next(&tl_expected) catch {
            continue;
        };

        if (tok.kind == TokenKind.EOF) {
            break;
        }

        switch (tok.kind) {
            TokenKind.Let => {
                continue;
            },
            else => unreachable,
        }
    }

    return error.NotGood;
}

pub fn getAst(self: *const Self) *const Ast {
    return &self.ast;
}

pub fn getErrs(self: *const Self) *const std.ArrayList(ParseError) {
    return &self.errs;
}

pub fn deinit(self: *Self) void {
    self.ast.deinit();
    self.errs.deinit();
}
