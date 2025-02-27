const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Position = @import("../Parser/Position.zig");

const Self = @This();

ident: Token,
position: Position,
type: ValueType,

pub fn init(ident: Token, _pos: Position, ty: ValueType) Self {
    return Self{
        .ident = ident,
        .position = _pos,
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

pub fn getType(self: *const Self) ValueType {
    return self.type;
}

pub fn getName(self: *const Self) *const Token {
    return &self.ident;
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
