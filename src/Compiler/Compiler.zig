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

const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprData = ExprNs.ExprData;

const LiteralExpr = @import("../AST/LiteralExpr.zig");

const Self = @This();

ast: *const Ast,
module: Module,
allocator: mem.Allocator,
cerrs: std.ArrayList(CompilerError),

pub fn init(allocator: mem.Allocator, ast: *const Ast, name: []const u8) Self {
    return Self{
        .module = Module.init(name, allocator),
        .allocator = allocator,
        .ast = ast,
        .cerrs = std.ArrayList(CompilerError).init(allocator),
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

fn compileExpr(self: *const Self, expr: *const Expr) CompileStatus!IRValue {
    const data = expr.data;
    switch (data.*) {
        ExprData.Literal => {
            const lit = data.Literal;
            return self.compileLiteral(&lit);
        },
        else => unreachable,
    }
}

pub fn compile(self: *Self) CompileStatus!void {
    const ast = self.ast;
    const glbls = ast.getGlobals();
    for (glbls.*) |glbl| {
        const name = glbl.getName().lexeme;
        const ty = self.resolveValType(glbl.getType());
        const val = glbl.getValue();
        const irval = try self.compileExpr(val);
        const linkage = glbl.linkage;
        const global = GlobalVariable.init(
            name,
            ty,
            irval.Constant,
            glbl.constant,
            linkage,
        );
        try self.module.addGlobal(global);
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
