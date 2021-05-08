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
local Sounds_TCAS_clb_inc = createGlobalPropertyi("a321neo/sounds/tcas/inc_climb",  0, false, true, false)
local Sounds_TCAS_clb_x   = createGlobalPropertyi("a321neo/sounds/tcas/cross_climb",  0, false, true, false)
local Sounds_TCAS_clb     = createGlobalPropertyi("a321neo/sounds/tcas/climb",  0, false, true, false)
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
    end
    
    local intruder_data = {
                           lat = lat, lon = lon, alt=int_acf.alt, vs=int_acf.vs,
                           alert = tcas_alert_value,
                           action = tcas_result,
                           debug_reason = debug_info,
                           danger = my_danger
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

    for i=2,n_acfs do

        if get(dr_tcas_targets_ground, i) == 0 then
             update_tcas_intruder(my_acf, i)
        end

    end
end

-------------------------------------------------------------------------------
-- Aural messages
-------------------------------------------------------------------------------

local SOUND_NONE    = 0
local SOUND_M_CROSS = 1
local SOUND_M       = 2
local SOUND_C_INC   = 3
local SOUND_C_CROSS = 4
local SOUND_C       = 5
local SOUND_D_INC   = 6
local SOUND_D_CROSS = 7
local SOUND_D       = 8
local SOUND_MON     = 9
local SOUND_COC     = 10
local SOUND_TT      = 11

local function set_sound(x)
    set(Sounds_TCAS_mnt_x,   x==SOUND_M_CROSS and 1 or 0)
    set(Sounds_TCAS_mnt,     x==SOUND_M and 1 or 0)
    set(Sounds_TCAS_clb_inc, x==SOUND_C_INC and 1 or 0)
    set(Sounds_TCAS_clb_x,   x==SOUND_C_CROSS and 1 or 0)
    set(Sounds_TCAS_clb,     x==SOUND_C and 1 or 0)
    set(Sounds_TCAS_des_inc, x==SOUND_D_INC and 1 or 0)
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
        if at_least_one_ta then
            set_sound(SOUND_TT)
        else
            set_sound(SOUND_NONE)
        end

        return
    end

    if get(TCAS_actual_mode) ~= TCAS_MODE_TARA then
        set_sound(SOUND_NONE)
        return  -- No aural RA warnings in TA
    end

end

-------------------------------------------------------------------------------
-- Main update
-------------------------------------------------------------------------------
function update()
    update_status()

    if get(TIME) - last_update_time > UPDATE_FREQ_SEC then
        update_tcas()
        last_update_time = get(TIME)
    end

    update_sounds()
end
