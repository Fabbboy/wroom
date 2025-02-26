const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const IRValue = @import("Value.zig").IRValue;

const Self = @This();

initializer: IRValue,
val_type: ValueType,

pub fn init(initializer: IRValue, val_type: ValueType) Self {
    return Self{
        .initializer = initializer,
        .val_type = val_type,
    };
}
