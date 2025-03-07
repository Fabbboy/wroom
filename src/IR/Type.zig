pub const Type = union(enum) {
    Integer: IntegerTy,

    pub fn init_int(ty: IntegerTy) Type {
        return Type{
            .Integer = ty,
        };
    }

    pub fn fmt(self: Type) []const u8 {
        switch (self) {
            Type.Integer => return self.Integer.fmt(),
        }
    }
};

pub const IntegerTy = enum {
    I32,

    pub fn fmt(self: IntegerTy) []const u8 {
        switch (self) {
            .I32 => return "i32",
        }
    }
};
