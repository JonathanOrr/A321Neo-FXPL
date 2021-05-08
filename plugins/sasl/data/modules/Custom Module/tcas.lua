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
-- File: tcas.lua
-- Short description: TCAS
-------------------------------------------------------------------------------

include("tcas_algorithm.lua")

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local MAX_H_RANGE = 100  -- NM radius
local MAX_V_RANGE = 9900 -- Feet +/-
local UPDATE_FREQ_SEC = 0.5
local M_TO_NMI = 1852.0
local SOUND_COC_DURATION = 10 -- This does not correspond to the sound! A too small value can cause traffic-traffic after TA COC

local SOUND_NONE    = 0
local SOUND_M_CROSS = 11
local SOUND_M       = 12
local SOUND_C_NOW   = 21
local SOUND_C_INC   = 22
local SOUND_C_CROSS = 23
local SOUND_C       = 24
local SOUND_D_NOW   = 31
local SOUND_D_INC   = 32
local SOUND_D_CROSS = 33
local SOUND_D       = 34
local SOUND_MON     = 41
local SOUND_COC     = 51
local SOUND_TT      = 52

-------------------------------------------------------------------------------
-- Datarefs
-------------------------------------------------------------------------------

local dr_num_tcas_targets = globalProperty("sim/cockpit2/tcas/indicators/tcas_num_acf")
local dr_tcas_targets_pos_x = globalProperty("sim/cockpit2/tcas/targets/position/x")
local dr_tcas_targets_pos_y = globalProperty("sim/cockpit2/tcas/targets/position/y")
local dr_tcas_targets_pos_lat = globalProperty("sim/cockpit2/tcas/targets/position/lat")
local dr_tcas_targets_pos_lon = globalProperty("sim/cockpit2/tcas/targets/position/lon")
local dr_tcas_targets_pos_ele = globalProperty("sim/cockpit2/tcas/targets/position/ele")
local dr_tcas_targets_pos_vx = globalProperty("sim/cockpit2/tcas/targets/position/vx")
local dr_tcas_targets_pos_vy = globalProperty("sim/cockpit2/tcas/targets/position/vy")
local dr_tcas_targets_pos_vs = globalProperty("sim/cockpit2/tcas/targets/position/vertical_speed")
local dr_tcas_targets_ground = globalProperty("sim/cockpit2/tcas/targets/position/weight_on_wheels")

local dr_my_x = globalProperty("sim/flightmodel/position/local_x")
local dr_my_y = globalProperty("sim/flightmodel/position/local_y")
local dr_my_vx = globalProperty("sim/flightmodel/position/local_vx")
local dr_my_vy = globalProperty("sim/flightmodel/position/local_vy")

local Sounds_TCAS_mnt_x   = createGlobalPropertyi("a321neo/sounds/tcas/cross_maintain", 0, false, true, false)
local Sounds_TCAS_mnt     = createGlobalPropertyi("a321neo/sounds/tcas/maintain",  0, false, true, false)
local Sounds_TCAS_clb_now = createGlobalPropertyi("a321neo/sounds/tcas/climb_now",  0, false, true, false)
local Sounds_TCAS_clb_inc = createGlobalPropertyi("a321neo/sounds/tcas/inc_climb",  0, false, true, false)
local Sounds_TCAS_clb_x   = createGlobalPropertyi("a321neo/sounds/tcas/cross_climb",  0, false, true, false)
local Sounds_TCAS_clb     = createGlobalPropertyi("a321neo/sounds/tcas/climb",  0, false, true, false)
local Sounds_TCAS_des_now = createGlobalPropertyi("a321neo/sounds/tcas/descent_now",  0, false, true, false)
local Sounds_TCAS_des_inc = createGlobalPropertyi("a321neo/sounds/tcas/inc_descent",  0, false, true, false)
local Sounds_TCAS_des_x   = createGlobalPropertyi("a321neo/sounds/tcas/cross_descent",  0, false, true, false)
local Sounds_TCAS_des     = createGlobalPropertyi("a321neo/sounds/tcas/descent",  0, false, true, false)

