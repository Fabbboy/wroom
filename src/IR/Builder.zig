const std = @import("std");
const mem = std.mem;

const Module = @import("Module.zig");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Function = @import("IRValue/Function.zig");
const FuncBlock = Function.FuncBlock;
const FuncParam = Function.FuncParam;

const Constant = @import("IRValue/Constant.zig").IRConstant;
const LocationNs = @import("IRValue/Location.zig");
const Location = LocationNs.Location;
const LocalLocation = LocationNs.LocalLocation;
const GlobalLocation = LocationNs.GlobalLocation;

const IRStatus = @import("Error.zig").IRStatus;
const IRValue = @import("Value.zig").IRValue;

const GlobalVariable = @import("IRValue/GlobalVariable.zig");

const InstructionNs = @import("Instruction.zig");
const Instruction = InstructionNs.Instruction;
const AllocaInst = InstructionNs.AllocaInst;
const StoreInst = InstructionNs.StoreInst;
const LoadInst = InstructionNs.LoadInst;
const CallInst = InstructionNs.CallInst;

const AddInst = @import("Instruction/Binary.zig").AddInst;
const SubInst = @import("Instruction/Binary.zig").SubInst;
const MulInst = @import("Instruction/Binary.zig").MulInst;
const DivInst = @import("Instruction/Binary.zig").DivInst;

const Self = @This();

module: *Module,
allocator: mem.Allocator,
active_block: ?*FuncBlock,

pub fn init(allocator: mem.Allocator, module: *Module) Self {
    return Self{
        .module = module,
        .allocator = allocator,
        .active_block = null,
    };
}

pub fn createGlobal(self: *Self, name: []const u8, val_type: ValueType, initializer: Constant) IRStatus!void {
    var local_init = initializer;
    if (local_init.getType() != val_type) {
        switch (local_init) {
            Constant.Floating => |value| {
                if (val_type == ValueType.I32) {
                    local_init = Constant.Int(@as(i64, @intFromFloat(value)));
                }
            },
            Constant.Integer => |value| {
                if (val_type == ValueType.F32) {
                    local_init = Constant.Float(@as(f64, @floatFromInt(value)));
                }
            },
        }
    }

    const variable = GlobalVariable.init(
        self.module.getNextGlobalId(),
        local_init,
        val_type,
    );

    try self.module.globals.insert(name, variable);
    return;
}

pub fn createFunction(self: *Self, name: []const u8, arguments: std.ArrayList(FuncParam), ret_type: ValueType) IRStatus!*Function {
    const function = Function.init(
        self.module.allocator,
        arguments,
        ret_type,
    );

    try self.module.functions.insert(name, function);
    const res = self.module.functions.get(name);
    return res.?;
}

pub fn createBlock(self: *Self, name: []const u8, function: *Function) IRStatus!*FuncBlock {
    const instrs = std.ArrayList(Instruction).init(self.allocator);
    const block = FuncBlock.init(name, instrs, function);
    const b = function.addBlock(block) catch |e| {
        instrs.deinit();
        block.deinit();
        return e;
    };
    return b;
}

pub fn createAlloca(self: *Self, size: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_alloca(AllocaInst.init(id, size));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, size)));
}

pub fn createStore(self: *Self, assignee: IRValue, value: IRValue, ty: ValueType) IRStatus!void {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;

    const inst = Instruction.init_store(StoreInst.init(assignee, value, ty));
    try bb.instructions.append(inst);
}

pub fn createLoad(self: *Self, location: Location, ty: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const locVal = try IRValue.init_location(self.allocator, location);
    const inst = Instruction.init_load(LoadInst.init(id, locVal, ty));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty)));
}

pub fn createAdd(self: *Self, lhs: IRValue, rhs: IRValue, ty: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_add(AddInst.init(id, lhs, rhs, ty));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty)));
}

pub fn createSub(self: *Self, lhs: IRValue, rhs: IRValue, ty: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_sub(SubInst.init(id, lhs, rhs, ty));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty)));
}

pub fn createMul(self: *Self, lhs: IRValue, rhs: IRValue, ty: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_mul(MulInst.init(id, lhs, rhs, ty));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty)));
}

pub fn createDiv(self: *Self, lhs: IRValue, rhs: IRValue, ty: ValueType) IRStatus!IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_div(DivInst.init(id, lhs, rhs, ty));
    try bb.instructions.append(inst);
    return IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty)));
}

pub fn createReturn(self: *Self, value: IRValue) IRStatus!void {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;
    const inst = Instruction.init_return(value);
    try bb.instructions.append(inst);
}

pub fn createCall(self: *Self, function: []const u8, args: std.ArrayList(IRValue), ty: ValueType, noret: bool) IRStatus!?IRValue {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    if (noret) {
        const bb = self.active_block.?;
        const inst = Instruction.init_call(CallInst.init(0, function, args, noret));
        try bb.instructions.append(inst);
        return null;
    }

    const bb = self.active_block.?;
    const id = bb.parent.getNextId();

    const inst = Instruction.init_call(CallInst.init(id, function, args, noret));
    try bb.instructions.append(inst);
    return (try IRValue.init_location(self.allocator, Location.LocVar(LocalLocation.init(id, ty))));
}

pub fn setActiveBlock(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

pub fn getActiveBlock(self: *Self) *FuncBlock {
    return self.active_block;
}
