const Constant = @import("Constant.zig").Constant;

pub const IRValue = union(enum) {
    Constant: Constant,

    pub fn init_constant(value: Constant) IRValue {
        return IRValue{
            .Constant = value,
        };
    }
};
