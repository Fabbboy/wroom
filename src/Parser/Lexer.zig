const std = @import("std");
const ascii = std.ascii;

const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;
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

fn getChar(self: *Self) u8 {
    if (self.idx >= self.source.len) {
        return 0;
    }

    return self.source[self.idx];
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
    const kind = keywords.get(lexeme);
    if (kind) |k| {
        return self.getToken(k);
    }

    return self.getToken(TokenKind.Ident);
}

fn lexNumber(self: *Self) Token {
    var kind = TokenKind.Int;

    while (ascii.isDigit(self.getChar())) {
        self.advance();
    }

    if (ascii.isDigit(self.getChar())) {
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
