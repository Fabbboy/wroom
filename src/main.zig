const std = @import("std");
const heap = std.heap;
const io = std.io;

const TokenKind = @import("Parser/Token.zig").TokenKind;
const Lexer = @import("Parser/Lexer.zig");
const Parser = @import("Parser/Parser.zig");

pub fn main() !void {
    const source = "let x = ";
    var gpa = std.heap.GeneralPurposeAllocator(.{ .verbose_log = true }){};
    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leak detected");
        }
    }

    var buf = std.ArrayList(u8).init(gpa.allocator());
    const buf_writer = buf.writer();

    var lexer = Lexer.init(source);
    var parser = Parser.init(&lexer, gpa.allocator());
    defer parser.deinit();

    parser.parse() catch {
        const errs = parser.getErrs();
        for (errs.items) |err| {
            try err.fmt(buf_writer);
            std.debug.print("{s}\n", .{buf.items});
            buf.clearRetainingCapacity();
        }

        buf.clearAndFree();
        return;
    };

    const ast = parser.getAst();

    for (ast.globals.items) |glbl| {
        try glbl.fmt(buf_writer);
        std.debug.print("{s}\n", .{buf.items});
        buf.clearRetainingCapacity();
    }

    buf.clearAndFree();
}
