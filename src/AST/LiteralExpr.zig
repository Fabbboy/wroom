const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = Token.ValueType;
const Position = @import("../Parser/Position.zig");

const Self = @This();

val: Token,
value_type: ValueType,
position: Position,

pub fn init(val: Token) Self {
    return Self{ .val = val, .value_type = switch (val.kind) {
        TokenKind.Int => ValueType.Int,
        TokenKind.Float => ValueType.Float,
        TokenKind.Null => ValueType.Void,
        else => ValueType.Untyped,
    }, .position = val.pos };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("LiteralExpr{ val: ");
    try self.val.fmt(fbuf);
    try fbuf.print(", value_type: {s} ", .{self.value_type.fmt()});
    try fbuf.writeAll(" }");
}

pub fn start(self: *const Self) usize {
    return self.position.start;
}

pub fn stop(self: *const Self) usize {
    return self.position.end;
}

pub fn pos(self: *const Self) Position {
    return self.position;
}
