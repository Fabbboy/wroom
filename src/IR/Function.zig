const std = @import("std");
const mem = std.mem;

const Instruction = @import("Instruction.zig").Instruction;
const Type = @import("Type.zig").Type;
const Linkage = @import("Linkage.zig").Linkage;

pub const FuncBlock = struct {
    name: []const u8,
    body: std.ArrayList(Instruction),

    pub fn init(allocator: mem.Allocator, name: []const u8) FuncBlock {
        return FuncBlock{
            .name = name,
            .body = std.ArrayList(Instruction).init(allocator),
        };
    }

    pub fn deinit(self: *FuncBlock) void {
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

pub fn init(name: []const u8, return_ty: Type, linkage: Linkage, blocks: std.ArrayList(FuncBlock)) Func {
    return Func{
        .name = name,
        .return_ty = return_ty,
        .linkage = linkage,
        .blocks = blocks,
    };
}

pub fn deinit(self: *Func) void {
    self.blocks.deinit();
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
