const std = @import("std");
const mem = std.mem;

const Module = @import("../IR/Module.zig");
const Ast = @import("../Parser/Ast.zig");

const CErr = @import("Error.zig");
const CompileStatus = CErr.CompileStatus;
const CompilerError = CErr.CompilerError;

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

pub fn compile(self: *const Self) CompileStatus!void {
    _ = self;
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