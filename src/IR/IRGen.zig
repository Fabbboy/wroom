const std = @import("std");
const fmt = std.fmt;

const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprKind = ExprNs.ExprKind;

const Ast = @import("../Parser/Ast.zig");
const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Module = @import("Module.zig");

const Variable = @import("Variable.zig");
const IRValue = @import("Value.zig").IRValue;
const IRStatus = @import("Error.zig").IRStatus;
const Constant = @import("Constant.zig").Constant;

const Self = @This();

ast: *const Ast,
module: *Module,

pub fn init(ast: *const Ast, module: *Module) Self {
    return Self{
        .ast = ast,
        .module = module,
    };
}

fn compileConstantExpr(self: *const Self, expr: *const Expr) IRStatus!IRValue {
    const data = expr.data.*;
    switch (data) {
        ExprKind.Literal => {
            const literal = data.Literal;
            switch (literal.value_type) {
                ValueType.Float => {
                    const value = try fmt.parseFloat(f64, literal.val.lexeme);
                    return IRValue.init_constant(Constant{ .Float = value });
                },
                ValueType.Int => {
                    const value = try fmt.parseInt(i64, literal.val.lexeme, 10);
                    return IRValue.init_constant(Constant{ .Int = value });
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
