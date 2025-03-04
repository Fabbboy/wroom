const std = @import("std");
const mem = std.mem;

const Module = @import("../IR/Module.zig");

const Target = @import("Target.zig").Target;

const Self = @This();

module: *const Module,
allocator: mem.Allocator,
buffer: std.ArrayList(u8),
target: Target,

pub fn init(allocator: mem.Allocator, module: *const Module, target: Target) Self {
    return Self{
        .module = module,
        .allocator = allocator,
        .buffer = std.ArrayList(u8).init(allocator),
        .target = target,
    };
}

pub fn compile(self: *Self) ![]const u8 {
    const writter = self.buffer.writer();
    _ = writter;

    return self.buffer.items;
}

pub fn deinit(self: *const Self) void {
    self.buffer.deinit();
}
