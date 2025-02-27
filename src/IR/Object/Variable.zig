const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const IRValue = @import("../Value.zig").IRValue;

const Instruction = @import("../Instruction.zig").Instruction;

const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

initializer: IRValue,
val_type: ValueType,

pub fn init(initializer: IRValue, val_type: ValueType) Self {
    return Self{
        .initializer = initializer,
        .val_type = val_type,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} = ", .{self.val_type.fmt()});
    try self.initializer.fmt(fbuf);
}

pub fn gen(self: *const Self, instrs: *std.ArrayList(Instruction)) IRStatus!void {
    _ = self;
    _ = instrs;
}