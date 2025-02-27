const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const IRValue = @import("../Value.zig").IRValue;

const Self = @This();

initializer: IRValue,
val_type: ValueType,
isGlobal: bool,
ssa_id: usize,

pub fn init(initializer: IRValue, val_type: ValueType, isGlobal: bool, ssa_id: usize) Self {
    return Self{
        .initializer = initializer,
        .val_type = val_type,
        .isGlobal = isGlobal,
        .ssa_id = ssa_id,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    if (self.isGlobal) {
        try fbuf.writeAll("global ");
    }
    try fbuf.print("{s} = ", .{self.val_type.fmt()});
    try self.initializer.fmt(fbuf);
}

pub fn deinit(self: *const Self) void {
    self.initializer.deinit();
}
