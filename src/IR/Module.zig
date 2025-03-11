const std = @import("std");
const mem = std.mem;

const GlobalVariable = @import("Values/GlobalVariable.zig");
const IRValue = @import("IRValue.zig").IRValue;

const Self = @This();

name: []const u8,
globals: std.ArrayList(GlobalVariable),
allocator: mem.Allocator,

pub fn init(name: []const u8, allocator: mem.Allocator) Self {
    return Self{
        .name = name,
        .globals = std.ArrayList(GlobalVariable).init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *const Self) void {
    self.globals.deinit();
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("module = {s}\n", .{self.name});
    for (self.globals.items) |global| {
        try global.fmt(fbuf);
        try fbuf.writeByte('\n');
    }
}

pub fn addGlobal(self: *Self, global: GlobalVariable) !void {
    try self.globals.append(global);
}

pub fn findGlobal(self: *const Self, name: []const u8) ?*const GlobalVariable {
    for (self.globals.items) |global| {
        if (mem.eql(u8, global.name, name)) {
            return &global;
        }
    }
    return null;
}
