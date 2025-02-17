const std = @import("std");
const mem = std.mem;

const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");
const Error = @import("Error.zig");
const ParseError = Error.ParseError;
const ParseStatus = Error.ParseStatus;

const Self = @This();

allocator: mem.Allocator,
lexer: *Lexer,
ast: Ast,
errs: std.ArrayList(ParseError),

pub fn init(lexer: *Lexer, allocator: mem.Allocator) Self {
    return Self{
        .lexer = lexer,
        .ast = Ast.init(allocator),
        .allocator = allocator,
        .errs = std.ArrayList(ParseError).init(allocator),
    };
}

pub fn parse(self: *Self) ParseStatus!void {
    _ = self;
    return error.NotGood;
}

pub fn getAst(self: *const Self) *const Ast {
    return &self.ast;
}

pub fn deinit(self: *Self) void {
    self.ast.deinit();
}
