const std = @import("std");
const mem = std.mem;

const ErrorNs = @import("Error.zig");
const SemaError = ErrorNs.SemaError;
const SemaStatus = ErrorNs.SemaStatus;

const Ast = @import("../Parser/Ast.zig");
const AssignStatement = @import("../AST/AssignStatement.zig");
const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ValueType = ExprNs.ValueType;
const ExprKind = ExprNs.ExprKind;

const Scope = @import("Scope.zig");

const Self = @This();

ast: *Ast,
currentScope: *Scope,
errs: std.ArrayList(SemaError),
allocator: mem.Allocator,

pub fn init(ast: *Ast, allocator: mem.Allocator) !Self {
    return Self{
        .ast = ast,
        .currentScope = try Scope.init(allocator, null),
        .errs = std.ArrayList(SemaError).init(allocator),
        .allocator = allocator,
    };
}

pub fn getErrs(self: *const Self) *const std.ArrayList(SemaError) {
    return &self.errs;
}

fn infer_expr(self: *Self, expr: *const Expr) ValueType {
    return switch (expr.data.*) {
        ExprKind.Literal => expr.data.Literal.value_type,
        ExprKind.Binary => {
            const bin = expr.data.Binary;
            const lhs_type = self.infer_expr(&bin.lhs);
            const rhs_type = self.infer_expr(&bin.rhs);

            if (lhs_type == rhs_type and lhs_type != ValueType.Untyped) {
                return lhs_type;
            }

            if ((lhs_type == ValueType.Int and rhs_type == ValueType.Float) or
                (lhs_type == ValueType.Float and rhs_type == ValueType.Int))
            {
                return ValueType.Float;
            }

            if (lhs_type == ValueType.Untyped) return rhs_type;
            if (rhs_type == ValueType.Untyped) return lhs_type;

            return ValueType.Untyped;
        },
    };
}

fn analyze_variable(self: *Self, variable: *AssignStatement) SemaStatus!void {
    if (self.currentScope.find(variable.ident.lexeme)) |f| {
        _ = f;
        try self.errs.append(SemaError.init_symbol_already_declared(variable.ident.lexeme));
        return error.NotGood;
    }

    try self.currentScope.push(variable.ident.lexeme, variable);

    const val_type = self.infer_expr(&variable.value);
    if (variable.type == ValueType.Untyped) {
        variable.setType(val_type);
    }

    if (variable.type != val_type) {
        try self.errs.append(SemaError.init_type_mismatch(variable.type, val_type));
        return error.NotGood;
    }
}

pub fn analyze(self: *Self) SemaStatus!void {
    for (self.ast.globals.items) |*glbl| {
        self.analyze_variable(glbl) catch {
            continue;
        };
    }
    if (self.errs.items.len > 0) {
        return error.NotGood;
    }

    return;
}

pub fn deinit(self: *Self) void {
    self.currentScope.deinit();
    self.errs.deinit();
}
