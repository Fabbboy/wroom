const std = @import("std");
const mem = std.mem;

const SymTable = @import("SymTable.zig").SymTable;
const Variable = @import("Variable.zig");

const Self = @This();

allocator: mem.Allocator,
globals: SymTable(Variable),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .allocator = allocator,
        .globals = SymTable(Variable).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    self.globals.deinit();
}
