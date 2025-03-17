const IRValue = @import("IRValue.zig").IRValue;
const Type = @import("Type.zig").Type;
const Module = @import("Module.zig");
const Function = @import("Function.zig");
const FuncBlock = Function.FuncBlock;

const AllocaInst = @import("Instructions/AllocaInst.zig");
const VReg = @import("Instructions/VReg.zig");

const Instruction = @import("Instruction.zig").Instruction;

const Self = @This();

mod: *Module,
active_block: ?*FuncBlock,

pub fn init(mod: *Module) Self {
    return Self{
        .mod = mod,
        .active_block = null,
    };
}

pub fn setInsert(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

fn getActiveParent(self: *Self) ?*Function {
    return self.active_block.?.parent;
}

pub fn createAlloca(self: *Self, ty: Type) IRValue {
    if (self.active_block == null) {
        unreachable;
    }

    const par = self.getActiveParent();
    const vreg = par.?.manager.getNext();

    const alloca = AllocaInst.init(ty, vreg);
    return IRValue.init_instruction(Instruction.init_alloca(alloca));
}
