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


local THIS_PAGE = MCDU_Page:new({id=402})

local function at_least_one_ir_aligning()
    return true -- ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_IN_ALIGN or ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_IN_ALIGN or ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_IN_ALIGN
end

local function get_irs_status(i)
    if ADIRS_sys[i].ir_status == IR_STATUS_OFF then
        return "OFF", ECAM_WHITE
    elseif ADIRS_sys[i].ir_status == IR_STATUS_IN_ALIGN and (get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1) then
        return "ALIGNING ON GPS", ECAM_WHITE
    elseif ADIRS_sys[i].ir_status == IR_STATUS_IN_ALIGN and (get(GPS_1_is_available) == 0 and get(GPS_2_is_available) == 0) then
        return "ALIGNING ON ---", ECAM_WHITE
    elseif ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED then
        return "ALIGNED ON GPS", ECAM_WHITE
    elseif ADIRS_sys[i].ir_status == IR_STATUS_ATT_ALIGNED then
        return "IN ATT", ECAM_WHITE
    else
        return "---", ECAM_WHITE
    end
end

function THIS_PAGE:render_gps(mcdu_data)
    if not at_least_one_ir_aligning() then
        return
    end
    
    self:set_line(mcdu_data, MCDU_LEFT, 2, "LAT   GPS POSITION  LONG", MCDU_SMALL, ECAM_WHITE)
    if get(GPS_1_is_available) == 0 and get(GPS_2_is_available) == 0 then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "--°"..mcdu_format_force_to_small("--")..".--", MCDU_LARGE, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "---°"..mcdu_format_force_to_small("--")..".--", MCDU_LARGE, ECAM_WHITE)
        return
    end

    local lat_d, lat_m, lat_s, lat_p = mcdu_ctrl_dd_to_dmsd(get(Aircraft_lat), "lat")
    local lon_d, lon_m, lon_s, lon_p = mcdu_ctrl_dd_to_dmsd(get(Aircraft_long), "lon")

    lat_d = Fwd_string_fill(tostring(math.floor(lat_d)), "0", 2)
    lat_m = Fwd_string_fill(tostring(math.floor(lat_m)), "0", 2)
    lon_d = Fwd_string_fill(tostring(math.floor(lon_d)), "0", 3)
    lon_m = Fwd_string_fill(tostring(math.floor(lon_m)), "0", 2)

    
    self:set_line(mcdu_data, MCDU_LEFT,  2, lat_d .. "°" .. mcdu_format_force_to_small(lat_m) .. "." .. math.floor(lat_s) .. lat_p, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, lon_d .. "°".. mcdu_format_force_to_small(lon_m) .. "." .. math.floor(lon_s) .. lon_p, MCDU_LARGE, ECAM_GREEN)
    
end

function THIS_PAGE:render_irs(mcdu_data, i)
    self:set_line(mcdu_data, MCDU_LEFT, 2+i, "  IRS" .. i .. " " .. get_irs_status(i), MCDU_SMALL, ECAM_WHITE)
    

    if ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED or (ADIRS_sys[i].ir_status == IR_STATUS_IN_ALIGN and (get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1)) then
        local lat_d, lat_m, lat_s, lat_p = mcdu_ctrl_dd_to_dmsd(get(Aircraft_lat), "lat")
        local lon_d, lon_m, lon_s, lon_p = mcdu_ctrl_dd_to_dmsd(get(Aircraft_long), "lon")
        
        lat_d = Fwd_string_fill(tostring(math.floor(lat_d)), "0", 2)
        lat_m = Fwd_string_fill(tostring(math.floor(lat_m)), "0", 2)
        lon_d = Fwd_string_fill(tostring(math.floor(lon_d)), "0", 3)
        lon_m = Fwd_string_fill(tostring(math.floor(lon_m)), "0", 2)
        
        
        self:set_line(mcdu_data, MCDU_LEFT,  2+i, "   " .. lat_d .. "°" .. lat_m .. "." .. math.floor(lat_s) .. lat_p .. 
        "/" .. lon_d .. "°".. lon_m .. "." .. math.floor(lon_s) .. lon_p, MCDU_LARGE, ECAM_GREEN)
    else
        self:set_line(mcdu_data, MCDU_LEFT,  2+i, "   --°--.--/---°--.--", MCDU_LARGE, ECAM_WHITE)

    end
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "IRS INIT")

    
    self:render_gps(mcdu_data)
    
    self:render_irs(mcdu_data, 1)
    self:render_irs(mcdu_data, 2)
    self:render_irs(mcdu_data, 3)

    self:set_line(mcdu_data, MCDU_LEFT,  6, "<RETURN", MCDU_LARGE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 400)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
