const std = @import("std");
const mem = std.mem;

const IRStatus = @import("Error.zig").IRStatus;

const AllocaInst = @import("Instructions/AllocaInst.zig");
const StoreInst = @import("Instructions/StoreInst.zig");

const BinaryInst = @import("Instructions/BinaryInst.zig");
const AddInst = BinaryInst.AddInst;
const SubInst = BinaryInst.SubInst;
const MulInst = BinaryInst.MulInst;
const DivInst = BinaryInst.DivInst;

const LoadInst = @import("Instructions/LoadInst.zig");

const VReg = @import("Instructions/VReg.zig").VReg;

pub const Instruction = union(enum) {
    Alloca: AllocaInst,
    Store: StoreInst,
    Add: AddInst,
    Sub: SubInst,
    Mul: MulInst,
    Div: DivInst,
    Load: LoadInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return Instruction{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) Instruction {
        return Instruction{ .Store = store };
    }

    pub fn init_add(add: AddInst) Instruction {
        return Instruction{ .Add = add };
    }

    pub fn init_sub(sub: SubInst) Instruction {
        return Instruction{ .Sub = sub };
    }

    pub fn init_mul(mul: MulInst) Instruction {
        return Instruction{ .Mul = mul };
    }

    pub fn init_div(div: DivInst) Instruction {
        return Instruction{ .Div = div };
    }

    pub fn init_load(load: LoadInst) Instruction {
        return Instruction{ .Load = load };
    }

    pub fn deinit(self: *Instruction) void {
        switch (self.*) {
            .Store => self.Store.deinit(),
            .Add => self.Add.deinit(),
            .Sub => self.Sub.deinit(),
            .Mul => self.Mul.deinit(),
            .Div => self.Div.deinit(),
            else => {},
        }
    }

    pub fn fmt(self: *const Instruction, fbuf: anytype) !void {
        switch (self.*) {
            .Alloca => try self.Alloca.fmt(fbuf),
            .Store => try self.Store.fmt(fbuf),
            .Add => try self.Add.fmt(fbuf),
            .Sub => try self.Sub.fmt(fbuf),
            .Mul => try self.Mul.fmt(fbuf),
            .Div => try self.Div.fmt(fbuf),
            .Load => try self.Load.fmt(fbuf),
        }
    }

    pub fn get_reg(self: *const Instruction) ?*const VReg {
        switch (self.*) {
            .Alloca => return self.Alloca.get_reg(),
            .Add => return self.Add.get_reg(),
            .Sub => return self.Sub.get_reg(),
            .Mul => return self.Mul.get_reg(),
            .Div => return self.Div.get_reg(),
            .Load => return self.Load.get_reg(),
            else => return null,
        }
    }

    pub fn set_parent(self: *Instruction, parent: ?*const InstructionNode) void {
        switch (self.*) {
            .Alloca => self.Alloca.set_parent(parent),
            .Store => self.Store.set_parent(parent),
            .Add => self.Add.set_parent(parent),
            .Sub => self.Sub.set_parent(parent),
            .Mul => self.Mul.set_parent(parent),
            .Div => self.Div.set_parent(parent),
            .Load => self.Load.set_parent(parent),
        }
    }

    pub fn get_parent(self: *const Instruction) ?*const InstructionNode {
        switch (self.*) {
            .Alloca => return self.Alloca.get_parent(),
            .Store => return self.Store.get_parent(),
            .Add => return self.Add.get_parent(),
            .Sub => return self.Sub.get_parent(),
            .Mul => return self.Mul.get_parent(),
            .Div => return self.Div.get_parent(),
            .Load => return self.Load.get_parent(),
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
