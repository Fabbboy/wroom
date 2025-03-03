const Position = @import("../Parser/Position.zig");

const ReturnStatement = @import("ReturnStatement.zig");
const AssignStatement = @import("AssignStatement.zig");
const FunctionCall = @import("FunctionCall.zig");

pub const Stmt = union(enum) {
    AssignStatement: AssignStatement,
    ReturnStatement: ReturnStatement,
    FunctionCall: FunctionCall,

    pub fn init_assign(assign: AssignStatement) Stmt {
        return .{ .AssignStatement = assign };
    }

    pub fn init_return(ret: ReturnStatement) Stmt {
        return .{ .ReturnStatement = ret };
    }

    pub fn init_function_call(call: FunctionCall) Stmt {
        return .{ .FunctionCall = call };
    }

    pub fn deinit(self: *const Stmt) void {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.deinit(),
            Stmt.ReturnStatement => self.ReturnStatement.deinit(),
            Stmt.FunctionCall => self.FunctionCall.deinit(),
        }
    }

    pub fn fmt(self: *const Stmt, fbuf: anytype) !void {
        switch (self.*) {
            Stmt.AssignStatement => try self.AssignStatement.fmt(fbuf),
            Stmt.ReturnStatement => try self.ReturnStatement.fmt(fbuf),
            Stmt.FunctionCall => try self.FunctionCall.fmt(fbuf),
        }
    }

    pub fn start(self: *const Stmt) usize {
        return switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.start(),
            Stmt.ReturnStatement => self.ReturnStatement.start(),
            Stmt.FunctionCall => self.FunctionCall.start(),
        };
    }

    pub fn stop(self: *const Stmt) usize {
        return switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.stop(),
            Stmt.ReturnStatement => self.ReturnStatement.stop(),
            Stmt.FunctionCall => self.FunctionCall.stop(),
        };
    }

    pub fn pos(self: *const Stmt) Position {
        return switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.pos(),
            Stmt.ReturnStatement => self.ReturnStatement.pos(),
            Stmt.FunctionCall => self.FunctionCall.pos(),
        };
    }
};
