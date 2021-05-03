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

Sounds_elec_bus_delayed = createGlobalPropertyf("a321neo/sounds/elec_bus_delayed", 0, false, true, false)
Sounds_blower_delayed   = createGlobalPropertyf("a321neo/sounds/blower_delayed", 0, false, true, false)
Sounds_extract_delayed  = createGlobalPropertyf("a321neo/sounds/extract_delayed", 0, false, true, false)

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

local blower_flag = false
local blower_start_time = 0

local function blower_extract_delay()
    if get(AC_ess_bus_pwrd) == 1 then
        set(Sounds_elec_bus_delayed, 1) 
    else
        Set_dataref_linear_anim(Sounds_elec_bus_delayed, 0, 0, 1, 0.5)
    end

    if get(AC_bus_1_pwrd) == 1 and get(FAILURE_AIRCOND_VENT_BLOWER) == 0 and not blower_flag then
        blower_start_time = get(TIME)
        print(blower_start_time)
        blower_flag = true
    elseif not(get(AC_bus_1_pwrd) == 1 and get(FAILURE_AIRCOND_VENT_BLOWER) == 0) then
        blower_flag = false
    end

    if get(Ventilation_blower_running) == 1 and  get(TIME) - blower_start_time < 5 then
        set(Sounds_blower_delayed, 0)
    elseif get(Ventilation_blower_running) == 1 and  get(TIME) - blower_start_time > 5 then
        set(Sounds_blower_delayed, 1)
    else
        set(Sounds_blower_delayed, 0)
    end
    
    Set_dataref_linear_anim(Sounds_extract_delayed, get(Ventilation_extract_running), 0, 1, 0.2)


    if get(AC_bus_1_pwrd) == 1 then
        set_alt_callouts()
        update_retard()
        play_gpws_sounds()
    end
end

function update()
    blower_extract_delay()
    thrust_rush()
    reverser_drfs()
end
