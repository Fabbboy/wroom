const std = @import("std");
const mem = std.mem;

const Stmt = @import("Stmt.zig").Stmt;

const Self = @This();

stmts: std.ArrayList(Stmt),

pub fn init(allocator: mem.Allocator) Self {
    return Self{
        .stmts = std.ArrayList(Stmt).init(allocator),
    };
}

pub fn fmt (self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("Block{ stmts: [");
    for (self.stmts.items) |stmt| {
        try stmt.fmt(fbuf);
        try fbuf.writeAll(", ");
    }
    try fbuf.writeAll("] }");
}

pub fn deinit(self: *const Self) void {
    for (self.stmts.items) |stmt| {
        stmt.deinit();
    }
    self.stmts.deinit();
}

pub fn start(self: *const Self) usize {
    return self.stmts.items[0].start();
}

pub fn stop(self: *const Self) usize {
    return self.stmts.items[self.stmts.items.len - 1].stop();
}

pub fn pos(self: *const Self) Stmt.Position {
    return self.stmts.items[0].pos();
}