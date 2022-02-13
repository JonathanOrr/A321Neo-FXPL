-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

include('libs/speed_helpers.lua')

local function drag_coefficient_gear(tas)
    return math.max(1,Math_rescale_no_lim(180, 1.62, 240, 1.84, tas))
end

local function drag_coefficient_flaps(pos, tas)
    if pos == 1 then    -- 1
        return 1    -- Slats seem to have basically no effect on the drag
    elseif pos == 2 then    -- 1 + f
        return math.max(1,Math_rescale_no_lim(180, 1.19, 200, 1.29, tas))
    elseif pos == 3 then    -- 2
        return math.max(1,Math_rescale_no_lim(180, 1.31, 200, 1.50, tas))
    elseif pos == 4 then    -- 3
        return math.max(1,Math_rescale_no_lim(180, 1.60, 200, 1.90, tas))
    elseif pos == 5 then    -- FULL
        return math.max(1,Math_rescale_no_lim(180, 1.87, 200, 2.26, tas))
    end
end


function predict_drag_w_gf(density_ratio, tas, mach, weight, flap_conf, is_gear_open)
    local base_drag = predict_drag(density_ratio, tas, mach, weight)

    local gear_contrib = 0
    local flap_contrib = 0

    if flap_conf > 0 then
        flap_contrib = base_drag * drag_coefficient_flaps(flap_conf, tas) - base_drag
    end 

    if is_gear_open then
        gear_contrib = base_drag * drag_coefficient_gear(tas) - base_drag
    end

    return gear_contrib + flap_contrib
end

function predict_drag(density_ratio, tas, mach, weight)

    local k_intercept    = 85181.2225251811
    local k_density      = -25678.2332664804
    local k_tas          = -2413.20964429833
    local k_mach         = 574539.051088178
    local k_density_tas  = 786.386764129413
    local k_density_mach = -155171.333100472
    local k_tas_mach     = -8824.79409156343
    local k_density2     = -2183.98471173943
    local k_tas2         = 19.9720761229528
    local k_mach2        = 958212.072935194

    local ref_weight = 69900

    tas = kts_to_ms(tas)

    local zero_order   = k_intercept
    local first_order  = k_density * density_ratio + k_tas * tas + k_mach * mach
    local second_order = k_density_tas * density_ratio * tas 
                       + k_density_mach * density_ratio * mach 
                       + k_tas_mach * tas * mach
    local second_order_pure = k_density2 * density_ratio * density_ratio
                            + k_mach2 * mach * mach
                            + k_tas2 * tas * tas

    local weight_ratio = (weight/ref_weight);


    return weight_ratio * (zero_order + first_order + second_order + second_order_pure)
end