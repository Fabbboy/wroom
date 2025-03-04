const Target = @import("Target.zig");
const Machine = Target.Machine;

const LINUX_X86_64_SYSV_STUB =
    \\.section .note.GNU-stack,"",%progbits
    \\.section .text  
    \\.globl _start
    \\.type _start, @function
    \\_start:
    \\    popq %rdi
    \\    movq %rsp, %rsi
    \\    andq $-16, %rsp
    \\    subq $8, %rsp  
    \\    call main
    \\    addq $8, %rsp
    \\    movq $60, %rax
    \\    xorl %edi, %edi
    \\    syscall
;

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
