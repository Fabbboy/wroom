const std = @import("std");
const zfmt = std.fmt;

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Self = @This();

pub const IRConstant = union(enum) {
    Voider: void,
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

    pub fn Void() IRConstant {
        return .Voider;
    }

    pub fn fmt(self: *const IRConstant, fbuf: anytype) !void {
        switch (self.*) {
            .Voider => try fbuf.writeAll("void"),
            .Integer => |value| {
                try fbuf.print("#{}", .{value});
            },
            .Floating => |value| {
                try fbuf.print("#{}", .{value});
            },
        }
    }

    pub fn getType(self: *const IRConstant) ValueType {
        switch (self.*) {
            .Voider => return ValueType.Void,
            .Integer => return ValueType.I32,
            .Floating => return ValueType.F32,
        }
    }
};
