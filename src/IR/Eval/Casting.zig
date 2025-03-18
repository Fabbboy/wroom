const TypeNs = @import("../Type.zig");
const Type = TypeNs.Type;
const IntegerTy = TypeNs.IntegerTy;
const FloatTy = TypeNs.FloatTy;

const ConstantNs = @import("../Values/Constant.zig");
const Constant = ConstantNs.Constant;
const IntValue = ConstantNs.IntValue;
const FloatValue = ConstantNs.FloatValue;

const IRStatus = @import("../Error.zig").IRStatus;

pub fn castIntToInt(val: IntValue, to: IntegerTy) Constant {
    return switch (val) {
        IntValue.I32 => switch (to) {
            IntegerTy.I32 => Constant.init_int_value(val),
        },
    };
}

pub fn castIntToFloat(val: IntValue, to: FloatTy) Constant {
    return switch (val) {
        IntValue.I32 => switch (to) {
            FloatTy.F32 => Constant.init_float_value(FloatValue.init_f32(@as(f32, @floatFromInt(val.I32)))),
        },
    };
}

pub fn castFloatToFloat(val: FloatValue, to: FloatTy) Constant {
    return switch (val) {
        FloatValue.F32 => switch (to) {
            FloatTy.F32 => Constant.init_float_value(val),
        },
    };
}

pub fn castFloatToInt(val: FloatValue, to: IntegerTy) Constant {
    return switch (val) {
        FloatValue.F32 => switch (to) {
            IntegerTy.I32 => return Constant.init_int_value(IntValue.init_i32(@as(i32, @intFromFloat(val.F32)))),
        },
    };
}

pub fn castIntValue(val: IntValue, to: Type) IRStatus!Constant {
    return switch (to) {
        Type.Integer => castIntToInt(val, to.Integer),
        Type.Float => castIntToFloat(val, to.Float),
        Type.Void => error.UnableToCast,
    };
}

pub fn castFloatValue(val: FloatValue, to: Type) IRStatus!Constant {
    return switch (to) {
        Type.Integer => castFloatToInt(val, to.Integer),
        Type.Float => castFloatToFloat(val, to.Float),
        Type.Void => error.UnableToCast,
    };
}

pub fn CastConstant(val: Constant, to: Type) IRStatus!Constant {
    return switch (val) {
        Constant.IntValue => try castIntValue(val.IntValue, to),
        Constant.FloatValue => try castFloatValue(val.FloatValue, to),
    };
}
