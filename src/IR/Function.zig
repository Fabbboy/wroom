const std = @import("std");
const mem = std.mem;

const Instruction = @import("Instruction.zig").Instruction;
const Type = @import("Type.zig").Type;
const Linkage = @import("Linkage.zig").Linkage;

const VRegManager = @import("Instructions/VReg.zig").VRegManager;

const Module = @import("Module.zig");

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
        for (self.body.items) |instr| {
            instr.deinit();
        }

        self.body.deinit();
    }

    pub fn createInst(self: *FuncBlock, inst: Instruction) !void {
        try self.body.append(inst);
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:\n", .{self.name});
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
manager: VRegManager,

pub fn init(module: *Module, name: []const u8, return_ty: Type, linkage: Linkage, allocator: mem.Allocator) !*Func {
    const f = Func{
        .name = name,
        .return_ty = return_ty,
        .linkage = linkage,
        .blocks = std.ArrayList(FuncBlock).init(allocator),
        .allocator = allocator,
        .manager = VRegManager.init(),
    };

    return try module.addFunction(f);
}

pub fn deinit(self: *const Func) void {
    for (self.blocks.items) |block| {
        block.deinit();
    }
    self.blocks.deinit();
}

pub fn createBlock(self: *Func, name: []const u8) !*FuncBlock {
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
    try fbuf.writeAll("\n}\n");
}
