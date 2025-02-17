const std = @import("std");
const heap = std.heap;

const TokenKind = @import("parser/token.zig").TokenKind;
const Lexer = @import("parser/lexer.zig");

pub fn main() !void {
    const source = "let x = 1 + 2 * 3";
    var lexer = Lexer.init(source);

    var buf: [1024]u8 = undefined;
    var fmtAlloc = heap.FixedBufferAllocator.init(&buf);
    defer fmtAlloc.reset();
    var fmtBuf = std.ArrayList(u8).init(fmtAlloc.allocator());
    var writer = fmtBuf.writer();

    while (true) {
        const tok = lexer.next();
        if (tok.kind == TokenKind.EOF) {
            break;
        }

        try tok.fmt(&writer);
        std.debug.print("{s}\n", .{fmtBuf.items});
        fmtBuf.clearAndFree();
    }
}
