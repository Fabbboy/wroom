const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Self = @This();

target: usize,
ty: ValueType,

pub fn init(target: usize, ty: ValueType) Self {
    return Self{
        .target = target,
        .ty = ty,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} %{}", .{ self.ty.fmt(), self.target });
}
