const std = @import("std");
const ParseIntError = std.fmt.ParseIntError;

pub const CompileStatus = error{
    NotGood,
    OutOfMemory,
} || ParseIntError;

pub const CompilerError = union(enum) {
    pub fn fmt(self: *const CompilerError, fbuf: anytype) CompileStatus!void {
        _ = self;
        _ = fbuf;
        return;
    }
};
