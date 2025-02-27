const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Instruction = @import("Instruction.zig").Instruction;

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
        try fbuf.print("{s} {s}", .{ self.type.fmt(), self.name });
    }
};

pub const FuncBlock = struct {
    name: []const u8,
    instructions: std.ArrayList(Instruction),

    pub fn init(name: []const u8, instructions: std.ArrayList(Instruction)) FuncBlock {
        return FuncBlock{
            .name = name,
            .instructions = instructions,
        };
    }

    pub fn deinit(self: *const FuncBlock) void {
        self.instructions.deinit();
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:\n", .{self.name});
        for (self.instructions.items) |instr| {
            try fbuf.writeAll("\t");
            try instr.fmt(fbuf);
            try fbuf.writeAll("\n");
        }
        try fbuf.writeAll("\n");
    }
};

const Self = @This();

ret_type: ValueType,
params: std.ArrayList(FuncParam),
blocks: std.ArrayList(FuncBlock),
allocator: mem.Allocator,
current_block: ?*const FuncBlock,

pub fn init(allocator: mem.Allocator, params: std.ArrayList(FuncParam), ret_type: ValueType) Self {
    return Self{
        .ret_type = ret_type,
        .params = params,
        .blocks = std.ArrayList(FuncBlock).init(allocator),
        .allocator = allocator,
        .current_block = null,
    };
}

pub fn deinit(self: *const Self) void {
    self.params.deinit();
    for (self.blocks.items) |block| {
        block.deinit();
    }

    self.blocks.deinit();
}

pub fn setInsertBlock(self: *Self, block: *const FuncBlock) void {
    self.current_block = block;
}

pub fn getCurrentBlock(self: *Self) *const FuncBlock {
    return self.current_block;
}

pub fn fmt(self: *const Self, fbuf: anytype, name: []const u8) !void {
    try fbuf.print("@{s}(", .{name});
    for (self.params.items, 0..) |param, i| {
        try param.fmt(fbuf);
        if (i + 1 != self.params.items.len) {
            try fbuf.writeAll(", ");
        }
    }

    try fbuf.print(") -> {s} {{\n", .{self.ret_type.fmt()});
    for (self.blocks.items) |block| {
        try block.fmt(fbuf);
    }
    try fbuf.writeAll("}\n");
}
