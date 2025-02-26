const Constant = @import("Constant.zig").Constant;

pub const IRValue = union(enum) {
    constant: Constant,

    pub fn init_constant(value: Constant) IRValue {
        return IRValue{
            .constant = value,
        };
    }
};
