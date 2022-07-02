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
-- File: PFD_data_source.lua
-- Short description: Various helper functions to get data and statuses for PFD 
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Function for data dependent on data KNOBs. These are usually used by PFD and ND only!
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

local function which_adr(i) -- It returns the current ADR index in use by `i` (capt or fo)
    if i == PFD_CAPT then
        return get(ADIRS_source_rotary_AIRDATA) == -1 and ADIRS_3 or ADIRS_1
    else
        return get(ADIRS_source_rotary_AIRDATA) ==  1 and ADIRS_3 or ADIRS_2
    end
end

local function which_ir(i) -- It returns the current IR index in use by `i` (capt or fo)
    if i == PFD_CAPT then
        return get(ADIRS_source_rotary_ATHDG) == -1 and ADIRS_3 or ADIRS_1
    else
        return get(ADIRS_source_rotary_ATHDG) ==  1 and ADIRS_3 or ADIRS_2
    end
end

local function get_common_data(data_name, condition_fun)

    local avg = 0
    local n = 0
    for i=1,3 do
        if condition_fun(i) then
            avg = avg + ADIRS_sys[i][data_name]
            n = n + 1
        end
    end

    if n > 0 then
        return avg / n
    else
        return 0
    end

end

local function get_adr_data(data_name)
    local condition_fun = function(i) return ADIRS_sys[i].adr_status == ADR_STATUS_ON end
    return get_common_data(data_name, condition_fun)
end

local function get_ir_full_data(data_name)
    local condition_fun = function(i) return ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED end
    return get_common_data(data_name, condition_fun)
end

local function get_ir_partial_data(data_name)
    local condition_fun = function(i) return ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[i].ir_status == IR_STATUS_ATT_ALIGNED end
    return get_common_data(data_name, condition_fun)
end

function adirs_is_adr_working(i)
    return ADIRS_sys[which_adr(i)].adr_status == ADR_STATUS_ON
end

function adirs_ir_works_nav_mode(i)
    return ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ALIGNED
end

function adirs_ir_works_att_mode(i)
    return ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ALIGNED 
        or ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ATT_ALIGNED
end

----------------------------------------------------------------------------------------------------
-- ADR
----------------------------------------------------------------------------------------------------

function adirs_is_ias_ok(i)
    return adirs_is_adr_working(i) and (get(All_on_ground) == 1 or adirs_get_ias(i) > 40) and adirs_get_ias(i) < 450
end

function adirs_get_ias(i)
    return ADIRS_sys[which_adr(i)].ias
end

function adirs_get_ias_trend(i)
    return ADIRS_sys[which_adr(i)].ias_trend
end

function adirs_is_tas_ok(i)
    return adirs_is_adr_working(i) and adirs_is_ias_ok(i) and adirs_is_alt_ok(i)
end

function adirs_get_tas(i)
    return ADIRS_sys[which_adr(i)].tas
end

function adirs_is_aoa_ok(i)
    return adirs_ir_works_att_mode(i) and get(ADIRS_sys[which_ir(i)].fail_aoa_dataref) == 0
end

function adirs_get_aoa(i)
    return ADIRS_sys[which_ir(i)].aoa
end

function adirs_is_alt_ok(i)
    return adirs_is_adr_working(i) and adirs_get_alt(i) < 45000 and adirs_get_alt(i) > -2000  
end

function adirs_get_alt(i)
    return ADIRS_sys[which_adr(i)].alt
end

function adirs_is_vs_ok(i)
    return adirs_is_adr_working(i)
end

function adirs_get_vs(i)
    return ADIRS_sys[which_adr(i)].vs
end

function adirs_is_wind_ok(i)
    return adirs_is_adr_working(i) and adirs_ir_works_nav_mode(i) and adirs_is_ias_ok(i)
end

function adirs_get_wind_spd(i)
    return ADIRS_sys[which_adr(i)].wind_spd
end

