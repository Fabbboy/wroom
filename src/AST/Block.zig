const std = @import("std");
const mem = std.mem;

const Position = @import("../Parser/Position.zig");

const Stmt = @import("Stmt.zig").Stmt;

const Self = @This();

stmts: std.ArrayList(Stmt),
pos: Position,

pub fn init(stmts: std.ArrayList(Stmt), position: Position) Self {
    return Self{
        .stmts = stmts,
        .pos = position,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
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

pub fn getBody(self: *const Self) *const []Stmt {
    return &self.stmts.items;
}

pub fn start(self: *const Self) usize {
    return self.pos.start;
}

pub fn stop(self: *const Self) usize {
    return self.pos.end;
}

pub fn pos(self: *const Self) Stmt.Position {
    return self.pos;
}
