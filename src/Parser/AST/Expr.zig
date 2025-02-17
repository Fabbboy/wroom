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

pub const Expr = union(enum) {
    Literal: LiteralExpr,
    Binary: BinaryExpr,

    pub fn init_literal(val: Token, allocator: mem.Allocator) !*Expr {
        const lit = try allocator.create(Expr);
        lit.* = @unionInit(Expr, "Literal", LiteralExpr.init(val, allocator)); // Fix
        return lit;
    }

    pub fn init_binary(lhs: Expr, rhs: Expr, op: BinaryExpr.OperatorType, allocator: mem.Allocator) !*Expr {
        const bin = try allocator.create(Expr);
        bin.* = @unionInit(Expr, "Binary", BinaryExpr.init(lhs, rhs, op, allocator)); // Fix
        return bin;
    }

    pub fn fmt(self: *const Expr, fbuf: anytype) !void {
        return switch (self.*) {
            Expr.Literal => self.Literal.fmt(fbuf),
            Expr.Binary => self.Binary.fmt(fbuf),
        };
    }

    pub fn deinit(self: *Expr) void {
        switch (self.*) {
            Expr.Binary => {
                const allocator = self.Binary.getAllocator();
                self.Binary.deinit();
                allocator.destroy(self);
            },
            Expr.Literal => {
                const allocator = self.Literal.getAllocator();
                allocator.destroy(self);
            },
        }
    }
};