function adirs_get_wind_dir(i)
    return ADIRS_sys[which_adr(i)].wind_dir
end

function adirs_is_mach_ok(i)
    return adirs_is_adr_working(i) and  adirs_is_tas_ok(i)
end

function adirs_get_mach(i)
    return ADIRS_sys[which_adr(i)].mach
end

----------------------------------------------------------------------------------------------------
-- IR
----------------------------------------------------------------------------------------------------

function adirs_is_att_ok(i)
    return adirs_ir_works_nav_mode(i) or adirs_ir_works_att_mode(i)
end

function adirs_get_pitch(i)
    return ADIRS_sys[which_ir(i)].pitch
end

function adirs_get_vpath(i)
    return ADIRS_sys[which_ir(i)].pitch - ADIRS_sys[which_ir(i)].aoa
end


function adirs_get_roll(i)
    return ADIRS_sys[which_ir(i)].roll
end

function adirs_is_hdg_ok(i)
    return adirs_ir_works_nav_mode(i) or (adirs_ir_works_att_mode(i) and not ADIRS_sys[which_ir(i)].ir_is_waiting_hdg)
end

function adirs_get_hdg(i)
    return ADIRS_sys[which_ir(i)].hdg
end

function adirs_is_true_hdg_ok(i)
    return adirs_ir_works_nav_mode(i)
end

function adirs_get_true_hdg(i)
    return ADIRS_sys[which_ir(i)].true_hdg
end

function adirs_is_track_ok(i)
    return adirs_ir_works_nav_mode(i)
end

function adirs_get_track(i)
    return ADIRS_sys[which_ir(i)].track
end

function adirs_is_position_ok(i)
    return adirs_ir_works_nav_mode(i)
end

function adirs_get_lat(i)
    return ADIRS_sys[which_ir(i)].lat
end

function adirs_get_lon(i)
    return ADIRS_sys[which_ir(i)].lon
end

function adirs_is_gs_ok(i)
    return adirs_ir_works_nav_mode(i)
end

function adirs_get_gs(i)
    return ADIRS_sys[which_ir(i)].gs
end

function adirs_get_gps_alt(i)

    local gps1_ok = GPS_sys[1].status == GPS_STATUS_NAV
    local gps2_ok = GPS_sys[2].status == GPS_STATUS_NAV

    if not gps1_ok and not gps2_ok then
        return 0
    end

    if gps1_ok and not gps2_ok then
        return GPS_sys[1].alt
    end

    if not gps1_ok and gps2_ok then
        return GPS_sys[2].alt
    end

    if i == PFD_CAPT then
        return GPS_sys[1].alt
    else
        return get(ADIRS_source_rotary_AIRDATA) ==  1 and GPS_sys[1].alt or GPS_sys[2].alt
    end
end

function adirs_is_gps_alt_ok(i)
    return adirs_ir_works_att_mode(i) and (GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV)
end

function adirs_is_gloads_ok(i)
    return adirs_ir_works_nav_mode(i)
end

function adirs_get_gload_vert(i)
    return ADIRS_sys[which_ir(i)].g_load_vert
end

function adirs_get_gload_lat(i)
    return ADIRS_sys[which_ir(i)].g_load_lat
end

function adirs_get_gload_long(i)
    return ADIRS_sys[which_ir(i)].g_load_long
end

----------------------------------------------------------------------------------------------------
-- PFD - Misc functions
----------------------------------------------------------------------------------------------------


function adirs_is_buss_visible(i)
    if i == PFD_CAPT then
        return (get(BUSS_Capt_man_enabled) == 1 or adirs_how_many_adrs_work() == 0) and adirs_is_aoa_ok(i)
    else
        return (get(BUSS_Fo_man_enabled) == 1 or adirs_how_many_adrs_work() == 0) and adirs_is_aoa_ok(i)
    end
end

