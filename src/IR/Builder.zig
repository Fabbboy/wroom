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

pub fn createBlock(self: *Self, name: []const u8, parent: *Function) !*FuncBlock {
    const block = FuncBlock.init(self.mod.allocator, name, parent);
    try parent.blocks.append(block);
    return &parent.blocks.items[parent.blocks.items.len - 1];
}