local Sounds_TCAS_mon     = createGlobalPropertyi("a321neo/sounds/tcas/monitor_vs",  0, false, true, false)
local Sounds_TCAS_coc     = createGlobalPropertyi("a321neo/sounds/tcas/coc",  0, false, true, false)
local Sounds_TCAS_traffic = createGlobalPropertyi("a321neo/sounds/tcas/traffic_traffic",  0, false, true, false)


-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
local last_update_time = 0

local at_least_one_ta = false
local at_least_one_ra = false
local last_tcas_sound = SOUND_NONE
local coc_start_time  = 0

TCAS_sys.acf_data = {}  -- Array with all the acfs
TCAS_sys.alert = {
    active = false,
    type = TCAS_ALERT_NONE,
}

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function update_status()

    set(TCAS_xplane_mode, 0)


    if get(TCAS_master) == 0 or get(TCAS_mode) == 0 then
        set(TCAS_actual_mode, TCAS_MODE_OFF)
        return
    end

    local failure_cond = get(FAILURE_TCAS) == 1
          or (get(FAILURE_ATC_1) == 1 and get(TCAS_atc_sel) == 1)
          or (get(FAILURE_ATC_2) == 1 and get(TCAS_atc_sel) == 2)
          or get(AC_bus_1_pwrd) == 0

    if failure_cond then
        set(TCAS_actual_mode, TCAS_MODE_FAULT)
        return
    end
    
--    set(TCAS_xplane_mode, 2)
    
    if get(TCAS_mode) == 2 then
        local radio_altitude = get(TCAS_atc_sel) == 1 and get(Capt_ra_alt_ft) or get(Fo_ra_alt_ft)
        local ta_only_cond = get(GPWS_mode_stall) == 1              -- TODO Add WINDSHEAR
                          or get(GPWS_mode_1_pullup) == 1
                          or get(GPWS_mode_2_pullup) == 1
                          or get(GPWS_pred_terr_pull) == 1
                          or get(GPWS_pred_obst_pull) == 1

       if not ta_only_cond and radio_altitude > 1000 then
            set(TCAS_actual_mode, TCAS_MODE_TARA)
            return
       end
    end

    set(TCAS_actual_mode, TCAS_MODE_TA)
end

local function update_tcas_intruder(my_acf, i)
    local lat = get(dr_tcas_targets_pos_lat, i)
    local lon = get(dr_tcas_targets_pos_lon, i)

    local int_acf = {
        x = get(dr_tcas_targets_pos_x, i) / M_TO_NMI,
        y = get(dr_tcas_targets_pos_y, i) / M_TO_NMI,
        alt = get(dr_tcas_targets_pos_ele, i) * 3.28084,
        vx = get(dr_tcas_targets_pos_vx, i) / M_TO_NMI,
        vy = get(dr_tcas_targets_pos_vy, i) / M_TO_NMI,
        vs = get(dr_tcas_targets_pos_vs, i) / 60
    }
    
    if math.abs(int_acf.alt - my_acf.alt) > MAX_V_RANGE then
        return  -- out of range (vertical)
    end
    if math.sqrt((int_acf.x - my_acf.x)^2 + (int_acf.y - my_acf.y)) > MAX_H_RANGE then
        return  -- out of range (horizontal)
    end

    local tcas_result, debug_info, my_danger = compute_tcas(my_acf, int_acf, UPDATE_FREQ_SEC)

    local tcas_alert_value = TCAS_ALERT_NONE
    if tcas_result == TCAS_OUTPUT_TRAFFIC then
        tcas_alert_value = TCAS_ALERT_TA
        at_least_one_ta = true
    elseif tcas_result ~= TCAS_OUTPUT_CLEAR then
        tcas_alert_value = TCAS_ALERT_RA
        at_least_one_ra = true
    end
    
    local intruder_data = {
                           lat = lat, lon = lon, alt=int_acf.alt, vs=int_acf.vs,
                           alert = tcas_alert_value,
                           action = tcas_result,
                           debug_reason = debug_info,
                           danger = my_danger,
                           alt_diff = my_acf.alt - int_acf.alt
                          }

    table.insert(TCAS_sys.acf_data, intruder_data)
    
    if TCAS_sys.most_dangerous == nil or TCAS_sys.most_dangerous.danger < my_danger then
        TCAS_sys.most_dangerous = intruder_data
    end
    
end

