const TargetNs = @import("Target.zig");
const Machine = TargetNs.Machine;

const x86_64 = @import("backend/x86_64.zig");

pub const Codegen = union(enum) {
    const Self = @This();
    x86_64: x86_64,

    pub fn init(target: Machine) Self {
        switch (target.target) {
            .X86_64 => return Self{
                .x86_64 = x86_64.init(target),
            },
        }
    }
};
