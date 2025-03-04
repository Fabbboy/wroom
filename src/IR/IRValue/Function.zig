const std = @import("std");
const mem = std.mem;

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Instruction = @import("../Instruction.zig").Instruction;

const IRStatus = @import("../Error.zig").IRStatus;

const Linkage = @import("../../AST/AssignStatement.zig").Linkage;

const Function = @This();

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
        try fbuf.print("{s} {s}", .{
            self.name,
            self.type.fmt(),
        });
    }
};

pub const FuncBlock = struct {
    name: []const u8,
    instructions: std.ArrayList(Instruction),
    parent: *Function,

    pub fn init(name: []const u8, instructions: std.ArrayList(Instruction), parent: *Function) FuncBlock {
        return FuncBlock{
            .name = name,
            .instructions = instructions,
            .parent = parent,
        };
    }

    pub fn deinit(self: *const FuncBlock) void {
        for (self.instructions.items) |instr| {
            instr.deinit();
        }
        self.instructions.deinit();
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:\n", .{self.name});
        for (self.instructions.items) |instr| {
            try fbuf.writeAll("\t");
            try instr.fmt(fbuf);
            try fbuf.writeAll("\n");
        }
    }

    pub fn getParent(self: *const FuncBlock) *const FuncBlock {
        return self.parent;
    }
};

const Self = @This();

ret_type: ValueType,
params: std.ArrayList(FuncParam),
blocks: std.ArrayList(FuncBlock),
allocator: mem.Allocator,
reg_id: usize,
linkage: Linkage,

pub fn init(allocator: mem.Allocator, params: std.ArrayList(FuncParam), ret_type: ValueType, linkage: Linkage) Self {
    return Self{
        .ret_type = ret_type,
        .params = params,
        .blocks = std.ArrayList(FuncBlock).init(allocator),
        .allocator = allocator,
        .reg_id = 0,
        .linkage = linkage,
    };
}

pub fn deinit(self: *const Self) void {
    self.params.deinit();
    for (self.blocks.items) |block| {
        block.deinit();
    }

    self.blocks.deinit();
}

pub fn getNextId(self: *Self) usize {
    const id = self.reg_id;
    self.reg_id += 1;
    return id;
}

pub fn fmt(self: *const Self, fbuf: anytype, name: []const u8) !void {
    switch (self.linkage) {
        .Public => try fbuf.writeAll("public "),
        .Internal => try fbuf.writeAll("internal "),
        .External => try fbuf.writeAll("external "),
    }
    try fbuf.print("@{s}(", .{name});
    for (self.params.items, 0..) |param, i| {
        try param.fmt(fbuf);
        if (i + 1 != self.params.items.len) {
            try fbuf.writeAll(", ");
        }
    }

    try fbuf.print(") -> {s}", .{self.ret_type.fmt()});

    if (self.linkage != .External) {
        try fbuf.writeAll(" {\n");
        for (self.blocks.items) |block| {
            try block.fmt(fbuf);
        }
        try fbuf.writeAll("}");
    }
}

pub fn addBlock(self: *Self, block: FuncBlock) IRStatus!*FuncBlock {
    try self.blocks.append(block);
    return &self.blocks.items[self.blocks.items.len - 1];
}
