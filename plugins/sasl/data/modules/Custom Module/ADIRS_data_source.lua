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
    return adirs_is_adr_working(i) and (get(All_on_ground) == 1 or adirs_get_ias(i) > 40) and adirs_get_ias(i) < 400
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
    if get(GPS_1_is_available) == 0 and get(GPS_1_is_available) == 0 then
        return 0
    end

    if get(GPS_1_is_available) == 1 and get(GPS_2_is_available) == 0 then
        return get(GPS_1_altitude)
    end

    if get(GPS_2_is_available) == 1 and get(GPS_1_is_available) == 0 then
        return get(GPS_2_altitude)
    end

    if i == PFD_CAPT then
        return get(GPS_1_altitude)
    else
        return get(ADIRS_source_rotary_AIRDATA) ==  1 and get(GPS_1_altitude) or get(GPS_2_altitude)
    end
end

function adirs_is_gps_alt_ok(i)
    return adirs_ir_works_att_mode(i) and (get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1)
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
    return math.abs(adirs_get_hdg(PFD_CAPT) - adirs_get_hdg(PFD_FO)) > 5
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

function adirs_how_many_irs_in_align()
    local ir1 = (ADIRS_sys[1].ir_status == IR_STATUS_IN_ALIGN and ADIRS_sys[1].ir_is_waiting_hdg) and 1 or 0
    local ir2 = (ADIRS_sys[2].ir_status == IR_STATUS_IN_ALIGN and ADIRS_sys[2].ir_is_waiting_hdg) and 1 or 0
    local ir3 = (ADIRS_sys[3].ir_status == IR_STATUS_IN_ALIGN and ADIRS_sys[3].ir_is_waiting_hdg) and 1 or 0

    return ir1+ir2+ir3
end

function adirs_set_hdg(hdg_inserted_by_the_pilot)
    local function set_hdg(adirs)
        if adirs.ir_status == IR_STATUS_IN_ALIGN then
            adirs.manual_hdg_offset = hdg_inserted_by_the_pilot - get(Flightmodel_mag_heading)
            adirs.ir_is_waiting_hdg = false
        end
    end
    set_hdg(ADIRS_sys[1])
    set_hdg(ADIRS_sys[2])
    set_hdg(ADIRS_sys[3])
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
local function is_aoa_valid(i)
    if get(ADIRS_sys[i].fail_aoa_dataref) == 1 then
        return false -- Self-detected
    end

    if ADIRS_sys[i].ir_status == IR_STATUS_OFF or ADIRS_sys[i].ir_status == IR_STATUS_FAULT then
        return false -- Failed or OFF IR
    end

    local margin = 0.3

    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1
    local aoa1 = ADIRS_sys[i].aoa
    local aoa2 = ADIRS_sys[oth1].aoa
    local aoa3 = ADIRS_sys[oth2].aoa

    return math.abs(aoa1 - aoa2) < margin or math.abs(aoa1 - aoa3) < margin
end

function adirs_get_avg_aoa()
    return voter("aoa", is_aoa_valid)
end

function adirs_how_many_aoa_disagree()
    -- This function can return only 0, 1 or 3
    return (is_aoa_valid(1) and 0 or 1) + (is_aoa_valid(2) and 0 or 1) + (is_aoa_valid(3) and 0 or 1)
end

function adirs_how_many_aoa_failed()
    local aoa1 = not (ADIRS_sys[1].ir_status == IR_STATUS_OFF or ADIRS_sys[1].ir_status == IR_STATUS_FAULT) and get(FAILURE_SENSOR_AOA_CAPT) == 0
    local aoa2 = not (ADIRS_sys[2].ir_status == IR_STATUS_OFF or ADIRS_sys[2].ir_status == IR_STATUS_FAULT) and get(FAILURE_SENSOR_AOA_FO) == 0
    local aoa3 = not (ADIRS_sys[3].ir_status == IR_STATUS_OFF or ADIRS_sys[3].ir_status == IR_STATUS_FAULT) and get(FAILURE_SENSOR_AOA_STBY) == 0

    return (aoa1 and 0 or 1) + (aoa2 and 0 or 1) + (aoa3 and 0 or 1)
end

