const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const TokenKind = Token.TokenKind;
const ValueType = Token.ValueType;
const Position = @import("../Parser/Position.zig");

const Self = @This();

name: Token,
position: Position,

pub fn init(name: Token) Self {
    return Self{ .name = name, .position = name.pos };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("VariableExpr{ name: ");
    try self.name.fmt(fbuf);
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
