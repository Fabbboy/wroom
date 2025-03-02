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

const GlobalVariable = @import("IRValue/GlobalVariable.zig");
const IRValue = @import("Value.zig").IRValue;
const IRStatus = @import("Error.zig").IRStatus;
const Constant = @import("IRValue/Constant.zig").IRConstant;

const AssignStatement = @import("../AST/AssignStatement.zig");
const FunctionDecl = @import("../AST/FunctionDecl.zig");
const Block = @import("../AST/Block.zig");
const Stmt = @import("../AST/Stmt.zig").Stmt;

const Function = @import("IRValue/Function.zig");
const FuncParam = Function.FuncParam;
const FuncBlock = Function.FuncBlock;

const Builder = @import("Builder.zig");

const ConstExprNs = @import("ConstExpr.zig");
const ConstExprAdd = ConstExprNs.ConstExprAdd;
const ConstExprSub = ConstExprNs.ConstExprSub;
const ConstExprMul = ConstExprNs.ConstExprMul;
const ConstExprDiv = ConstExprNs.ConstExprDiv;

const Self = @This();

ast: *const Ast,
module: *Module,
allocator: mem.Allocator,
builder: Builder,

pub fn init(ast: *const Ast, module: *Module, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .module = module,
        .allocator = allocator,
        .builder = Builder.init(allocator, module),
    };
}

fn compileConstantBinary(self: *const Self, binary: *const BinaryExpr, ty: ValueType) IRStatus!Constant {
    const clhs = try self.compileConstantExpr(binary.getLHS(), ty);
    const crhs = try self.compileConstantExpr(binary.getRHS(), ty);
    const op = binary.op;

    switch (op) {
        OperatorType.Plus => return ConstExprAdd(clhs, crhs),
        OperatorType.Minus => return ConstExprSub(clhs, crhs),
        OperatorType.Star => return ConstExprMul(clhs, crhs),
        OperatorType.Slash => return ConstExprDiv(clhs, crhs),
        else => unreachable,
    }
}

fn compileConstantExpr(self: *const Self, expr: *const Expr, ty: ValueType) IRStatus!Constant {
    const data = expr.data.*;
    switch (data) {
        ExprKind.Literal => {
            const literal = data.Literal;
            switch (literal.value_type) {
                ValueType.Float => {
                    const value = try fmt.parseFloat(f64, literal.val.lexeme);
                    return Constant.Float(value);
                },
                ValueType.Int => {
                    const value = try fmt.parseInt(i64, literal.val.lexeme, 10);
                    return Constant.Int(value);
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

fn generateStmt(self: *Self, stmt: *const Stmt) IRStatus!void {
    _ = self;
    switch (stmt.*) {
        Stmt.AssignStatement => {},
        Stmt.ReturnStatement => {},
    }
}

fn generateFunction(self: *Self, func: *const FunctionDecl) IRStatus!void {
    const params = func.getParams();
    var func_params = std.ArrayList(FuncParam).init(self.allocator);
    for (params.*) |param| {
        const param_name = param.getName().lexeme;
        const ty = param.getType();
        try func_params.append(FuncParam.init(param_name, ty));
    }

    const ret_type = func.getReturnType();
    const name = func.getName().lexeme;
    const created_function = try self.builder.createFunction(name, func_params, ret_type);

    if (func.body) |block| {
        const bb = try self.builder.createBlock("entry", created_function);
        self.builder.setActiveBlock(bb);
        const body = block.getBody();
        for (body.*) |stmt| {
            try self.generateStmt(&stmt);
        }
    } else {
        @panic("External functions are not supported yet");
    }
}

pub fn generate(self: *Self) IRStatus!void {
    const globals = self.ast.getGlobals();
    for (globals.*) |glbl| {
        const name = glbl.getName().lexeme;
        const ty = glbl.getType();

        const initializer = try self.compileConstantExpr(glbl.getValue(), ty);
        try self.builder.createGlobal(name, ty, initializer);
    }

    const functions = self.ast.getFunctions();
    for (functions.*) |func| {
        try self.generateFunction(&func);
    }
}
