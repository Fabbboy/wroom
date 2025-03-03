const std = @import("std");
const mem = std.mem;

const ExprNs = @import("Expr.zig");
const Expr = ExprNs.Expr;

const Position = @import("../Parser/Position.zig");

const Token = @import("../Parser/Token.zig");
const OperatorType = Token.OperatorType;

const ParseStatus = @import("../Parser/Error.zig").ParseStatus;

const Self = @This();

lhs: Expr,
rhs: Expr,
op: OperatorType,

pub fn init(lhs: Expr, rhs: Expr, op: OperatorType) Self {
    return Self{
        .lhs = lhs,
        .rhs = rhs,
        .op = op,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) ParseStatus!void {
    try fbuf.writeAll("BinaryExpr{ lhs: ");
    try self.lhs.fmt(fbuf);
    try fbuf.writeAll(", rhs: ");
    try self.rhs.fmt(fbuf);
    try fbuf.print(", op: {} ", .{self.op});
    try fbuf.writeAll(" }");
}

pub fn deinit(self: *const Self) void {
    self.rhs.deinit();
    self.lhs.deinit();
}

pub fn getRHS(self: *const Self) *const Expr {
    return &self.rhs;
}

pub fn getLHS(self: *const Self) *const Expr {
    return &self.lhs;
}

pub fn start(self: *const Self) usize {
    return self.lhs.start();
}

pub fn stop(self: *const Self) usize {
    return self.rhs.stop();
}

pub fn pos(self: *const Self) Position {
    return Position.init(self.lhs.pos().line, self.lhs.pos().column, self.lhs.start(), self.rhs.stop());
}
