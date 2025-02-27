const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

pub const FuncParam = struct {
    name: []const u8,
    type: ValueType,

    pub fn init(name: []const u8, ty: ValueType) FuncParam {
        return FuncParam{
            .name = name,
            .type = ty,
        };
    }

    pub fn fmt(self: *const FuncParam, fbuf: anytype) !void {
        try fbuf.writeAll("FuncParam{ name: ");
        try fbuf.print("{s}, type: {s}", .{ self.name, self.type.fmt() });
        try fbuf.writeAll(" }");
    }
};

const Self = @This();

ret_type: ValueType,
params: std.ArrayList(FuncParam),

pub fn init(params: std.ArrayList(FuncParam), ret_type: ValueType) Self {
    return Self{
        .ret_type = ret_type,
        .params = params,
    };
}

pub fn deinit(self: *const Self) void {
    self.params.deinit();
}

pub fn fmt(self: *const Self, fbuf: anytype, name: []const u8) !void {
    try fbuf.print("@{s}(", .{name});
    for (self.params.items, 0..) |param, i| {
        try fbuf.print("{s} {s}", .{ param.type.fmt(), param.name });
        if (i + 1 != self.params.items.len) {
            try fbuf.writeAll(", ");
        }
    }

    try fbuf.print(") -> {s} {{\n", .{self.ret_type.fmt()});
    try fbuf.writeAll("}\n");
}
