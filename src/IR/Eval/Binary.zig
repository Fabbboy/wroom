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

pub fn evalBinarySub(lhs: *const IRValue, rhs: *const IRValue) IRValue {
    switch (lhs.*) {
        IRValue.Constant => {
            const l = lhs.Constant;
            switch (rhs.*) {
                IRValue.Constant => {
                    const r = rhs.Constant;
                    return IRValue.init_constant(Constant.sub(&l, &r));
                },
            }
        },
    }
}

pub fn evalBinaryMul(lhs: *const IRValue, rhs: *const IRValue) IRValue {
    switch (lhs.*) {
        IRValue.Constant => {
            const l = lhs.Constant;
            switch (rhs.*) {
                IRValue.Constant => {
                    const r = rhs.Constant;
                    return IRValue.init_constant(Constant.mul(&l, &r));
                },
            }
        },
    }
}

pub fn evalBinaryDiv(lhs: *const IRValue, rhs: *const IRValue) IRValue {
    switch (lhs.*) {
        IRValue.Constant => {
            const l = lhs.Constant;
            switch (rhs.*) {
                IRValue.Constant => {
                    const r = rhs.Constant;
                    return IRValue.init_constant(Constant.div(&l, &r));
                },
            }
        },
    }
}
