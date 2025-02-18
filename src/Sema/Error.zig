const ExprNs = @import("../Parser/AST/Expr.zig");
const ValueType = ExprNs.ValueType;

pub const SemaStatus = error{
    NotGood,
    OutOfMemory,
};

pub const SemaError = union(enum) {
    SymbolAlreadyDeclared: SymbolAlreadyDeclared,
    TypeMismatch: TypeMismatch,

    pub fn init_symbol_already_declared(name: []const u8) SemaError {
        return SemaError{ .SymbolAlreadyDeclared = SymbolAlreadyDeclared.init(name) };
    }

    pub fn init_type_mismatch(lhs: ValueType, rhs: ValueType) SemaError {
        return SemaError{ .TypeMismatch = TypeMismatch.init(lhs, rhs) };
    }

    pub fn fmt(self: *const SemaError, fbuf: anytype) !void {
        switch (self.*) {
            SemaError.SymbolAlreadyDeclared => try self.SymbolAlreadyDeclared.fmt(fbuf),
            SemaError.TypeMismatch => try self.TypeMismatch.fmt(fbuf),
        }
    }
};

pub const TypeMismatch = struct {
    lhs: ValueType,
    rhs: ValueType,

    pub fn init(lhs: ValueType, rhs: ValueType) TypeMismatch {
        return TypeMismatch{
            .lhs = lhs,
            .rhs = rhs,
        };
    }

    pub fn fmt(self: *const TypeMismatch, fbuf: anytype) !void {
        try fbuf.print("Type mismatch: expected '{}', got '{}'", .{ self.lhs, self.rhs });
    }
};

pub const SymbolAlreadyDeclared = struct {
    name: []const u8,

    pub fn init(name: []const u8) SymbolAlreadyDeclared {
        return SymbolAlreadyDeclared{
            .name = name,
        };
    }

    pub fn fmt(self: *const SymbolAlreadyDeclared, fbuf: anytype) !void {
        try fbuf.print("Symbol already declared: '{s}'", .{self.name});
    }
};
