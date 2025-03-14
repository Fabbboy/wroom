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
const Block = @import("../AST/Block.zig");

const Function = @import("../IR/Function.zig");
const FuncBlock = Function.FuncBlock;

const LiteralExpr = @import("../AST/LiteralExpr.zig");

const AssignStatement = @import("../AST/AssignStatement.zig");

const Builder = @import("../IR/Builder.zig");

const Stmt = @import("../AST/Stmt.zig").Stmt;

const binEvalNs = @import("../IR/Eval/Binary.zig");
const evalBinary = binEvalNs.evalBinary;

const CastConstant = @import("../IR/Eval/Casting.zig").CastConstant;

const Self = @This();

ast: *const Ast,
module: Module,
allocator: mem.Allocator,
cerrs: std.ArrayList(CompilerError),
builder: Builder,

pub fn init(allocator: mem.Allocator, ast: *const Ast, name: []const u8) Self {
    var mod = Module.init(name, allocator);

    return Self{
        .module = mod,
        .allocator = allocator,
        .ast = ast,
        .cerrs = std.ArrayList(CompilerError).init(allocator),
        .builder = Builder.init(&mod),
    };
}

fn resolveValType(self: *const Self, valt: ValueType) Type {
    _ = self;
    switch (valt) {
        ValueType.I32 => return Type.init_int(IntType.I32),
        ValueType.F32 => return Type.init_float(FloatType.F32),
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
                    return IRValue.init_constant(CastConstant(val.Constant, ty));
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
        IRValue.Constant => CastConstant(irval.Constant, ty),
        else => unreachable,
    };

    const linkage = glbl.linkage;
    const global = GlobalVariable.init(
        name,
        ty,
        final_val,
        glbl.constant,
        linkage,
    );

    try self.module.addGlobal(global);
}

fn compileStatement(self: *Self, stmt:Stmt) CompileStatus!void {
    _ = self;
    _ = stmt;
}

pub fn compile(self: *Self) CompileStatus!void {
    const ast = self.ast;
    const glbls = ast.getGlobals();
    for (glbls.*) |glbl| {
        try self.compileGlobal(glbl);
    }

    const funcs = ast.getFunctions();
    for (funcs.*) |func| {
        const name = func.getName().lexeme;
        const ret_ty = self.resolveValType(func.getReturnType());
        const linkage = func.linkage;

        var f = Function.init(name, ret_ty, linkage, self.allocator);
        try self.module.addFunction(f);

        const body = func.getBody();
        if (body) |block| {
            const bb = try f.addBlock("entry");
            self.builder.setInsert(bb);
            const b = block.getBody();
            for (b.*) |stmt| {
                try self.compileStatement(stmt);
            }
        }
    }

    return;
}

pub fn deinit(self: *const Self) void {
    self.module.deinit();
    self.cerrs.deinit();
}

pub fn getMod(self: *const Self) *const Module {
    return &self.module;
}

pub fn getCerrs(self: *const Self) *const []CompilerError {
    return &self.cerrs.items;
}
