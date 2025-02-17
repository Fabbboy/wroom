const std = @import("std");
const mem = std.mem;

const Token = @import("../Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = @import("Expr.zig").ValueType;

const Self = @This();

val: Token,
value_type: ValueType,
allocator: mem.Allocator,

pub fn init(val: Token, allocator: mem.Allocator) Self {
    return Self{
        .val = val,
        .value_type = ValueType.Untyped,
        .allocator = allocator,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("LiteralExpr{{ val: ");
    try self.val.fmt(fbuf);
    try fbuf.print(", value_type: {} }}", .{self.value_type});
}

pub fn getAllocator(self: *const Self) mem.Allocator {
    return self.allocator;
}
