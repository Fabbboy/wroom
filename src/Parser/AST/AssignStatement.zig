const std = @import("std");
const mem = std.mem;

const Token = @import("../Token.zig");
const Expr = @import("Expr.zig");
const ValueType = Expr.ValueType;
const ExprKind = Expr.ExprKind;

const Self = @This();

ident: Token,
type: ValueType,
value: Expr.Expr,
allocator: mem.Allocator,

pub fn init(ident: Token, ty: ValueType, value: Expr, allocator: mem.Allocator) Self {
    return Self{
        .ident = ident,
        .type = ty,
        .value = value,
        .allocator = allocator,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("AssignStatement{{ ident: {}, type: {}, value: ", .{ self.ident, self.type });

    try self.value.fmt(fbuf);

    try fbuf.writeAll(" }}");
}
