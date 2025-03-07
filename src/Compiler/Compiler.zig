const std = @import("std");
const mem = std.mem;

const Module = @import("../IR/Module.zig");
const Ast = @import("../Parser/Ast.zig");

const Self = @This();

ast: *const Ast,
module: Module,
allocator: mem.Allocator,

pub fn init(allocator: mem.Allocator, ast: *const Ast, name: []const u8) Self {
    return Self{
        .module = Module.init(name, allocator),
        .allocator = allocator,
        .ast = ast,
    };
}

pub fn deinit(self: *const Self) void {
    self.module.deinit();
}

pub fn getMod(self: *const Self) *const Module {
    return &self.module;
}
