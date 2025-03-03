const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const Constant = @import("../IRValue/Constant.zig").IRConstant;

const Self = @This();

glob_id: usize,
initializer: Constant,
val_type: ValueType,

pub fn init(glob_id: usize, initializer: Constant, val_type: ValueType) Self {
    return Self{
        .glob_id = glob_id,
        .initializer = initializer,
        .val_type = val_type,
    };
}

pub fn getType(self: *const Self) ValueType {
    return self.val_type;
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} = ", .{self.val_type.fmt()});
    try self.initializer.fmt(fbuf);
}
