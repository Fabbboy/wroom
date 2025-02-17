const std = @import("std");
const mem = std.mem;
const Token = @import("Token.zig");
const TokenKind = Token.TokenKind;

const Self = @This();

const AssignStatement = @import("AST/AssignStatement.zig");

allocator: mem.Allocator,
globals: std.ArrayList(AssignStatement),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .allocator = allocator,
        .globals = std.ArrayList(AssignStatement).init(allocator),
    };
}

pub fn pushGlobal(self: *Self, assign: AssignStatement) !void {
    try self.globals.append(assign);
}
