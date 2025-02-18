const std = @import("std");
const mem = std.mem;

const AssignStatement = @import("../Parser/AST/AssignStatement.zig");

const Self = @This();

parent: ?*Self,
symbols: std.StringHashMap(*AssignStatement),
allocator: mem.Allocator,

pub fn init(allocator: mem.Allocator, parent: ?*Self) !*Self {
    const self = try allocator.create(Self);
    self.parent = parent;
    self.symbols = std.StringHashMap(*AssignStatement).init(allocator);
    self.allocator = allocator;
    return self;
}

pub fn find(self: *Self, name: []const u8) ?*AssignStatement {
    if (self.symbols.contains(name)) {
        return self.symbols.get(name);
    }

    if (self.parent) |parent| {
        return parent.find(name);
    }

    return null;
}

pub fn push(self: *Self, name: []const u8, value: *AssignStatement) !void {
    try self.symbols.put(name, value);
}

pub fn deinit(self: *Self) void {
    if (self.parent) |parent| {
        parent.deinit();
        self.parent = null;
    }
    self.symbols.deinit();
    self.allocator.destroy(self);
}
