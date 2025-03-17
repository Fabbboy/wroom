const std = @import("std");
const mem = std.mem;

const IRStatus = @import("Error.zig").IRStatus;

const AllocaInst = @import("Instructions/AllocaInst.zig");
const StoreInst = @import("Instructions/StoreInst.zig");

const VReg = @import("Instructions/VReg.zig");

pub const InstructionData = union(enum) {
    Alloca: AllocaInst,
    Store: StoreInst,

    pub fn init_alloca(alloca: AllocaInst) InstructionData {
        return InstructionData{ .Alloca = alloca };
    }

    pub fn init_store(store: StoreInst) InstructionData {
        return InstructionData{ .Store = store };
    }

    pub fn deinit(self: *const InstructionData) void {
        switch (self.*) {
            .Store => self.Store.deinit(),
            else => {},
        }
    }

    pub fn fmt(self: *const InstructionData, fbuf: anytype) !void {
        switch (self.*) {
            .Alloca => try self.Alloca.fmt(fbuf),
            .Store => try self.Store.fmt(fbuf),
        }
    }
};

pub const Instruction = struct {
    data: *InstructionData,
    allocator: mem.Allocator,

    pub fn init_alloca(allocator: mem.Allocator, alloca: AllocaInst) IRStatus!Instruction {
        const data = try allocator.create(InstructionData);
        data.* = InstructionData{ .Alloca = alloca };
        return Instruction{
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn init_store(allocator: mem.Allocator, store: StoreInst) IRStatus!Instruction {
        const data = try allocator.create(InstructionData);
        data.* = InstructionData{ .Store = store };
        return Instruction{
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *const Instruction) void {
        self.data.deinit();
        self.allocator.destroy(self.data);
    }

    pub fn fmt(self: *const Instruction, fbuf: anytype) !void {
        try self.data.fmt(fbuf);
    }

    pub fn get_reg(self: *const Instruction) ?VReg {
        switch (self.data.*) {
            .Alloca => return self.data.Alloca.vreg,
            else => return null,
        }
    }
};
