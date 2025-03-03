const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRValue = @import("Value.zig").IRValue;

const IRStatus = @import("Error.zig").IRStatus;

pub const Instruction = union(enum) {
    const Self = @This();

    Alloca: AllocaInst,
    Store: StoreInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return .{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) Instruction {
        return .{ .Store = store };
    }

    pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
        return switch (self.*) {
            Instruction.Alloca => |alloca| {
                try alloca.fmt(fbuf);
            },
            Instruction.Store => |store| {
                try store.fmt(fbuf);
            },
        };
    }

    pub fn deinit(self: *const Self) void {
        return switch (self.*) {
            Instruction.Store => |store| {
                store.deinit();
            },
            else => {},
        };
    }
};

pub const AllocaInst = struct {
    id: usize,
    size: ValueType,

    pub fn init(id: usize, size: ValueType) AllocaInst {
        return AllocaInst{
            .id = id,
            .size = size,
        };
    }

    pub fn fmt(self: *const AllocaInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = alloca {s}", .{ self.id, self.size.fmt() });
    }
};

pub const StoreInst = struct {
    target: IRValue,
    value: IRValue,
    ty: ValueType,

    pub fn init(target: IRValue, value: IRValue, ty: ValueType) StoreInst {
        return StoreInst{
            .target = target,
            .value = value,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const StoreInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("store {s} ", .{self.ty.fmt()});
        try self.value.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.target.fmt(fbuf);
    }

    pub fn deinit(self: *const StoreInst) void {
        self.target.deinit();
        self.value.deinit();
    }
};
