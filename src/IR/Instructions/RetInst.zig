const InstructionNode = @import("../Instruction.zig").InstructionNode;
const VReg = @import("VReg.zig").VReg;
const IRValue = @import("../IRValue.zig").IRValue;
const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

ret_val: IRValue,
parent: ?*const InstructionNode,

pub fn init(ret_val: IRValue) Self {
    return Self{
        .ret_val = ret_val,
        .parent = null,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    try fbuf.writeAll("ret ");
    try self.ret_val.fmt(fbuf);
}

pub fn deinit(self: *Self) void {
    self.ret_val.deinit();
}

pub fn get_parent(self: *const Self) ?*const InstructionNode {
    return self.parent;
}

pub fn set_parent(self: *Self, parent: ?*const InstructionNode) void {
    self.parent = parent;
}
