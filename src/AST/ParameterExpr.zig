const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Position = @import("../Parser/Position.zig");

const Self = @This();

ident: Token,
pos: Position,
type: ValueType,

pub fn init(ident: Token, _pos: Position, ty: ValueType) Self {
    return Self{
        .ident = ident,
        .pos = _pos,
        .type = ty,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("ParameterExpr{ ident: ");
    try self.ident.fmt(fbuf);
    try fbuf.writeAll(", type: ");
    try fbuf.print("{s}", .{self.type.fmt()});
    try fbuf.writeAll(" }");
}

pub fn start(self: *const Self) usize {
    return self.pos.start;
}

pub fn stop(self: *const Self) usize {
    return self.pos.end;
}

pub fn pos(self: *const Self) Position {
    return self.pos;
}

