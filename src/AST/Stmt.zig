const Position = @import("../Parser/Position.zig");

const ReturnStatement = @import("ReturnStatement.zig");
const AssignStatement = @import("AssignStatement.zig");

pub const Stmt = union(enum) {
    AssignStatement: AssignStatement,
    ReturnStatement: ReturnStatement,

    pub fn init_assign(assign: AssignStatement) Stmt {
        return .{ .AssignStatement = assign };
    }

    pub fn init_return(ret: ReturnStatement) Stmt {
        return .{ .ReturnStatement = ret };
    }

    pub fn deinit(self: *const Stmt) void {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.deinit(),
            Stmt.ReturnStatement => self.ReturnStatement.deinit(),
        }
    }

    pub fn fmt(self: *const Stmt, fbuf: anytype) !void {
        switch (self.*) {
            Stmt.AssignStatement => try self.AssignStatement.fmt(fbuf),
            Stmt.ReturnStatement => try self.ReturnStatement.fmt(fbuf),
        }
    }

    pub fn start(self: *const Stmt) usize {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.start(),
            Stmt.ReturnStatement => self.ReturnStatement.start(),
        }
    }

    pub fn stop(self: *const Stmt) usize {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.stop(),
            Stmt.ReturnStatement => self.ReturnStatement.stop(),
        }
    }

    pub fn pos(self: *const Stmt) Position {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.pos(),
            Stmt.ReturnStatement => self.ReturnStatement.pos(),
        }
    }
};
