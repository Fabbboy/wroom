const std = @import("std");
const mem = std.mem;

const LiteralExpr = @import("LiteralExpr.zig");
const BinaryExpr = @import("BinaryExpr.zig");
const Token = @import("../Token.zig");

pub const ValueType = enum {
    Untyped,
    Int,
    Float,
};

pub const ExprKind = enum {
    Literal,
    Binary,
};

pub const ExprData = union(ExprKind) {
    Literal: LiteralExpr,
    Binary: BinaryExpr,

    pub fn deinit(self: *ExprData, allocator: mem.Allocator) void {
        switch (self.*) {
            ExprKind.Binary => self.Binary.deinit(),
            ExprKind.Literal => {},
        }
        allocator.destroy(self);
    }
};

pub const Expr = struct {
    data: *ExprData,
    allocator: mem.Allocator,   

    pub fn init_literal(val: Token, allocator: mem.Allocator) !Expr {
        const lit_data = try allocator.create(ExprData);
        lit_data.* = ExprData{ .Literal = LiteralExpr.init(val, allocator) };
        return Expr{ .data = lit_data, .allocator = allocator };
    }

    pub fn init_binary(lhs: Expr, rhs: Expr, op: BinaryExpr.OperatorType, allocator: mem.Allocator) !Expr {
        const bin_data = try allocator.create(ExprData);
        bin_data.* = ExprData{ .Binary = BinaryExpr.init(lhs, rhs, op, allocator) };
        return Expr{ .data = bin_data, .allocator = allocator };
    }

    pub fn fmt(self: *const Expr, fbuf: anytype) !void {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.fmt(fbuf),
            ExprKind.Binary => self.data.Binary.fmt(fbuf),
        };
    }

    pub fn deinit(self: *const Expr) void {
        self.data.deinit(self.allocator);
    }
};
