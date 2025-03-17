const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const ErrorNs = @import("Error.zig");
const SemaError = ErrorNs.SemaError;
const SemaStatus = ErrorNs.SemaStatus;

const TypeMismatch = ErrorNs.TypeMismatch;
const SymbolAlreadyDeclared = ErrorNs.SymbolAlreadyDeclared;
const SymbolUndefined = ErrorNs.SymbolUndefined;
const IllegalAssignment = ErrorNs.IllegalAssignment;
const CannotAssignToVoid = ErrorNs.CannotAssignToVoid;
const ArgumentCountMismatch = ErrorNs.ArgumentCountMismatch;
const UnusedReturnValue = ErrorNs.UnusedReturnValue;
const MainNeedsPublicInt = ErrorNs.MainNeedsPublicInt;
const ExternCannotHaveBody = ErrorNs.ExternCannotHaveBody;
const CallNotAllowed = ErrorNs.CallNotAllowed;
const CannotCast = ErrorNs.CannotCast;

const Ast = @import("../Parser/Ast.zig");
const AssignStatement = @import("../AST/AssignStatement.zig");
const ExprNs = @import("../AST/Expr.zig");
const Expr = ExprNs.Expr;
const ExprData = ExprNs.ExprData;

const FunctionCall = @import("../AST/FunctionCall.zig");

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

fn pushError(self: *Self, err: SemaError) SemaStatus!void {
    try self.errs.append(err);
    return error.NotGood;
}

fn pushScope(self: *Self) !void {
    self.currentScope = try Scope.init(self.allocator, self.currentScope);
}

fn popScope(self: *Self) void {
    if (self.currentScope.parent) |parent| {
        const temp = self.currentScope;
        self.currentScope = parent;
        temp.deinit();
    }
}

pub fn getErrs(self: *const Self) *const []SemaError {
    return &self.errs.items;
}

fn analyze_func_call(self: *Self, func: *const FunctionCall) SemaStatus!ValueType {
    if (self.currentScope.findFunc(func.name.lexeme)) |f| {
        if (f.params.items.len != func.arguments.items.len) {
            try self.pushError(SemaError.init_argument_count_mismatch(ArgumentCountMismatch.init(f.params.items.len, func.arguments.items.len, func.pos())));
            return error.NotGood;
        }

        for (f.params.items, 0..) |*param, i| {
            const arg = func.arguments.items[i];
            const arg_type = try self.infer_expr(&arg, false);
            if (param.type != arg_type) {
                try self.pushError(SemaError.init_type_mismatch(TypeMismatch.init(param.type, arg_type, arg.pos())));
                return error.NotGood;
            }
        }

        return f.ret_type;
    }

    try self.pushError(SemaError.init_symbol_undefined(SymbolUndefined.init(func.name.lexeme, func.pos())));
    return error.NotGood;
}

fn infer_expr(self: *Self, expr: *const Expr, glbl: bool) SemaStatus!ValueType {
    return switch (expr.data.*) {
        ExprData.Literal => expr.data.Literal.value_type,
        ExprData.Binary => {
            const bin = expr.data.Binary;
            const lhs_type = try self.infer_expr(&bin.lhs, glbl);
            const rhs_type = try self.infer_expr(&bin.rhs, glbl);

            if (lhs_type == ValueType.Void or rhs_type == ValueType.Void) {
                try self.pushError(SemaError.init_cannot_assign_to_void(CannotAssignToVoid.init(expr.pos())));
                return error.NotGood;
            }

            if (lhs_type == rhs_type and lhs_type != ValueType.Untyped) {
                return lhs_type;
            }

            try self.pushError(SemaError.init_type_mismatch(TypeMismatch.init(lhs_type, rhs_type, expr.pos())));
            return error.NotGood;
        },
        ExprData.Variable => {
            const fvar = expr.data.Variable;
            if (self.currentScope.find(fvar.name.lexeme)) |f| {
                return f;
            }
            try self.pushError(SemaError.init_symbol_undefined(SymbolUndefined.init(fvar.name.lexeme, fvar.pos())));
            return error.NotGood;
        },
        ExprData.FunctionCall => {
            if (glbl) {
                try self.pushError(SemaError.init_call_not_allowed(CallNotAllowed.init(expr.pos())));
                return error.NotGood;
            }

            return self.analyze_func_call(&expr.data.FunctionCall);
        },
        ExprData.Cast => {
            const lexpr = expr.data.Cast;
            const to_cast = lexpr.val;
            const expr_type = try self.infer_expr(&to_cast, glbl);

            if (expr_type == ValueType.Void) {
                try self.pushError(SemaError.init_cannot_cast(CannotCast.init(expr.pos(), expr_type, lexpr.cast_to)));
                return error.NotGood;
            }

            if (lexpr.cast_to == ValueType.Untyped) {
                return expr_type;
            }
            return expr.data.Cast.cast_to;
        },
        else => unreachable,
    };
}

