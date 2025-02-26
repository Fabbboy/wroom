const Constant = @import("Constant.zig").Constant;

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
            Constant.Integer => {
                @panic("Division can not result in integer");
            },
            Constant.Floating => |b_val| {
                if (b_val == 0.0) @panic("Division by zero");
                return Constant.Float(@as(f64, @floatFromInt(a_val)) / b_val);
            },
        },
        Constant.Floating => |a_val| switch (b) {
            Constant.Integer => |b_val| {
                if (b_val == 0) @panic("Division by zero");
                return Constant.Float(a_val / @as(f64, @floatFromInt(b_val)));
            },
            Constant.Floating => |b_val| {
                if (b_val == 0.0) @panic("Division by zero");
                return Constant.Float(a_val / b_val);
            },
        },
    }
}
