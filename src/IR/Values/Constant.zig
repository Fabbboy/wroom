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

    pub fn fmt(self: *const IntValue, fbuf: anytype) !void {
        switch (self.*) {
            IntValue.I32 => {
                try fbuf.print("{}", .{self.I32});
            },
        }
    }
};
