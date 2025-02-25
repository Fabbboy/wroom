const Token = @import("../Parser/Token.zig");
const ValueType = Token.ValueType;

const Position = @import("../Parser/Position.zig");

pub const SemaStatus = error{
    NotGood,
    OutOfMemory,
};

pub const SemaError = union(enum) {
    SymbolAlreadyDeclared: SymbolAlreadyDeclared,
    TypeMismatch: TypeMismatch,
    SymbolUndefined: SymbolUndefined,

    pub fn init_symbol_already_declared(name: []const u8, pos: Position) SemaError {
        return SemaError{ .SymbolAlreadyDeclared = SymbolAlreadyDeclared.init(name, pos) };
    }

    pub fn init_type_mismatch(lhs: ValueType, rhs: ValueType, pos: Position) SemaError {
        return SemaError{ .TypeMismatch = TypeMismatch.init(lhs, rhs, pos) };
    }

    pub fn init_symbol_undefined(name: []const u8, pos: Position) SemaError {
        return SemaError{ .SymbolUndefined = SymbolUndefined.init(name, pos) };
    }

    pub fn fmt(self: *const SemaError, fbuf: anytype) !void {
        switch (self.*) {
            SemaError.SymbolAlreadyDeclared => try self.SymbolAlreadyDeclared.fmt(fbuf),
            SemaError.TypeMismatch => try self.TypeMismatch.fmt(fbuf),
            SemaError.SymbolUndefined => try self.SymbolUndefined.fmt(fbuf),
        }
    }
};

pub const TypeMismatch = struct {
    lhs: ValueType,
    rhs: ValueType,
    pos: Position,

    pub fn init(lhs: ValueType, rhs: ValueType, pos: Position) TypeMismatch {
        return TypeMismatch{
            .lhs = lhs,
            .rhs = rhs,
            .pos = pos,
        };
    }

    pub fn fmt(self: *const TypeMismatch, fbuf: anytype) !void {
        try fbuf.print("{}:{} Type mismatch: expected '{}', got '{}'", .{ self.pos.line, self.pos.column, self.lhs, self.rhs });
    }
};

pub const SymbolAlreadyDeclared = struct {
    name: []const u8,
    pos: Position,

    pub fn init(name: []const u8, pos: Position) SymbolAlreadyDeclared {
        return SymbolAlreadyDeclared{
            .name = name,
            .pos = pos,
        };
    }

    pub fn fmt(self: *const SymbolAlreadyDeclared, fbuf: anytype) !void {
        try fbuf.print("{}:{} Symbol already declared: '{s}'", .{ self.pos.line, self.pos.column, self.name });
    }
};

pub const SymbolUndefined = struct {
    name: []const u8,
    pos: Position,

    pub fn init(name: []const u8, pos: Position) SymbolUndefined {
        return SymbolUndefined{
            .name = name,
            .pos = pos,
        };
    }

    pub fn fmt(self: *const SymbolUndefined, fbuf: anytype) !void {
        try fbuf.print("{}:{} Symbol undefined: '{s}'", .{ self.pos.line, self.pos.column, self.name });
    }
};
