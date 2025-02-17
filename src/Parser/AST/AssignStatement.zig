const std = @import("std");
const mem = std.mem;

const Token = @import("../Token.zig");
const ExprNs = @import("Expr.zig");
const Expr = ExprNs.Expr;
const ValueType = ExprNs.ValueType;
const ExprKind = ExprNs.ExprKind;

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

    try fbuf.writeAll(" }}");
}

pub fn deinit(self: *const Self) void {
    self.value.deinit();
}
