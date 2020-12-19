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
include('GPWS_predictive.lua')


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

local gpws_terrain_is_working = false
local gpws_terrain_was_active = false   -- Doesn't include inhibition (e.g. altitude)
local gpws_was_active = false

local time_in_mode_2 = 0
local initial_alt_in_mode_2 = 0

local mode_5_inhibited = false -- This happens when the pilot pressed the GPWS silence button

local max_ra_gained = 0 -- For MODE 4c

local prev_ra = 0   -- Previous frame radio altitude for rate computation
local last_update = 0
local data_delayed = {
    ra_altitude = 0,
    ra_rate     = 0,
    vvi_rate    = 0,
    ias         = 0
}

sasl.registerCommandHandler (GPWS_cmd_TER, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_terrain_mode = not gpws_terrain_mode end end )
sasl.registerCommandHandler (GPWS_cmd_SYS, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_system_mode = not gpws_system_mode end end )
sasl.registerCommandHandler (GPWS_cmd_GS_MODE, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_gs_mode = not gpws_gs_mode end end )
sasl.registerCommandHandler (GPWS_cmd_FLAP_MODE, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_flap_mode = not gpws_flap_mode end end )
sasl.registerCommandHandler (GPWS_cmd_LDG_FLAP_3, 0, function(phase) if phase == SASL_COMMAND_BEGIN then gpws_flap_3_mode = not gpws_flap_3_mode end end )
sasl.registerCommandHandler (GPWS_cmd_silence, 0, function(phase) if phase == SASL_COMMAND_BEGIN then mode_5_inhibited = true end end )



function onAirportLoaded()
    mode_3_armed = false
    time_in_mode_2 = 0
    initial_alt_in_mode_2 = 0
    if get(Capt_ra_alt_ft) > 100 then
        max_ra_gained = 1500 -- to disable
    end
end

-------------------------------------------------------------------------------
-- MODE 1
-------------------------------------------------------------------------------

function update_mode_1(alt, vs)

    set(GPWS_mode_1_sinkrate, 0)
    set(GPWS_mode_1_pullup,   0)
    set(GPWS_mode_is_active, 0, 1)

    if not gpws_system_mode or get(FAILURE_GPWS) == 1 or get(AC_bus_1_pwrd) == 0 then return end -- Not active

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

-------------------------------------------------------------------------------
-- MODE 2
-------------------------------------------------------------------------------

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
    
    if not gpws_system_mode or get(FAILURE_GPWS) == 1 or get(AC_bus_1_pwrd) == 0 then return end -- Not active
    
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

-------------------------------------------------------------------------------
-- MODE 3
-------------------------------------------------------------------------------


function update_mode_3(alt, vs)
    set(GPWS_mode_3_dontsink, 0)

    if not gpws_system_mode or get(FAILURE_GPWS) == 1 or get(AC_bus_1_pwrd) == 0 then return end -- Not active

    if alt < 10 or alt > 2450 then
        set(GPWS_mode_is_active, 0, 3)
        return
    end

    if alt < 245 and (get(Eng_1_N1) >= 74 or get(Eng_2_N1) >= 74) then
        -- Takeoff or go-around is defined as the aircraft being lower than 245
        -- and takeoff power applied
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

-------------------------------------------------------------------------------
-- MODE 4
-------------------------------------------------------------------------------
function update_mode_4_a(alt, ias)
    local upper_limit =  gpws_terrain_is_working and 500 or 1000
    
    if alt < 30 or alt > upper_limit then
        return
    end
    
    if get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment) >= 3 then
        return -- Landing gear is down
    end
    
    -- Region 1: TOO LOW GEAR
    if ias <= 190 and alt <= 500 then
        set(GPWS_mode_4_tl_gear, 1)
    end

    -- Region 2: TOO LOW TERRAIN
    local line_limit = Math_rescale(190, 500, 250, upper_limit, ias)
    if ias > 190 and alt <= line_limit then
        set(GPWS_mode_4_a_terrain, 1)
    end

    set(GPWS_mode_4_mode_a, 1)
end

function update_mode_4_b(alt, ias)
    local upper_limit =  gpws_terrain_is_working and 500 or 1000
    
    if alt < 30 or alt > upper_limit then
        return
    end
    
    if is_flap_in_landing() then
        return -- Flaps ok return
    end
    
    -- Region 1: TOO LOW FLAPS
    if ias <= 159 and alt <= 245 then
        set(GPWS_mode_4_tl_flaps, 1)
    end

    -- Region 2: TOO LOW TERRAIN
    local line_limit = Math_rescale(159, 245, 250, upper_limit, ias)
    if ias > 159 and alt <= line_limit then
        set(GPWS_mode_4_b_terrain, 1)
    end

    set(GPWS_mode_4_mode_b, 1)
    
end

