const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

pub const MAX_EXPECTED_KINDS = 16;

pub const ParseStatus = error{
    NotGood,
    OutOfMemory,
};

pub const ParseError = union(enum) {
    UnexpectedToken: UnexpectedToken,
    LexerError: LexerError,

    pub fn init_unexpected_token(got: Token, expected: []const TokenKind) ParseError {
        return .{ .UnexpectedToken = UnexpectedToken.init(got, expected) };
    }

    pub fn init_lexer_error(got: Token) ParseError {
        return .{ .LexerError = LexerError.init(got) };
    }

    pub fn fmt(self: *const ParseError, fbuf: anytype) !void {
        return switch (self.*) {
            .UnexpectedToken => self.UnexpectedToken.fmt(fbuf),
            .LexerError => self.LexerError.fmt(fbuf),
        };
    }
};

pub const UnexpectedToken = struct {
    got: Token,
    expected: [MAX_EXPECTED_KINDS]TokenKind,
    expected_len: usize,

    pub fn init(got: Token, expected: []const TokenKind) UnexpectedToken {
        if (expected.len > MAX_EXPECTED_KINDS) {
            @panic("Too many expected kinds");
        }

        var e = UnexpectedToken{
            .got = got,
            .expected = undefined,
            .expected_len = expected.len,
        };

        for (expected, 0..) |kind, i| {
            e.expected[i] = kind;
        }

        return e;
    }

    pub fn fmt(self: *const UnexpectedToken, fbuf: anytype) !void {
        try fbuf.print("Unexpected token: {s}, expected one of: ", .{self.got.kind.fmt()});
        for (0..self.expected_len) |i| {
            try fbuf.print("{s}", .{self.expected[i].fmt()});
            if (i + 1 != self.expected_len) {
                try fbuf.writeAll(", ");
            }
        }
    }
};

pub const LexerError = struct {
    got: Token,

    pub fn fmt(self: *const LexerError, fbuf: anytype) !void {
        try fbuf.writeAll("Lexer error: ");
        try self.got.fmt(fbuf);
    }

    pub fn init(got: Token) LexerError {
        return LexerError{ .got = got };
    }
};
