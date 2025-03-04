const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const Constant = @import("../IRValue/Constant.zig").IRConstant;

const Self = @This();

glob_id: usize,
initializer: Constant,
val_type: ValueType,
constant: bool,

pub fn init(glob_id: usize, initializer: Constant, val_type: ValueType, constant: bool) Self {
    return Self{
        .glob_id = glob_id,
        .initializer = initializer,
        .val_type = val_type,
        .constant = constant,
    };
}

pub fn getType(self: *const Self) ValueType {
    return self.val_type;
}

pub fn fmt(self: *const Self, fbuf: anytype, name: []const u8) !void {
    try fbuf.print("{s} @{s} {s} = ", .{ self.val_type.fmt(), name, if (self.constant) "const" else "" });
    try self.initializer.fmt(fbuf);
}
