const Instruction = @import("Instruction.zig").Instruction;
const Constant = @import("Values/Constant.zig").Constant;

pub const IRValue = union(enum) {
    Constant: Constant,
    Instruction: *const Instruction,

    pub fn init_constant(val: Constant) IRValue {
        return IRValue{
            .Constant = val,
        };
    }

    pub fn init_instruction(val: *const Instruction) IRValue {
        return IRValue{
            .Instruction = val,
        };
    }

    pub fn deinit(self: *const IRValue) void {
        switch (self.*) {
            else => {},
        }
    }

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        switch (self.*) {
            IRValue.Constant => {
                try self.Constant.fmt(fbuf);
            },
            IRValue.Instruction => {
                const reg = self.Instruction.get_reg();
                if (reg) |r| {
                    try r.fmt(fbuf);
                }
            },
        }
    }
};
