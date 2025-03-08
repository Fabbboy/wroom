const std = @import("std");
const ParseIntError = std.fmt.ParseIntError;

pub const IRStatus = error{
    OutOfMemory,
    NotGood,
} || ParseIntError;
