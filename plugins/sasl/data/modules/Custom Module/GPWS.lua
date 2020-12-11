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
-- File: GPWS.lua 
-- Short description: GPWS system
-------------------------------------------------------------------------------

include('constants.lua')

local is_warning = false
local is_caution = false
local mode_3_armed = false
local flap_3_mode = false


function update_mode_1(alt, vs)

    set(GPWS_mode_1_sinkrate, 0)
    set(GPWS_mode_1_pullup,   0)

    if alt < 10 or alt > 2450 then
        set(GPWS_mode_is_active, 0, 1)
        return
    end

    set(GPWS_mode_is_active, 1, 1)

    local max_vs_for_sinkrate = Math_rescale(10,  1000, 2450, 5000, alt)
    if alt > 300 then
        local max_vs_for_pullup   = Math_rescale(300, 1600, 2450, 7000, alt)
        if -vs >= max_vs_for_pullup then
            is_warning = true
            set(GPWS_mode_1_pullup,   1)
        elseif -vs >= max_vs_for_sinkrate then
            is_caution = true
            set(GPWS_mode_1_sinkrate, 1)
        end
    else
        local max_vs_for_pullup   = Math_rescale(300, 1600, 10, 1500, alt)
        if -vs >= max_vs_for_pullup then
            is_warning = true
            set(GPWS_mode_1_pullup,   1)
        elseif -vs >= max_vs_for_sinkrate then
            is_caution = true
            set(GPWS_mode_1_sinkrate, 1)
        end    
    end

end

function update_mode_3(alt, vs)

    set(GPWS_mode_3_dontsink, 0)
    if alt < 10 or alt > 2450 then
        set(GPWS_mode_is_active, 0, 3)
        return
    end

    if alt < 245 then   -- Takeoff or go-around is defined as the aircraft being lower than 245
        mode_3_armed = true
    elseif alt > 1500 then
        mode_3_armed = false
    end

    if mode_3_armed then
        set(GPWS_mode_is_active, 1, 3)
    end
    
    local flap_gear_cond = get(Gear_handle) == 0 or (get(Flaps_internal_config) ~= 5 and not (get(Flaps_internal_config) == 4 and flap_3_mode))
    
    if mode_3_armed and -vs >= alt/10 and flap_gear_cond then
        set(GPWS_mode_3_dontsink, 1)
        is_caution = 1
    end

end

function update_pbs()
    pb_set(PB.mip.gpws_capt, is_caution, is_warning)
    
end

function update()
    is_warning = false
    is_caution = false
    
    update_mode_1(get(Capt_ra_alt_ft), get(Capt_VVI))
    update_mode_3(get(Capt_ra_alt_ft), get(Capt_VVI))


    update_pbs()
end
