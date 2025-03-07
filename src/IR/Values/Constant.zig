const std = @import("std");
const zfmt = std.fmt;

const TypeNs = @import("../Type.zig");
const Type = TypeNs.Type;
const IntegerTy = TypeNs.IntegerTy;

pub const Constant = union(enum) {
    IntValue: IntValue,

    pub fn init_int_value(value: IntValue) Constant {
        return Constant{
            .IntValue = value,
        };
    }

    pub fn fmt(self: *const Constant, fbuf: anytype) !void {
        switch (self.*) {
            Constant.IntValue => {
                try self.IntValue.fmt(fbuf);
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

    pub fn from(ty: Type, value: []const u8) !IntValue {
        switch (ty) {
            Type.Integer => {
                const ity = ty.Integer;
                switch (ity) {
                    IntegerTy.I32 => {
                        const raw_val: i32 = zfmt.parseInt(i32, value, 10) catch unreachable;
                        return IntValue.init_i32(raw_val);
                    },
                }
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
