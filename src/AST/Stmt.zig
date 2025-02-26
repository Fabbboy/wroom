const Position = @import("../Parser/Position.zig");

const AssignStatement = @import("AssignStatement.zig");

pub const Stmt = union(enum) {
    AssignStatement: AssignStatement,

    pub fn init_assign(assign: AssignStatement) Stmt {
        return Stmt.AssignStatement(assign);
    }

    pub fn deinit(self: *const Stmt) void {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.deinit(),
        }
    }

    pub fn fmt(self: *const Stmt, fbuf: anytype) !void {
        switch (self.*) {
            Stmt.AssignStatement => try self.AssignStatement.fmt(fbuf),
        }
    }

    pub fn start(self: *const Stmt) usize {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.start(),
        }
    }

    pub fn stop(self: *const Stmt) usize {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.stop(),
        }
    }

    pub fn pos(self: *const Stmt) Position {
        switch (self.*) {
            Stmt.AssignStatement => self.AssignStatement.pos(),
        }
    }
};
