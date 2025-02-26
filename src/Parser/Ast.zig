const std = @import("std");
const mem = std.mem;
const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

const Self = @This();

const AssignStatement = @import("../AST/AssignStatement.zig");
const FunctionDecl = @import("../AST/FunctionDecl.zig");

allocator: mem.Allocator,
globals: std.ArrayList(AssignStatement),
functions: std.ArrayList(FunctionDecl),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .allocator = allocator,
        .globals = std.ArrayList(AssignStatement).init(allocator),
        .functions = std.ArrayList(FunctionDecl).init(allocator),
    };
}

pub fn getGlobals(self: *const Self) *const []AssignStatement {
    return &self.globals.items;
}

pub fn getFunctions(self: *const Self) *const []FunctionDecl {
    return &self.functions.items;
}

pub fn pushGlobal(self: *Self, assign: AssignStatement) !void {
    try self.globals.append(assign);
}

pub fn pushFunction(self: *Self, func: FunctionDecl) !void {
    try self.functions.append(func);
}

pub fn deinit(self: *Self) void {
    for (self.globals.items) |global| {
        global.deinit();
    }
    self.globals.deinit();
    for (self.functions.items) |func| {
        func.deinit();
    }
    self.functions.deinit();
}
