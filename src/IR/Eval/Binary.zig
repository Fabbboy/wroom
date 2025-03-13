const ConstantNs = @import("../Values/Constant.zig");
const Constant = ConstantNs.Constant;
const IntValue = ConstantNs.IntValue;
const FloatValue = ConstantNs.FloatValue;

const IRValue = @import("../IRValue.zig").IRValue;

fn evalBinaryAddInt(lhs: IntValue, rhs: IntValue) Constant {
    return switch (lhs) {
        IntValue.I32 => |lval| {
            return switch (rhs) {
                IntValue.I32 => |rval| {
                    return Constant.init_int_value(IntValue.init_i32(lval + rval));
                },
            };
        },
    };
}

pub fn evalBinaryAdd(lhs: Constant, rhs: Constant) Constant {
    return switch (lhs) {
        Constant.IntValue => |rlhs| {
            return switch (rhs) {
                Constant.IntValue => |rrhs| evalBinaryAddInt(rlhs, rrhs),
                else => unreachable,
            };
        },
        else => unreachable,
    };
}
