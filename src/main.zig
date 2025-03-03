const std = @import("std");
const heap = std.heap;
const io = std.io;
const process = std.process;
const fs = std.fs;

const TokenKind = @import("Parser/Token.zig").TokenKind;
const Lexer = @import("Parser/Lexer.zig");
const Parser = @import("Parser/Parser.zig");
const Sema = @import("Sema/Sema.zig");

const IRModule = @import("IR/Module.zig");
const IRGen = @import("IR/IRGen.zig");

var fmt_buf: [4096]u8 = undefined;

pub fn main() !void {
    const page_allocator = std.heap.page_allocator;

    var fixed_buf_allocator = std.heap.FixedBufferAllocator.init(fmt_buf[0..]);
    var format_buffer = std.ArrayList(u8).init(fixed_buf_allocator.allocator());
    defer format_buffer.deinit();
    const buf_writer = format_buffer.writer();

    const args = try process.argsAlloc(fixed_buf_allocator.allocator());
    defer process.argsFree(fixed_buf_allocator.allocator(), args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <source file>\n", .{args[0]});
        return;
    }

    const source_path = args[1];
    const file_fd = try fs.cwd().openFile(source_path, .{});
    defer file_fd.close();

    const file_stat = try file_fd.stat();
    const file_contents = try page_allocator.alloc(u8, file_stat.size);
    defer page_allocator.free(file_contents);

    const read_result = try file_fd.readAll(file_contents);
    if (read_result != file_stat.size) {
        std.debug.print("Failed to read file\n", .{});
        return;
    }

    const source = file_contents[0..read_result];

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

    var lexer = Lexer.init(source);
    var parser = Parser.init(&lexer, gpa.allocator());
    defer parser.deinit();

    parser.parse() catch {
        const errs = parser.getErrs();
        for (errs.items) |err| {
            try err.fmt(buf_writer);
            std.debug.print("{s}\n", .{format_buffer.items});
            format_buffer.clearRetainingCapacity();
        }

        format_buffer.clearRetainingCapacity();
        return;
    };

    const ast = parser.getAst();

    var sema = try Sema.init(ast, gpa.allocator());
    defer sema.deinit();
    sema.analyze() catch {
        const errs = sema.getErrs();
        for (errs.*) |err| {
            try err.fmt(buf_writer);
            std.debug.print("{s}\n", .{format_buffer.items});
            format_buffer.clearRetainingCapacity();
        }

        format_buffer.clearRetainingCapacity();
        return;
    };

    const globals = ast.getGlobals();
    for (globals.*) |glbl| {
        try glbl.fmt(buf_writer);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
        const range = source[glbl.start()..glbl.stop()];
        std.debug.print("Source: {s}\n", .{range});
    }

    const functions = ast.getFunctions();
    for (functions.*) |func| {
        try func.fmt(buf_writer);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
        const range = source[func.start()..func.stop()];
        std.debug.print("Source: {s}\n", .{range});
    }

    var module = IRModule.init(gpa.allocator());
    defer module.deinit();
    var generator = IRGen.init(ast, &module, gpa.allocator());
    defer generator.deinit();
    try generator.generate();

    const errs = generator.getErrs();
    for (errs.*) |err| {
        try err.fmt(buf_writer);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
    }

    var globalIter = module.getGlobals().table.iterator();
    while (globalIter.next()) |global| {
        const name = global.key_ptr.*;
        const value = global.value_ptr.*;
        try buf_writer.print("@{s} ", .{name});
        try value.fmt(buf_writer);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
    }

    var functionIter = module.getFunctions().table.iterator();
    while (functionIter.next()) |function| {
        const name = function.key_ptr.*;
        const value = function.value_ptr.*;
        try value.fmt(buf_writer, name);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
    }

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}

test {
    std.testing.refAllDecls(@This());
}
