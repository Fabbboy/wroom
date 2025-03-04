pub const Section = enum {
    TEXT,
    DATA,
    RODATA,
    BSS,

    pub fn fmt(self: Section, fbuf: anytype) void {
        switch (self) {
            .TEXT => fbuf.writeAll("text"),
            .DATA => fbuf.writeAll("data"),
            .RODATA => fbuf.writeAll("rodata"),
            .BSS => fbuf.writeAll("bss"),
        }
    }
};
