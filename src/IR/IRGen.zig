const std = @import("std");
const fmt = std.fmt;

const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprKind = ExprNs.ExprKind;

const BinaryExpr = @import("../AST/BinaryExpr.zig");

const Ast = @import("../Parser/Ast.zig");
const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const OperatorType = Token.OperatorType;

const Module = @import("Module.zig");

const Variable = @import("Variable.zig");
const IRValue = @import("Value.zig").IRValue;
const IRStatus = @import("Error.zig").IRStatus;
const Constant = @import("Constant.zig").Constant;

const ConstExprNs = @import("ConstExpr.zig");
const ConstExprAdd = ConstExprNs.ConstExprAdd;
const ConstExprSub = ConstExprNs.ConstExprSub;
const ConstExprMul = ConstExprNs.ConstExprMul;
const ConstExprDiv = ConstExprNs.ConstExprDiv;

const Self = @This();

ast: *const Ast,
module: *Module,

pub fn init(ast: *const Ast, module: *Module) Self {
    return Self{
        .ast = ast,
        .module = module,
    };
}

fn compileConstantBinary(self: *const Self, binary: *const BinaryExpr) IRStatus!IRValue {
    const lhs = try self.compileConstantExpr(binary.getLHS());
    const rhs = try self.compileConstantExpr(binary.getRHS());
    const op = binary.op;

    const clhs = lhs.constant;
    const crhs = rhs.constant;

    switch (op) {
        OperatorType.Plus => return IRValue.init_constant(ConstExprAdd(clhs, crhs)),
        OperatorType.Minus => return IRValue.init_constant(ConstExprSub(clhs, crhs)),
        OperatorType.Star => return IRValue.init_constant(ConstExprMul(clhs, crhs)),
        OperatorType.Slash => return IRValue.init_constant(ConstExprDiv(clhs, crhs)),
        else => @panic("Unsupported operator"),
    }

    @panic("Not implemented");
}

fn compileConstantExpr(self: *const Self, expr: *const Expr) IRStatus!IRValue {
    const data = expr.data.*;
    switch (data) {
        ExprKind.Literal => {
            const literal = data.Literal;
            switch (literal.value_type) {
                ValueType.Float => {
                    const value = try fmt.parseFloat(f64, literal.val.lexeme);
                    return IRValue.init_constant(Constant{ .Floating = value });
                },
                ValueType.Int => {
                    const value = try fmt.parseInt(i64, literal.val.lexeme, 10);
                    return IRValue.init_constant(Constant{ .Integer = value });
                },
                else => @panic("Unsupported literal type"),
            }
        },
        ExprKind.Variable => {
            const name = data.Variable.name.lexeme;
            const variable = self.module.globals.get(name);
            if (variable) |v| {
                return v.initializer;
            }
            @panic("Internal: Variable not found");
        },
        ExprKind.Binary => {
            return try self.compileConstantBinary(&data.Binary);
        },
        else => @panic("Unsupported expression type"),
    }
}

pub fn generate(self: *const Self) IRStatus!void {
    const globals = self.ast.getGlobals();
    for (globals.*) |glbl| {
        const name = glbl.getName().lexeme;
        const ty = glbl.getType();

        const initializer = try self.compileConstantExpr(glbl.getValue());

        const variable = Variable.init(initializer, ty);
        try self.module.globals.insert(name, variable);
    }
}
