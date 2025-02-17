const std = @import("std");
const mem = std.mem;

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");

const Self = @This();

allocator: mem.Allocator,
lexer: *Lexer,
ast: Ast,

pub fn init(lexer: *Lexer, allocator: mem.Allocator) Self {
    return Self{
        .lexer = lexer,
        .ast = Ast.init(allocator),
        .allocator = allocator,
    };
}

pub fn getAst(self: *const Self) *const Ast {
    return &self.ast;
}
