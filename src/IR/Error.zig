pub const IRStatus = error{
    NotGood,
    OutOfMemory,
    Overflow,
    InvalidCharacter,
};

pub const IRError = union(enum) {
    SymbolNotFound: SymbolNotFound,

    pub fn init_function_not_found(err: SymbolNotFound) IRError {
        return IRError{ .SymbolNotFound = err };
    }

    pub fn fmt(self: *const IRError, fbuf: anytype) !void {
        switch (self.*) {
            IRError.SymbolNotFound => try self.SymbolNotFound.fmt(fbuf),
        }
    }
};

pub const SymbolNotFound = struct {
    name: []const u8,

    pub fn init(name: []const u8) SymbolNotFound {
        return SymbolNotFound{
            .name = name,
        };
    }

    pub fn fmt(self: *const SymbolNotFound, fbuf: anytype) !void {
        try fbuf.print("Symbol not found in IR Context: '{s}'", .{self.name});
    }
};
