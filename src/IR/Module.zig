const std = @import("std");
const mem = std.mem;

const SymTable = @import("ADT/SymTable.zig").SymTable;
const Variable = @import("Object/Variable.zig");

const Function = @import("Object/Function.zig");
const FuncBlock = Function.FuncBlock;

const Self = @This();

allocator: mem.Allocator,
globals: SymTable(Variable),
functions: SymTable(Function),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .allocator = allocator,
        .globals = SymTable(Variable).init(allocator),
        .functions = SymTable(Function).init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    var varNext = self.globals.table.iterator();
    while (varNext.next()) |entry| {
        const value = entry.value_ptr.*;
        value.deinit();
    }
    self.globals.deinit();

    var funcNext = self.functions.table.iterator();
    while (funcNext.next()) |entry| {
        const value = entry.value_ptr.*;
        value.deinit();
    }
    self.functions.deinit();
}

pub fn getGlobals(self: *const Self) *const SymTable(Variable) {
    return &self.globals;
}

pub fn getFunctions(self: *const Self) *const SymTable(Function) {
    return &self.functions;
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("Module{ globals: ");
    try self.globals.fmt(fbuf);
    try fbuf.writeAll(" }");
}
