const Token = @import("../Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = @import("Expr.zig").ValueType;

const Self = @This();

val: Token,
value_type: ValueType,

pub fn init(val: Token) Self {
    return Self{
        .val = val,
        .value_type = switch (val.kind) {
            TokenKind.Int => ValueType.Int,
            TokenKind.Float => ValueType.Float,
            _ => unreachable,
        },
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("LiteralExpr{{ val: ");
    try self.val.fmt(fbuf);
    try fbuf.print(", value_type: {} }}", .{self.value_type});
}
