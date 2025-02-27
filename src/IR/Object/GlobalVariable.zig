const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const Constant = @import("../IRValue/Constant.zig").IRConstant;

const Self = @This();

initializer: Constant,
val_type: ValueType,

pub fn init(initializer: Constant, val_type: ValueType) Self {
    return Self{
        .initializer = initializer,
        .val_type = val_type,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} = ", .{self.val_type.fmt()});
    try self.initializer.fmt(fbuf);
}
