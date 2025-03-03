const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const OperatorType = Token.OperatorType;

const ExprNs = @import("Expr.zig");
const Expr = ExprNs.Expr;
const ExprData = ExprNs.ExprData;

const Position = @import("../Parser/Position.zig");

const Self = @This();

ident: Token,
type: ValueType,
value: Expr,
assign_type: OperatorType,
new_var: bool,

pub fn init(ident: Token, ty: ValueType, value: Expr, assign_type: OperatorType, new_var: bool) Self {
    return Self{
        .ident = ident,
        .type = ty,
        .value = value,
        .assign_type = assign_type,
        .new_var = new_var,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("AssignStatement{ ident: ");
    try self.ident.fmt(fbuf);
    try fbuf.print(", type: {s}, assign: {s},  value: ", .{ self.type.fmt(), self.assign_type.fmt() });
    try self.value.fmt(fbuf);
    try fbuf.writeAll(" }");
}

pub fn setType(self: *Self, ty: ValueType) void {
    self.type = ty;
}

pub fn getType(self: *const Self) ValueType {
    return self.type;
}

pub fn getName(self: *const Self) *const Token {
    return &self.ident;
}

pub fn getValue(self: *const Self) *const Expr {
    return &self.value;
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
