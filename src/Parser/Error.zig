const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

const MAX_EXPECTED_KINDS = 16;

pub const ParseStatus = error{
    NotGood,
};

pub const ParseError = union(enum) {
    UnexpectedToken: UnexpectedToken,
};

pub const UnexpectedToken = struct {
    got: Token,
    expected: [MAX_EXPECTED_KINDS]TokenKind,
    expected_len: usize,

    pub fn init(got: Token, expected: []TokenKind) UnexpectedToken {
        if (expected.len > MAX_EXPECTED_KINDS) {
            @panic("Too many expected kinds");
        }

        var e = UnexpectedToken{
            .got = got,
            .expected_len = expected.len,
        };

        for (expected, 0..) |kind, i| {
            e.expected[i] = kind;
        }

        return e;
    }

    pub fn fmt(self: *const UnexpectedToken, fbuf: anytype) !void {
        try fbuf.print("Unexpected token: {s}, expected one of: ", .{self.got});
        for (self.expected_len) |i| {
            try fbuf.print("{s}", .{self.expected[i]});
            if (i + 1 != self.expected_len) {
                try fbuf.writeAll(", ");
            }
        }
    }
};
