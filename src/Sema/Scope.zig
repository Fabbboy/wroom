const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const AssignStatement = @import("../AST/AssignStatement.zig");
const FunctionDecl = @import("../AST/FunctionDecl.zig");

const Self = @This();

parent: ?*Self,
symbols: std.StringHashMap(ValueType),
functions: std.StringHashMap(*FunctionDecl),
allocator: mem.Allocator,

pub fn init(allocator: mem.Allocator, parent: ?*Self) !*Self {
    const self = try allocator.create(Self);
    self.parent = parent;
    self.symbols = std.StringHashMap(ValueType).init(allocator);
    self.functions = std.StringHashMap(*FunctionDecl).init(allocator);
    self.allocator = allocator;
    return self;
}

pub fn find(self: *Self, name: []const u8) ?ValueType {
    if (self.symbols.contains(name)) {
        return self.symbols.get(name);
    }

    if (self.parent) |parent| {
        return parent.find(name);
    }

    return null;
}

pub fn findFunc(self: *Self, name: []const u8) ?*FunctionDecl {
    if (self.functions.contains(name)) {
        return self.functions.get(name);
    }

    if (self.parent) |parent| {
        return parent.findFunc(name);
    }

    return null;
}

pub fn push(self: *Self, name: []const u8, value: ValueType) !void {
    try self.symbols.put(name, value);
}

pub fn pushFunc(self: *Self, func: *FunctionDecl) !void {
    try self.functions.put(func.name.lexeme, func);
}

pub fn deinit(self: *Self) void {
    if (self.parent) |parent| {
        parent.deinit();
        self.parent = null;
    }
    self.symbols.deinit();
    self.functions.deinit();
    self.allocator.destroy(self);
}
