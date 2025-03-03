const std = @import("std");
const mem = std.mem;

const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const IRConstant = @import("IRValue/Constant.zig").IRConstant;
const GlobalVariable = @import("IRValue/GlobalVariable.zig");
const Location = @import("IRValue/Location.zig").Location;

pub const IRValueData = union(enum) {
    Constant: IRConstant,
    Global: GlobalVariable,
    Location: Location,

    pub fn init_constant(value: IRConstant) IRValueData {
        return IRValueData{
            .Constant = value,
        };
    }

    pub fn init_global(value: GlobalVariable) IRValueData {
        return IRValueData{
            .Global = value,
        };
    }

    pub fn init_location(value: Location) IRValueData {
        return IRValueData{
            .Location = value,
        };
    }

    pub fn fmt(self: *const IRValueData, fbuf: anytype) !void {
        switch (self.*) {
            IRValueData.Constant => |value| {
                try value.fmt(fbuf);
            },
            IRValueData.Global => |value| {
                try value.fmt(fbuf);
            },
            IRValueData.Location => |value| {
                try value.fmt(fbuf);
            },
        }
    }
};

pub const IRValue = struct {
    data: *IRValueData,
    allocator: mem.Allocator,

    pub fn init_constant(allocator: mem.Allocator, value: IRConstant) !IRValue {
        const data = try allocator.create(IRValueData);
        data.* = IRValueData.init_constant(value);
        return IRValue{
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn init_global(allocator: mem.Allocator, value: GlobalVariable) !IRValue {
        const data = try allocator.create(IRValueData);
        data.* = IRValueData.init_global(value);
        return IRValue{
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn init_location(allocator: mem.Allocator, value: Location) !IRValue {
        const data = try allocator.create(IRValueData);
        data.* = IRValueData.init_location(value);
        return IRValue{
            .data = data,
            .allocator = allocator,
        };
    }

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        try self.data.fmt(fbuf);
    }

    pub fn deinit(self: *const IRValue) void {
        self.allocator.destroy(self.data);
    }

    pub fn getType(self: *const IRValue) ValueType {
        switch (self.data.*) {
            IRValueData.Constant => |value| {
                return value.getType();
            },
            IRValueData.Global => |value| {
                return value.getType();
            },
            IRValueData.Location => |value| {
                return value.getType();
            },
        }
    }

    pub fn copy(self: *const IRValue) !IRValue {
        const data = try self.allocator.create(IRValueData);
        data.* = self.data.*;
        return IRValue{
            .data = data,
            .allocator = self.allocator,
        };
    }
};
