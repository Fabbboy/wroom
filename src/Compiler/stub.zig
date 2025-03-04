const Target = @import("Target.zig");
const Machine = Target.Machine;

const LINUX_X86_64_SYSV_STUB = @embedFile("stubs/x86_64_sysv.S");

fn getX86Specific(machine: Machine) []const u8 {
    switch (machine.os) {
        .Linux => switch (machine.abi) {
            .SysV => return LINUX_X86_64_SYSV_STUB,
        },
    }
}

pub fn GetStub(machine: Machine) []const u8 {
    switch (machine.target) {
        .X86_64 => return getX86Specific(machine),
    }
}
