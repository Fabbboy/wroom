const Module = @import("Module.zig");

const Function = @import("Object/Function.zig");
const FuncBlock = Function.FuncBlock;

const Self = @This();

module: *Module,
active_block: ?*FuncBlock,

pub fn init(module: *Module) Self {
    return Self{
        .module = module,
        .active_block = null,
    };
}

pub fn setActiveBlock(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

pub fn getActiveBlock(self: *Self) *FuncBlock {
    return self.active_block;
}