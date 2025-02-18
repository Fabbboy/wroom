pub const SemaStatus = error{
    NotGood,
    OutOfMemory,
};

pub const SemaError = union(enum) {
    pub fn fmt(self: *const SemaError, fbuf: anytype) !void {
        _ = self;
        _ = fbuf;
        return;
    }
};
