const std = @import("std");
const mem = std.mem;

const Module = @import("../IR/Module.zig");

const TargetNs = @import("Target.zig");
const Machine = TargetNs.Machine;

const GetStub = @import("Stub.zig").GetStub;
const Codegen = @import("Codegen.zig").Codegen;

const Self = @This();

module: *const Module,
allocator: mem.Allocator,
buffer: std.ArrayList(u8),
machine: Machine,
codegen: Codegen,

pub fn init(allocator: mem.Allocator, module: *const Module, target: Machine) Self {
    return Self{
        .module = module,
        .allocator = allocator,
        .buffer = std.ArrayList(u8).init(allocator),
        .machine = target,
        .codegen = Codegen.init(target),
    };
}

pub fn compile(self: *Self) ![]const u8 {
    const writter = self.buffer.writer();
    try writter.print("{s}\n", .{GetStub(self.machine)});

    return self.buffer.items;
}

pub fn deinit(self: *const Self) void {
    self.buffer.deinit();
}
