const std = @import("std");
const mem = std.mem;

const IRValue = @import("IRValue.zig").IRValue;
const Type = @import("Type.zig").Type;
const Module = @import("Module.zig");
const Function = @import("Function.zig");
const FuncBlock = Function.FuncBlock;

const IRStatus = @import("Error.zig").IRStatus;

const VReg = @import("Instructions/VReg.zig");

const Instruction = @import("Instruction.zig").Instruction;
const AllocaInst = @import("Instructions/AllocaInst.zig");
const StoreInst = @import("Instructions/StoreInst.zig");

const BinaryInst = @import("Instructions/BinaryInst.zig");
const AddInst = BinaryInst.AddInst;

const Self = @This();

mod: *Module,
active_block: ?*FuncBlock,
active_func: ?*Function,
allocator: mem.Allocator,

pub fn init(mod: *Module, allocator: mem.Allocator) Self {
    return Self{
        .mod = mod,
        .active_block = null,
        .active_func = null,
        .allocator = allocator,
    };
}

pub fn setInsert(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
    self.active_func = block.parent;
}

pub fn createAlloca(self: *Self, ty: Type) !IRValue {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    if (self.active_func == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;
    const par = self.active_func.?;

    const vreg = par.manager.getNext();

    const alloca = AllocaInst.init(ty, vreg);
    const alloca_inst = Instruction.init_alloca(
        alloca,
    );

    return IRValue.init_instruction(try block.insert(alloca_inst));
}

pub fn createStore(self: *Self, dest: *const Instruction, src: IRValue) IRStatus!void {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;

    const store = StoreInst.init(dest, src);
    const store_inst = Instruction.init_store(
        store,
    );

    _ = try block.insert(store_inst);
}

pub fn createAdd(self: *Self, lhs: IRValue, rhs: IRValue) IRStatus!IRValue {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;

    const vreg = self.active_func.?.manager.getNext();

    const add = AddInst.init(vreg, lhs, rhs);
    const add_inst = Instruction.init_add(add);

    return IRValue.init_instruction(try block.insert(add_inst));
}

pub fn createSub(self: *Self, lhs: IRValue, rhs: IRValue) IRStatus!IRValue {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;

    const vreg = self.active_func.?.manager.getNext();

    const sub = BinaryInst.SubInst.init(vreg, lhs, rhs);
    const sub_inst = Instruction.init_sub(sub);

    return IRValue.init_instruction(try block.insert(sub_inst));
}

pub fn createMul(self: *Self, lhs: IRValue, rhs: IRValue) IRStatus!IRValue {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;

    const vreg = self.active_func.?.manager.getNext();

    const mul = BinaryInst.MulInst.init(vreg, lhs, rhs);
    const mul_inst = Instruction.init_mul(mul);

    return IRValue.init_instruction(try block.insert(mul_inst));
}

pub fn createDiv(self: *Self, lhs: IRValue, rhs: IRValue) IRStatus!IRValue {
    if (self.active_block == null) {
        return error.NoActiveContext;
    }

    const block = self.active_block.?;

    const vreg = self.active_func.?.manager.getNext();

    const div = BinaryInst.DivInst.init(vreg, lhs, rhs);
    const div_inst = Instruction.init_div(div);

    return IRValue.init_instruction(try block.insert(div_inst));
}