function adirs_is_gps_alt_visible(i)
    if i == PFD_CAPT then
        return (get(BUSS_Capt_man_enabled) == 1 or adirs_how_many_adrs_work() == 0) and adirs_is_gps_alt_ok(i)
    else
        return (get(BUSS_Fo_man_enabled) == 1 or adirs_how_many_adrs_work() == 0) and adirs_is_gps_alt_ok(i)
    end
end

function adirs_pfds_disagree_on_ias()
    return math.abs(adirs_get_ias(PFD_CAPT) - adirs_get_ias(PFD_FO)) > 3
end

function adirs_pfds_disagree_on_alt()
    local diff = math.abs(adirs_get_alt(PFD_CAPT) - adirs_get_alt(PFD_FO))
    return (get(Capt_Baro) == 29.92 or get(Capt_Baro) == 29.92)
            and diff > 500
            or diff > 250
end

function adirs_pfds_disagree_on_att()
    return math.abs(adirs_get_pitch(PFD_CAPT) - adirs_get_pitch(PFD_FO)) > 5 or math.abs(adirs_get_roll(PFD_CAPT) - adirs_get_roll(PFD_FO)) > 5
end

function adirs_pfds_disagree_on_hdg()
    local diff = Math_angle_diff(adirs_get_hdg(PFD_CAPT), adirs_get_hdg(PFD_FO))
    return math.abs(diff) > 5
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Functions for data independent from the ADIRS - Used for FBW, AP, etc. 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

function adirs_how_many_adrs_work()
    local adr1 = ADIRS_sys[1].adr_status == ADR_STATUS_ON and 1 or 0
    local adr2 = ADIRS_sys[2].adr_status == ADR_STATUS_ON and 1 or 0
    local adr3 = ADIRS_sys[3].adr_status == ADR_STATUS_ON and 1 or 0

    return adr1+adr2+adr3
end

function adirs_set_hdg(hdg_inserted_by_the_pilot)
    ADIRS_sys[1]:set_hdg(hdg_inserted_by_the_pilot)
    ADIRS_sys[2]:set_hdg(hdg_inserted_by_the_pilot)
    ADIRS_sys[3]:set_hdg(hdg_inserted_by_the_pilot)
end

function adirs_how_many_irs_fully_work()
    local ir1 = ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED and 1 or 0
    local ir2 = ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED and 1 or 0
    local ir3 = ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED and 1 or 0

    return ir1+ir2+ir3
end