----------------------------------------------------------------------------------------------------
-- ADR
----------------------------------------------------------------------------------------------------
local function is_adr_valid(i)

    if ADIRS_sys[i].adr_status == ADR_STATUS_OFF or ADIRS_sys[i].adr_status == ADR_STATUS_FAULT then
        return false -- Failed or OFF ADR
    end

    if (i == 1 and get(FAILURE_SENSOR_STATIC_CAPT_ERR) == 1) or
       (i == 2 and get(FAILURE_SENSOR_STATIC_FO_ERR) == 1) or
       (i == 3 and get(FAILURE_SENSOR_STATIC_STBY_ERR) == 1) then
        return false    -- I need to cheat here: the altitude of x-plane altimeter depends on the
                        -- baro settings, but it's better not to run a voter on a value that depends
                        -- on the pilot input
    end

    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1

    local ias_margin = 3
    local ias1 = ADIRS_sys[i].ias
    local ias2 = ADIRS_sys[oth1].ias
    local ias3 = ADIRS_sys[oth2].ias

    local mach_margin = 0.05
    local mach1 = ADIRS_sys[i].mach
    local mach2 = ADIRS_sys[oth1].mach
    local mach3 = ADIRS_sys[oth2].mach

    return (math.abs(mach1 - mach2) < mach_margin or math.abs(mach1 - mach3) < mach_margin) and
           (math.abs(ias1  - ias2) < ias_margin   or math.abs(ias1  - ias3) < ias_margin)
end


function adirs_get_avg_ias()
    return voter("ias", is_adr_valid)
end

function adirs_get_avg_ias_trend()
    return voter("ias_trend", is_adr_valid)
end

function adirs_get_avg_tas()
    return voter("tas", is_adr_valid)
end

function adirs_get_avg_alt()
    return voter("alt", is_adr_valid)
end

function adirs_get_avg_vs()
    return voter("vs", is_adr_valid)
end

function adirs_get_avg_mach()
    return voter("mach", is_adr_valid)
end

function adirs_how_many_adr_params_disagree()
    -- This function can return only 0, 1 or 3
    return (is_adr_valid(1) and 0 or 1) + (is_adr_valid(2) and 0 or 1) + (is_adr_valid(3) and 0 or 1)
end

----------------------------------------------------------------------------------------------------
-- IR
----------------------------------------------------------------------------------------------------

local function is_ir_valid(i)

    if ADIRS_sys[i].ir_status == IR_STATUS_OFF or ADIRS_sys[i].ir_status == IR_STATUS_FAULT then
        return false -- Failed or OFF IR
    end

    local oth1 = (i) % 3 + 1
    local oth2 = (oth1) % 3 + 1

    local margin = 5
    local pitch1 = ADIRS_sys[i].pitch
    local pitch2 = ADIRS_sys[oth1].pitch
    local pitch3 = ADIRS_sys[oth2].pitch

    local roll1 = ADIRS_sys[i].roll
    local roll2 = ADIRS_sys[oth1].roll
    local roll3 = ADIRS_sys[oth2].roll

    local hdg1 = ADIRS_sys[i].hdg
    local hdg2 = ADIRS_sys[oth1].hdg
    local hdg3 = ADIRS_sys[oth2].hdg

    return (math.abs(pitch1 - pitch2) < margin or math.abs(pitch1 - pitch3) < margin) and
           (math.abs(roll1  - roll2)  < margin or math.abs(roll1  - roll3) < margin)  and
           (math.abs(hdg1   - hdg2)  < margin  or math.abs(hdg1   - hdg3) < margin)
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

function adirs_get_avg_vpath()
    return adirs_get_avg_pitch() - adirs_get_avg_aoa()
end


function adirs_how_many_ir_params_disagree()
    -- This function can return only 0, 1 or 3
    -- It does not include AoA that is managed with a dedicated function

    return (is_ir_valid(1) and 0 or 1) + (is_ir_valid(2) and 0 or 1) + (is_ir_valid(3) and 0 or 1)
end

----------------------------------------------------------------------------------------------------
-- FMS/GPS/GPIRS
----------------------------------------------------------------------------------------------------
function adirs_gps_get_coords(i)    -- i = GPS 1 or GPS 2?
    if i==1 then
        if get(GPS_1_is_available) == 1 then
            return {get(GPS_1_lat), get(GPS_1_lon)}
        else
            return {nil,nil}
        end
    else
        if get(GPS_2_is_available) == 1 then
            return {get(GPS_2_lat), get(GPS_2_lon)}
        else
            return {nil,nil}
        end
    end
end

function adirs_gps_get_altitude(i)  -- i = GPS 1 or GPS 2?
    return i == 1 and get(GPS_1_altitude) or get(GPS_2_altitude)
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

    if     i == 1 and get(GPS_1_is_available) == 1 then
        lat = lat + get(GPS_1_lat)
        lon = lon + get(GPS_1_lon)
    elseif i == 1 and get(GPS_2_is_available) == 1 then
        lat = lat + get(GPS_2_lat)
        lon = lon + get(GPS_2_lon)
    elseif i == 2 and get(GPS_2_is_available) == 1 then
        lat = lat + get(GPS_2_lat)
        lon = lon + get(GPS_2_lon)
    elseif i == 2 and get(GPS_1_is_available) == 1 then
        lat = lat + get(GPS_1_lat)
        lon = lon + get(GPS_1_lon)
    else
        return {nil, nil} -- Not ok, no GPIRS
    end
    
    return {lat/2, lon/2}
end



