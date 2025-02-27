const std = @import("std");
const fmt = std.fmt;
const mem = std.mem;

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

const AssignStatement = @import("../AST/AssignStatement.zig");
const FunctionDecl = @import("../AST/FunctionDecl.zig");

const Function = @import("Function.zig");
const FuncParam = Function.FuncParam;
const FuncBlock = Function.FuncBlock;

const ConstExprNs = @import("ConstExpr.zig");
const ConstExprAdd = ConstExprNs.ConstExprAdd;
const ConstExprSub = ConstExprNs.ConstExprSub;
const ConstExprMul = ConstExprNs.ConstExprMul;
const ConstExprDiv = ConstExprNs.ConstExprDiv;

const Self = @This();

ast: *const Ast,
module: *Module,
allocator: mem.Allocator,

pub fn init(ast: *const Ast, module: *Module, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .module = module,
        .allocator = allocator,
    };
}

fn compileConstantBinary(self: *const Self, binary: *const BinaryExpr, ty: ValueType) IRStatus!IRValue {
    const lhs = try self.compileConstantExpr(binary.getLHS(), ty);
    const rhs = try self.compileConstantExpr(binary.getRHS(), ty);
    const op = binary.op;

    const clhs = lhs.Constant;
    const crhs = rhs.Constant;

    switch (op) {
        OperatorType.Plus => return IRValue.init_constant(ConstExprAdd(clhs, crhs)),
        OperatorType.Minus => return IRValue.init_constant(ConstExprSub(clhs, crhs)),
        OperatorType.Star => return IRValue.init_constant(ConstExprMul(clhs, crhs)),
        OperatorType.Slash => return IRValue.init_constant(ConstExprDiv(clhs, crhs)),
        else => unreachable,
    }
}

fn compileConstantExpr(self: *const Self, expr: *const Expr, ty: ValueType) IRStatus!IRValue {
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
                else => unreachable,
            }
        },
        ExprKind.Variable => {
            const name = data.Variable.name.lexeme;
            const variable = self.module.globals.get(name);
            return variable.?.initializer;
        },
        ExprKind.Binary => {
            return try self.compileConstantBinary(&data.Binary, ty);
        },
        else => unreachable,
    }
}

fn generateGlobal(self: *const Self, assign: *const AssignStatement) IRStatus!void {
    const name = assign.getName().lexeme;
    const ty = assign.getType();

    var initializer = try self.compileConstantExpr(assign.getValue(), ty);
    switch (initializer.Constant) {
        Constant.Floating => |value| {
            if (ty == ValueType.Int) {
                initializer = IRValue.init_constant(Constant.Int(@as(i64, @intFromFloat(value))));
            }
        },
        else => {},
    }

    const variable = Variable.init(initializer, ty);
    try self.module.globals.insert(name, variable);
}

fn generateFunction(self: *const Self, func: *const FunctionDecl) IRStatus!void {
    const name = func.getName().lexeme;
    const ret_ty = func.getReturnType();

    const params = func.getParams();
    var func_params = std.ArrayList(FuncParam).init(self.allocator);
    for (params.*) |param| {
        const param_name = param.getName().lexeme;
        const ty = param.getType();
        try func_params.append(FuncParam.init(param_name, ty));
    }

    const blocks = std.ArrayList(FuncBlock).init(self.allocator);

    const function = Function.init(func_params, blocks, ret_ty);
    try self.module.functions.insert(name, function);
}

pub fn generate(self: *const Self) IRStatus!void {
    const globals = self.ast.getGlobals();
    for (globals.*) |glbl| {
        try self.generateGlobal(&glbl);
    }

    const functions = self.ast.getFunctions();
    for (functions.*) |func| {
        try self.generateFunction(&func);
    }
}
