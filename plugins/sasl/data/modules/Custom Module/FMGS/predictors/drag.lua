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