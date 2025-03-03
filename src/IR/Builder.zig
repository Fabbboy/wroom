const std = @import("std");
const mem = std.mem;

const Module = @import("Module.zig");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Function = @import("IRValue/Function.zig");
const FuncBlock = Function.FuncBlock;
const FuncParam = Function.FuncParam;

const Constant = @import("IRValue/Constant.zig").IRConstant;
const Location = @import("IRValue/Location.zig");
const LocationStorage = Location.LocationStorage;

const IRStatus = @import("Error.zig").IRStatus;
const IRValue = @import("Value.zig").IRValue;

const GlobalVariable = @import("IRValue/GlobalVariable.zig");

const InstructionNs = @import("Instruction.zig");
const Instruction = InstructionNs.Instruction;
const AllocaInst = InstructionNs.AllocaInst;
const StoreInst = InstructionNs.StoreInst;
const LoadInst = InstructionNs.LoadInst;

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
                if (val_type == ValueType.Int) {
                    local_init = Constant.Int(@as(i64, @intFromFloat(value)));
                }
            },
            Constant.Integer => |value| {
                if (val_type == ValueType.Float) {
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
    return IRValue.init_location(self.allocator, Location.init(LocationStorage.LocVar(id), size));
}

pub fn createStore(self: *Self, target: IRValue, value: IRValue, ty: ValueType) IRStatus!void {
    if (self.active_block == null) {
        return IRStatus.NotGood;
    }

    const bb = self.active_block.?;

    const inst = Instruction.init_store(StoreInst.init(target, value, ty));
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
    return IRValue.init_location(self.allocator, Location.init(LocationStorage.LocVar(id), ty));
}

pub fn setActiveBlock(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

pub fn getActiveBlock(self: *Self) *FuncBlock {
    return self.active_block;
}