function update_mode_4_c(alt, ias)
    if get(EWD_flight_phase) >= 6 or get(EWD_flight_phase) <= 2 then
        max_ra_gained = 0
    end
    
    if alt > max_ra_gained then
        max_ra_gained = alt
    end
    
    if max_ra_gained > 1000 then
        return -- Already took off
    end
    
    if alt < 30 or alt > Math_rescale(190, 500, 250, 1000, ias) then
        return -- not enabled    
    end

    if is_flap_in_landing() and get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment) >= 3 then
        return -- Flaps and gear ok, no trigger
    end

    set(GPWS_mode_4_mode_c, 1)
   
    if max_ra_gained >= 1333 and max_ra_gained <= 2400 and alt < 1000 then
        set(GPWS_mode_4_c_terrain, 1)
    elseif alt < Math_rescale_no_lim(100, 50, 1333, 1000, max_ra_gained) then
        set(GPWS_mode_4_c_terrain, 1)
    end
    
end

function update_mode_4(alt, ias)
    -- Resets the datarefs
    set(GPWS_mode_is_active, 0, 4)

    set(GPWS_mode_4_mode_a, 0)
    set(GPWS_mode_4_mode_b, 0)
    set(GPWS_mode_4_mode_c, 0)

    set(GPWS_mode_4_a_terrain, 0)
    set(GPWS_mode_4_b_terrain, 0)
    set(GPWS_mode_4_c_terrain, 0)
    set(GPWS_mode_4_tl_flaps, 0)
    set(GPWS_mode_4_tl_gear, 0)


    if gpws_system_mode and get(FAILURE_GPWS) == 0 and get(AC_bus_1_pwrd) == 1 then
        if get(EWD_flight_phase) == PHASE_FINAL or get(EWD_flight_phase) == PHASE_AIRBONE then
            -- 4A - Gear
            update_mode_4_a(alt, ias)
            if gpws_flap_mode then
                -- 4B - Flaps
                update_mode_4_b(alt, ias)
            end
        end
        -- 4C - After takeoff protection
        update_mode_4_c(alt, ias)
    end
    
    set(GPWS_mode_is_active, math.min(1, get(GPWS_mode_4_mode_a) + get(GPWS_mode_4_mode_b) + get(GPWS_mode_4_mode_c)), 4)
    if get(GPWS_mode_is_active) == 1 then
        is_caution = true
    end
end

-------------------------------------------------------------------------------
-- MODE 5
-------------------------------------------------------------------------------

function update_mode_5(alt)

    set(GPWS_mode_is_active, 0, 5)
    set(GPWS_mode_5_glideslope, 0)
    set(GPWS_mode_5_glideslope_hard, 0)

    if not gpws_gs_mode or not gpws_system_mode or get(FAILURE_GPWS) == 1 or get(AC_bus_1_pwrd) == 0 then
        return false -- Manually disabled
    end

    if get(ILS_1_glideslope_flag) == 1 then
        return false -- No ILS signal received
    end

    if get(EWD_flight_phase) ~= PHASE_FINAL and get(EWD_flight_phase) ~= PHASE_AIRBONE then
        return false
    end
    
    if alt > 1000 then
        return false -- Too high - inibith
    end

    if alt < 30 then
        return false -- Too low - inibith
    end

    set(GPWS_mode_is_active, 1, 5)
    
    -- Ok so, the minimum of x-plane dots is -2.5, the following rules apply:
    -- - if > 350 RA is a "light" glideslope if dots < -1.3
    -- if 180 < RA < 350: it's "light" if < -1.3 or "hard" if < -2
    -- if 30 < RA < 180: we have two lines

    if alt < 350 and alt >= 180 and get(ILS_1_glideslope_dots) <= -2 then
        set(GPWS_mode_5_glideslope_hard, mode_5_inhibited and 0 or 1)
        return mode_5_inhibited
    end

    if alt < 180 and get(ILS_1_glideslope_dots) <= Math_rescale(30, -3.6, 180, -2, alt) then
        set(GPWS_mode_5_glideslope_hard, mode_5_inhibited and 0 or 1)
        return mode_5_inhibited 
    elseif alt < 180 and  get(ILS_1_glideslope_dots) <= Math_rescale(30, -3, 180, -1, alt)  then
        set(GPWS_mode_5_glideslope, mode_5_inhibited and 0 or 1)
        return mode_5_inhibited
    end
    
    if alt >= 350 and get(ILS_1_glideslope_dots) <= -1.3 then
        set(GPWS_mode_5_glideslope, mode_5_inhibited and 0 or 1)
        return mode_5_inhibited
    end

    if alt < 350 and alt >= 180 and get(ILS_1_glideslope_dots) <= -1.3 and get(ILS_1_glideslope_dots) > -2 then
        set(GPWS_mode_5_glideslope, mode_5_inhibited and 0 or 1)
        return mode_5_inhibited
    end

    return false
end

