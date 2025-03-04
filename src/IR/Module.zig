const std = @import("std");
const mem = std.mem;

const SymTable = @import("../ADT/SymTable.zig").SymTable;
const GlobalVariable = @import("IRValue/GlobalVariable.zig");

const Function = @import("IRValue/Function.zig");
const FuncBlock = Function.FuncBlock;

const IRValue = @import("Value.zig").IRValue;

const Self = @This();

name: []const u8,
allocator: mem.Allocator,
globals: SymTable(GlobalVariable),
functions: SymTable(Function),
globals_id: usize,

pub fn init(allocator: mem.Allocator, name: []const u8) Self {
    return Self{
        .name = name,
        .allocator = allocator,
        .globals = SymTable(GlobalVariable).init(allocator),
        .functions = SymTable(Function).init(allocator),
        .globals_id = 0,
    };
}

pub fn deinit(self: *Self) void {
    self.globals.deinit();

    var funcNext = self.functions.table.iterator();
    while (funcNext.next()) |entry| {
        const value = entry.value_ptr.*;
        value.deinit();
    }
    self.functions.deinit();
}

pub fn getNextGlobalId(self: *Self) usize {
    const id = self.globals_id;
    self.globals_id += 1;
    return id;
}

pub fn getGlobals(self: *const Self) *const SymTable(GlobalVariable) {
    return &self.globals;
}

pub fn getFunctions(self: *const Self) *const SymTable(Function) {
    return &self.functions;
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("module: {s}\n", .{self.name});
    var glblsIter = self.globals.table.iterator();
    while (glblsIter.next()) |entry| {
        const value = entry.value_ptr;
        try value.fmt(fbuf);
        try fbuf.writeAll("\n");
    }

    var funcsIter = self.functions.table.iterator();
    while (funcsIter.next()) |entry| {
        const name = entry.key_ptr;
        const value = entry.value_ptr;
        try value.fmt(fbuf, name.*);
        try fbuf.writeAll("\n");
    }

    try fbuf.writeAll("\n");
}
