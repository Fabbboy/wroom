const IRValue = @import("Value.zig").IRValue;

const Self = @This();

initializer: IRValue,

pub fn init(initializer: IRValue) Self {
    return Self{
        .initializer = initializer,
    };
}

