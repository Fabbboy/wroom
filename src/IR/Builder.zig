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
    const block = self.active_block.?;

    const par = self.getActiveParent();
    const vreg = par.?.manager.getNext();

    const alloca = AllocaInst.init(ty, vreg);
    const alloca_inst = try block.insert(
        try Instruction.init_alloca(
            self.allocator,
            alloca,
        ),
    );

    return IRValue.init_instruction(alloca_inst);
}

pub fn createStore(self: *Self, dest: *const Instruction, src: IRValue) !IRValue {
    if (self.active_block == null) {
        unreachable;
    }

    const block = self.active_block.?;

    const store = StoreInst.init(dest, src);
    const store_inst = try block.insert(
        try Instruction.init_store(
            self.allocator,
            store,
        ),
    );

    return IRValue.init_instruction(store_inst);
}
