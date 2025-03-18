const std = @import("std");
const mem = std.mem;

const IRStatus = @import("Error.zig").IRStatus;

const AllocaInst = @import("Instructions/AllocaInst.zig");
const StoreInst = @import("Instructions/StoreInst.zig");

const VReg = @import("Instructions/VReg.zig");

pub const Instruction = union(enum) {
    Alloca: AllocaInst,
    Store: StoreInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return Instruction{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) Instruction {
        return Instruction{ .Store = store };
    }

    pub fn deinit(self: *Instruction) void {
        switch (self.*) {
            .Store => self.Store.deinit(),
            else => {},
        }
    }

    pub fn fmt(self: *const Instruction, fbuf: anytype) !void {
        switch (self.*) {
            .Alloca => try self.Alloca.fmt(fbuf),
            .Store => try self.Store.fmt(fbuf),
        }
    }

    pub fn get_reg(self: *const Instruction) ?*const VReg {
        switch (self.*) {
            .Alloca => return self.Alloca.get_reg(),
            .Store => return null,
        }
    }

    pub fn set_parent(self: *Instruction, parent: ?*const InstructionNode) void {
        switch (self.*) {
            .Alloca => self.Alloca.set_parent(parent),
            .Store => self.Store.set_parent(parent),
        }
    }

    pub fn get_parent(self: *const Instruction) ?*const InstructionNode {
        switch (self.*) {
            .Alloca => return self.Alloca.get_parent(),
            .Store => return self.Store.get_parent(),
        }
    }
};

pub const InstructionNode = struct {
    inst: Instruction,
    next: ?*InstructionNode,
    prev: ?*InstructionNode,
    allocator: mem.Allocator,

    pub fn init(inst: Instruction, next: ?*InstructionNode, prev: ?*InstructionNode, allocator: mem.Allocator) !*InstructionNode {
        const node = try allocator.create(InstructionNode);

        var inst_copy = inst;
        inst_copy.set_parent(node);
        node.inst = inst_copy;
        node.next = next;
        node.prev = prev;
        node.allocator = allocator;
        return node;
    }

    pub fn getInst(self: *const InstructionNode) *const Instruction {
        return &self.inst;
    }

    pub fn deinit(self: *InstructionNode) void {
        self.inst.deinit();
        if (self.next) |n| {
            n.deinit();
        }
        self.allocator.destroy(self);
    }
};
