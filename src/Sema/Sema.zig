const std = @import("std");
const mem = std.mem;

const ErrorNs = @import("Error.zig");
const SemaError = ErrorNs.SemaError;
const SemaStatus = ErrorNs.SemaStatus;

const Ast = @import("../Parser/Ast.zig");

const Self = @This();

ast: *Ast,
errs: std.ArrayList(SemaError),
allocator: mem.Allocator,

pub fn init(ast: *Ast, allocator: mem.Allocator) Self {
    return Self{
        .ast = ast,
        .errs = std.ArrayList(SemaError).init(allocator),
        .allocator = allocator,
    };
}

pub fn getErrs(self: *const Self) *const std.ArrayList(SemaError) {
    return &self.errs;
}

pub fn analyze(self: *Self) SemaStatus!void {
    _ = self;
    return SemaStatus.NotGood;
}

pub fn deinit(self: *Self) void {
    self.errs.deinit();
}
