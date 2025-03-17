pub const Type = union(enum) {
    Integer: IntegerTy,
    Float: FloatTy,
    Void: void,

    pub fn init_int(ty: IntegerTy) Type {
        return Type{
            .Integer = ty,
        };
    }

    pub fn init_float(ty: FloatTy) Type {
        return Type{
            .Float = ty,
        };
    }

    pub fn init_void() Type {
        return Type{
            .Void = void{},
        };
    }

    pub fn fmt(self: Type) []const u8 {
        switch (self) {
            Type.Integer => return self.Integer.fmt(),
            Type.Float => return self.Float.fmt(),
            Type.Void => return "void",
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

pub const FloatTy = enum {
    F32,

    pub fn fmt(self: FloatTy) []const u8 {
        switch (self) {
            .F32 => return "f32",
        }
    }
};
