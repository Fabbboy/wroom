const IRStatus = @import("../IR/Error.zig").IRStatus;

pub const CompileStatus = error{
    NotGood,
    OutOfMemory,
} || IRStatus;

pub const CompilerError = union(enum) {
    pub fn fmt(self: *const CompilerError, fbuf: anytype) CompileStatus!void {
        _ = self;
        _ = fbuf;
        return;
    }
};
