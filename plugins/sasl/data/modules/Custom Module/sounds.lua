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
-- File: sounds.lua 
-- Short description: Sound management
-------------------------------------------------------------------------------

include('sounds_GPWS.lua')

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local BLOWER_VOL_RISE_TIME    = 1       -- Time (in sec) required to go from 0 to max volume (self-test)
local BLOWER_SHUTDOWN_DELAY   = 0.5     -- This must be higher than the elec bus switch time
local BLOWER_START_DELAY_TIME = 5
local BLOWER_SELF_TEST_TIME   = 8

-------------------------------------------------------------------------------
-- Datarefs
-------------------------------------------------------------------------------

local Sounds_elec_bus_delayed = createGlobalPropertyf("a321neo/sounds/elec_bus_delayed", 0, false, true, false)
local Sounds_blower_volume    = createGlobalPropertyf("a321neo/sounds/blower_volume", 0, false, true, false)    -- 0: OFF, 0.5: NORMAL, 1: TEST
local Sounds_extract_delayed  = createGlobalPropertyf("a321neo/sounds/extract_delayed", 0, false, true, false)

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
local blower_stop_time  = 0
local blower_start_time = 0
local blower_fast_start = false

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------


local function thrust_rush()
    local athr_pos_L = get(ATHR_is_overriding) == 1 and get(ATHR_desired_N1, 1) or math.min(get(Throttle_blue_dot, 1), get(ATHR_desired_N1, 1))
    local athr_pos_R = get(ATHR_is_overriding) == 1 and get(ATHR_desired_N1, 2) or math.min(get(Throttle_blue_dot, 2), get(ATHR_desired_N1, 2))

    if get(ATHR_is_controlling) == 0 and get(ATHR_is_overriding) == 0 then
        athr_pos_L = get(Throttle_blue_dot, 1)
        athr_pos_R = get(Throttle_blue_dot, 2)
    end

    set(SOUND_rush_L , get(Throttle_blue_dot, 1) - get(Eng_1_N1))
    set(SOUND_rush_R , get(Throttle_blue_dot, 2) - get(Eng_2_N1))
end

local function reverser_drfs()
    if get(Eng_1_reverser_deployment) > 0.1 then
        set(REV_L, Set_anim_value_no_lim(get(REV_L), get(Eng_1_N1), 1) )
    else
        set(REV_L, Set_anim_value_no_lim(get(REV_L), 0, 1) )
    end

    if get(Eng_2_reverser_deployment) > 0.1 then
        set(REV_R, Set_anim_value_no_lim(get(REV_R), get(Eng_2_N1), 1) )
    else
        set(REV_R, Set_anim_value_no_lim(get(REV_R), 0, 1) )
    end
end


local function elec_delays()
    if get(AC_ess_bus_pwrd) == 1 then
        set(Sounds_elec_bus_delayed, 1) 
    else
        Set_dataref_linear_anim(Sounds_elec_bus_delayed, 0, 0, 1, 0.5)
    end

end

local function update_blower()

    if debug_kill_blowers then set(Sounds_blower_volume, 0) return end

    -- Blower logic:
    -- 1. It delays for 5 second on startup +8 seconds for test
    -- 2. it turns on and off instantly on override switch
    -- 3. It does not restart in a power swap

    if get(FAILURE_AIRCOND_VENT_BLOWER) == 1 or get(Ventilation_blower_override) == 1 then
        -- No chance here, the blower is failed or the override switch pressed
        -- switch off immediately
        Set_dataref_linear_anim(Sounds_blower_volume, 0, 0, 1, BLOWER_VOL_RISE_TIME)
        blower_fast_start = true    -- In this case, the next start would be without the delay and
                                    -- self test
        return
    end

    if blower_fast_start and get(Ventilation_blower_running) == 1 then
        blower_stop_time = 0
        Set_dataref_linear_anim(Sounds_blower_volume, 0.5, 0, 1, BLOWER_VOL_RISE_TIME)
        return
    end

    blower_fast_start = false

    if get(Ventilation_blower_running) == 0 then 
        if blower_stop_time == 0 then
            -- This happens only when the elec is off
            blower_stop_time = get(TIME)
        end

        if get(TIME) - blower_stop_time > BLOWER_SHUTDOWN_DELAY then
            Set_dataref_linear_anim(Sounds_blower_volume, 0, 0, 1, BLOWER_VOL_RISE_TIME)
            blower_start_time = 0
            return
        end

        return -- Otherwise wait and stay with the previous setting
    end

    -- Ok if we are here, the blower is running (or about to run)
    blower_stop_time = 0

    if blower_start_time == 0 then
        blower_start_time = get(TIME)
    end

    local diff_time = get(TIME) - blower_start_time
    if diff_time > BLOWER_START_DELAY_TIME + BLOWER_SELF_TEST_TIME or get(All_on_ground) == 0 then
        -- Normal sound
        Set_dataref_linear_anim(Sounds_blower_volume, 0.5, 0, 1, BLOWER_VOL_RISE_TIME)
    elseif diff_time > BLOWER_START_DELAY_TIME then
        -- Self-test sound
        Set_dataref_linear_anim(Sounds_blower_volume, 1, 0, 1, BLOWER_VOL_RISE_TIME)
    end

end

local function update_extract()

    Set_dataref_linear_anim(Sounds_extract_delayed, get(Ventilation_extract_running), 0, 1, 0.2)

end

local function gpws_sounds()
    set(GPWS_at_least_one_triggered, 1)

    if get(AC_bus_1_pwrd) == 1 then
        set_alt_callouts()
        update_retard()
        play_gpws_sounds()
    end
end

-------------------------------------------------------------------------------
-- update()
-------------------------------------------------------------------------------


function update()
    elec_delays()
    update_blower()
    update_extract()
    gpws_sounds()
    thrust_rush()
    reverser_drfs()
end
