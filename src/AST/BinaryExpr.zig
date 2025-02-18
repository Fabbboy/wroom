const std = @import("std");
const mem = std.mem;

const ExprNs = @import("Expr.zig");
const Expr = ExprNs.Expr;

pub const OperatorType = enum {
    Add,
    Sub,
    Mul,
    Div,
};

const Self = @This();

lhs: Expr,
rhs: Expr,
op: OperatorType,
allocator: mem.Allocator,

pub fn init(lhs: Expr, rhs: Expr, op: OperatorType, allocator: mem.Allocator) Self {
    return Self{
        .lhs = lhs,
        .rhs = rhs,
        .op = op,
        .allocator = allocator,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) error{OutOfMemory}!void {
    try fbuf.writeAll("BinaryExpr{{ lhs: ");
    try self.lhs.fmt(fbuf);
    try fbuf.writeAll(", rhs: ");
    try self.rhs.fmt(fbuf);
    try fbuf.print(", op: {} }}", .{self.op});
}

pub fn deinit(self: *Self) void {
    self.rhs.deinit();
    self.lhs.deinit();
}
