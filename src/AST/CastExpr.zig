const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Expr = @import("Expr.zig").Expr;

const Position = @import("../Parser/Position.zig");

const Self = @This();

val: Expr,
cast_to: ValueType,
position: Position,

pub fn init(val: Expr, cast_to: ValueType, position: Position) Self {
    return Self{ .val = val, .cast_to = cast_to, .position = position };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("CastExpr{ val: ");
    try self.val.fmt(fbuf);
    try fbuf.writeAll(", cast_to: ");
    try fbuf.print("{s}, pos: ", .{self.cast_to});
    try self.position.fmt(fbuf);
    try fbuf.writeAll(" }");
}

pub fn deinit(self: *Self) void {
    self.val.deinit();
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
