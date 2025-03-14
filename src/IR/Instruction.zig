pub const Instruction = union(enum) {
    pub fn fmt(self: *const Instruction, fbuf: anytype) !void {
        _ = self;
        _ = fbuf;
    }
};