function adirs_how_many_irs_partially_work()
    local ir1 = (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0
    local ir2 = (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0
    local ir3 = (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0

    return ir1+ir2+ir3
end

local function voter(field, check_function)

    local total_valid = 0
    local total_value = 0

    for i=1,3 do
        local x = ADIRS_sys[i][field]

        if check_function(i) then
            total_valid = total_valid + 1
            total_value = total_value + x
        end
    end

    if total_valid > 0 then
        return total_value / total_valid
    else
        return 0    -- No agreement = No valid data = Triple failure
    end
end

----------------------------------------------------------------------------------------------------
-- AoA
----------------------------------------------------------------------------------------------------
function adirs_is_aoa_valid(i)
    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1
    local i_off =    not (ADIRS_sys[i].ir_status    == IR_STATUS_ALIGNED or ADIRS_sys[i].ir_status    == IR_STATUS_ATT_ALIGNED) or get(ADIRS_sys[i].fail_aoa_dataref)    == 1
    local oth1_off = not (ADIRS_sys[oth1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[oth1].ir_status == IR_STATUS_ATT_ALIGNED) or get(ADIRS_sys[oth1].fail_aoa_dataref) == 1
    local oth2_off = not (ADIRS_sys[oth2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[oth2].ir_status == IR_STATUS_ATT_ALIGNED) or get(ADIRS_sys[oth2].fail_aoa_dataref) == 1
    local only_one_active = oth1_off and oth2_off

    if i_off then
        return false -- Self-detected, or shuntdown
    end

    if only_one_active then
        return true --if there is only one IR left, the system can't tell which is correct
    end

    local margin = 0.3

    local aoa1 = ADIRS_sys[i].aoa
    local aoa2 = ADIRS_sys[oth1].aoa
    local aoa3 = ADIRS_sys[oth2].aoa

    local aoa_1v2 = false
    local aoa_1v3 = false

    if not oth1_off then
        aoa_1v2 = math.abs(aoa1 - aoa2) < margin
    end
    if not oth2_off then
        aoa_1v3 = math.abs(aoa1 - aoa3) < margin
    end

    return aoa_1v2 or aoa_1v3
end

function adirs_get_avg_aoa()
    return voter("aoa", adirs_is_aoa_valid)
end

function adirs_how_many_aoa_working()
    local aoa1 = (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_CAPT) == 0
    local aoa2 = (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_FO) == 0
    local aoa3 = (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_STBY) == 0

    return (aoa1 and 1 or 0) + (aoa2 and 1 or 0) + (aoa3 and 1 or 0)
end

function adirs_aoa_disagree()
    --check disagreement between working IRs
    if adirs_how_many_aoa_working() <= 1 then
        return false
    end

    local TOTAL_DISAGREE = 0

    if (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_CAPT) == 0 then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_aoa_valid(1) and 0 or 1)
    end
    if (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_FO) == 0 then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_aoa_valid(2) and 0 or 1)
    end
    if (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) and get(FAILURE_SENSOR_AOA_STBY) == 0 then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_aoa_valid(3) and 0 or 1)
    end

    if TOTAL_DISAGREE >= (adirs_how_many_aoa_working() - 1) then
        return true
    else
        return false
    end
end

----------------------------------------------------------------------------------------------------
-- ADR
----------------------------------------------------------------------------------------------------
function adirs_is_adr_valid(i)
    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1
    local i_off    = ADIRS_sys[i].adr_status == ADR_STATUS_OFF    or ADIRS_sys[i].adr_status == ADR_STATUS_FAULT
    local oth1_off = ADIRS_sys[oth1].adr_status == ADR_STATUS_OFF or ADIRS_sys[oth1].adr_status == ADR_STATUS_FAULT
    local oth2_off = ADIRS_sys[oth2].adr_status == ADR_STATUS_OFF or ADIRS_sys[oth2].adr_status == ADR_STATUS_FAULT
    local only_one_active = oth1_off and oth2_off

    if i_off then
        return false -- Failed or OFF ADR
    end

    if only_one_active then
        return true --if there is only one ADR left, the system can't tell which is correct
    end

    -- I need to cheat here: the altitude of x-plane altimeter depends on the
    -- baro settings, but it's better not to run a voter on a value that depends
    -- on the pilot input
    local static_errs = {
        FAILURE_SENSOR_STATIC_CAPT_ERR,
        FAILURE_SENSOR_STATIC_FO_ERR,
        FAILURE_SENSOR_STATIC_STBY_ERR,
    }

    local self_v_oth1 = false
    local self_v_oth2 = false

    if not oth1_off then
        self_v_oth1 = get(static_errs[i]) == 0 and get(static_errs[oth1]) == 0
    end
    if not oth2_off then
        self_v_oth2 = get(static_errs[i]) == 0 and get(static_errs[oth2]) == 0
    end

    if not self_v_oth1 and not self_v_oth2 then
        return false
    end

    --compare general ADR data--
    local compare = {
        {data = "ias",  margin = 3},
        {data = "mach", margin = 0.05},
    }

    for key, val in pairs(compare) do
        local selfData = ADIRS_sys[i][val.data]
        local oth1Data = ADIRS_sys[oth1][val.data]
        local oth2Data = ADIRS_sys[oth2][val.data]

        self_v_oth1 = false
        self_v_oth2 = false

        if not oth1_off then
            self_v_oth1 = math.abs(selfData  -  oth1Data) < val.margin
        end
        if not oth2_off then
            self_v_oth2 = math.abs(selfData  -  oth2Data) < val.margin
        end

        if not self_v_oth1 and not self_v_oth2 then
            return false
        end
    end

    return true
end

function adirs_get_avg_ias()
    return voter("ias", adirs_is_adr_valid)
end

function adirs_get_avg_ias_trend()
    return voter("ias_trend", adirs_is_adr_valid)
end

function adirs_get_avg_tas()
    return voter("tas", adirs_is_adr_valid)
end

function adirs_get_avg_alt()
    return voter("alt", adirs_is_adr_valid)
end

function adirs_get_avg_vs()
    return voter("vs", adirs_is_adr_valid)
end

function adirs_get_avg_mach()
    return voter("mach", adirs_is_adr_valid)
end

function adirs_adr_params_disagree()
    --check disagreement between working ADRs
    if adirs_how_many_adrs_work() <= 1 then
        return false
    end

    local TOTAL_DISAGREE = 0

    if ADIRS_sys[1].adr_status == ADR_STATUS_ON then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_adr_valid(1) and 0 or 1)
    end
    if ADIRS_sys[2].adr_status == ADR_STATUS_ON then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_adr_valid(2) and 0 or 1)
    end
    if ADIRS_sys[3].adr_status == ADR_STATUS_ON then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (adirs_is_adr_valid(3) and 0 or 1)
    end

    if TOTAL_DISAGREE >= (adirs_how_many_adrs_work() - 1) then
        return true
    else
        return false
    end

    return TOTAL_DISAGREE
