const std = @import("std");
const heap = std.heap;
const io = std.io;

const TokenKind = @import("Parser/Token.zig").TokenKind;
const Lexer = @import("Parser/Lexer.zig");
const Parser = @import("Parser/Parser.zig");
const Sema = @import("Sema/Sema.zig");

const IRModule = @import("IR/Module.zig");
const IRGen = @import("IR/IRGen.zig");

pub fn main() !void {
    const source = "let glbl = 123 func main(argc: int) int {let locl = 1 locl += 20 return locl}";
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .verbose_log = true,
        .enable_memory_limit = true,
        .thread_safe = false,
    }){};
    defer {
        if (gpa.deinit() == .leak) {
            @panic("Memory leak detected");
        }
    }

    var fmt_buf: [4096]u8 = undefined;
    var fixed_buf_allocator = std.heap.FixedBufferAllocator.init(fmt_buf[0..]);
    var buf = std.ArrayList(u8).init(fixed_buf_allocator.allocator());
    defer buf.deinit();
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

        buf.clearRetainingCapacity();
        return;
    };

    const ast = parser.getAst();

    var sema = try Sema.init(ast, gpa.allocator());
    defer sema.deinit();
    sema.analyze() catch {
        const errs = sema.getErrs();
        for (errs.*) |err| {
            try err.fmt(buf_writer);
            std.debug.print("{s}\n", .{buf.items});
            buf.clearRetainingCapacity();
        }

        buf.clearRetainingCapacity();
        return;
    };

    const globals = ast.getGlobals();
    for (globals.*) |glbl| {
        try glbl.fmt(buf_writer);
        std.debug.print("{s}\n", .{buf.items});
        buf.clearRetainingCapacity();
        const range = source[glbl.start()..glbl.stop()];
        std.debug.print("Source: {s}\n", .{range});
    }

    const functions = ast.getFunctions();
    for (functions.*) |func| {
        try func.fmt(buf_writer);
        std.debug.print("{s}\n", .{buf.items});
        buf.clearRetainingCapacity();
        const range = source[func.start()..func.body.?.stop()];
        std.debug.print("Source: {s}\n", .{range});
    }

    var module = IRModule.init(gpa.allocator());
    defer module.deinit();
    var generator = IRGen.init(ast, &module, gpa.allocator());
    defer generator.deinit();
    try generator.generate();

    var globalIter = module.getGlobals().table.iterator();
    while (globalIter.next()) |global| {
        const name = global.key_ptr.*;
        const value = global.value_ptr.*;
        try buf_writer.print("@{s} ", .{name});
        try value.fmt(buf_writer);
        std.debug.print("{s}\n", .{buf.items});
        buf.clearRetainingCapacity();
    }

    var functionIter = module.getFunctions().table.iterator();
    while (functionIter.next()) |function| {
        const name = function.key_ptr.*;
        const value = function.value_ptr.*;
        try value.fmt(buf_writer, name);
        std.debug.print("{s}\n", .{buf.items});
        buf.clearRetainingCapacity();
    }

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}

test {
    std.testing.refAllDecls(@This());
}
