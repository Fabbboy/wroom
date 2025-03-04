const TargetNs = @import("Target.zig");
const Machine = TargetNs.Machine;

const x86_64 = @import("backend/x86_64.zig");

const GlobalVariable = @import("../IR//IRValue/GlobalVariable.zig");

const Section = @import("Elf.zig").Section;

pub const Codegen = union(enum) {
    const Self = @This();
    x86_64: x86_64,

    pub fn init(target: Machine) Self {
        switch (target.target) {
            .X86_64 => return Self{
                .x86_64 = x86_64.init(target),
            },
        }
    }

    pub fn enterSection(self: *Self, section: Section, writter: anytype) !void {
        switch (self.*) {
            .x86_64 => try self.x86_64.enterSection(section, writter),
        }
    }

    pub fn emitVariable(self: *Self, name: []const u8, global: *const GlobalVariable, writter: anytype) !void {
        switch (self.*) {
            .x86_64 => try self.x86_64.emitVariable(name, global, writter),
        }
    }
};
