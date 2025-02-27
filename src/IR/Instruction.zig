pub const Instruction = union(enum) {
    const Self = @This();

    pub fn fmt(self: *const Self, fbuf: anytype) !void {
        return switch (self) {
            else => {
                try fbuf.writeAll("Instruction{ }");
            },
        };
    }
};
