const std = @import("std");

const Token = @import("../Parser/Token.zig");
const Position = @import("../Parser/Position.zig");

const Expr = @import("Expr.zig").Expr;

const Self = @This();

arguments: std.ArrayList(Expr),
name: Token,
position: Position,

pub fn init(name: Token, arguments: std.ArrayList(Expr), position: Position) Self {
    return Self{
        .arguments = arguments,
        .name = name,
        .position = position,
    };
}

pub fn deinit(self: *const Self) void {
    for (self.arguments.items) |arg| {
        arg.deinit();
    }
    self.arguments.deinit();
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("FunctionCall{ name: ");
    try self.name.fmt(fbuf);
    try fbuf.writeAll(", arguments: [");
    for (self.arguments.items, 0..) |arg, i| {
        try arg.fmt(fbuf);
        if (i + 1 != self.arguments.items.len) {
            try fbuf.writeAll(", ");
        }
    }
    try fbuf.writeAll("] }");
}

pub fn start(self: *const Self) usize {
    return self.position.start;
}

pub fn stop(self: *const Self) usize {
    return self.arguments.items[self.arguments.items.len - 1].stop();
}

pub fn pos(self: *const Self) Position {
    return self.position;
}
