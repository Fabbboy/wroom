pub const Section = enum {
    TEXT,
    DATA,
    RODATA,
    BSS,

    pub fn fmt(self: Section) []const u8 {
        switch (self) {
            .TEXT => return "text",
            .DATA => return "data",
            .RODATA => return "rodata",
            .BSS => return "bss",
        }
    }
};
