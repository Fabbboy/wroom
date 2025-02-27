const std = @import("std");
const zfmt = std.fmt;

const Self = @This();

pub const IRConstant = union(enum) {
    Integer: i64,
    Floating: f64,

    pub fn Int(value: i64) IRConstant {
        return .{
            .Integer = value,
        };
    }

    pub fn Float(value: f64) IRConstant {
        return .{
            .Floating = value,
        };
    }

    pub fn fmt(self: *const IRConstant, fbuf: anytype) !void {
        switch (self.*) {
            .Integer => |value| {
                try fbuf.print("{}", .{value});
            },
            .Floating => |value| {
                try fbuf.print("{}", .{value});
            },
        }
    }
};
