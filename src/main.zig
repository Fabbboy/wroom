const std = @import("std");
const heap = std.heap;
const io = std.io;
const process = std.process;
const fs = std.fs;
const mem = std.mem;

const TokenKind = @import("Parser/Token.zig").TokenKind;
const Lexer = @import("Parser/Lexer.zig");
const Parser = @import("Parser/Parser.zig");
const Sema = @import("Sema/Sema.zig");

const IRModule = @import("IR/Module.zig");
const IRGen = @import("IR/IRGen.zig");

var fmt_buf: [4096]u8 = undefined;

var gpa = std.heap.GeneralPurposeAllocator(.{
    .verbose_log = true,
    .enable_memory_limit = true,
    .thread_safe = false,
}){};

const page_allocator = std.heap.page_allocator;

var fixed_buf_allocator = std.heap.FixedBufferAllocator.init(fmt_buf[0..]);

fn readFile(path: []const u8, allocator: mem.Allocator) !?[]u8 {
    const file_fd = try fs.cwd().openFile(path, .{
        .mode = .read_only,
    });
    defer file_fd.close();

    const file_stat = try file_fd.stat();
    const file_contents = try allocator.alloc(u8, file_stat.size);

    const read_result = try file_fd.readAll(file_contents);
    if (read_result != file_stat.size) {
        return null;
    }

    return file_contents[0..read_result];
}

fn handleErrs(errs: anytype, format_buffer: *std.ArrayList(u8)) !void {
    const buf_writer = format_buffer.writer();

    for (errs.*) |err| {
        try err.fmt(buf_writer);
        std.debug.print("{s}\n", .{format_buffer.items});
        format_buffer.clearRetainingCapacity();
    }
}

pub fn main() !void {
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
    const source = try readFile(source_path, page_allocator) orelse return;
    defer page_allocator.free(source);

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
        try handleErrs(errs, &format_buffer);
        return;
    };

    const ast = parser.getAst();

    var sema = try Sema.init(ast, gpa.allocator());
    defer sema.deinit();
    sema.analyze() catch {
        const errs = sema.getErrs();
        try handleErrs(errs, &format_buffer);
        return;
    };

    var module = IRModule.init(gpa.allocator(), "main");
    defer module.deinit();
    var generator = IRGen.init(ast, &module, gpa.allocator());
    defer generator.deinit();
    try generator.generate();

    const errs = generator.getErrs();
    try handleErrs(errs, &format_buffer);

    try module.fmt(&buf_writer);
    std.debug.print("{s}\n", .{format_buffer.items});
    format_buffer.clearRetainingCapacity();

    std.debug.print("Allocated: {d:.2}KiB\n", .{@as(f64, @floatFromInt(gpa.total_requested_bytes)) / 1024.0});
}

test {
    std.testing.refAllDecls(@This());
}
