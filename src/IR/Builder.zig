const Module = @import("Module.zig");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Function = @import("IRValue/Function.zig");
const FuncBlock = Function.FuncBlock;

const Constant = @import("IRValue/Constant.zig").IRConstant;

const IRStatus = @import("Error.zig").IRStatus;
const IRValue = @import("Value.zig").IRValue;

const GlobalVariable = @import("IRValue/GlobalVariable.zig");

const Self = @This();

module: *Module,
active_block: ?*FuncBlock,

pub fn init(module: *Module) Self {
    return Self{
        .module = module,
        .active_block = null,
    };
}

pub fn createGlobal(self: *Self, name: []const u8, val_type: ValueType, initializer: Constant) IRStatus!IRValue {
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
        local_init,
        val_type,
    );

    try self.module.globals.insert(name, variable);

    return try IRValue.init_global(self.module.allocator, variable);
}

pub fn setActiveBlock(self: *Self, block: *FuncBlock) void {
    self.active_block = block;
}

pub fn getActiveBlock(self: *Self) *FuncBlock {
    return self.active_block;
}
