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
-- File: FMGS/limits.lua
-------------------------------------------------------------------------------

include('libs/air_helpers.lua')

local function compute_max_alt(curr_weight)

    local max_fl = Math_rescale_lim_lower(62000, 39100, 78000, 34500, curr_weight)

    local delta_isa = get(OTA) - Temperature_get_ISA()  -- TODO Verify if it's OTA or TAT

    local isa_correction_table = {
        {   -- No AI
            {0, 0},
            {10, -1300},
            {15, -3300},
            {20, -5100}
        },
        {   -- Eng AI
            {0, -200},
            {10, -1500},
            {15, -3500},
            {20, -5300}
        },
        {   -- All AI
            {0, -500},
            {10, -4200},
            {15, -4800},
            {20, -6500}
        },
    }

    local idx = (AI_sys.comp[ANTIICE_ENG_1].valve_status or AI_sys.comp[ANTIICE_ENG_2].valve_status) and 2 or 1
    idx = (AI_sys.comp[ANTIICE_WING_L].valve_status or AI_sys.comp[ANTIICE_WING_R].valve_status) and 3 or idx
    local correction = Table_interpolate(isa_correction_table[idx], delta_isa)
    max_fl = max_fl + correction
 
    return max_fl
end


local function compute_opt_alt()
    if FMGS_sys.data.limits.max_alt then
        return FMGS_sys.data.limits.max_alt - 3500;    -- Check Airbus Cost Index document
    else
        return nil
    end
end

function update_limits()
    FMGS_sys.data.limits.max_alt = compute_max_alt(get(Aircraft_total_weight_kgs))
    FMGS_sys.data.limits.opt_alt = compute_opt_alt()
end