FBW.lateral.inputs = {
    x_to_P = function (x, bank)
        --properties
        local degrade_margin = 15
        local max_return_rate = 7.5
        local max_roll_rate = 15
        local max_aprot_roll_rate = 7.5

        --inputs
        local abs_x = math.abs(x)
        local p = (FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE and max_aprot_roll_rate or max_roll_rate) * x

        --manipulations
        local max_allowable_bank = Math_rescale(0, FBW.lateral.protections.bank_limit[1], 1, FBW.lateral.protections.bank_limit[2], abs_x)

        --check for bank exceedence
        local l_limitation = Math_rescale(-max_allowable_bank - degrade_margin, 2, -max_allowable_bank + degrade_margin, 0, bank)
        local r_limitation = Math_rescale(max_allowable_bank - degrade_margin,  0,  max_allowable_bank + degrade_margin, 2, bank)

        --rescale input--
        local l_limit_table = {
            {0, p},
            {1, math.max(0, p)},
            {2, math.max(max_return_rate, p)},
        }
        local p_limited = Table_interpolate(l_limit_table, l_limitation)

        local r_limit_table = {
            {0, p_limited},
            {1, math.min(p_limited, 0)},
            {2, math.min(p_limited, -max_return_rate)},
        }
        p_limited = Table_interpolate(r_limit_table, r_limitation)

        return p_limited
    end,
}