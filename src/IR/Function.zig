const std = @import("std");
const mem = std.mem;

const InstructionNs = @import("Instruction.zig");
const Instruction = InstructionNs.Instruction;
const InstructionNode = InstructionNs.InstructionNode;

const Type = @import("Type.zig").Type;
const Linkage = @import("Linkage.zig").Linkage;

const VRegManager = @import("Instructions/VReg.zig").VRegManager;

const Module = @import("Module.zig");

pub const FuncBlock = struct {
    name: []const u8,
    head: ?*InstructionNode = null,
    tail: ?*InstructionNode = null,
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
        instr.?.deinit();
    }

    pub fn insert(self: *FuncBlock, instr: Instruction) !*Instruction {
        const node = try InstructionNode.init(
            instr,
            null,
            self.tail,
            self.parent.allocator,
        );

        if (self.tail) |t| {
            t.*.next = node;
        }

        self.tail = node;
        if (self.head == null) {
            self.head = node;
        }
        return &node.inst;
    }

    pub fn fmt(self: *const FuncBlock, fbuf: anytype) !void {
        try fbuf.print("{s}:\n", .{self.name});
        var instr = self.head;
        while (instr) |i| {
            try fbuf.writeAll("    ");
            try i.getInst().fmt(fbuf);
            try fbuf.writeAll("\n");
            instr = i.next;
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
