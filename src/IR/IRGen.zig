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

const Variable = @import("Object/Variable.zig");
const IRValue = @import("Value.zig").IRValue;
const IRStatus = @import("Error.zig").IRStatus;
const Constant = @import("IRValue/Constant.zig").IRConstant;

const AssignStatement = @import("../AST/AssignStatement.zig");
const FunctionDecl = @import("../AST/FunctionDecl.zig");
const Block = @import("../AST/Block.zig");
const Stmt = @import("../AST/Stmt.zig").Stmt;

const Function = @import("Object/Function.zig");
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
id: usize,

pub fn init(ast: *const Ast, module: *Module, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .module = module,
        .allocator = allocator,
        .id = 0,
    };
}

pub fn getNextId(self: *Self) usize {
    const id = self.id;
    self.id += 1;
    return id;
}

fn compileConstantBinary(self: *const Self, binary: *const BinaryExpr, ty: ValueType) IRStatus!IRValue {
    const lhs = try self.compileConstantExpr(binary.getLHS(), ty);
    const rhs = try self.compileConstantExpr(binary.getRHS(), ty);
    const op = binary.op;

    const clhs = lhs.data.Constant;
    const crhs = rhs.data.Constant;

    switch (op) {
        OperatorType.Plus => return IRValue.init_constant(self.allocator, ConstExprAdd(clhs, crhs)),
        OperatorType.Minus => return IRValue.init_constant(self.allocator, ConstExprSub(clhs, crhs)),
        OperatorType.Star => return IRValue.init_constant(self.allocator, ConstExprMul(clhs, crhs)),
        OperatorType.Slash => return IRValue.init_constant(self.allocator, ConstExprDiv(clhs, crhs)),
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
                    return IRValue.init_constant(self.allocator, Constant{ .Floating = value });
                },
                ValueType.Int => {
                    const value = try fmt.parseInt(i64, literal.val.lexeme, 10);
                    return IRValue.init_constant(self.allocator, Constant{ .Integer = value });
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

fn generateGlobal(self: *Self, assign: *const AssignStatement) IRStatus!void {
    const name = assign.getName().lexeme;
    const ty = assign.getType();

    var initializer = try self.compileConstantExpr(assign.getValue(), ty);
    switch (initializer.data.Constant) {
        Constant.Floating => |value| {
            if (ty == ValueType.Int) {
                initializer = try IRValue.init_constant(self.allocator, Constant.Int(@as(i64, @intFromFloat(value))));
            }
        },
        else => {},
    }

    const variable = Variable.init(initializer, ty, true, self.getNextId());
    try self.module.globals.insert(name, variable);
}

fn generateStatement(self: *const Self, func: *Function, stmt: *const Stmt) IRStatus!void {
    _ = self;
    _ = func;
    _ = stmt;

    return;
}

fn generateBody(self: *const Self, func: *Function, body: *const Block) IRStatus!void {
    const b = body.getBody();
    for (b.*) |stmt| {
        try self.generateStatement(func, &stmt);
    }
    return;
}

fn generateFunction(self: *Self, func: *const FunctionDecl) IRStatus!void {
    const name = func.getName().lexeme;
    const ret_ty = func.getReturnType();

    const params = func.getParams();
    var func_params = std.ArrayList(FuncParam).init(self.allocator);
    for (params.*) |param| {
        const param_name = param.getName().lexeme;
        const ty = param.getType();
        try func_params.append(FuncParam.init(param_name, ty));
    }

    var function = Function.init(self.allocator, func_params, ret_ty);
    if (func.body) |b| {
        self.generateBody(&function, &b) catch {
            function.deinit();
            return error.NotGood;
        };
    }

    self.module.functions.insert(name, function) catch {
        function.deinit();
        return error.NotGood;
    };
}

pub fn generate(self: *Self) IRStatus!void {
    const globals = self.ast.getGlobals();
    for (globals.*) |glbl| {
        try self.generateGlobal(&glbl);
    }

    const functions = self.ast.getFunctions();
    for (functions.*) |func| {
        try self.generateFunction(&func);
    }
}
