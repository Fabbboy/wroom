const Ast = @import("../Parser/Ast.zig");
const Module = @import("Module.zig");

const Self = @This();

ast: *const Ast,
module: *Module,

pub fn init(ast: *const Ast, module: *Module) Self {
    return Self{
        .ast = ast,
        .module = module,
    };
}

pub fn generate(self: *const Self) !void {
    const globals = self.ast.getGlobals();
    _ = globals;
}
