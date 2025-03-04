const TargetNs = @import("../Target.zig");
const Machine = TargetNs.Machine;

const Self = @This();
machine: Machine,

pub fn init(target: Machine) Self {
    return Self{
        .machine = target,
    };
}