end

----------------------------------------------------------------------------------------------------
-- IR
----------------------------------------------------------------------------------------------------

local function is_ir_valid(i)
    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1
    local i_off =    not (ADIRS_sys[i].ir_status    == IR_STATUS_ALIGNED or ADIRS_sys[i].ir_status    == IR_STATUS_ATT_ALIGNED)
    local oth1_off = not (ADIRS_sys[oth1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[oth1].ir_status == IR_STATUS_ATT_ALIGNED)
    local oth2_off = not (ADIRS_sys[oth2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[oth2].ir_status == IR_STATUS_ATT_ALIGNED)
    local only_one_active = oth1_off and oth2_off

    if i_off then
        return false -- Failed or OFF IR
    end

    if only_one_active then
        return true --if there is only one IR left, the system can't tell which is correct
    end

    --compare general IR data--
    local compare = {
        {data = "pitch", margin = 5},
        {data = "roll",  margin = 5},
        {data = "hdg",   margin = 5},
    }

    for key, val in pairs(compare) do
        local selfData = ADIRS_sys[i][val.data]
        local oth1Data = ADIRS_sys[oth1][val.data]
        local oth2Data = ADIRS_sys[oth2][val.data]

        local self_v_oth1 = false
        local self_v_oth2 = false

        if not oth1_off then
            self_v_oth1 = math.abs(selfData  -  oth1Data) < val.margin
        end
        if not oth2_off then
            self_v_oth2 = math.abs(selfData  -  oth2Data) < val.margin
        end

        if not self_v_oth1 and not self_v_oth2 then
            return false
        end
    end

    return true
end

function adirs_get_avg_pitch()
    return voter("pitch", is_ir_valid)
end

function adirs_get_avg_roll()
    return voter("roll", is_ir_valid)
end

function adirs_get_avg_hdg()
    return voter("hdg", is_ir_valid)
end
function adirs_get_avg_true_hdg()
    return voter("true_hdg", is_ir_valid)
end
function adirs_get_avg_track()
    return voter("track", is_ir_valid)
end

function adirs_get_avg_gs()
    return voter("gs", is_ir_valid)
end

function adirs_get_avg_vpath()
    return adirs_get_avg_pitch() - adirs_get_avg_aoa()
end


function adirs_ir_disagree()
    -- It does not include AoA that is managed with a dedicated function
    --check disagreement between working IRs
    if adirs_how_many_irs_partially_work() <= 1 then
        return false
    end

    local TOTAL_DISAGREE = 0

    if (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (is_ir_valid(1) and 0 or 1)
    end
    if (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (is_ir_valid(2) and 0 or 1)
    end
    if (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) then
        TOTAL_DISAGREE = TOTAL_DISAGREE + (is_ir_valid(3) and 0 or 1)
    end

    if TOTAL_DISAGREE >= (adirs_how_many_irs_partially_work() - 1) then
        return true
    else
        return false
    end
end

----------------------------------------------------------------------------------------------------
-- FMS/GPS/GPIRS
----------------------------------------------------------------------------------------------------
function adirs_gps_get_coords(i)    -- i = GPS 1 or GPS 2?
    if i==1 then
        if GPS_sys[1].status == GPS_STATUS_NAV then
            return {GPS_sys[1].lat, GPS_sys[1].lon}
        else
            return {nil,nil}
        end
    else
        if GPS_sys[2].status == GPS_STATUS_NAV then
            return {GPS_sys[2].lat, GPS_sys[2].lon}
        else
            return {nil,nil}
        end
    end
end

function adirs_gps_get_altitude(i)  -- i = GPS 1 or GPS 2?
    return i == 1 and GPS_sys[1].alt or GPS_sys[2].alt
end

function adirs_get_mixed_irs()
    local lat = 0
    local lon = 0
    local n = 0
    for i=1,3 do
        if ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED then
            lat = lat + ADIRS_sys[i].lat
            lon = lon + ADIRS_sys[i].lon
            n = n + 1
        end
    end
    
    if n > 0 then
        return {lat/n, lon/n}
    else
        return {nil,nil}
    end
end

function adirs_get_fms(i) -- i==FMS1 or FMS2?
    local gpirs = adirs_get_gpirs(i)
    if gpirs[1] ~= nil and gpirs[2] ~= nil then
        return gpirs
    end
    
    local mixed_irs = adirs_get_mixed_irs()
    if mixed_irs[1] == nil or mixed_irs[2] == nil then
        return {nil,nil}
    end
    
    return {mixed_irs[1]+ADIRS_sys.FMS_bias[i][1], mixed_irs[2]+ADIRS_sys.FMS_bias[i][2]}
end

function adirs_get_gpirs(i) -- i == 1 CAPT SIDE, i==2 FO SIDE. It returns lat,lon. It may return nil,nil!
    local lat = 0
    local lon = 0
    local ok = false

    local ref_adirs = (i-1)*2 + 1

    if ADIRS_sys[ref_adirs].ir_status == IR_STATUS_ALIGNED then
        lat = lat + ADIRS_sys[ref_adirs].lat
        lon = lon + ADIRS_sys[ref_adirs].lon
        ok = true
    elseif ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED then
        lat = lat + ADIRS_sys[3].lat
        lon = lon + ADIRS_sys[3].lon
        ok = true
    end

    if not ok then
        return {nil,nil}  -- Not ok, no GPIRS
    end

    if     i == 1 and GPS_sys[1].status == GPS_STATUS_NAV then
        lat = lat + GPS_sys[1].lat
        lon = lon + GPS_sys[1].lon
    elseif i == 1 and GPS_sys[2].status == GPS_STATUS_NAV then
        lat = lat + GPS_sys[2].lat
        lon = lon + GPS_sys[2].lon
    elseif i == 2 and GPS_sys[2].status == GPS_STATUS_NAV then
        lat = lat + GPS_sys[2].lat
        lon = lon + GPS_sys[2].lon
    elseif i == 2 and GPS_sys[1].status == GPS_STATUS_NAV then
        lat = lat + GPS_sys[1].lat
        lon = lon + GPS_sys[1].lon
    else
        return {nil, nil} -- Not ok, no GPIRS
    end
    
    return {lat/2, lon/2}
end



