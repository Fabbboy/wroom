const std = @import("std");
const zfmt = std.fmt;

const IRStatus = @import("../Error.zig").IRStatus;

const TypeNs = @import("../Type.zig");
const Type = TypeNs.Type;
const IntegerTy = TypeNs.IntegerTy;
const FloatTy = TypeNs.FloatTy;

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
                return .init_int_value(try IntValue.int_from(val, ty.Integer));
            },
            Type.Float => {
                return .init_float_value(try FloatValue.float_from(val, ty.Float));
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

    pub fn int_from(val: []const u8, ty: IntegerTy) !IntValue {
        switch (ty) {
            IntegerTy.I32 => {
                const value = zfmt.parseInt(i32, val, 10) catch {
                    return error.FailedToParseNumeric;
                };
                return IntValue.init_i32(value);
            },
        }
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

    pub fn float_from(val: []const u8, ty: FloatTy) !FloatValue {
        switch (ty) {
            FloatTy.F32 => {
                const value = zfmt.parseFloat(f32, val) catch {
                    return error.FailedToParseNumeric;
                };
                return FloatValue.init_f32(value);
            },
        }
    }

    pub fn fmt(self: *const FloatValue, fbuf: anytype) !void {
        switch (self.*) {
            FloatValue.F32 => {
                try fbuf.print("{}", .{self.F32});
            },
        }
    }
};
