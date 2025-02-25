const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const Position = @import("../Parser/Position.zig");

const Self = @This();

name: Token,
position: Position,
ret_type: ValueType,

pub fn init(name: Token, ret_type: ValueType, position: Position) Self {
    return Self{ .name = name, .ret_type = ret_type, .position = position };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("FunctionDecl{{ name: ");
    try self.name.fmt(fbuf);
    try fbuf.print(", ret_type: {s}", .{self.ret_type.fmt()});
    try fbuf.writeAll(" }}");
}

pub fn start(self: *const Self) usize {
    return self.position.start;
}

pub fn stop(self: *const Self) usize {
    return self.position.end;
}

pub fn pos(self: *const Self) Position {
    return self.position;
}
