const std = @import("std");
const mem = std.mem;

const GlobalVariable = @import("Values/GlobalVariable.zig");
const IRValue = @import("IRValue.zig").IRValue;

const Function = @import("Function.zig");

const Self = @This();

name: []const u8,
globals: std.StringHashMap(GlobalVariable),
funcs: std.StringHashMap(Function),
allocator: mem.Allocator,

pub fn init(name: []const u8, allocator: mem.Allocator) Self {
    return Self{
        .name = name,
        .globals = std.StringHashMap(GlobalVariable).init(allocator),
        .funcs = std.StringHashMap(Function).init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *Self) void {
    self.globals.deinit();

    var funcNext = self.funcs.iterator();
    while (funcNext.next()) |func| {
        const f = func.value_ptr;
        f.deinit();
    }

    self.funcs.deinit();
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("module = {s}\n", .{self.name});
    var glblNext = self.globals.iterator();
    while (glblNext.next()) |global| {
        const v = global.value_ptr;

        try v.fmt(fbuf);
        try fbuf.writeByte('\n');
    }

    var funcNext = self.funcs.iterator();
    while (funcNext.next()) |func| {
        const f = func.value_ptr;
        try f.fmt(fbuf);
        try fbuf.writeByte('\n');
    }
}

pub fn addGlobal(self: *Self, name: []const u8, global: GlobalVariable) !*GlobalVariable {
    try self.globals.put(name, global);
    return self.globals.getPtr(name).?;
}

pub fn addFunction(self: *Self, func: Function) !*Function {
    try self.funcs.put(func.name, func);
    return self.funcs.getPtr(func.name).?;
}

pub fn findGlobal(self: *const Self, name: []const u8) ?*const GlobalVariable {
    return self.globals.getPtr(name);
}
