const Token = @import("../../Parser/Token.zig");
const OperatorType = Token.OperatorType;

const ConstantNs = @import("../Values/Constant.zig");
const Constant = ConstantNs.Constant;
const IntValue = ConstantNs.IntValue;
const FloatValue = ConstantNs.FloatValue;

const Type = @import("../Type.zig").Type;
const IntegerTy = Type.IntegerTy;
const FloatTy = Type.FloatTy;

const IRValue = @import("../IRValue.zig").IRValue;

const BinOpFunc = fn (lhs: Constant, rhs: Constant) ?Constant;

fn binOpInt(comptime op: OperatorType, lhs: i64, rhs: i64) ?i64 {
    return switch (op) {
        .Plus => lhs + rhs,
        .Minus => lhs - rhs,
        .Star => lhs * rhs,
        .Slash => @divTrunc(lhs, rhs),
        else => return null,
    };
}

fn binOpFloat(comptime op: OperatorType, lhs: f64, rhs: f64) ?f64 {
    return switch (op) {
        .Plus => lhs + rhs,
        .Minus => lhs - rhs,
        .Star => lhs * rhs,
        .Slash => lhs / rhs,
        else => return null,
    };
}

fn getIdx(val: Constant) u8 {
    return switch (val) {
        .IntValue => 0,
        .FloatValue => 1,
    };
}

fn binOpHandler(comptime op: OperatorType, lhs: Constant, rhs: Constant) ?Constant {
    return switch (lhs) {
        .IntValue => switch (rhs) {
            .IntValue => {
                const lhs_val: i64 = lhs.IntValue.to_i64();
                const rhs_val: i64 = rhs.IntValue.to_i64();
                const result = binOpInt(op, lhs_val, rhs_val) orelse return null;

                return Constant.init_int_value(IntValue{ .I32 = @as(i32, @intCast(result)) });
            },
            .FloatValue => {
                const lhs_val: f64 = lhs.IntValue.to_f64();
                const rhs_val: f64 = rhs.FloatValue.to_f64();
                const result = binOpFloat(op, lhs_val, rhs_val) orelse return null;
                return Constant.init_float_value(FloatValue.init_f32(@as(f32, @floatCast(result))));
            },
        },
        .FloatValue => switch (rhs) {
            .IntValue => {
                const lhs_val: f64 = lhs.FloatValue.to_f64();
                const rhs_val: f64 = rhs.IntValue.to_f64();
                const result = binOpFloat(op, lhs_val, rhs_val) orelse return null;
                return Constant.init_float_value(FloatValue.init_f32(@as(f32, @floatCast(result))));
            },
            .FloatValue => {
                const lhs_val: f64 = lhs.FloatValue.to_f64();
                const rhs_val: f64 = rhs.FloatValue.to_f64();
                const result = binOpFloat(op, lhs_val, rhs_val) orelse return null;
                return Constant.init_float_value(FloatValue.init_f32(@as(f32, @floatCast(result))));
            },
        },
    };
}

const BinOpFuncTable: [4]*const fn (Constant, Constant) ?Constant = .{
    &binOpHandlerPlus,
    &binOpHandlerMinus,
    &binOpHandlerMul,
    &binOpHandlerDiv,
};

fn binOpHandlerPlus(lhs: Constant, rhs: Constant) ?Constant {
    return binOpHandler(.Plus, lhs, rhs);
}
fn binOpHandlerMinus(lhs: Constant, rhs: Constant) ?Constant {
    return binOpHandler(.Minus, lhs, rhs);
}
fn binOpHandlerMul(lhs: Constant, rhs: Constant) ?Constant {
    return binOpHandler(.Star, lhs, rhs);
}
fn binOpHandlerDiv(lhs: Constant, rhs: Constant) ?Constant {
    return binOpHandler(.Slash, lhs, rhs);
}

fn getFunc(op: OperatorType) *const fn (Constant, Constant) ?Constant {
    switch (op) {
        .Plus => return &binOpHandlerPlus,
        .Minus => return &binOpHandlerMinus,
        .Star => return &binOpHandlerMul,
        .Slash => return &binOpHandlerDiv,
        else => return null,
    }
}

pub fn evalBinary(lhs: Constant, rhs: Constant, op: OperatorType) ?Constant {
    const func = getFunc(op) orelse return null;
    return func(lhs, rhs);
}
