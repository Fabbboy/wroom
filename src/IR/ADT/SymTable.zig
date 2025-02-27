const std = @import("std");
const mem = std.mem;

pub fn SymTable(comptime T: type) type {
    return struct {
        const Self = @This();

        table: std.StringHashMap(T),
        allocator: mem.Allocator,

        pub fn init(allocator: mem.Allocator) Self {
            return Self{
                .table = std.StringHashMap(T).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.table.deinit();
        }

        pub fn insert(self: *Self, key: []const u8, value: T) !void {
            try self.table.put(key, value);
        }

        pub fn get(self: *const Self, key: []const u8) ?*T {
            return self.table.getPtr(key);
        }
    };
}
