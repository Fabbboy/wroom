const Ast = @import("../Parser/Ast.zig");

const Self = @This();

ast: *Ast,

pub fn init(ast: *Ast) Self {
    return Self{ .ast = ast };
}
