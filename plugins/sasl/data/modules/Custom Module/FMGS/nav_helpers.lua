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
-- File: FMGS/nav_helpers.lua 
-- Short description: Various functions for navigation purposes
-------------------------------------------------------------------------------

local function roll_limit(x)
    if adirs_how_many_adrs_work() == 0 then
        return 30 -- Max limit if ADRs fail
    end

    local tas = adirs_get_avg_tas()
    if tas < 100 then
        return Math_rescale(0, 15, 100, 25, tas)
    elseif tas < 150 and x == 1 then
        return Math_rescale(0, 15, 150, 30, tas)
    elseif tas < 300 or (x == 2 and tas < 350) then
        return x == 1 and 30 or 25
    elseif tas < 450 then
        return Math_rescale(300, 30, 450, 20, tas)
    end
    return 19 -- over 400
end

local function is_in_land_or_loc()
    return false -- TODO
end

local function is_in_hdg()
    return false -- TODO
end

function FMGS_get_roll_limit()

    -- If engine failures, then roll limit is set to 15
    if get(FAILURE_ENG_1_FAILURE) == 1 or get(FAILURE_ENG_2_FAILURE) == 1 then
        return 15
    end
    
    if get(Capt_ra_alt_ft) < 700 and is_in_land_or_loc() then
        return 10
    end

    if is_in_hdg() or FMGS_sys.curr_segment == FMGS_SEGMENT_SID or FMGS_sys.curr_segment == FMGS_SEGMENT_STAR
                   or FMGS_sys.curr_segment == FMGS_SEGMENT_HOLD or FMGS_sys.curr_segment == FMGS_SEGMENT_OFF_ROUTE then -- or proc turns?
        -- Roll limit 2
        return roll_limit(2)
    elseif FMGS_sys.curr_segment == FMGS_SEGMENT_EN_ROUTE then
        return 15
    end

    return roll_limit(1)
end

