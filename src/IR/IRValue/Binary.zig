const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();
const IRValue = @import("../Value.zig").IRValue;

lhs: IRValue,
rhs: IRValue,
op: Token.OperatorType,

pub fn init(lhs: IRValue, rhs: IRValue, op: Token.OperatorType) Self {
    return Self{
        .lhs = lhs,
        .rhs = rhs,
        .op = op,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    try self.lhs.fmt(fbuf);
    try fbuf.print(" {s} ", .{self.op.fmt()});
    try self.rhs.fmt(fbuf);
}
