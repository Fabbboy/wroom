pub const AllocaInst = @import("Instructions/AllocaInst.zig");

pub const Instruction = union(enum) {
    Alloca: AllocaInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return Instruction{ .Alloca = alloca };
    }
    pub fn fmt(self: *const Instruction, fbuf: anytype) !void {
        switch (self.*) {
            .Alloca => try self.Alloca.fmt(fbuf),
        }
    }
};
