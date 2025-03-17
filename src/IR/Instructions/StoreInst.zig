const IRValue = @import("../IRValue.zig").IRValue;
const Instruction = @import("../Instruction.zig").Instruction;
const IRStatus = @import("../Error.zig").IRStatus;

const Self = @This();

dest: Instruction,
val: IRValue,

pub fn init(dest: Instruction, val: IRValue) Self {
    return Self{
        .dest = dest,
        .val = val,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
    try self.dest.fmt(fbuf);
    try fbuf.writeAll("\n");
    try fbuf.writeAll("\tstore ");

    const handle = self.dest.getRegister();
    if (handle) |r| {
        try r.fmt(fbuf);
    } else {
        try fbuf.writeAll("null");
    }

    try fbuf.writeAll(", ");
    try self.val.fmt(fbuf);
}

pub fn deinit(self: *const Self) void {
    self.dest.deinit();
    self.val.deinit();
}
