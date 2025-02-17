const Lexer = @import("lexer.zig");
const Ast = @import("ast.zig");

const Self = @This();

lexer: *Lexer,
ast: Ast,

pub fn init(lexer: *Lexer) Self {
    return Self{
        .lexer = lexer,
        .ast = Ast.init(),
    };
}
