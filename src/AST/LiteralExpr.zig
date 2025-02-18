const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = @import("Expr.zig").ValueType;

const Self = @This();

val: Token,
value_type: ValueType,
allocator: mem.Allocator,

pub fn init(val: Token, allocator: mem.Allocator) Self {
    return Self{
        .val = val,
        .value_type = switch (val.kind) {
            TokenKind.Int => ValueType.Int,
            TokenKind.Float => ValueType.Float,
            else => ValueType.Untyped,
        },
        .allocator = allocator,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("LiteralExpr{{ val: ");
    try self.val.fmt(fbuf);
    try fbuf.print(", value_type: {} }}", .{self.value_type});
}
