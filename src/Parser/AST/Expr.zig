const LiteralExpr = @import("LiteralExpr.zig");
const Token = @import("../Token.zig");

pub const ValueType = enum {
    Int,
    Float,
};

pub const Expr = union(enum) {
    Literal: LiteralExpr,

    pub fn init_literal(val: Token) Expr {
        return Expr{
            .Literal = LiteralExpr.init(val),
        };
    }

    pub fn fmt(self: *const Expr, fbuf: anytype) !void {
        return switch (self.*) {
            Expr.Literal => self.Literal.fmt(fbuf),
        };
    }
};
