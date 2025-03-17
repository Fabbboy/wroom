const Type = @import("../Type.zig").Type;
const VReg = @import("VReg.zig");

const Self = @This();

size: Type,
vreg: VReg,

pub fn init(size: Type, vreg: VReg) Self {
    return Self{
        .size = size,
        .vreg = vreg,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try self.vreg.fmt(fbuf);
    try fbuf.print(" = alloca {s}", .{self.size.fmt()});
}
