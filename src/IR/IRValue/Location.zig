const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Self = @This();

pub const LocationStorage = union(enum) {
    Local: usize,
    Global: []const u8,

    pub fn LocVar(id: usize) LocationStorage {
        return .{
            .Local = id,
        };
    }

    pub fn LocGlobal(name: []const u8) LocationStorage {
        return .{
            .Global = name,
        };
    }

    pub fn fmt(self: *const LocationStorage, fbuf: anytype) !void {
        return switch (self.*) {
            LocationStorage.Local => |local| {
                try fbuf.print("%{}", .{local});
            },
            LocationStorage.Global => |global| {
                try fbuf.print("@{s}", .{global});
            },
        };
    }
};

target: LocationStorage,
ty: ValueType,

pub fn init(target: LocationStorage, ty: ValueType) Self {
    return Self{
        .target = target,
        .ty = ty,
    };
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} ", .{self.ty.fmt()});
    try self.target.fmt(fbuf);
}
