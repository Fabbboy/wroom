const std = @import("std");
const heap = std.heap;

const TokenKind = @import("parser/token.zig").TokenKind;
const Lexer = @import("parser/lexer.zig");
const Parser = @import("parser/parser.zig");

pub fn main() !void {
    const source = "let x = 1 + 2 * 3";
    var lexer = Lexer.init(source); 
    const parser = Parser.init(&lexer);
    _ = parser;
}
