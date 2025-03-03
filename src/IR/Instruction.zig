const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRValue = @import("Value.zig").IRValue;

const IRStatus = @import("Error.zig").IRStatus;

pub const Instruction = union(enum) {
    const Self = @This();

    Alloca: AllocaInst,
    Store: StoreInst,
    Load: LoadInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return .{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) Instruction {
        return .{ .Store = store };
    }

    pub fn init_load(load: LoadInst) Instruction {
        return .{ .Load = load };
    }

    pub fn fmt(self: *const Self, fbuf: anytype) IRStatus!void {
        return switch (self.*) {
            Instruction.Alloca => |alloca| {
                try alloca.fmt(fbuf);
            },
            Instruction.Store => |store| {
                try store.fmt(fbuf);
            },
            Instruction.Load => |load| {
                try load.fmt(fbuf);
            },
        };
    }

    pub fn deinit(self: *const Self) void {
        return switch (self.*) {
            Instruction.Store => |store| {
                store.deinit();
            },
            Instruction.Load => |load| {
                load.deinit();
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
        try fbuf.print("store {s}, ", .{self.ty.fmt()});
        try self.target.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.value.fmt(fbuf);
    }

    pub fn deinit(self: *const StoreInst) void {
        self.target.deinit();
        self.value.deinit();
    }
};

pub const LoadInst = struct {
    id: usize,
    src: IRValue,
    ty: ValueType,

    pub fn init(id: usize, src: IRValue, ty: ValueType) LoadInst {
        return LoadInst{
            .id = id,
            .src = src,
            .ty = ty,
        };
    }

    pub fn fmt(self: *const LoadInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = load {s}, ", .{ self.id, self.ty.fmt() });
        try self.src.fmt(fbuf);
    }

    pub fn deinit(self: *const LoadInst) void {
        self.src.deinit();
    }
};
