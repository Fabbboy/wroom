const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const ExprNs = @import("Expr.zig");
const Expr = ExprNs.Expr;
const ExprKind = ExprNs.ExprKind;

const Position = @import("../Parser/Position.zig");

const Self = @This();

ident: Token,
type: ValueType,
value: Expr,

pub fn init(ident: Token, ty: ValueType, value: Expr) Self {
    return Self{
        .ident = ident,
        .type = ty,
        .value = value,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("AssignStatement{{ ident: {}, type: {}, value: ", .{ self.ident, self.type });

    try self.value.fmt(fbuf);

    try fbuf.writeAll(" }");
}

pub fn setType(self: *Self, ty: ValueType) void {
    self.type = ty;
}

pub fn getType(self: *const Self) ValueType {
    return self.type;
}

pub fn deinit(self: *const Self) void {
    self.value.deinit();
}

pub fn start(self: *const Self) usize {
    return self.ident.pos.start;
}

pub fn stop(self: *const Self) usize {
    return self.value.stop();
}

pub fn pos(self: *const Self) Position {
    return Position.init(self.ident.pos.line, self.ident.pos.column, self.start(), self.stop());
}
