const InstructionNode = @import("../Instruction.zig").InstructionNode;

const Type = @import("../Type.zig").Type;
const VReg = @import("VReg.zig").VReg;

const Self = @This();

size: Type,
vreg: VReg,
parent: ?*const InstructionNode,

pub fn init(size: Type, vreg: VReg) Self {
    return Self{
        .size = size,
        .vreg = vreg,
        .parent = null,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try self.vreg.fmt(fbuf);
    try fbuf.print(" = alloca {s}", .{self.size.fmt()});
}

pub fn get_reg(self: *const Self) *const VReg {
    return &self.vreg;
}

pub fn get_parent(self: *const Self) ?*const InstructionNode {
    return self.parent;
}

pub fn set_parent(self: *Self, parent: ?*const InstructionNode) void {
    self.parent = parent;
}