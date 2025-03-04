const TargetNs = @import("../Target.zig");
const Machine = TargetNs.Machine;

const Section = @import("../Elf.zig").Section;

const Token = @import("../../Parser/Token.zig");
const ValueType = Token.ValueType;

const GlobalVariable = @import("../../IR//IRValue/GlobalVariable.zig");

const Function = @import("../../IR/IRValue/Function.zig");
const FuncBlock = Function.FuncBlock;

const IRValue = @import("../../IR/Value.zig").IRValue;
const Constant = @import("../../IR/IRValue/Constant.zig").IRConstant;

const Instruction = @import("../../IR/Instruction.zig").Instruction;

const Self = @This();
machine: Machine,
func_name: ?[]const u8,
function: ?*const Function,

fn getType(ty: ValueType) []const u8 {
    switch (ty) {
        .I32 => return ".long",
        .F32 => return ".float",
        .Ptr => return ".quad",
        .Void => return ".zero",
        else => return ".zero",
    }
}

fn getSize(ty: ValueType) u32 {
    switch (ty) {
        .I32 => return 4,
        .F32 => return 4,
        .Ptr => return 8,
        .Void => return 4,
        else => return 4,
    }
}

pub fn init(target: Machine) Self {
    return Self{
        .machine = target,
        .func_name = null,
        .function = null,
    };
}

pub fn enterSection(self: *Self, section: Section, writter: anytype) !void {
    _ = self;
    try writter.print(".section .{s}\n", .{section.fmt()});
}

fn emitPrologue(self: *Self, function: *const Function, writter: anytype) !void {
    _ = self;
    _ = function;
    try writter.writeAll("\tpushq %rbp\n");
    try writter.writeAll("\tmovq %rsp, %rbp\n");
}

fn emitEpilogue(self: *Self, function: *const Function, writter: anytype) !void {
    _ = self;
    _ = function;
    try writter.writeAll("\tleave\n");
}

pub fn emitInstruction(self: *Self, instr: *const Instruction, writter: anytype) !void {
    _ = self;
    //Alloca: AllocaInst,
    //Store: StoreInst,
    //Load: LoadInst,
    //Add: AddInst,
    //Sub: SubInst,
    //Mul: MulInst,
    //Div: DivInst,
    //Return: IRValue,
    //Call: CallInst,

    switch (instr.*) {
        Instruction.Alloca => |alloca| {
            const size = alloca.size;
            try writter.print("\tsubq ${}, %rsp\n", .{getSize(size)});
        },
        else => {},
    }
}

pub fn emitBlock(self: *Self, block: *const FuncBlock, writter: anytype) !void {
    try writter.print(".{s}_{s}:\n", .{ self.func_name.?, block.name });
    for (block.instructions.items) |instr| {
        try self.emitInstruction(&instr, writter);
    }

    try writter.writeAll("\n");
}
pub fn emitFunction(self: *Self, name: []const u8, function: *const Function, writter: anytype) !void {
    self.function = function;
    self.func_name = name;

    if (function.linkage == .External) {
        try writter.print(".extern {s}\n", .{name});
        return;
    }
    if (function.linkage == .Public) {
        try writter.print("\t.globl {s}\n", .{name});
    }
    try writter.writeAll("\t.p2align 4\n");
    try writter.print("\t.type {s}, @function\n", .{name});
    try writter.print("{s}:\n", .{name});
    try writter.writeAll("\t.cfi_startproc\n");
    try self.emitPrologue(function, writter);

    const blocks = function.getBlocks();
    for (blocks.*) |block| {
        try self.emitBlock(&block, writter);
    }

    try self.emitEpilogue(function, writter);
    try writter.writeAll("\tret\n");
    try writter.print(".SL{s}_end:\n", .{name});
    try writter.print("\t.size {s}, .SL{s}_end-{s}\n", .{ name, name, name });
    try writter.writeAll("\t.cfi_endproc\n");
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
        try writter.print("\t.globl {s}\n", .{name});
    } else if (global.linkage == .External) {
        try writter.print("\t.extern {s}\n", .{name});
        return;
    }

    try writter.print("{s}:\n\t{s} ", .{ name, getType(global.getType()) });
    try self.emitConstant(&global.initializer, writter);
    try writter.print("\n\t.size {s}, {}\n", .{ name, getSize(global.getType()) });
    try writter.writeAll("\n");
}
