const std = @import("std");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRValue = @import("Value.zig").IRValue;

const IRStatus = @import("Error.zig").IRStatus;

const AddInst = @import("Instruction/Binary.zig").AddInst;
const SubInst = @import("Instruction/Binary.zig").SubInst;
const MulInst = @import("Instruction/Binary.zig").MulInst;
const DivInst = @import("Instruction/Binary.zig").DivInst;

pub const Instruction = union(enum) {
    const Self = @This();

    Alloca: AllocaInst,
    Store: StoreInst,
    Load: LoadInst,
    Add: AddInst,
    Sub: SubInst,
    Mul: MulInst,
    Div: DivInst,
    Return: IRValue,
    Call: CallInst,

    pub fn init_alloca(alloca: AllocaInst) Instruction {
        return .{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) Instruction {
        return .{ .Store = store };
    }

    pub fn init_load(load: LoadInst) Instruction {
        return .{ .Load = load };
    }

    pub fn init_add(add: AddInst) Instruction {
        return .{ .Add = add };
    }

    pub fn init_sub(sub: SubInst) Instruction {
        return .{ .Sub = sub };
    }

    pub fn init_mul(mul: MulInst) Instruction {
        return .{ .Mul = mul };
    }

    pub fn init_div(div: DivInst) Instruction {
        return .{ .Div = div };
    }

    pub fn init_return(ret: IRValue) Instruction {
        return .{ .Return = ret };
    }

    pub fn init_call(call: CallInst) Instruction {
        return .{ .Call = call };
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
            Instruction.Add => |add| {
                try add.fmt(fbuf);
            },
            Instruction.Sub => |sub| {
                try sub.fmt(fbuf);
            },
            Instruction.Mul => |mul| {
                try mul.fmt(fbuf);
            },
            Instruction.Div => |div| {
                try div.fmt(fbuf);
            },
            Instruction.Return => |ret| {
                try fbuf.writeAll("return ");
                try ret.fmt(fbuf);
            },
            Instruction.Call => |call| {
                try call.fmt(fbuf);
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
            Instruction.Add => |add| {
                add.deinit();
            },
            Instruction.Sub => |sub| {
                sub.deinit();
            },
            Instruction.Mul => |mul| {
                mul.deinit();
            },
            Instruction.Div => |div| {
                div.deinit();
            },
            Instruction.Return => |ret| {
                ret.deinit();
            },
            Instruction.Call => |call| {
                call.deinit();
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
    assignee: IRValue,
    value: IRValue,
    by: ValueType,

    pub fn init(target: IRValue, value: IRValue, by: ValueType) StoreInst {
        return StoreInst{
            .assignee = target,
            .value = value,
            .by = by,
        };
    }

    pub fn fmt(self: *const StoreInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("store {s} ", .{self.by.fmt()});
        try self.assignee.fmt(fbuf);
        try fbuf.writeAll(", ");
        try self.value.fmt(fbuf);
    }

    pub fn deinit(self: *const StoreInst) void {
        self.assignee.deinit();
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

pub const CallInst = struct {
    id: usize,
    name: []const u8,
    args: std.ArrayList(IRValue),

    pub fn init(id: usize, name: []const u8, args: std.ArrayList(IRValue)) CallInst {
        return CallInst{
            .id = id,
            .name = name,
            .args = args,
        };
    }

    pub fn fmt(self: *const CallInst, fbuf: anytype) IRStatus!void {
        try fbuf.print("%{} = call @{s}(", .{ self.id, self.name });
        for (self.args.items, 0..) |arg, i| {
            try arg.fmt(fbuf);
            if (i + 1 != self.args.items.len) {
                try fbuf.writeAll(", ");
            }
        }
        try fbuf.writeAll(")");
    }

    pub fn deinit(self: *const CallInst) void {
        for (self.args.items) |arg| {
            arg.deinit();
        }

        self.args.deinit();
    }
};
