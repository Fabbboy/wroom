const std = @import("std");

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRValue = @import("Value.zig").IRValue;

const IRStatus = @import("Error.zig").IRStatus;

const BinaryInst = @import("Instruction/Binary.zig");
const AddInst = BinaryInst.AddInst;
const SubInst = BinaryInst.SubInst;
const MulInst = BinaryInst.MulInst;
const DivInst = BinaryInst.DivInst;

const MoveInst = @import("Instruction/Move.zig");
const AllocaInst = MoveInst.AllocaInst;
const StoreInst = MoveInst.StoreInst;
const LoadInst = MoveInst.LoadInst;

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

pub const CallInst = struct {
    id: usize,
    name: []const u8,
    args: std.ArrayList(IRValue),
    noret: bool,

    pub fn init(id: usize, name: []const u8, args: std.ArrayList(IRValue), noret: bool) CallInst {
        return CallInst{
            .id = id,
            .name = name,
            .args = args,
            .noret = noret,
        };
    }

    pub fn fmt(self: *const CallInst, fbuf: anytype) IRStatus!void {
        //try fbuf.print("%{} = call ", .{self.id});
        if (self.noret) {
            try fbuf.writeAll("call ");
        } else {
            try fbuf.print("%{} = call ", .{self.id});
        }
        try fbuf.print("@{s}(", .{self.name});
        for (self.args.items, 0..) |arg, i| {
            try arg.fmt(fbuf);
            if ((i + 1) < self.args.items.len) {
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
