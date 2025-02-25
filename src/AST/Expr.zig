const std = @import("std");
const mem = std.mem;

const LiteralExpr = @import("LiteralExpr.zig");
const BinaryExpr = @import("BinaryExpr.zig");
const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Position = @import("../Parser/Position.zig");

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
        lit_data.* = ExprData{ .Literal = LiteralExpr.init(val) };
        return Expr{ .data = lit_data, .allocator = allocator };
    }

    pub fn init_binary(lhs: Expr, rhs: Expr, op: BinaryExpr.OperatorType, allocator: mem.Allocator) !Expr {
        const bin_data = try allocator.create(ExprData);
        bin_data.* = ExprData{ .Binary = BinaryExpr.init(lhs, rhs, op) };
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

    pub fn start(self: *const Expr) usize {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.start(),
            ExprKind.Binary => self.data.Binary.start(),
        };
    }

    pub fn stop(self: *const Expr) usize {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.stop(),
            ExprKind.Binary => self.data.Binary.stop(),
        };
    }

    pub fn pos(self: *const Expr) Position {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.pos(),
            ExprKind.Binary => self.data.Binary.pos(),
        };
    }
};
