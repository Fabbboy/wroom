const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const Self = @This();

pub const Location = union(enum) {
    Local: LocalLocation,
    Global: GlobalLocation,
    Param: ParamLocation,

    pub fn LocVar(loc: LocalLocation) Location {
        return .{
            .Local = loc,
        };
    }

    pub fn LocGlobal(loc: GlobalLocation) Location {
        return .{
            .Global = loc,
        };
    }

    pub fn LocParam(loc: ParamLocation) Location {
        return .{
            .Param = loc,
        };
    }

    pub fn fmt(self: *const Location, fbuf: anytype) !void {
        switch (self.*) {
            Location.Local => |loc| {
                try loc.fmt(fbuf);
            },
            Location.Global => |loc| {
                try loc.fmt(fbuf);
            },
            Location.Param => |loc| {
                try loc.fmt(fbuf);
            },
        }
    }

    pub fn getType(self: *const Location) ValueType {
        switch (self.*) {
            Location.Local => |loc| {
                return loc.valtype;
            },
            Location.Global => |loc| {
                return loc.valtype;
            },
            Location.Param => |loc| {
                return loc.valtype;
            },
        }
    }
};

pub const LocalLocation = struct {
    id: usize,
    valtype: ValueType,

    pub fn init(id: usize, valtype: ValueType) LocalLocation {
        return LocalLocation{
            .id = id,
            .valtype = valtype,
        };
    }

    pub fn fmt(self: *const LocalLocation, fbuf: anytype) !void {
        try fbuf.print("%{}", .{self.id});
    }
};

pub const GlobalLocation = struct {
    name: []const u8,
    valtype: ValueType,

    pub fn init(name: []const u8, valtype: ValueType) GlobalLocation {
        return GlobalLocation{
            .name = name,
            .valtype = valtype,
        };
    }

    pub fn fmt(self: *const GlobalLocation, fbuf: anytype) !void {
        try fbuf.print("@{s}", .{self.name});
    }
};

pub const ParamLocation = struct {
    name: []const u8,
    valtype: ValueType,

    pub fn init(name: []const u8, valtype: ValueType) ParamLocation {
        return ParamLocation{
            .name = name,
            .valtype = valtype,
        };
    }

    pub fn fmt(self: *const ParamLocation, fbuf: anytype) !void {
        try fbuf.print("@{s}", .{self.name});
    }
};
