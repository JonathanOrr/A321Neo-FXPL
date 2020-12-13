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
local PRELIMINARY_MODE_2_TIME = 5
local UPDATE_INTERVAL = 0.5

local is_warning = false
local is_caution = false
local mode_3_armed = false

local gpws_terrain_mode = true
local gpws_system_mode = true
local gpws_gs_mode = true
local gpws_flap_mode = true
local gpws_flap_3_mode = false

local time_in_mode_2 = 0
local initial_alt_in_mode_2 = 0

local prev_ra = 0   -- Previous frame radio altitude for rate computation
local last_update = 0
local data_delayed = {
    ra_altitide = 0,
    ra_rate     = 0,
    vvi_rate    = 0,
    ias         = 0
}

sasl.registerCommandHandler (GPWS_cmd_TER, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_terrain_mode = not gpws_terrain_mode end end )
sasl.registerCommandHandler (GPWS_cmd_SYS, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_system_mode = not gpws_system_mode end end )
sasl.registerCommandHandler (GPWS_cmd_GS_MODE, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_gs_mode = not gpws_gs_mode end end )
sasl.registerCommandHandler (GPWS_cmd_FLAP_MODE, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_flap_mode = not gpws_flap_mode end end )
sasl.registerCommandHandler (GPWS_cmd_LDG_FLAP_3, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_flap_3_mode = not gpws_flap_3_mode end end )


function update_mode_1(alt, vs)

    set(GPWS_mode_1_sinkrate, 0)
    set(GPWS_mode_1_pullup,   0)
    set(GPWS_mode_is_active, 0, 1)

    if not gpws_system_mode then return end -- Not active

    if alt >= 10 and alt <= 2450 then
        set(GPWS_mode_is_active, 1, 1)
    else
        return
    end

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

local function is_flap_in_landing()
    return (get(Flaps_internal_config) == 5 or (get(Flaps_internal_config) == 4 and gpws_flap_3_mode))
end




local function get_mode_2_submodes(alt, ias)

    set(GPWS_mode_2_mode_a, 0)
    set(GPWS_mode_2_mode_b, 0)

    if not is_flap_in_landing() then
        -- MODE 2A
        -- Conditions:
        -- - flaps not in landing configuration
        -- - aircraft not in glideslope beam TODO
        local upper_limit_top    = 2450
        local upper_limit_bottom = 1250
        local upper_limit = Math_rescale(220, 1250, 310, 2450, ias)
        local lower_limit = 30
        
        if alt < lower_limit or alt > upper_limit then
            -- bye bye
            return 0
        end
        
        set(GPWS_mode_2_mode_a, 1)
        return 1
    else
        if alt < 200 or alt > 600 then
            -- TODO With ILS ok, altitude lower bound becomes 30
            return 0
        else
            set(GPWS_mode_2_mode_b, 1)
            return 2
        end
    end
    

end

local function is_in_mode_2_boundaries(alt, vs)
    -- If in final the lower bound for rate changes
    upper_horiz = get(EWD_flight_phase) == PHASE_FINAL and 789 or 1250
    
    -- there are two different rates depending on altitude
    if alt < upper_horiz then
        local vs_limit = Math_rescale(30, 2000, upper_horiz, 3000, alt)
        return -vs >= vs_limit
    else
        local vs_limit = Math_rescale(upper_horiz, 3000, 950, 2450, alt)
        return -vs >= vs_limit
    end
end

function update_mode_2(alt, vs, ias)
    set(GPWS_mode_is_active, 0, 2)
    set(GPWS_mode_2_terrterr, 0)
    set(GPWS_mode_2_pullup,   0)
    set(GPWS_mode_2_terr, 0)
    
    if not gpws_system_mode then return end -- Not active
    
    local mode = get_mode_2_submodes(alt, ias)

    if mode == 0 then
        time_in_mode_2 = 0
        return
    elseif mode == 1 then
        set(GPWS_mode_is_active, 1, 2)
        if is_in_mode_2_boundaries(alt, vs) then
            if time_in_mode_2 == 0 then
                time_in_mode_2 = get(TIME)
            elseif get(TIME) - time_in_mode_2 > PRELIMINARY_MODE_2_TIME then
                -- After the TERRAIN TERRAIN, we execute the PULL UP sound
                set(GPWS_mode_2_pullup, 1)
                initial_alt_in_mode_2 = alt
                is_warning = true
            else
                -- TERRAIN TERRAIN is sound the first time
                set(GPWS_mode_2_terrterr, 1)
                is_caution = true
            end
        elseif initial_alt_in_mode_2 ~= 0 and alt - initial_alt_in_mode_2 < 300 then
            -- TERRAIN continues to sound until the aircraft gained 300 ft
            is_warning = true -- Light continues to show pull up
            set(GPWS_mode_2_terr, 1)
        else
            initial_alt_in_mode_2 = 0
            time_in_mode_2 = 0
        end
    else
        set(GPWS_mode_is_active, 1, 2)
        time_in_mode_2 = 0
        if is_in_mode_2_boundaries(alt, vs) then
            set(GPWS_mode_2_terr, 1)
            is_caution = true
        end
    end
    
end

function update_mode_3(alt, vs)
    set(GPWS_mode_3_dontsink, 0)

    if not gpws_system_mode then return end -- Not active

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
    
    local flap_gear_cond = get(Gear_handle) == 0 or is_flap_in_landing()
    
    if mode_3_armed and -vs >= alt/10 and flap_gear_cond then
        set(GPWS_mode_3_dontsink, 1)
        is_caution = 1
    end

end

local function update_pbs()
    pb_set(PB.mip.gpws_capt, is_caution, is_warning)
    
    pb_set(PB.ovhd.gpws_sys,       not gpws_system_mode, false)
    pb_set(PB.ovhd.gpws_terr,      not gpws_terrain_mode, false)
    pb_set(PB.ovhd.gpws_gs_mode,   not gpws_gs_mode, false)
    pb_set(PB.ovhd.gpws_flap_mode, not gpws_flap_mode, false)
    pb_set(PB.ovhd.gpws_ldg_flap_3, gpws_flap_3_mode, false)
    
end

local function update_local_data()
    if get(TIME) - last_update > UPDATE_INTERVAL then
        last_update = get(TIME)
        
        local radio_rate = get(DELTA_TIME) > 0 and (get(Capt_ra_alt_ft) - prev_ra) / get(DELTA_TIME) * 60 or 0
        prev_ra = get(Capt_ra_alt_ft)
        
        data_delayed.ra_altitide = get(Capt_ra_alt_ft)
        data_delayed.ra_rate     = radio_rate
        data_delayed.vvi_rate    = get(Capt_VVI)
        data_delayed.ias         = get(IAS)
        
    end
end

function update()
    is_warning = false
    is_caution = false

    update_local_data()


    update_mode_1(data_delayed.ra_altitide, data_delayed.vvi_rate)
    update_mode_2(data_delayed.ra_altitide, data_delayed.ra_rate, data_delayed.ias)
    update_mode_3(data_delayed.ra_altitide, data_delayed.vvi_rate)

    update_pbs()
end
