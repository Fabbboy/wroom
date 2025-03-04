const TargetNs = @import("../Target.zig");
const Machine = TargetNs.Machine;

const Section = @import("../Elf.zig").Section;

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const GlobalVariable = @import("../../IR//IRValue/GlobalVariable.zig");

const IRValue = @import("../../IR/Value.zig").IRValue;
const Constant = @import("../../IR/IRValue/Constant.zig").IRConstant;

const Self = @This();
machine: Machine,

fn getType(ty: ValueType) []const u8 {
    switch (ty) {
        .I32 => return ".long",
        .F32 => return ".float",
        .Ptr => return ".quad",
        .Void => return ".zero",
        else => return ".zero",
    }
}

pub fn init(target: Machine) Self {
    return Self{
        .machine = target,
    };
}

pub fn enterSection(self: *Self, section: Section, writter: anytype) !void {
    _ = self;
    try writter.print(".section .{s}\n", .{section.fmt()});
}

pub fn emitConstant(self: *Self, constant: *const Constant, writter: anytype) !void {
    _ = self;
    switch (constant.*) {
        .Voider => try writter.writeAll("4"),
        .Integer => |value| {
            try writter.print("{}", .{value});
        },
        .Floating => |value| {
            try writter.print("{}", .{value});
        },
    }
}

pub fn emitVariable(self: *Self, name: []const u8, global: *const GlobalVariable, writter: anytype) !void {
    if (global.constant and global.linkage == .Internal) return;

    if (global.linkage == .Public) {
        try writter.print(".globl {s}\n", .{name});
    } else if (global.linkage == .External) {
        try writter.print(".extern {s}\n", .{name});
        return;
    }

    try writter.print("{s}: {s} ", .{ name, getType(global.getType()) });
    try self.emitConstant(&global.initializer, writter);
    try writter.writeAll("\n");
}
