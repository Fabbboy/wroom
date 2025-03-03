const std = @import("std");
const mem = std.mem;

const LiteralExpr = @import("LiteralExpr.zig");
const BinaryExpr = @import("BinaryExpr.zig");
const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const OperatorType = Token.OperatorType;

const ParseStatus = @import("../Parser/Error.zig").ParseStatus;

const VariableExpr = @import("VariableExpr.zig");

const ParameterExpr = @import("ParameterExpr.zig");

const FunctionCall = @import("FunctionCall.zig");

const Position = @import("../Parser/Position.zig");

pub const ExprKind = enum {
    Literal,
    Binary,
    Variable,
    Parameter,
    FunctionCall,
};

pub const ExprData = union(ExprKind) {
    Literal: LiteralExpr,
    Binary: BinaryExpr,
    Variable: VariableExpr,
    Parameter: ParameterExpr,
    FunctionCall: FunctionCall,

    pub fn deinit(self: *ExprData, allocator: mem.Allocator) void {
        switch (self.*) {
            ExprKind.Binary => self.Binary.deinit(),
            ExprKind.Literal => {},
            ExprKind.Variable => {},
            ExprKind.Parameter => {},
            ExprKind.FunctionCall => {},
        }
        allocator.destroy(self);
    }
};

pub const Expr = struct {
    data: *ExprData,
    allocator: mem.Allocator,

    pub fn init_literal(val: Token, allocator: mem.Allocator) ParseStatus!Expr {
        const lit_data = try allocator.create(ExprData);
        lit_data.* = ExprData{ .Literal = LiteralExpr.init(val) };
        return Expr{ .data = lit_data, .allocator = allocator };
    }

    pub fn init_binary(lhs: Expr, rhs: Expr, op: OperatorType, allocator: mem.Allocator) ParseStatus!Expr {
        const bin_data = try allocator.create(ExprData);
        bin_data.* = ExprData{ .Binary = BinaryExpr.init(lhs, rhs, op) };
        return Expr{ .data = bin_data, .allocator = allocator };
    }

    pub fn init_variable(name: Token, allocator: mem.Allocator) ParseStatus!Expr {
        const var_data = try allocator.create(ExprData);
        var_data.* = ExprData{ .Variable = VariableExpr.init(name) };
        return Expr{ .data = var_data, .allocator = allocator };
    }

    pub fn init_parameter(name: Token, allocator: mem.Allocator) ParseStatus!Expr {
        const param_data = try allocator.create(ExprData);
        param_data.* = ExprData{ .Parameter = ParameterExpr.init(name) };
        return Expr{ .data = param_data, .allocator = allocator };
    }

    pub fn init_function_call(name: Token, arguments: std.ArrayList(Expr), position: Position, allocator: mem.Allocator) ParseStatus!Expr {
        const func_data = try allocator.create(ExprData);
        func_data.* = ExprData{ .FunctionCall = FunctionCall.init(name, arguments, position) };
        return Expr{ .data = func_data, .allocator = allocator };
    }

    pub fn fmt(self: *const Expr, fbuf: anytype) ParseStatus!void {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.fmt(fbuf),
            ExprKind.Binary => self.data.Binary.fmt(fbuf),
            ExprKind.Variable => self.data.Variable.fmt(fbuf),
            ExprKind.Parameter => self.data.Parameter.fmt(fbuf),
            ExprKind.FunctionCall => self.data.FunctionCall.fmt(fbuf),
        };
    }

    pub fn deinit(self: *const Expr) void {
        self.data.deinit(self.allocator);
    }

    pub fn start(self: *const Expr) usize {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.start(),
            ExprKind.Binary => self.data.Binary.start(),
            ExprKind.Variable => self.data.Variable.start(),
            ExprKind.Parameter => self.data.Parameter.start(),
            ExprKind.FunctionCall => self.data.FunctionCall.start(),
        };
    }

    pub fn stop(self: *const Expr) usize {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.stop(),
            ExprKind.Binary => self.data.Binary.stop(),
            ExprKind.Variable => self.data.Variable.stop(),
            ExprKind.Parameter => self.data.Parameter.stop(),
            ExprKind.FunctionCall => self.data.FunctionCall.stop(),
        };
    }

    pub fn pos(self: *const Expr) Position {
        return switch (self.data.*) {
            ExprKind.Literal => self.data.Literal.pos(),
            ExprKind.Binary => self.data.Binary.pos(),
            ExprKind.Variable => self.data.Variable.pos(),
            ExprKind.Parameter => self.data.Parameter.pos(),
            ExprKind.FunctionCall => self.data.FunctionCall.pos(),
        };
    }
};
