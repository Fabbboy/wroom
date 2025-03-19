pub const VRegManager = struct {
    const Man = @This();
    next_id: usize,

    pub fn init() Man {
        return Man{ .next_id = 0 };
    }

    pub fn getNext(self: *Man) VReg {
        const vreg = self.next_id;
        self.next_id += 1;
        return VReg.init_local(vreg);
    }
};

pub const VReg = union(enum) {
    local: usize,
    global: []const u8,

    pub fn init_local(vreg: usize) VReg {
        return VReg{
            .local = vreg,
        };
    }

    pub fn init_global(name: []const u8) VReg {
        return VReg{
            .global = name,
        };
    }

    pub fn fmt(self: *const VReg, fbuf: anytype) !void {
        switch (self.*) {
            VReg.local => try fbuf.print("%{}", .{self.local}),
            VReg.global => try fbuf.print("@{s}", .{self.global}),
        }
    }
};
