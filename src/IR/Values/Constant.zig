const std = @import("std");
const zfmt = std.fmt;

const IRStatus = @import("../Error.zig").IRStatus;

const TypeNs = @import("../Type.zig");
const Type = TypeNs.Type;
const IntegerTy = TypeNs.IntegerTy;

pub const Constant = union(enum) {
    IntValue: IntValue,
    FloatValue: FloatValue,

    pub fn init_int_value(value: IntValue) Constant {
        return Constant{
            .IntValue = value,
        };
    }

    pub fn init_float_value(value: FloatValue) Constant {
        return Constant{
            .FloatValue = value,
        };
    }

    pub fn init_from(val: []const u8, ty: Type) IRStatus!Constant {
        switch (ty) {
            Type.Integer => {
                const value = zfmt.parseInt(i32, val, 10) catch {
                    return error.FailedToParseNumeric;
                };
                return Constant.init_int_value(IntValue.init_i32(value));
            },
            Type.Float => {
                const value = zfmt.parseFloat(f32, val) catch {
                    return error.FailedToParseNumeric;
                };
                return Constant.init_float_value(FloatValue.init_f32(value));
            },
        }
    }

    pub fn fmt(self: *const Constant, fbuf: anytype) !void {
        switch (self.*) {
            Constant.IntValue => {
                try self.IntValue.fmt(fbuf);
            },
            Constant.FloatValue => {
                try self.FloatValue.fmt(fbuf);
            },
        }
    }
};

pub const IntValue = union(enum) {
    I32: i32,

    pub fn init_i32(value: i32) IntValue {
        return IntValue{
            .I32 = value,
        };
    }

    pub fn fmt(self: *const IntValue, fbuf: anytype) !void {
        switch (self.*) {
            IntValue.I32 => {
                try fbuf.print("{}", .{self.I32});
            },
        }
    }
};

pub const FloatValue = union(enum) {
    F32: f32,

    pub fn init_f32(value: f32) FloatValue {
        return FloatValue{
            .F32 = value,
        };
    }

    pub fn fmt(self: *const FloatValue, fbuf: anytype) !void {
        switch (self.*) {
            FloatValue.F32 => {
                try fbuf.print("{}", .{self.F32});
            },
        }
    }
};
