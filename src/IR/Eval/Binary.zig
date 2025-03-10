const Constant = @import("../Values/Constant.zig").Constant;
const IRValue = @import("../IRValue.zig").IRValue;

pub fn evalBinaryAdd(lhs: *const IRValue, rhs: *const IRValue) IRValue {
    switch (lhs.*) {
        IRValue.Constant => {
            const l = lhs.Constant;
            switch (rhs.*) {
                IRValue.Constant => {
                    const r = rhs.Constant;
                    return IRValue.init_constant(Constant.add(&l, &r));
                },
            }
        },
    }
}
