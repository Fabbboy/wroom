const Self = @This();

pub const Constant = union(enum) {
    Int: i64,
    Float: f64,
};
