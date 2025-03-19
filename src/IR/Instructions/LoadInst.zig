const Type = @import("../Type.zig").Type;
const InstructionNode = @import("../Instruction.zig").InstructionNode;
const VReg = @import("VReg.zig").VReg;
const IRValue = @import("../IRValue.zig").IRValue;
const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

ty: Type,
dest: VReg,
src: VReg,
parent: ?*const InstructionNode,

pub fn init(dest: VReg, src: VReg, ty: Type) Self {
    return Self{
        .ty = ty,
        .dest = dest,
        .src = src,
        .parent = null,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    try self.dest.fmt(fbuf);
    try fbuf.print(" = load {s}, ", .{self.ty.fmt()});
    try self.src.fmt(fbuf);
}

pub fn get_parent(self: *const Self) ?*const InstructionNode {
    return self.parent;
}

pub fn set_parent(self: *Self, parent: ?*const InstructionNode) void {
    self.parent = parent;
}

pub fn get_reg(self: *const Self) VReg {
    return self.dest;
}
