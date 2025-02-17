const Ast = @import("../Parser/Ast.zig");

const Self = @This();

ast: *const Ast,

pub fn init(ast: *const Ast) Self {
    return Self{ .ast = ast };
}
