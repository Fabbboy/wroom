const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRStatus = @import("../Error.zig").IRStatus;

const IRValue = @import("../Value.zig").IRValue;

pub const AddInst = struct {
    id: usize,
    lhs: IRValue,
    rhs: IRValue,
    ty: ValueType,

    pub fn init(id: usize, lhs: IRValue, rhs: IRValue, ty: ValueType) AddInst {
        return AddInst{
            .id = id,
            .lhs = lhs,
            .rhs = rhs,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const AddInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = add {s} ", .{ self.id, self.ty.fmt() });
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn deinit(self: *const AddInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const SubInst = struct {
    id: usize,
    lhs: IRValue,
    rhs: IRValue,
    ty: ValueType,

    pub fn init(id: usize, lhs: IRValue, rhs: IRValue, ty: ValueType) SubInst {
        return SubInst{
            .id = id,
            .lhs = lhs,
            .rhs = rhs,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const SubInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = sub {s} ", .{ self.id, self.ty.fmt() });
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn deinit(self: *const SubInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const MulInst = struct {
    id: usize,
    lhs: IRValue,
    rhs: IRValue,
    ty: ValueType,

    pub fn init(id: usize, lhs: IRValue, rhs: IRValue, ty: ValueType) MulInst {
        return MulInst{
            .id = id,
            .lhs = lhs,
            .rhs = rhs,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const MulInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = mul {s} ", .{ self.id, self.ty.fmt() });
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn deinit(self: *const MulInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};

pub const DivInst = struct {
    id: usize,
    lhs: IRValue,
    rhs: IRValue,
    ty: ValueType,

    pub fn init(id: usize, lhs: IRValue, rhs: IRValue, ty: ValueType) DivInst {
        return DivInst{
            .id = id,
            .lhs = lhs,
            .rhs = rhs,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const DivInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = div {s} ", .{ self.id, self.ty.fmt() });
        try self.lhs.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.rhs.fmt(fbuf);
    }

    pub fn deinit(self: *const DivInst) void {
        self.lhs.deinit();
        self.rhs.deinit();
    }
};
