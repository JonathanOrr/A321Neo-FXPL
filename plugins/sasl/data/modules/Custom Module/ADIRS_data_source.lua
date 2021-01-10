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

function is_adr_working(i)
    return ADIRS_sys[which_adr(i)].adr_status == ADR_STATUS_ON
end

function ir_works_nav_mode(i)
    return ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ALIGNED
end

function ir_works_att_mode(i)
    return ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ALIGNED 
        or ADIRS_sys[which_ir(i)].ir_status == IR_STATUS_ATT_ALIGNED
end

function how_many_adrs_work()
    local adr1 = ADIRS_sys[1].adr_status == ADR_STATUS_ON and 1 or 0
    local adr2 = ADIRS_sys[2].adr_status == ADR_STATUS_ON and 1 or 0
    local adr3 = ADIRS_sys[3].adr_status == ADR_STATUS_ON and 1 or 0
    
    return adr1+adr2+adr3
end

function how_many_irs_fully_work()
    local ir1 = ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED and 1 or 0
    local ir2 = ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED and 1 or 0
    local ir3 = ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED and 1 or 0
    
    return ir1+ir2+ir3
end

function how_many_irs_partially_work()
    local ir1 = (ADIRS_sys[1].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[1].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0
    local ir2 = (ADIRS_sys[2].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[2].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0
    local ir3 = (ADIRS_sys[3].ir_status == IR_STATUS_ALIGNED or ADIRS_sys[3].ir_status == IR_STATUS_ATT_ALIGNED) and 1 or 0
    
    return ir1+ir2+ir3
end

-- ADR

function is_ias_ok(i)
    return is_adr_working(i)
end

function get_ias(i)
    return ADIRS_sys[which_adr(i)].ias
end

function get_avg_ias()
    return get_adr_data("ias")
end


function get_ias_trend(i)
    return ADIRS_sys[which_adr(i)].ias_trend
end

function is_tas_ok(i)
    return is_adr_working(i)
end

function get_tas(i)
    return ADIRS_sys[which_adr(i)].tas
end

function get_avg_tas()
    return get_adr_data("tas")
end

function is_aoa_ok(i)
    return is_adr_working(i)
end

function get_aoa(i)
    return ADIRS_sys[which_adr(i)].aoa
end

function get_avg_aoa()
    return get_adr_data("aoa")
end

function is_alt_ok(i)
    return is_adr_working(i)
end

function get_alt(i)
    return ADIRS_sys[which_adr(i)].alt
end

function get_avg_alt()
    return get_adr_data("alt")
end

function is_vs_ok(i)
    return is_adr_working(i)
end

function get_vs(i)
    return ADIRS_sys[which_adr(i)].vs
end

function get_avg_vs()
    return get_adr_data("vs")
end

function is_wind_ok(i)
    return is_adr_working(i) and ir_works_nav_mode(i)
end

function get_wind_spd(i)
    return ADIRS_sys[which_adr(i)].wind_spd
end

function get_wind_dir(i)
    return ADIRS_sys[which_adr(i)].wind_dir
end

function is_mach_ok(i)
    return is_adr_working(i)
end

function get_mach(i)
    return ADIRS_sys[which_adr(i)].mach
end

-- IR

function is_att_ok(i)
    return ir_works_nav_mode(i) or ir_works_att_mode(i)
end

function get_pitch(i)
    return ADIRS_sys[which_ir(i)].pitch
end

function get_roll(i)
    return ADIRS_sys[which_ir(i)].roll
end

function get_avg_pitch()
    return get_ir_partial_data("pitch")
end

function get_avg_roll()
    return get_ir_partial_data("roll")
end

function is_hdg_ok(i)
    return ir_works_nav_mode(i) or (ir_works_att_mode(i) and not ADIRS_sys[which_ir(i)].ir_is_waiting_hdg)
end

function get_hdg(i)
    return ADIRS_sys[which_ir(i)].hdg
end

function get_avg_hdg()
    return get_ir_partial_data("hdg")
end

function is_true_hdg_ok(i)
    return ir_works_nav_mode(i)
end

function get_true_hdg(i)
    return ADIRS_sys[which_ir(i)].true_hdg
end

function get_avg_hdg()
    return get_ir_full_data("true_hdg")
end

function is_track_ok(i)
    return ir_works_nav_mode(i)
end

function get_track(i)
    return ADIRS_sys[which_ir(i)].track
end

function get_avg_track()
    return get_ir_full_data("track")
end

function is_position_ok(i)
    return ir_works_nav_mode(i)
end

function get_lat(i)
    return ADIRS_sys[which_ir(i)].lat
end

function get_lon(i)
    return ADIRS_sys[which_ir(i)].lon
end

function is_gs_ok(i)
    return ir_works_nav_mode(i)
end

function get_gs(i)
    return ADIRS_sys[which_ir(i)].gs
end
