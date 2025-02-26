const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const ErrorNs = @import("Error.zig");
const SemaError = ErrorNs.SemaError;
const SemaStatus = ErrorNs.SemaStatus;

const Ast = @import("../Parser/Ast.zig");
const AssignStatement = @import("../AST/AssignStatement.zig");
const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprKind = ExprNs.ExprKind;

const FunctionDecl = @import("../AST/FunctionDecl.zig");

const Block = @import("../AST/Block.zig");

const Stmt = @import("../AST/Stmt.zig").Stmt;

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

fn pushScope(self: *Self) !void {
    self.currentScope = try Scope.init(self.allocator, self.currentScope);
}

fn popScope(self: *Self) void {
    var iter = self.currentScope.symbols.iterator();
    while (iter.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;
        std.debug.print("Popping scope: {s} {s}\n", .{ key, value.fmt() });
    }

    if (self.currentScope.parent) |parent| {
        const temp = self.currentScope;
        self.currentScope = parent;
        temp.deinit();
    }
}

pub fn getErrs(self: *const Self) *const std.ArrayList(SemaError) {
    return &self.errs;
}

fn infer_expr(self: *Self, expr: *const Expr) SemaStatus!ValueType {
    return switch (expr.data.*) {
        ExprKind.Literal => expr.data.Literal.value_type,
        ExprKind.Binary => {
            const bin = expr.data.Binary;
            const lhs_type = try self.infer_expr(&bin.lhs);
            const rhs_type = try self.infer_expr(&bin.rhs);

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
        ExprKind.Variable => {
            const fvar = expr.data.Variable;
            if (self.currentScope.find(fvar.name.lexeme)) |f| {
                return f;
            }
            try self.errs.append(SemaError.init_symbol_undefined(fvar.name.lexeme, fvar.pos()));
            return error.NotGood;
        },
        else => unreachable,
    };
}

fn analyze_variable(self: *Self, variable: *AssignStatement) SemaStatus!void {
    if (!variable.new_var) {
        const found: ?ValueType = self.currentScope.find(variable.ident.lexeme);
        if (found == null) {
            try self.errs.append(SemaError.init_symbol_undefined(variable.ident.lexeme, variable.pos()));
            return error.NotGood;
        }

        const val_type = try self.infer_expr(&variable.value);
        if (found != val_type) {
            try self.errs.append(SemaError.init_type_mismatch(found.?, val_type, variable.pos()));
            return error.NotGood;
        }
        variable.setType(found.?);

        return;
    }

    if (self.currentScope.find(variable.ident.lexeme)) |f| {
        _ = f;
        try self.errs.append(SemaError.init_symbol_already_declared(variable.ident.lexeme, variable.pos()));
        return error.NotGood;
    }

    const val_type = try self.infer_expr(&variable.value);
    if (variable.type == ValueType.Untyped) {
        variable.setType(val_type);
    }

    try self.currentScope.push(variable.ident.lexeme, variable.getType());

    if (variable.type != val_type) {
        try self.errs.append(SemaError.init_type_mismatch(variable.getType(), val_type, variable.pos()));
        return error.NotGood;
    }
}

fn analyze_function(self: *Self, func: *const FunctionDecl) SemaStatus!void {
    if (self.currentScope.findFunc(func.name.lexeme)) |f| {
        _ = f;
        try self.errs.append(SemaError.init_symbol_already_declared(func.name.lexeme, func.pos()));
        return error.NotGood;
    }

    try self.currentScope.pushFunc(func);
    try self.pushScope();
    defer self.popScope();

    for (func.params.items) |*param| {
        if (self.currentScope.find(param.ident.lexeme)) |f| {
            _ = f;
            try self.errs.append(SemaError.init_symbol_already_declared(param.ident.lexeme, param.pos()));
            return error.NotGood;
        }

        try self.currentScope.push(param.ident.lexeme, param.getType());
    }

    if (func.body) |body| {
        self.analyze_block(&body, false) catch {
            return error.NotGood;
        };
    }
}

fn analyze_block(self: *Self, block: *const Block, needs_scope: bool) SemaStatus!void {
    var hasErr = false;
    if (needs_scope) {
        try self.pushScope();
    }

    for (block.stmts.items) |*stmt| {
        self.analyze_statement(stmt) catch {
            hasErr = true;
            continue;
        };
    }

    if (needs_scope) {
        self.popScope();
    }

    if (hasErr) {
        return error.NotGood;
    }
}

fn analyze_statement(self: *Self, stmt: *Stmt) SemaStatus!void {
    return switch (stmt.*) {
        Stmt.AssignStatement => self.analyze_variable(&stmt.AssignStatement),
    };
}

pub fn analyze(self: *Self) SemaStatus!void {
    for (self.ast.globals.items) |*glbl| {
        self.analyze_variable(glbl) catch {
            continue;
        };
    }

    for (self.ast.functions.items) |*func| {
        self.analyze_function(func) catch {
            continue;
        };
    }

    if (self.errs.items.len > 0) {
        return error.NotGood;
    }

    return;
}

pub fn deinit(self: *Self) void {
    while (self.currentScope.parent) |parent| {
        const temp = self.currentScope;
        self.currentScope = parent;
        temp.deinit();
        std.debug.print("Found un-popped scope\n", .{});
    }
    self.currentScope.deinit();
    self.errs.deinit();
}
