pub const Linkage = enum {
    Public,
    Internal,
    External,

    pub fn fmt(self: Linkage) []const u8 {
        switch (self) {
            .Public => return "public",
            .Internal => return "internal",
            .External => return "external",
        }
    }
};
