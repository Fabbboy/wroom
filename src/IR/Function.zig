const std = @import("std");
const mem = std.mem;

const Instruction = @import("Instruction.zig").Instruction;
const Type = @import("Type.zig").Type;
const Linkage = @import("Linkage.zig").Linkage;

pub const FuncBlock = struct {
    name: []const u8,
    body: std.ArrayList(Instruction),
    parent: *Func,

    pub fn init(allocator: mem.Allocator, name: []const u8, parent: *Func) FuncBlock {
        return FuncBlock{
            .name = name,
            .body = std.ArrayList(Instruction).init(allocator),
            .parent = parent,
        };
    }

    pub fn deinit(self: *const FuncBlock) void {
        self.body.deinit();
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:", .{self.name});
        for (self.body.items) |instr| {
            try fbuf.writeAll("\t");
            try instr.fmt(fbuf);
            try fbuf.writeAll("\n");
        }
    }
};

const Func = @This();

name: []const u8,
return_ty: Type,
linkage: Linkage,
blocks: std.ArrayList(FuncBlock),
allocator: mem.Allocator,

pub fn init(name: []const u8, return_ty: Type, linkage: Linkage, allocator: mem.Allocator) Func {
    return Func{
        .name = name,
        .return_ty = return_ty,
        .linkage = linkage,
        .blocks = std.ArrayList(FuncBlock).init(allocator),
        .allocator = allocator,
    };
}

pub fn deinit(self: *const Func) void {
    std.debug.print("Deinit function {s}:{}\n", .{ self.name, self.blocks.items.len });
    for (self.blocks.items) |block| {
        block.deinit();
    }
    self.blocks.deinit();
}

pub fn addBlock(self: *Func, name: []const u8) !*FuncBlock {
    std.debug.print("Add block {s}\n", .{name});
    const block = FuncBlock.init(self.allocator, name, self);
    try self.blocks.append(block);
    return &self.blocks.items[self.blocks.items.len - 1];
}

pub fn fmt(self: *const Func, fbuf: anytype) !void {
    try fbuf.print("{s} {s} @{s}", .{
        self.return_ty.fmt(),
        self.linkage.fmt(),
        self.name,
    });
    try fbuf.writeAll("(");
    try fbuf.writeAll(")");
    try fbuf.writeAll(" {\n");
    for (self.blocks.items) |block| {
        try block.fmt(fbuf);
    }
    try fbuf.writeAll("}\n");
}
