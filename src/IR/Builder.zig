const std = @import("std");
const mem = std.mem;

const IRValue = @import("IRValue.zig").IRValue;
const Type = @import("Type.zig").Type;
const Module = @import("Module.zig");
const Function = @import("Function.zig");
const FuncBlock = Function.FuncBlock;

const VReg = @import("Instructions/VReg.zig");

const Instruction = @import("Instruction.zig").Instruction;
const AllocaInst = @import("Instructions/AllocaInst.zig");
const StoreInst = @import("Instructions/StoreInst.zig");

const Self = @This();

mod: *Module,
active_block: ?*FuncBlock,
allocator: mem.Allocator,

pub fn init(mod: *Module, allocator: mem.Allocator) Self {
    return Self{
        .mod = mod,
        .active_block = null,
        .allocator = allocator,
    };
}

pub fn setInsert(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

fn getActiveParent(self: *Self) ?*Function {
    return self.active_block.?.parent;
}

pub fn createAlloca(self: *Self, ty: Type) !IRValue {
    if (self.active_block == null) {
        unreachable;
    }

    const par = self.getActiveParent();
    const vreg = par.?.manager.getNext();

    const alloca = AllocaInst.init(ty, vreg);
    const inst_id = self.active_block.?.getNextInstId();
    return IRValue.init_instruction(try Instruction.init_alloca(inst_id, self.allocator, alloca));
}

pub fn createStore(self: *Self, dest: Instruction, src: IRValue) !IRValue {
    if (self.active_block == null) {
        unreachable;
    }

    const store = StoreInst.init(dest, src);
    const inst_id = self.active_block.?.getNextInstId();
    return IRValue.init_instruction(try Instruction.init_store(inst_id, self.allocator, store));
}
