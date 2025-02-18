const std = @import("std");
const mem = std.mem;

const AssignStatement = @import("../Parser/AST/AssignStatement.zig");

const Self = @This();

parent: ?*Self,
symbols: std.StringHashMap(*AssignStatement),
allocator: mem.Allocator,

pub fn init(allocator: mem.Allocator, parent: ?*Self) Self {
    return Self{
        .parent = parent,
        .symbols = std.StringHashMap(*AssignStatement).init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    if (self.parent) |parent| {
        parent.deinit();
        self.parent = null;
    }
    self.symbols.deinit();
}
