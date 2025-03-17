const Instruction = @import("Instruction.zig").Instruction;
const Constant = @import("Values/Constant.zig").Constant;

pub const IRValue = union(enum) {
    Constant: Constant,
    Instruction: Instruction,

    pub fn init_constant(val: Constant) IRValue {
        return IRValue{
            .Constant = val,
        };
    }

    pub fn init_instruction(val: Instruction) IRValue {
        return IRValue{
            .Instruction = val,
        };
    }

    pub fn deinit(self: *const IRValue) void {
        switch (self.*) {
            IRValue.Instruction => {
                self.Instruction.deinit();
            },
            else => {},
        }
    }

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        switch (self.*) {
            IRValue.Constant => {
                try self.Constant.fmt(fbuf);
            },
            IRValue.Instruction => {
                try self.Instruction.fmt(fbuf);
            },
        }
    }
};
