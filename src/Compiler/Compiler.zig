const std = @import("std");
const mem = std.mem;

const Module = @import("../IR/Module.zig");

const Self = @This();

module: *const Module,
allocator: mem.Allocator,

pub fn init(module: *const Module, allocator: mem.Allocator) Self {
    return Self{
        .module = module,
        .allocator = allocator,
    };
}