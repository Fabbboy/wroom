const std = @import("std");
const sys_fmt = std.fmt;
const io = std.io;
const mem = std.mem;
const Position = @import("Position.zig");

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
    Let,
    Period,
    Colon,
    Type,
    Func,
    LParen,
    RParen,
    Comma,

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
            TokenKind.Let => "Let",
            TokenKind.Period => "Period",
            TokenKind.Colon => "Colon",
            TokenKind.Type => "Type",
            TokenKind.Func => "Func",
            TokenKind.LParen => "LParen",
            TokenKind.RParen => "RParen",
            TokenKind.Comma => "Comma",
        };
    }
};

pub const ValueType = enum {
    Untyped,
    Int,
    Float,

    pub fn fmt(self: ValueType) []const u8 {
        return switch (self) {
            ValueType.Untyped => "Untyped",
            ValueType.Int => "Int",
            ValueType.Float => "Float",
        };
    }
};

pub const TokenData = union(TokenKind) {
    EOF: void,
    Invalid: void,
    Ident: void,
    Int: void,
    Float: void,
    Assign: void,
    Plus: void,
    Minus: void,
    Star: void,
    Slash: void,
    Let: void,
    Period: void,
    Colon: void,
    Type: ValueType,
    Func: void,
    LParen: void,
    RParen: void,
    Comma: void,
};

kind: TokenKind,
lexeme: []const u8,
pos: Position,
data: ?TokenData,

pub fn init(kind: TokenKind, lexeme: []const u8, pos: Position) Self {
    return Self{
        .kind = kind,
        .lexeme = lexeme,
        .pos = pos,
        .data = null,
    };
}

pub fn initWithValue(kind: TokenKind, lexeme: []const u8, pos: Position, data: TokenData) Self {
    return Self{
        .kind = kind,
        .lexeme = lexeme,
        .pos = pos,
        .data = data,
    };
}

pub fn empty() Self {
    return Self{
        .kind = TokenKind.Invalid,
        .lexeme = &[_]u8{},
        .pos = Position.init(0, 0, 0, 0),
        .data = null,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("Token{ kind: ");
    try fbuf.print("{s}, lexeme: '{s}', pos: ", .{ self.kind.fmt(), self.lexeme });
    try self.pos.fmt(fbuf);
    try fbuf.writeAll(" }");
}

pub const KeywordValue = struct {
    kind: TokenKind,
    data: ?TokenData,
};

pub const keywords = std.StaticStringMap(KeywordValue).initComptime(.{
    .{ "let", .{ .kind = TokenKind.Let, .data = null } },
    .{ "int", .{ .kind = TokenKind.Type, .data = TokenData{ .Type = ValueType.Int } } },
    .{ "float", .{ .kind = TokenKind.Type, .data = TokenData{ .Type = ValueType.Float } } },
    .{ "func", .{ .kind = TokenKind.Func, .data = null } },
});
