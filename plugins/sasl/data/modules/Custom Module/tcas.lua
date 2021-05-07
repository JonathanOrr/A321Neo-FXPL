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

local dr_my_x = globalProperty("sim/flightmodel/position/local_x")
local dr_my_y = globalProperty("sim/flightmodel/position/local_y")
local dr_my_vx = globalProperty("sim/flightmodel/position/local_vx")
local dr_my_vy = globalProperty("sim/flightmodel/position/local_vy")

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
local last_update_time = 0

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

local function update_tcas()
    local n_acfs = get(dr_num_tcas_targets)

    local M_TO_NMI = 1852.0

    local my_acf = {
        x = get(dr_my_x) / M_TO_NMI,
        y = get(dr_my_y) / M_TO_NMI,
        vx = get(dr_my_vx) / M_TO_NMI,
        vy = get(dr_my_vy) / M_TO_NMI,
        alt = get(Capt_ra_alt_ft),
        vs = get(VVI)
    }

    TCAS_sys.acf_data = {}

    for i=2,n_acfs do

        local lat = get(dr_tcas_targets_pos_lat, i)
        local lon = get(dr_tcas_targets_pos_lon, i)

        local int_acf = {
            x = get(dr_tcas_targets_pos_x, i) / M_TO_NMI,
            y = get(dr_tcas_targets_pos_y, i) / M_TO_NMI,
            alt = get(dr_tcas_targets_pos_ele, i) * 3.28084,
            vx = get(dr_tcas_targets_pos_vx, i) / M_TO_NMI,
            vy = get(dr_tcas_targets_pos_vy, i) / M_TO_NMI,
            vs = get(dr_tcas_targets_pos_vs, i)
        }

        local tcas_result, debug_info = compute_tcas(my_acf, int_acf, UPDATE_FREQ_SEC)

        local tcas_alert_value = TCAS_ALERT_NONE
        if tcas_result == TCAS_OUTPUT_TRAFFIC then
            tcas_alert_value = TCAS_ALERT_TA
        elseif tcas_result ~= TCAS_OUTPUT_CLEAR then
            tcas_alert_value = TCAS_ALERT_RA
        end
        
        table.insert(TCAS_sys.acf_data, {lat = lat, lon = lon, alt=int_acf.alt, vs=int_acf.vs, alert = tcas_alert_value, action = tcas_result, debug_reason=debug_info})
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

end
