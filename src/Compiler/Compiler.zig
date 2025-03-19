const std = @import("std");
const mem = std.mem;
const fmt = std.fmt;

const Module = @import("../IR/Module.zig");
const Ast = @import("../Parser/Ast.zig");

const CErr = @import("Error.zig");
const CompileStatus = CErr.CompileStatus;
const CompilerError = CErr.CompilerError;

const GlobalVariable = @import("../IR/Values/GlobalVariable.zig");
const IRValue = @import("../IR/IRValue.zig").IRValue;

const ConstantNs = @import("../IR/Values/Constant.zig");
const Constant = ConstantNs.Constant;
const IntValue = ConstantNs.IntValue;

const Linkage = @import("../IR/Linkage.zig").Linkage;

const TypeNs = @import("../IR/Type.zig");
const Type = TypeNs.Type;
const IntType = TypeNs.IntegerTy;
const FloatType = TypeNs.FloatTy;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const OperatorType = Token.OperatorType;

const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprData = ExprNs.ExprData;

const ParseFunction = @import("../AST/FunctionDecl.zig");
const ParseBlock = @import("../AST/Block.zig");

const Function = @import("../IR/Function.zig");
const FuncBlock = Function.FuncBlock;

const LiteralExpr = @import("../AST/LiteralExpr.zig");

const AssignStatement = @import("../AST/AssignStatement.zig");

const Builder = @import("../IR/Builder.zig");

const Stmt = @import("../AST/Stmt.zig").Stmt;

const binEvalNs = @import("../IR/Eval/Binary.zig");
const evalBinary = binEvalNs.evalBinary;

const CastConstant = @import("../IR/Eval/Casting.zig").CastConstant;

const VReg = @import("../IR/Instructions/VReg.zig").VReg;

const NamendPair = struct { val: IRValue, ty: Type };

const Self = @This();

ast: *const Ast,
module: Module,
allocator: mem.Allocator,
cerrs: std.ArrayList(CompilerError),
builder: Builder,
namend_values: std.StringHashMap(NamendPair),

pub fn init(allocator: mem.Allocator, ast: *const Ast, name: []const u8) Self {
    var mod = Module.init(name, allocator);

    return Self{
        .module = mod,
        .allocator = allocator,
        .ast = ast,
        .cerrs = std.ArrayList(CompilerError).init(allocator),
        .builder = Builder.init(&mod, allocator),
        .namend_values = std.StringHashMap(NamendPair).init(allocator),
    };
}

fn resolveValType(self: *const Self, valt: ValueType) Type {
    _ = self;
    switch (valt) {
        ValueType.I32 => return Type.init_int(IntType.I32),
        ValueType.F32 => return Type.init_float(FloatType.F32),
        ValueType.Void => return Type.init_void(),
        else => unreachable,
    }
}

fn compileLiteral(self: *const Self, lit: *const LiteralExpr) CompileStatus!IRValue {
    const val = lit.val;
    const ty = self.resolveValType(lit.value_type);
    const value = Constant.init_from(val.lexeme, ty) catch {
        return error.FailedToParseNumeric;
    };

    return IRValue.init_constant(value);
}

fn compileConstantExpr(self: *const Self, expr: *const Expr) CompileStatus!IRValue {
    const data = expr.data;
    switch (data.*) {
        ExprData.Literal => {
            const lit = data.Literal;
            return self.compileLiteral(&lit);
        },
        ExprData.Binary => {
            const binary = data.Binary;
            const lhs = try self.compileConstantExpr(binary.getLHS());
            const rhs = try self.compileConstantExpr(binary.getRHS());
            const op = binary.op;
            const res = evalBinary(lhs.Constant, rhs.Constant, op);
            if (res) |r| {
                return IRValue.init_constant(r);
            } else {
                return error.FailedToEvalBinary;
            }
        },
        ExprData.Variable => {
            const variable = data.Variable;
            if (self.module.findGlobal(variable.name.lexeme)) |glbl| {
                return IRValue.init_constant(glbl.value);
            }
            unreachable;
        },
        ExprData.Cast => {
            const cast = data.Cast;
            const val = try self.compileConstantExpr(&cast.val);
            switch (val) {
                IRValue.Constant => {
                    const ty = self.resolveValType(cast.cast_to);
                    return IRValue.init_constant(try CastConstant(val.Constant, ty));
                },
                else => unreachable,
            }
        },
        else => unreachable,
    }
}

fn compileGlobal(self: *Self, glbl: AssignStatement) CompileStatus!void {
    const name = glbl.getName().lexeme;
    const ty = self.resolveValType(glbl.getType());
    const val = glbl.getValue();
    const irval = try self.compileConstantExpr(val);
    const final_val = switch (irval) {
        IRValue.Constant => try CastConstant(irval.Constant, ty),
        else => unreachable,
    };

    const linkage = glbl.linkage;
    _ = try GlobalVariable.init(
        &self.module,
        name,
        ty,
        final_val,
        glbl.constant,
        linkage,
    );
}

