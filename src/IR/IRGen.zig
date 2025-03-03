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
const IRValueNs = @import("Value.zig");
const IRValue = IRValueNs.IRValue;
const IRValueData = IRValueNs.IRValueData;
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

const SymTable = @import("ADT/SymTable.zig").SymTable;

const LocationNs = @import("IRValue/Location.zig");
const Location = LocationNs.Location;
const LocalLocation = LocationNs.LocalLocation;
const GlobalLocation = LocationNs.GlobalLocation;

const Self = @This();

ast: *const Ast,
module: *Module,
allocator: mem.Allocator,
builder: Builder,
namend: SymTable(IRValue),

pub fn init(ast: *const Ast, module: *Module, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .module = module,
        .allocator = allocator,
        .builder = Builder.init(allocator, module),
        .namend = SymTable(IRValue).init(allocator),
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

fn generateExpression(self: *Self, expr: *const Expr) IRStatus!IRValue {
    const data = expr.data.*;

    switch (data) {
        ExprKind.Literal => {
            const literal = data.Literal;
            var constant: Constant = undefined;
            switch (literal.value_type) {
                ValueType.Float => {
                    const value = try fmt.parseFloat(f64, literal.val.lexeme);
                    constant = Constant.Float(value);
                },
                ValueType.Int => {
                    const value = try fmt.parseInt(i64, literal.val.lexeme, 10);
                    constant = Constant.Int(value);
                },
                else => unreachable,
            }

            const value = try IRValue.init_constant(self.allocator, constant);
            return value;
        },
        ExprKind.Variable => {
            const name = data.Variable.name.lexeme;
            const localLoc = self.namend.get(name);
            if (localLoc) |l| {
                const localLoad = try self.builder.createLoad(l.data.Location, ValueType.Ptr);
                return localLoad;
            }

            const global = self.module.globals.get(name);
            if (global) |g| {
                const globalLoc = Location.LocGlobal(GlobalLocation.init(name, g.val_type));
                const globalLoad = try self.builder.createLoad(globalLoc, g.val_type);
                return globalLoad;
            }
        },
        ExprKind.Binary => {
            const binary = data.Binary;
            const lhs = try self.generateExpression(binary.getLHS());
            const rhs = try self.generateExpression(binary.getRHS());
            const op = binary.op;

            switch (op) {
                OperatorType.Plus => {
                    const add = try self.builder.createAdd(lhs, rhs, lhs.getType());
                    return add;
                },
                OperatorType.Minus => {
                    const sub = try self.builder.createSub(lhs, rhs, lhs.getType());
                    return sub;
                },
                OperatorType.Star => {
                    const mul = try self.builder.createMul(lhs, rhs, lhs.getType());
                    return mul;
                },
                OperatorType.Slash => {
                    const div = try self.builder.createDiv(lhs, rhs, lhs.getType());
                    return div;
                },
                else => unreachable,
            }
        },
        else => unreachable,
    }

    return undefined;
}

fn generateStmt(self: *Self, stmt: *const Stmt) IRStatus!void {
    switch (stmt.*) {
        Stmt.AssignStatement => {
            const assign = stmt.*.AssignStatement;
            const name = assign.getName().lexeme;
            const ty = assign.getType();
            const new_var = assign.new_var;

            const alloca = try self.builder.createAlloca(ty);
            defer alloca.deinit();
            const alloca_loc = alloca.data.Location;
            const loc = try IRValue.init_location(self.allocator, alloca_loc);

            if (new_var) {
                const val = try self.generateExpression(assign.getValue());
                try self.builder.createStore(loc, val, ty);
            }

            try self.namend.insert(name, loc);
        },
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

pub fn deinit(self: *Self) void {
    self.namend.deinit();
}
