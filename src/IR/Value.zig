const std = @import("std");

const IRConstant = @import("IRValue/Constant.zig").IRConstant;
const IRBinary = @import("IRValue/Binary.zig");

pub const IRValue = union(enum) {
    Constant: IRConstant,
    Binary: IRBinary,

    pub fn init_constant(value: IRConstant) IRValue {
        return IRValue{
            .Constant = value,
        };
    }

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        switch (self.*) {
            IRValue.Constant => |value| {
                try value.fmt(fbuf);
            },
            else => unreachable,
        }
    }
};
