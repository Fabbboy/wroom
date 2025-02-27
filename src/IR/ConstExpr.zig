const std = @import("std");
const math = std.math;

const Constant = @import("IRValue/Constant.zig").IRConstant;

pub fn ConstExprAdd(a: Constant, b: Constant) Constant {
    switch (a) {
        Constant.Integer => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Int(a_val + b_val),
            Constant.Floating => |b_val| return Constant.Float(@as(f64, @floatFromInt(a_val)) + b_val),
        },
        Constant.Floating => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Float(a_val + @as(f64, @floatFromInt(b_val))),
            Constant.Floating => |b_val| return Constant.Float(a_val + b_val),
        },
    }
}

pub fn ConstExprSub(a: Constant, b: Constant) Constant {
    switch (a) {
        Constant.Integer => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Int(a_val - b_val),
            Constant.Floating => |b_val| return Constant.Float(@as(f64, @floatFromInt(a_val)) - b_val),
        },
        Constant.Floating => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Float(a_val - @as(f64, @floatFromInt(b_val))),
            Constant.Floating => |b_val| return Constant.Float(a_val - b_val),
        },
    }
}

pub fn ConstExprMul(a: Constant, b: Constant) Constant {
    switch (a) {
        Constant.Integer => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Int(a_val * b_val),
            Constant.Floating => |b_val| return Constant.Float(@as(f64, @floatFromInt(a_val)) * b_val),
        },
        Constant.Floating => |a_val| switch (b) {
            Constant.Integer => |b_val| return Constant.Float(a_val * @as(f64, @floatFromInt(b_val))),
            Constant.Floating => |b_val| return Constant.Float(a_val * b_val),
        },
    }
}

pub fn ConstExprDiv(a: Constant, b: Constant) Constant {
    switch (a) {
        Constant.Integer => |a_val| switch (b) {
            Constant.Integer => |b_val| {
                if (b_val == 0) return Constant.Int(if (a_val >= 0) std.math.maxInt(i64) else std.math.minInt(i64));
                std.debug.print("i{} / i{}\n", .{ a_val, b_val });
                std.debug.print("1: {}\n", .{@as(f64, @floatFromInt(a_val))});
                std.debug.print("2: {}\n", .{@as(f64, @floatFromInt(b_val))});
                std.debug.print("3: {}\n", .{@as(f64, @floatFromInt(a_val)) / @as(f64, @floatFromInt(b_val))});
                std.debug.print("4: {}\n", .{@as(i64, @intFromFloat(@as(f64, @floatFromInt(a_val)) / @as(f64, @floatFromInt(b_val))))});
                return Constant.Float(@as(f64, @floatFromInt(a_val)) / @as(f64, @floatFromInt(b_val)));
            },
            Constant.Floating => |b_val| {
                std.debug.print("i{} / f{}\n", .{ a_val, b_val });
                if (b_val == 0.0) return Constant.Float(if (a_val >= 0) math.inf(f64) else -math.inf(f64));
                return Constant.Float(@as(f64, @floatFromInt(a_val)) / b_val);
            },
        },
        Constant.Floating => |a_val| switch (b) {
            Constant.Integer => |b_val| {
                std.debug.print("f{} / i{}\n", .{ a_val, b_val });
                if (b_val == 0) return Constant.Float(if (a_val >= 0) math.inf(f64) else -math.inf(f64));
                return Constant.Float(a_val / @as(f64, @floatFromInt(b_val)));
            },
            Constant.Floating => |b_val| {
                std.debug.print("f{} / f{}\n", .{ a_val, b_val });
                if (b_val == 0.0) return Constant.Float(if (a_val >= 0) math.inf(f64) else -math.inf(f64));
                return Constant.Float(a_val / b_val);
            },
        },
    }
}
