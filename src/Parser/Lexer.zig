const std = @import("std");
const ascii = std.ascii;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;
const TokenData = Token.TokenData;
const keywords = Token.keywords;

const Position = @import("Position.zig");

const Self = @This();

source: []const u8,
idx: usize,
line: usize,
column: usize,
start: usize,
currTok: Token,
nextTok: Token,

pub fn init(source: []const u8) Self {
    var s = Self{
        .source = source,
        .line = 1,
        .column = 1,
        .start = 0,
        .idx = 0,
        .currTok = Token.empty(),
        .nextTok = Token.empty(),
    };

    _ = s.next();
    return s;
}

fn getPosition(self: *Self) Position {
    return Position.init(self.line, self.column, self.start, self.idx);
}

fn getLexeme(self: *Self) []const u8 {
    return self.source[self.start..self.idx];
}

fn getToken(self: *Self, kind: TokenKind) Token {
    return Token.init(kind, self.getLexeme(), self.getPosition());
}

fn getTokenWithValue(self: *Self, kind: TokenKind, value: TokenData) Token {
    return Token.initWithValue(kind, self.getLexeme(), self.getPosition(), value);
}

fn getChar(self: *Self) u8 {
    if (self.idx >= self.source.len) {
        return 0;
    }

    return self.source[self.idx];
}

fn getPeekChar(self: *Self) u8 {
    if (self.idx + 1 >= self.source.len) {
        return 0;
    }

    return self.source[self.idx + 1];
}

fn advance(self: *Self) void {
    const c = self.getChar();
    if (c == '\n') {
        self.line += 1;
        self.column = 1;
    } else {
        self.column += 1;
    }

    self.idx += 1;
}

fn lexTrivia(self: *Self) void {
    while (self.idx < self.source.len and ascii.isWhitespace(self.getChar())) {
        self.advance();
    }
}

fn lexIdentifier(self: *Self) Token {
    while (ascii.isAlphanumeric(self.getChar()) or self.getChar() == '_') {
        self.advance();
    }

    const lexeme = self.getLexeme();
    const kv_raw = keywords.get(lexeme);
    if (kv_raw) |kv| {
        if (kv.data) |data| {
            return self.getTokenWithValue(kv.kind, data);
        } else {
            return self.getToken(kv.kind);
        }
    }

    return self.getToken(TokenKind.Ident);
}

fn lexNumber(self: *Self) Token {
    var kind = TokenKind.Int;

    while (ascii.isDigit(self.getChar())) {
        self.advance();
    }

    if (self.getChar() == '.' and ascii.isDigit(self.getPeekChar())) {
        self.advance();
        kind = TokenKind.Float;
        while (ascii.isDigit(self.getChar())) {
            self.advance();
        }
    }

    return self.getToken(kind);
}

fn lex(self: *Self) Token {
    self.lexTrivia();
    if (self.idx >= self.source.len) {
        return self.getToken(TokenKind.EOF);
    }

    self.start = self.idx;
    const c = self.getChar();
    self.advance();

    switch (c) {
        '0'...'9' => return self.lexNumber(),
        'a'...'z', 'A'...'Z', '_' => return self.lexIdentifier(),
        '=' => return self.getToken(TokenKind.Assign),
        '+' => return self.getToken(TokenKind.Plus),
        '-' => return self.getToken(TokenKind.Minus),
        '*' => return self.getToken(TokenKind.Star),
        '/' => return self.getToken(TokenKind.Slash),
        '.' => return self.getToken(TokenKind.Period),
        ':' => return self.getToken(TokenKind.Colon),
        '(' => return self.getToken(TokenKind.LParen),
        ')' => return self.getToken(TokenKind.RParen),
        ',' => return self.getToken(TokenKind.Comma),
        else => return self.getToken(TokenKind.Invalid),
    }
}

pub fn next(self: *Self) Token {
    self.currTok = self.nextTok;
    self.nextTok = self.lex();
    return self.currTok;
}

pub fn peek(self: *Self) Token {
    return self.nextTok;
}

test "lexer - simple tokens" {
    const source = "= + - * / . :";
    var lexer = Self.init(source);

    try std.testing.expectEqual(TokenKind.Assign, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Plus, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Minus, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Star, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Slash, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Period, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.Colon, lexer.next().kind);
    try std.testing.expectEqual(TokenKind.EOF, lexer.next().kind);
}

test "lexer - numbers" {
    const source = "123 45.67";
    var lexer = Self.init(source);

    const intToken = lexer.next();
    try std.testing.expectEqual(TokenKind.Int, intToken.kind);
    try std.testing.expectEqualStrings("123", intToken.lexeme);

    const floatToken = lexer.next();
    try std.testing.expectEqual(TokenKind.Float, floatToken.kind);
    try std.testing.expectEqualStrings("45.67", floatToken.lexeme);
}

test "lexer - identifiers and keywords" {
    const source = "foo bar_baz _test";
    var lexer = Self.init(source);

    const id1 = lexer.next();
    try std.testing.expectEqual(TokenKind.Ident, id1.kind);
    try std.testing.expectEqualStrings("foo", id1.lexeme);

    const id2 = lexer.next();
    try std.testing.expectEqual(TokenKind.Ident, id2.kind);
    try std.testing.expectEqualStrings("bar_baz", id2.lexeme);

    const id3 = lexer.next();
    try std.testing.expectEqual(TokenKind.Ident, id3.kind);
    try std.testing.expectEqualStrings("_test", id3.lexeme);
}

test "lexer - whitespace handling" {
    const source = "  \n\t  123  foo  \n  ";
    var lexer = Self.init(source);

    const numToken = lexer.next();
    try std.testing.expectEqual(TokenKind.Int, numToken.kind);
    try std.testing.expectEqualStrings("123", numToken.lexeme);

    const idToken = lexer.next();
    try std.testing.expectEqual(TokenKind.Ident, idToken.kind);
    try std.testing.expectEqualStrings("foo", idToken.lexeme);

    try std.testing.expectEqual(TokenKind.EOF, lexer.next().kind);
}
