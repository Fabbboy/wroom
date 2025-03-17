const std = @import("std");
const mem = std.mem;

const Instruction = @import("Instruction.zig").Instruction;
const Type = @import("Type.zig").Type;
const Linkage = @import("Linkage.zig").Linkage;

const VRegManager = @import("Instructions/VReg.zig").VRegManager;

const Module = @import("Module.zig");

pub const FuncBlock = struct {
    name: []const u8,
    head: ?*Instruction = null,
    tail: ?*Instruction = null,
    parent: *Func,

    pub fn init(name: []const u8, parent: *Func) FuncBlock {
        return FuncBlock{
            .name = name,
            .head = null,
            .tail = null,
            .parent = parent,
        };
    }

    pub fn deinit(self: *FuncBlock) void {
        var instr = self.head;
        while (instr) |current| {
            const next = current.next;
            current.deinit();
            instr = next;
        }
        self.head = null;
        self.tail = null;
    }

    pub fn insert(self: *FuncBlock, instr: *Instruction) !*Instruction {
        instr.prev = self.tail;
        instr.next = null;

        if (self.tail) |last| {
            last.next = instr;
        } else {
            self.head = instr;
        }

        self.tail = instr;
        return instr;
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:\n", .{self.name});
        var instr = self.head;
        while (instr) |i| {
            try fbuf.writeAll("\t");
            try i.fmt(fbuf);
            try fbuf.writeAll("\n");
            instr = i.next;
        }
        try fbuf.writeAll("\n");
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

pub fn deinit(self: *Func) void {
    for (self.blocks.items) |*block| {
        block.deinit();
    }
    self.blocks.deinit();
}

pub fn createBlock(self: *Func, name: []const u8) !*FuncBlock {
    const block = FuncBlock.init(name, self);
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
