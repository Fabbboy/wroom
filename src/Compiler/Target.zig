pub const Target = enum {
    X86_64,
};

pub const OSTag = enum {
    Linux,
};

pub const ABI = enum {
    SysV,
};

pub const Machine = struct {
    target: Target,
    os: OSTag,
    abi: ABI,
};
