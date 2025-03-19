const IRValue = @import("../IRValue.zig").IRValue;
const InstructionNs = @import("../Instruction.zig");
const Instruction = InstructionNs.Instruction;
const InstructionNode = InstructionNs.InstructionNode;
const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

dest: *const Instruction,
val: IRValue,
parent: ?*const InstructionNode,

pub fn init(dest: *const Instruction, val: IRValue) Self {
    return Self{
        .dest = dest,
        .val = val,
        .parent = null,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    const handle = self.dest.get_reg();
    if (handle) |r| {
        try fbuf.writeAll("store ");
        try r.fmt(fbuf);
        try fbuf.writeAll(", ");
        switch (self.val) {
            IRValue.Constant => {
                try self.val.Constant.fmt(fbuf);
            },
            IRValue.Instruction => {
                const inst = self.val.Instruction;
                if (inst.get_reg()) |reg| {
                    try reg.fmt(fbuf);
                }
            },
        }
    }
}

pub fn deinit(self: *Self) void {
    self.val.deinit();
}

pub fn get_parent(self: *const Self) ?*const InstructionNode {
    return self.parent;
}

pub fn set_parent(self: *Self, parent: ?*const InstructionNode) void {
    self.parent = parent;
}
