const Constant = @import("Values/Constant.zig").Constant;

pub const IRValue = union(enum) {
    Constant: Constant,

    pub fn init_constant(val: Constant) IRValue {
        return IRValue{
            .Constant = val,
        };
    }

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        switch (self.*) {
            IRValue.Constant => {
                try self.Constant.fmt(fbuf);
            },
        }
    }
};
