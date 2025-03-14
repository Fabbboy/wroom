const Module = @import("Module.zig");
const Function = @import("Function.zig");
const FuncBlock = Function.FuncBlock;

const Self = @This();

mod: *Module,
active_block: ?*FuncBlock,

pub fn init(mod: *Module) Self {
    return Self{ .mod = mod, .active_block = null };
}

pub fn setInsert(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}
