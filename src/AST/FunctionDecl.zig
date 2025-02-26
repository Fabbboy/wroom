const std = @import("std");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const Position = @import("../Parser/Position.zig");

const ParameterExpr = @import("ParameterExpr.zig");

const Self = @This();

name: Token,
position: Position,
ret_type: ValueType,
params: std.ArrayList(ParameterExpr),

pub fn init(name: Token, ret_type: ValueType, params: std.ArrayList(ParameterExpr), position: Position) Self {
    return Self{
        .name = name,
        .ret_type = ret_type,
        .position = position,
        .params = params,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("FunctionDecl{{ name: ");
    try self.name.fmt(fbuf);
    try fbuf.print(", ret_type: {s}, params: [", .{self.ret_type.fmt()});
    for (self.params.items) |param| {
        try param.fmt(fbuf);
        try fbuf.writeAll(", ");
    }
    try fbuf.writeAll("] }}");
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

pub fn deinit(self: *const Self) void {
    self.params.deinit();
}
