const InstructionNode = @import("../Instruction.zig").InstructionNode;
const VReg = @import("VReg.zig").VReg;
const IRValue = @import("../IRValue.zig").IRValue;
const IRStatus = @import("../Error.zig").IRStatus;

pub const AddInst = struct {
    dest: VReg,
    lhs: IRValue,
    rhs: IRValue,
    parent: ?*const InstructionNode,

    pub fn init(dest: VReg, lhs: IRValue, rhs: IRValue) AddInst {
        return AddInst{
            .dest = dest,
            .lhs = lhs,
            .rhs = rhs,
            .parent = null,
        };
    }

    pub fn fmt(self: *const AddInst, fbuf: anytype) IRStatus!void {
        try self.dest.fmt(fbuf);
        try fbuf.writeAll(" = add ");
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn get_reg(self: *const AddInst) VReg {
        return self.dest;
    }

    pub fn get_parent(self: *const AddInst) ?*const InstructionNode {
        return self.parent;
    }

    pub fn set_parent(self: *AddInst, parent: ?*const InstructionNode) void {
        self.parent = parent;
    }

    pub fn deinit(self: *AddInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const SubInst = struct {
    dest: VReg,
    lhs: IRValue,
    rhs: IRValue,
    parent: ?*const InstructionNode,

    pub fn init(dest: VReg, lhs: IRValue, rhs: IRValue) SubInst {
        return SubInst{
            .dest = dest,
            .lhs = lhs,
            .rhs = rhs,
            .parent = null,
        };
    }

    pub fn fmt(self: *const SubInst, fbuf: anytype) IRStatus!void {
        try self.dest.fmt(fbuf);
        try fbuf.writeAll(" = sub ");
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn get_reg(self: *const SubInst) VReg {
        return self.dest;
    }

    pub fn get_parent(self: *const SubInst) ?*const InstructionNode {
        return self.parent;
    }

    pub fn set_parent(self: *SubInst, parent: ?*const InstructionNode) void {
        self.parent = parent;
    }

    pub fn deinit(self: *SubInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const MulInst = struct {
    dest: VReg,
    lhs: IRValue,
    rhs: IRValue,
    parent: ?*const InstructionNode,

    pub fn init(dest: VReg, lhs: IRValue, rhs: IRValue) MulInst {
        return MulInst{
            .dest = dest,
            .lhs = lhs,
            .rhs = rhs,
            .parent = null,
        };
    }

    pub fn fmt(self: *const MulInst, fbuf: anytype) IRStatus!void {
        try self.dest.fmt(fbuf);
        try fbuf.writeAll(" = mul ");
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn get_reg(self: *const MulInst) VReg {
        return self.dest;
    }

    pub fn get_parent(self: *const MulInst) ?*const InstructionNode {
        return self.parent;
    }

    pub fn set_parent(self: *MulInst, parent: ?*const InstructionNode) void {
        self.parent = parent;
    }

    pub fn deinit(self: *MulInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const DivInst = struct {
    dest: VReg,
    lhs: IRValue,
    rhs: IRValue,
    parent: ?*const InstructionNode,

    pub fn init(dest: VReg, lhs: IRValue, rhs: IRValue) DivInst {
        return DivInst{
            .dest = dest,
            .lhs = lhs,
            .rhs = rhs,
            .parent = null,
        };
    }

    pub fn fmt(self: *const DivInst, fbuf: anytype) IRStatus!void {
        try self.dest.fmt(fbuf);
        try fbuf.writeAll(" = div ");
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn get_reg(self: *const DivInst) VReg {
        return self.dest;
    }

    pub fn get_parent(self: *const DivInst) ?*const InstructionNode {
        return self.parent;
    }

    pub fn set_parent(self: *DivInst, parent: ?*const InstructionNode) void {
        self.parent = parent;
    }

    pub fn deinit(self: *DivInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};
