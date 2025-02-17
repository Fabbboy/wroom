const std = @import("std");
const sys_fmt = std.fmt;
const io = std.io;
const mem = std.mem;
const Position = @import("position.zig");

const Self = @This();

pub const TokenKind = enum {
    EOF,
    Invalid,
    Ident,
    Int,
    Float,
    Assign,
    Plus,
    Minus,
    Star,
    Slash,

    pub fn fmt(self: TokenKind) []const u8 {
        return switch (self) {
            TokenKind.EOF => "EOF",
            TokenKind.Invalid => "Invalid",
            TokenKind.Ident => "Ident",
            TokenKind.Int => "Int",
            TokenKind.Float => "Float",
            TokenKind.Assign => "Assign",
            TokenKind.Plus => "Plus",
            TokenKind.Minus => "Minus",
            TokenKind.Star => "Star",
            TokenKind.Slash => "Slash",
        };
    }
};

kind: TokenKind,
lexeme: []const u8,
pos: Position,

pub fn init(kind: TokenKind, lexeme: []const u8, pos: Position) Self {
    return Self{
        .kind = kind,
        .lexeme = lexeme,
        .pos = pos,
    };
}

pub fn empty() Self {
    return Self{
        .kind = TokenKind.Invalid,
        .lexeme = &[_]u8{},
        .pos = Position.init(0, 0, 0, 0),
    };
}
