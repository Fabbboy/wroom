const std = @import("std");
const mem = std.mem;

const IRConstant = @import("IRValue/Constant.zig").IRConstant;

pub const IRValueData = union(enum) {
    Constant: IRConstant,

    pub fn init_constant(value: IRConstant) IRValueData {
        return IRValueData{
            .Constant = value,
        };
    }

    pub fn fmt(self: *const IRValueData, fbuf: anytype) !void {
        switch (self.*) {
            IRValueData.Constant => |value| {
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

    pub fn fmt(self: *const IRValue, fbuf: anytype) !void {
        try self.data.fmt(fbuf);
    }

    pub fn deinit(self: *const IRValue) void {
        self.allocator.destroy(self.data);
    }
};
