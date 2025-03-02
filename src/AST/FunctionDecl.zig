const std = @import("std");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;
const Position = @import("../Parser/Position.zig");

const ParameterExpr = @import("ParameterExpr.zig");

const Block = @import("Block.zig");

const Self = @This();

name: Token,
position: Position,
ret_type: ValueType,
params: std.ArrayList(ParameterExpr),
body: ?Block,

pub fn init(name: Token, ret_type: ValueType, params: std.ArrayList(ParameterExpr), block: ?Block, position: Position) Self {
    return Self{
        .name = name,
        .ret_type = ret_type,
        .position = position,
        .params = params,
        .body = block,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.writeAll("FunctionDecl{ name: ");
    try self.name.fmt(fbuf);
    try fbuf.writeAll(", ret_type: ");
    try fbuf.print("{s}", .{self.ret_type.fmt()});
    try fbuf.writeAll(", params: [");
    for (self.params.items) |param| {
        try param.fmt(fbuf);
        try fbuf.writeAll(", ");
    }
    if (self.body) |block| {
        try fbuf.writeAll("], block: ");
        try block.fmt(fbuf);
        try fbuf.writeAll(" }");
    } else {
        try fbuf.writeAll("], block: null }");
    }
}

pub fn getName(self: *const Self) *const Token {
    return &self.name;
}

pub fn getParams(self: *const Self) *const []ParameterExpr {
    return &self.params.items;
}

pub fn getReturnType(self: *const Self) ValueType {
    return self.ret_type;
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
    if (self.body) |block| {
        block.deinit();
    }
}

pub fn getBody(self: *const Self) ?*const Block {
    return self.body;
}