fn compileExpr(self: *Self, expr: *const Expr) CompileStatus!IRValue {
    const data = expr.data;
    switch (data.*) {
        ExprData.Literal => {
            const lit = data.Literal;
            return self.compileLiteral(&lit);
        },
        ExprData.Binary => {
            const binary = data.Binary;
            const lhs = try self.compileExpr(binary.getLHS());
            const rhs = try self.compileExpr(binary.getRHS());
            const op = binary.op;
            return switch (op) {
                OperatorType.Plus => try self.builder.createAdd(lhs, rhs),
                OperatorType.Minus => try self.builder.createSub(lhs, rhs),
                OperatorType.Star => try self.builder.createMul(lhs, rhs),
                OperatorType.Slash => try self.builder.createDiv(lhs, rhs),
                else => unreachable,
            };
        },
        ExprData.Variable => {
            const variable = data.Variable;
            if (self.namend_values.contains(variable.name.lexeme)) {
                return self.namend_values.get(variable.name.lexeme).?.val;
            }

            if (self.module.findGlobal(variable.name.lexeme)) |glbl| {
                return self.builder.createLoad(VReg.init_global(glbl.name), glbl.ty);
            }
            unreachable;
        },
        else => unreachable,
    }
}

fn compileAssign(self: *Self, assign: *const AssignStatement) CompileStatus!void {
    const existing = self.namend_values.get(assign.getName().lexeme);
    if (existing) |e| {
        switch (assign.assign_type) {
            OperatorType.Assign => {
                const val = try self.compileExpr(assign.getValue());
                try self.builder.createStore(e.val.Instruction, val);
            },
            OperatorType.Plus => {
                const loaded = try self.builder.createLoad(e.val.Instruction.get_reg().?, e.ty);
                const val = try self.compileExpr(assign.getValue());
                const res = try self.builder.createAdd(loaded, val);
                try self.builder.createStore(e.val.Instruction, res);
            },
            OperatorType.Minus => {
                const loaded = try self.builder.createLoad(e.val.Instruction.get_reg().?, e.ty);
                const val = try self.compileExpr(assign.getValue());
                const res = try self.builder.createSub(loaded, val);
                try self.builder.createStore(e.val.Instruction, res);
            },
            OperatorType.Star => {
                const loaded = try self.builder.createLoad(e.val.Instruction.get_reg().?, e.ty);
                const val = try self.compileExpr(assign.getValue());
                const res = try self.builder.createMul(loaded, val);
                try self.builder.createStore(e.val.Instruction, res);
            },
            OperatorType.Slash => {
                const loaded = try self.builder.createLoad(e.val.Instruction.get_reg().?, e.ty);
                const val = try self.compileExpr(assign.getValue());
                const res = try self.builder.createDiv(loaded, val);
                try self.builder.createStore(e.val.Instruction, res);
            },
        }
    } else {
        const ty = self.resolveValType(assign.getType());

        const alloca = try self.builder.createAlloca(ty);
        const val = try self.compileExpr(assign.getValue());
        try self.builder.createStore(alloca.Instruction, val);
        const namend = NamendPair{ .val = alloca, .ty = ty };
        try self.namend_values.put(assign.getName().lexeme, namend);
    }
}

fn compileStmt(self: *Self, stmt: *const Stmt) CompileStatus!void {
    switch (stmt.*) {
        Stmt.AssignStatement => {
            const assign = stmt.AssignStatement;
            try self.compileAssign(&assign);
        },
        else => unreachable,
    }
}

fn compileBody(self: *Self, block: *const ParseBlock, irf: *Function) CompileStatus!void {
    const bb = try irf.createBlock("entry");
    self.builder.setInsert(bb);

    const stmts = block.getBody();
    for (stmts.*) |*stmt| {
        try self.compileStmt(stmt);
    }
}

pub fn compile(self: *Self) CompileStatus!void {
    const ast = self.ast;
    const glbls = ast.getGlobals();
    for (glbls.*) |glbl| {
        try self.compileGlobal(glbl);
    }

    const funcs = ast.getFunctions();
    for (funcs.*) |func| {
        self.namend_values.clearRetainingCapacity();
        const name = func.getName().lexeme;
        const ret_ty = self.resolveValType(func.getReturnType());
        const linkage = func.linkage;

        const f = try Function.init(
            &self.module,
            name,
            ret_ty,
            linkage,
            self.allocator,
        );

        const body = func.getBody();
        if (body) |block| {
            try self.compileBody(block, f);
        }
    }

    return;
}

pub fn deinit(self: *Self) void {
    self.module.deinit();
    self.cerrs.deinit();
    self.namend_values.deinit();
}

pub fn getMod(self: *const Self) *const Module {
    return &self.module;
}

pub fn getCerrs(self: *const Self) *const []CompilerError {
    return &self.cerrs.items;
}
