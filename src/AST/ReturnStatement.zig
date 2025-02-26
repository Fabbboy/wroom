const Position = @import("../Parser/Position.zig");

const Expr = @import("Expr.zig").Expr;

const Self = @This();

value: Expr,
position: Position,

pub fn init(value: Expr, position: Position) Self {
    return .{
        .value = value,
        .position = position,
    };
}

pub fn deinit(self: *const Self) void {
    self.value.deinit();
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("ReturnStatement{ value: ");
    try self.value.fmt(fbuf);
    try fbuf.writeAll(" }");
}

pub fn start(self: *const Self) usize {
    return self.position.start;
}

pub fn stop(self: *const Self) usize {
    return self.value.stop();
}

pub fn pos(self: *const Self) Position {
    return self.position;
}
