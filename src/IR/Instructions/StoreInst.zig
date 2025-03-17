const IRValue = @import("../IRValue.zig").IRValue;
const Instruction = @import("../Instruction.zig").Instruction;
const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

dest: *const Instruction,
val: IRValue,

pub fn init(dest: *const Instruction, val: IRValue) Self {
    return Self{
        .dest = dest,
        .val = val,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    const handle = self.dest.get_reg();
    if (handle) |r| {
        try fbuf.writeAll("store ");
        try r.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.val.fmt(fbuf);
    }
}

pub fn deinit(self: *const Self) void {
    self.val.deinit();
}
