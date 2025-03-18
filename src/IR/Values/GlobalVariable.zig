const Type = @import("../Type.zig").Type;
const Constant = @import("Constant.zig").Constant;
const Linkage = @import("../Linkage.zig").Linkage;
const Module = @import("../Module.zig");

const Self = @This();

name: []const u8,
ty: Type,
value: Constant,
is_const: bool,
linkage: Linkage,

pub fn init(mod: *Module, name: []const u8, ty: Type, value: Constant, is_const: bool, linkage: Linkage) !*Self {
    const va = Self{
        .name = name,
        .ty = ty,
        .value = value,
        .is_const = is_const,
        .linkage = linkage,
    };

    return try mod.addGlobal(name, va);
}

pub fn fmt(self: *const Self, fbuf: anytype) !void {
    try fbuf.print("{s} @{s} = ", .{ self.linkage.fmt(), self.name });
    if (self.is_const) {
        try fbuf.writeAll("const ");
    }
    try fbuf.print("{s} ", .{self.ty.fmt()});
    try self.value.fmt(fbuf);
}
