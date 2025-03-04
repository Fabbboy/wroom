const std = @import("std");

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;
const Constant = @import("../IRValue/Constant.zig").IRConstant;

const Linkage = @import("../../AST/AssignStatement.zig").Linkage;

const Self = @This();

glob_id: usize,
initializer: Constant,
val_type: ValueType,
constant: bool,
linkage: Linkage,

pub fn init(glob_id: usize, initializer: Constant, val_type: ValueType, constant: bool, linkage: Linkage) Self {
    return Self{
        .glob_id = glob_id,
        .initializer = initializer,
        .val_type = val_type,
        .constant = constant,
        .linkage = linkage,
    };
}

pub fn getType(self: *const Self) ValueType {
    return self.val_type;
}

pub fn fmt(self: *const Self, fbuf: anytype, name: []const u8) !void {
    try fbuf.print("{s} {s} @{s} = {s} ", .{ self.linkage.fmt(), if (self.constant) "const" else "", name, self.val_type.fmt() });
    try self.initializer.fmt(fbuf);
}
