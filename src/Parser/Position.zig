const std = @import("std");
const sys_fmt = std.fmt;
const mem = std.mem;

const Self = @This();

line: usize,
column: usize,
start: usize,
end: usize,

pub fn init(line: usize, column: usize, start: usize, end: usize) Self {
    return Self{
        .line = line,
        .column = column,
        .start = start,
        .end = end,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("Pos{ line: ");
    try fbuf.print("{}, column: {}, start: {}, end: {} ", .{ self.line, self.column, self.start, self.end });
    try fbuf.writeAll(" }");
}
