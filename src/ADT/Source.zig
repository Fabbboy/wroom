const std = @import("std");
const mem = std.mem;
const fs = std.fs;

const Self = @This();

path: []const u8,
stat: ?fs.File.Stat,
len: usize,
contents: ?[]u8,
allocator: mem.Allocator,
lines: std.ArrayList(usize),

fn readFullFile(self: *Self) !void {
    const file_fd = try fs.cwd().openFile(self.path, .{
        .mode = .read_only,
    });
    defer file_fd.close();

    self.stat = try file_fd.stat();
    const stat = self.stat.?;
    self.len = stat.size;
    self.contents = try self.allocator.alloc(u8, stat.size);

    const read_result = try file_fd.readAll(self.contents.?);
    if (read_result != stat.size) {
        return error.UnexpectedEof;
    }
}

fn readLines(self: *Self) !void {
    var idx: usize = 0;
    var last_idx: usize = 0;

    try self.pushNewLine(last_idx);

    while (idx < self.len) {
        if (self.contents.?[idx] == '\n') {
            last_idx = idx + 1;
            if (last_idx < self.len) {
                try self.pushNewLine(last_idx);
            }
        }
        idx += 1;
    }
}

pub fn init(allocator: mem.Allocator, path: []const u8) !Self {
    var self = Self{
        .path = path,
        .len = 0,
        .allocator = allocator,
        .contents = null,
        .stat = null,
        .lines = std.ArrayList(usize).init(allocator),
    };

    try self.readFullFile();
    try self.readLines();
    return self;
}

pub fn getContents(self: *const Self) ![]u8 {
    return self.contents.?;
}

pub fn pushNewLine(self: *Self, idx: usize) !void {
    try self.lines.append(idx);
}

pub fn deinit(self: *Self) void {
    if (self.contents) |c| {
        self.allocator.free(c);
        self.contents = null;
    }

    self.lines.deinit();
}