fn analyze_variable(self: *Self, variable: *AssignStatement, glbl: bool) SemaStatus!void {
    if (!variable.new_var) {
        const found: ?ValueType = self.currentScope.find(variable.ident.lexeme);
        if (found == null) {
            try self.pushError(SemaError.init_symbol_undefined(SymbolUndefined.init(variable.ident.lexeme, variable.pos())));
            return error.NotGood;
        }

        const val_type = try self.infer_expr(&variable.value, glbl);
        if (found != val_type) {
            try self.pushError(SemaError.init_type_mismatch(TypeMismatch.init(found.?, val_type, variable.pos())));
            return error.NotGood;
        }
        variable.setType(found.?);

        return;
    }

    if (self.currentScope.find(variable.ident.lexeme)) |_| {
        try self.pushError(SemaError.init_symbol_already_declared(SymbolAlreadyDeclared.init(variable.ident.lexeme, variable.pos())));
        return error.NotGood;
    }

    const assign = variable.assign_type;
    if (assign != Token.OperatorType.Assign) {
        try self.pushError(SemaError.init_illegal_assignment(IllegalAssignment.init(variable.pos())));
        return error.NotGood;
    }

    const val_type = self.infer_expr(&variable.value, glbl) catch |e| {
        try self.currentScope.push(variable.ident.lexeme, variable.getType());
        return e;
    };
    if (val_type == ValueType.Void) {
        try self.pushError(SemaError.init_cannot_assign_to_void(CannotAssignToVoid.init(variable.pos())));
        return error.NotGood;
    }

    if (variable.type == ValueType.Void) {
        try self.pushError(SemaError.init_cannot_assign_to_void(CannotAssignToVoid.init(variable.pos())));
        return error.NotGood;
    }
    
    if (variable.type == ValueType.Untyped) {
        variable.setType(val_type);
    }

    try self.currentScope.push(variable.ident.lexeme, variable.getType());

    if (variable.type != val_type) {
        try self.pushError(SemaError.init_type_mismatch(TypeMismatch.init(variable.getType(), val_type, variable.pos())));
        return error.NotGood;
    }
}

fn analyze_function(self: *Self, func: *const FunctionDecl) SemaStatus!void {
    if (self.currentScope.findFunc(func.name.lexeme)) |_| {
        try self.pushError(SemaError.init_symbol_already_declared(SymbolAlreadyDeclared.init(func.name.lexeme, func.pos())));
        return error.NotGood;
    }

    try self.currentScope.pushFunc(func);
    if (mem.eql(u8, func.name.lexeme, "main")) {
        if (func.linkage != .Public or func.ret_type != ValueType.I32) {
            try self.pushError(SemaError.init_main_needs_public_int(MainNeedsPublicInt.init(func.pos())));
            return error.NotGood;
        }
    }

    try self.pushScope();
    defer self.popScope();

    for (func.params.items) |*param| {
        if (self.currentScope.find(param.ident.lexeme)) |_| {
            try self.pushError(SemaError.init_symbol_already_declared(SymbolAlreadyDeclared.init(param.ident.lexeme, param.pos())));
            return error.NotGood;
        }

        try self.currentScope.push(param.ident.lexeme, param.getType());
    }

    if (func.body) |body| {
        if (func.linkage == .External) {
            try self.pushError(SemaError.init_extern_cannot_have_body(ExternCannotHaveBody.init(func.pos())));
            return error.NotGood;
        }

        self.analyze_block(&body, false, func.name.lexeme) catch {
            return error.NotGood;
        };
    }
}

fn analyze_block(self: *Self, block: *const Block, needs_scope: bool, name: []const u8) SemaStatus!void {
    var hasErr = false;
    if (needs_scope) {
        try self.pushScope();
    }

    for (block.stmts.items) |*stmt| {
        self.analyze_statement(stmt, name) catch {
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

fn analyze_statement(self: *Self, stmt: *Stmt, name: []const u8) SemaStatus!void {
    return switch (stmt.*) {
        Stmt.AssignStatement => self.analyze_variable(&stmt.AssignStatement, false),
        Stmt.ReturnStatement => {
            const ret = stmt.ReturnStatement;
            const val_type = try self.infer_expr(&ret.value, false);

            const func = self.currentScope.findFunc(name);
            if (func) |f| {
                if (f.ret_type != val_type) {
                    try self.pushError(SemaError.init_type_mismatch(TypeMismatch.init(f.ret_type, val_type, ret.pos())));
                    return error.NotGood;
                }
            }
        },
        Stmt.FunctionCall => {
            const ret = try self.analyze_func_call(&stmt.FunctionCall);
            if (ret != ValueType.Void) {
                try self.pushError(SemaError.init_unused_return_value(UnusedReturnValue.init(stmt.FunctionCall.pos())));
                return error.NotGood;
            }
        },
    };
}

pub fn analyze(self: *Self) SemaStatus!void {
    for (self.ast.globals.items) |*glbl| {
        self.analyze_variable(glbl, true) catch {
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
