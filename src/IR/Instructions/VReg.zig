const VReg = @This();

vreg: usize,

pub fn init(vreg: usize) VReg {
    return VReg{
        .vreg = vreg,
    };
}

pub fn fmt(self: *const VReg, fbuf: anytype) !void {
    try fbuf.print("%{}", .{self.vreg});
}

pub const VRegManager = struct {
    const Man = @This();
    next_id: usize,

    pub fn init() Man {
        return Man{ .next_id = 0 };
    }

    pub fn getNext(self: *Man) VReg {
        const vreg = self.next_id;
        self.next_id += 1;
        return VReg.init(vreg);
    }
};