local function update_tcas()
    local n_acfs = get(dr_num_tcas_targets)

    local my_acf = {
        x = get(dr_my_x) / M_TO_NMI,
        y = get(dr_my_y) / M_TO_NMI,
        vx = get(dr_my_vx) / M_TO_NMI,
        vy = get(dr_my_vy) / M_TO_NMI,
        alt = get(Capt_Baro_Alt),
        vs = get(VVI) / 60
    }

    TCAS_sys.acf_data = {}
    TCAS_sys.most_dangerous = nil
    at_least_one_ta = false
    at_least_one_ra = false

    for i=2,n_acfs do

        if get(dr_tcas_targets_ground, i) == 0 then
             update_tcas_intruder(my_acf, i)
        end

    end
    
    TCAS_sys.alert.active = at_least_one_ta or at_least_one_ra
    TCAS_sys.alert.type   = at_least_one_ra and TCAS_ALERT_RA or (at_least_one_ta and TCAS_ALERT_TA or TCAS_ALERT_NONE)

end

-------------------------------------------------------------------------------
-- Aural messages
-------------------------------------------------------------------------------


local function set_sound(x)
    last_tcas_sound = x

    set(Sounds_TCAS_mnt_x,   x==SOUND_M_CROSS and 1 or 0)
    set(Sounds_TCAS_mnt,     x==SOUND_M and 1 or 0)
    set(Sounds_TCAS_clb_inc, x==SOUND_C_INC and 1 or 0)
    set(Sounds_TCAS_clb_now, x==SOUND_C_NOW and 1 or 0)
    set(Sounds_TCAS_clb_x,   x==SOUND_C_CROSS and 1 or 0)
    set(Sounds_TCAS_clb,     x==SOUND_C and 1 or 0)
    set(Sounds_TCAS_des_inc, x==SOUND_D_INC and 1 or 0)
    set(Sounds_TCAS_des_now, x==SOUND_D_NOW and 1 or 0)
    set(Sounds_TCAS_des_x,   x==SOUND_D_CROSS and 1 or 0)
    set(Sounds_TCAS_des,     x==SOUND_D and 1 or 0)

    set(Sounds_TCAS_mon,     x==SOUND_MON and 1 or 0)
    set(Sounds_TCAS_coc,     x==SOUND_COC and 1 or 0)
    set(Sounds_TCAS_traffic, x==SOUND_TT  and 1 or 0)
end

