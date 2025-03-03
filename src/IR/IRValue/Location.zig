const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Self = @This();

pub const Location = union(enum) {
    Local: usize,
    Global: []const u8,

    pub fn LocVar(id: usize) Location {
        return .{
            .Local = id,
        };
    }

    pub fn LocGlobal(name: []const u8) Location {
        return .{
            .Global = name,
        };
    }

    pub fn fmt(self: *const Location, fbuf: anytype) !void {
        return switch (self.*) {
            Location.Local => |local| {
                try fbuf.print("%{}", .{local});
            },
            Location.Global => |global| {
                try fbuf.print("@{s}", .{global});
            },
        };
    }
};
