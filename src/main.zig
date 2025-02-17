const std = @import("std");
const heap = std.heap;

const TokenKind = @import("parser/token.zig").TokenKind;
const Lexer = @import("parser/lexer.zig");

pub fn main() !void {
    const source = "let x = 1 + 2 * 3";
    var lexer = Lexer.init(source);

    while (true) {
        const tok = lexer.next();
        if (tok.kind == TokenKind.EOF) {
            break;
        }

        std.debug.print("{}\n", .{tok});
    }
}
