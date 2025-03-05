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
    Null,
    Assign,
    Plus,
    Minus,
    Star,
    Slash,
    Let,
    Const,
    Pub,
    Extern,
    Period,
    Colon,
    Type,
    Func,
    LParen,
    RParen,
    Comma,
    LBrace,
    RBrace,
    Return,

    pub fn fmt(self: TokenKind) []const u8 {
        return switch (self) {
            TokenKind.EOF => "EOF",
            TokenKind.Invalid => "Invalid",
            TokenKind.Ident => "Ident",
            TokenKind.Int => "Int",
            TokenKind.Float => "Float",
            TokenKind.Null => "Null",
            TokenKind.Assign => "Assign",
            TokenKind.Plus => "Plus",
            TokenKind.Minus => "Minus",
            TokenKind.Star => "Star",
            TokenKind.Slash => "Slash",
            TokenKind.Let => "Let",
            TokenKind.Const => "Const",
            TokenKind.Pub => "Pub",
            TokenKind.Extern => "Extern",
            TokenKind.Period => "Period",
            TokenKind.Colon => "Colon",
            TokenKind.Type => "Type",
            TokenKind.Func => "Func",
            TokenKind.LParen => "LParen",
            TokenKind.RParen => "RParen",
            TokenKind.Comma => "Comma",
            TokenKind.LBrace => "LBrace",
            TokenKind.RBrace => "RBrace",
            TokenKind.Return => "Return",
        };
    }
};

pub const ValueType = enum {
    Untyped,
    Ptr,
    I32,
    F32,
    Void,

    pub fn fmt(self: ValueType) []const u8 {
        return switch (self) {
            ValueType.Untyped => "untyped",
            ValueType.Ptr => "ptr",
            ValueType.I32 => "i32",
            ValueType.F32 => "f32",
            ValueType.Void => "void",
        };
    }
};

pub const OperatorType = enum {
    Assign,
    Plus,
    Minus,
    Star,
    Slash,

    pub fn fmt(self: OperatorType) []const u8 {
        return switch (self) {
            OperatorType.Assign => "Assign",
            OperatorType.Plus => "Plus",
            OperatorType.Minus => "Minus",
            OperatorType.Star => "Star",
            OperatorType.Slash => "Slash",
        };
    }
};

pub const TokenData = union(TokenKind) {
    EOF: void,
    Invalid: void,
    Ident: void,
    Int: void,
    Float: void,
    Null: void,
    Assign: OperatorType,
    Plus: void,
    Minus: void,
    Star: void,
    Slash: void,
    Let: void,
    Const: void,
    Pub: void,
    Extern: void,
    Period: void,
    Colon: void,
    Type: ValueType,
    Func: void,
    LParen: void,
    RParen: void,
    Comma: void,
    LBrace: void,
    RBrace: void,
    Return: void,
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
    .{ "let", KeywordValue{ .kind = TokenKind.Let, .data = null } },
    .{ "const", KeywordValue{ .kind = TokenKind.Const, .data = null } },
    .{ "pub", KeywordValue{ .kind = TokenKind.Pub, .data = null } },
    .{ "extern", KeywordValue{ .kind = TokenKind.Extern, .data = null } },
    .{ "int", KeywordValue{ .kind = TokenKind.Type, .data = TokenData{ .Type = ValueType.I32 } } },
    .{ "float", KeywordValue{ .kind = TokenKind.Type, .data = TokenData{ .Type = ValueType.F32 } } },
    .{ "void", KeywordValue{ .kind = TokenKind.Type, .data = TokenData{ .Type = ValueType.Void } } },
    .{ "func", KeywordValue{ .kind = TokenKind.Func, .data = null } },
    .{ "return", KeywordValue{ .kind = TokenKind.Return, .data = null } },
    .{ "null", KeywordValue{ .kind = TokenKind.Null, .data = null } },
});

pub const operators = std.StaticStringMap(OperatorType).initComptime(.{
    .{ "+", OperatorType.Plus },
    .{ "-", OperatorType.Minus },
    .{ "*", OperatorType.Star },
    .{ "/", OperatorType.Slash },
    .{ "=", OperatorType.Assign },
});
