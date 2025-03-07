pub const CompileStatus = error{
    NotGood,
    OutOfMemory,
};

pub const CompilerError = union(enum) {
    pub fn fmt(self: *const CompilerError, fbuf: anytype) CompileStatus!void {
        _ = self;
        _ = fbuf;
        return;
    }
};
