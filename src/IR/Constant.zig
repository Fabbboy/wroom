const Self = @This();

pub const Constant = union(enum) {
    Integer: i64,
    Floating: f64,

    pub fn Int(value: i64) Constant {
        return .{
            .Integer = value,
        };
    }

    pub fn Float(value: f64) Constant {
        return .{
            .Floating = value,
        };
    }
};