-------------------------------------------------------------------------------
-- MODE PITCH
-------------------------------------------------------------------------------
local function update_mode_pitch()
    set(GPWS_mode_pitch, 0)
    if get(Capt_ra_alt_ft) > 20 then
        return -- Too high - inibith
    end
    
    if not gpws_system_mode or get(FAILURE_GPWS) == 1 or get(AC_bus_1_pwrd) == 0 then
        return -- Manually disabled
    end

    if get(Eng_1_N1) >= 74 or get(Eng_2_N1) >= 74 then
        return -- Not working in T/O or G/A phase
    end

    -- TODO APs not engaged
    
    local THRESHOLD = 8.25
    local pitch_now      = get(Flightmodel_pitch)
    local pitch_in_1_sec = get(Flightmodel_pitch) + get(Pitch_rate)

    if pitch_now > THRESHOLD or pitch_in_1_sec > THRESHOLD then
        set(GPWS_mode_pitch, 1)
        is_caution = true
    end
end

-------------------------------------------------------------------------------
-- MISC
-------------------------------------------------------------------------------


local function update_pbs()
    pb_set(PB.mip.gpws_capt, is_caution, is_warning)
    pb_set(PB.mip.gpws_fo, is_caution, is_warning)
    
    pb_set(PB.ovhd.gpws_sys,       not gpws_system_mode, get(FAILURE_GPWS) == 1)
    pb_set(PB.ovhd.gpws_terr,      not gpws_terrain_mode, get(FAILURE_GPWS_TERR) == 1)
    pb_set(PB.ovhd.gpws_gs_mode,   not gpws_gs_mode, false)
    pb_set(PB.ovhd.gpws_flap_mode, not gpws_flap_mode, false)
    pb_set(PB.ovhd.gpws_ldg_flap_3, gpws_flap_3_mode, false)
    
    set(GPWS_mode_flap_disabled, gpws_flap_mode and 0 or 1)
    set(GPWS_mode_flap_3, gpws_flap_3_mode and 1 or 0)
    

    
end

local function update_local_data()
    if get(TIME) - last_update > UPDATE_INTERVAL then
        last_update = get(TIME)
        
        local radio_rate = get(DELTA_TIME) > 0 and ((get(Capt_ra_alt_ft) - prev_ra) / UPDATE_INTERVAL * 60) or 0
        prev_ra = get(Capt_ra_alt_ft)
        
        data_delayed.ra_altitude = get(Capt_ra_alt_ft)
        data_delayed.ra_rate     = radio_rate
        data_delayed.vvi_rate    = get(Capt_VVI)
        data_delayed.ias         = get(IAS)
        
    end
end

local function update_gpws_terrain_mode()
    gpws_terrain_is_working = gpws_terrain_mode and get(Capt_Baro_Alt) < 18000 and get(FAILURE_GPWS_TERR) == 0 and get(AC_bus_1_pwrd) == 1 
    
    if gpws_terrain_is_working then
        set(GPWS_pred_is_active, 1)
        update_gpws_predictive()
        c, w = update_gpws_predictive_cautions()

        if c or w then  -- Force Terrain ON in this case
            set(ND_Capt_Terrain, 1)
            set(ND_Fo_Terrain, 1)
        end
        
        set(GPWS_pred_terr, c and 1 or 0)
        set(GPWS_pred_terr_pull, w and 1 or 0)

        set(GPWS_pred_obst, 0)  -- TODO Not implemented
        set(GPWS_pred_obst_pull, 0) -- TODO Not implemented

        is_caution = is_caution or c
        is_warning = is_warning or w
    else
        set(GPWS_pred_is_active, 0)
        set(GPWS_pred_terr, 0)
        set(GPWS_pred_terr_pull, 0)
        set(GPWS_pred_obst, 0)
        set(GPWS_pred_obst_pull, 0)
    end
end



local function check_inop()
    -- For sounds only

    gpws_is_active = get(FAILURE_GPWS) == 0 and gpws_system_mode
    if gpws_was_active and not gpws_is_active then
        set(GPWS_req_inop, 1)
    end
    gpws_was_active = gpws_is_active

    
    gpws_terrain_is_active = get(FAILURE_GPWS_TERR) == 0 and gpws_terrain_mode
    if gpws_terrain_was_active and not gpws_terrain_is_active then
        set(GPWS_req_terr_inop, 1)
    end
    gpws_terrain_was_active = gpws_terrain_is_active
    
end

function update()
    perf_measure_start("GPWS:update()")

    is_warning = false
    is_caution = false

    check_inop()

    update_local_data()

    update_mode_1(data_delayed.ra_altitude, data_delayed.vvi_rate)
    update_mode_2(data_delayed.ra_altitude, data_delayed.ra_rate, data_delayed.ias)
    update_mode_3(data_delayed.ra_altitude, data_delayed.vvi_rate)
    update_mode_4(data_delayed.ra_altitude, data_delayed.ias)
    mode_5_inhibited = update_mode_5(data_delayed.ra_altitude)
    
    if get(GPWS_mode_5_glideslope) + get(GPWS_mode_5_glideslope_hard) >= 1 then
        is_caution = true
    end
    
    update_mode_pitch() -- This doesn't use delayed data
    
    update_gpws_terrain_mode()
    
    update_pbs()
    
    perf_measure_stop("GPWS:update()")
end