local function update_sounds()
    if get(TCAS_actual_mode) ~= TCAS_MODE_TARA and get(TCAS_actual_mode) ~= TCAS_MODE_TA then
        set_sound(SOUND_NONE)
        return  -- No aural warnings in other modes
    end
    
    if TCAS_sys.most_dangerous == nil or TCAS_sys.most_dangerous.alert ~= TCAS_ALERT_RA then
        -- So, no aircraft here triggered an RA, just check for the traffic and that's it
        if at_least_one_ta and (last_tcas_sound == SOUND_NONE or last_tcas_sound == SOUND_TT) and coc_start_time == 0 then
            set_sound(SOUND_TT)
        elseif last_tcas_sound ~= SOUND_NONE and last_tcas_sound ~= SOUND_TT and coc_start_time == 0 then
            coc_start_time = get(TIME)
            set_sound(SOUND_COC)
        elseif coc_start_time == 0 or get(TIME) - coc_start_time > SOUND_COC_DURATION then
            set_sound(SOUND_NONE)
            coc_start_time = 0
        end

        return
    end

    if get(TCAS_actual_mode) ~= TCAS_MODE_TARA then
        set_sound(SOUND_NONE)
        return  -- No aural RA warnings in TA
    end
    
    local what_i_want_to_say = SOUND_NONE

    -- Let's start with basic stuff
    if TCAS_sys.most_dangerous.action == TCAS_OUTPUT_CLIMB_HIGH then
        what_i_want_to_say = SOUND_C_INC
    elseif TCAS_sys.most_dangerous.action == TCAS_OUTPUT_CLIMB_LOW then
        what_i_want_to_say = SOUND_C
    elseif TCAS_sys.most_dangerous.action == TCAS_OUTPUT_DESCEND_HIGH then
        what_i_want_to_say = SOUND_D_INC
    elseif TCAS_sys.most_dangerous.action == TCAS_OUTPUT_DESCEND_LOW then
        what_i_want_to_say = SOUND_D
    end
    
    if last_tcas_sound == SOUND_NONE then
        -- Maintain V/S, only activable as the first message
        if    (what_i_want_to_say == SOUND_C     and get(Capt_VVI) > 1500)
           or (what_i_want_to_say == SOUND_C_INC and get(Capt_VVI) > 2500) then
            what_i_want_to_say = SOUND_M
        end
        
        if (what_i_want_to_say == SOUND_D and get(Capt_VVI) < -1500)
           or (what_i_want_to_say == SOUND_D_INC and get(Capt_VVI) < -2500) then
            what_i_want_to_say = SOUND_M
        end
    elseif last_tcas_sound == SOUND_C_INC and (what_i_want_to_say == SOUND_C and get(Capt_VVI) > 2500) then
            what_i_want_to_say = SOUND_M
    elseif last_tcas_sound == SOUND_D_INC and (what_i_want_to_say == SOUND_D and get(Capt_VVI) < -2500) then
            what_i_want_to_say = SOUND_M
    end
    
    if what_i_want_to_say == SOUND_NONE then
        return  -- This should not happen
    end
    
    -- If last tcas sound was an INC, CROSS or NOW, let's get it back to normal
    if (what_i_want_to_say == SOUND_C) and (last_tcas_sound == SOUND_C_INC or last_tcas_sound == SOUND_C_CROSS or last_tcas_sound == SOUND_C_NOW) then
        last_tcas_sound = SOUND_C
    end
    if (what_i_want_to_say == SOUND_D) and (last_tcas_sound == SOUND_D_INC or last_tcas_sound == SOUND_D_CROSS or last_tcas_sound == SOUND_D_NOW) then
        last_tcas_sound = SOUND_D
    end

    if last_tcas_sound == what_i_want_to_say then
        -- Nothing to do
        return
    end
    
    -- Case 1: we changed idea from descent to climb 
    if     (what_i_want_to_say == SOUND_C_INC or what_i_want_to_say == SOUND_C) 
       and (
               (last_tcas_sound > 10 and last_tcas_sound < 20) or
               (last_tcas_sound > 30 and last_tcas_sound < 50)
           )
       then
        set_sound(SOUND_C_NOW)
        last_tcas_sound = what_i_want_to_say
        return
    end

    -- Case 2: we changed idea from climb to descent
    if     (what_i_want_to_say == SOUND_D_INC or what_i_want_to_say == SOUND_D) 
       and (
               (last_tcas_sound > 10 and last_tcas_sound < 30) or
               (last_tcas_sound > 40 and last_tcas_sound < 50)
           )
       then
        set_sound(SOUND_D_NOW)
        last_tcas_sound = what_i_want_to_say
        return
    end

    -- Case 3: climb with crossing
    if (what_i_want_to_say == SOUND_C_INC or what_i_want_to_say == SOUND_C) and TCAS_sys.most_dangerous.alt_diff < 0 then
        set_sound(SOUND_C_CROSS)
        last_tcas_sound = what_i_want_to_say
        return
    end

    -- Case 4: descend with crossing
    if (what_i_want_to_say == SOUND_D_INC or what_i_want_to_say == SOUND_D) and TCAS_sys.most_dangerous.alt_diff > 0 then
        set_sound(SOUND_D_CROSS)
        last_tcas_sound = what_i_want_to_say
        return
    end

    -- Case 5: maintaining with crossing
    if (what_i_want_to_say == SOUND_M) and
       ((TCAS_sys.most_dangerous.alt_diff > 0 and get(Capt_VVI) < 0) or 
        (TCAS_sys.most_dangerous.alt_diff < 0 and get(Capt_VVI) > 0)) then
        set_sound(SOUND_M_CROSS)
        last_tcas_sound = SOUND_M
        return
    end

    -- Case 6: everything else
    set_sound(what_i_want_to_say)

end

-------------------------------------------------------------------------------
-- Main update
-------------------------------------------------------------------------------
function update()
    update_status()

    if get(TIME) - last_update_time > UPDATE_FREQ_SEC then
        update_tcas()
        update_sounds()
        last_update_time = get(TIME)
    end

end
