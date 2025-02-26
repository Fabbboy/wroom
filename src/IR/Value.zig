const Constant = @import("Constant.zig");

pub const IRValue = union(enum) {
    Constant: Constant,
};
