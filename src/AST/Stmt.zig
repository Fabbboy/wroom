const Position = @import("Position.zig");

const AssignStatement = @import("AssignStatement.zig");

pub const Stmt = union(enum) {
    AssignStatement: AssignStatement,

    pub fn init_assign(assign: AssignStatement) Stmt {
        return Stmt.AssignStatement(assign);
    }

    pub fn deinit(self: *Stmt) void {
        switch (self) {
            AssignStatement => self.AssignStatement.deinit(),
        }
    }

    pub fn fmt(self: *const Stmt, fbuf: anytype) !void {
        switch (self) {
            AssignStatement => self.AssignStatement.fmt(fbuf),
        }
    }

    pub fn start(self: *const Stmt) usize {
        switch (self) {
            AssignStatement => self.AssignStatement.start(),
        }
    }

    pub fn stop(self: *const Stmt) usize {
        switch (self) {
            AssignStatement => self.AssignStatement.stop(),
        }
    }

    pub fn pos(self: *const Stmt) Position {
        switch (self) {
            AssignStatement => self.AssignStatement.pos(),
        }
    }
};
