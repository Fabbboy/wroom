const std = @import("std");
const mem = std.mem;

const ErrorNs = @import("Error.zig");
const SemaError = ErrorNs.SemaError;
const SemaStatus = ErrorNs.SemaStatus;

const Ast = @import("../Parser/Ast.zig");
const AssignStatement = @import("../Parser/AST/AssignStatement.zig");

const Scope = @import("Scope.zig");

const Self = @This();

ast: *Ast,
currentScope: Scope,
errs: std.ArrayList(SemaError),
allocator: mem.Allocator,

pub fn init(ast: *Ast, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .currentScope = Scope.init(allocator, null),
        .errs = std.ArrayList(SemaError).init(allocator),
        .allocator = allocator,
    };
}

pub fn getErrs(self: *const Self) *const std.ArrayList(SemaError) {
    return &self.errs;
}

fn analyze_variable(self: *Self, variable: *AssignStatement) SemaStatus!void {
    _ = self;
    _ = variable;
}

pub fn analyze(self: *Self) SemaStatus!void {
    for (self.ast.globals.items) |*glbl| {
        self.analyze_variable(glbl) catch {
            continue;
        };
    }
    return SemaStatus.NotGood;
}

pub fn deinit(self: *Self) void {
    self.currentScope.deinit();
    self.errs.deinit();
}
