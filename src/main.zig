const std = @import("std");
const heap = std.heap;

const TokenKind = @import("Parser/Token.zig").TokenKind;
const Lexer = @import("Parser/Lexer.zig");
const Parser = @import("Parser/Parser.zig");

pub fn main() !void {
    const source = "let x = 1 + 2 * 3";
    var lexer = Lexer.init(source); 
    const parser = Parser.init(&lexer);
    _ = parser;
}
