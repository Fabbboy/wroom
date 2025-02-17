const Lexer = @import("Lexer.zig");
const Ast = @import("Ast.zig");

const Self = @This();

lexer: *Lexer,
ast: Ast,

pub fn init(lexer: *Lexer) Self {
    return Self{
        .lexer = lexer,
        .ast = Ast.init(),
    };
}
