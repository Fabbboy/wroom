const Ast = @import("../Parser/Ast.zig");
const Module = @import("Module.zig");

const Variable = @import("Variable.zig");
const IRValue = @import("Value.zig").IRValue;
const IRStatus = @import("Error.zig").IRStatus;
const Constant = @import("Constant.zig");

const Self = @This();

ast: *const Ast,
module: *Module,

pub fn init(ast: *const Ast, module: *Module) Self {
    return Self{
        .ast = ast,
        .module = module,
    };
}

pub fn generate(self: *const Self) IRStatus!void {
    const globals = self.ast.getGlobals();
    for (globals.*) |glbl| {
        const name = glbl.getName().lexeme;
        const ty = glbl.getType();

        const value = IRValue{ .Constant = Constant{} };
        const variable = Variable.init(value, ty);
        try self.module.globals.insert(name, variable);
    }
}
