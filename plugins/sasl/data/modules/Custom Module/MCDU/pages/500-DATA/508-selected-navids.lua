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
-- File: 505-ac-status.lua 
-------------------------------------------------------------------------------

include('libs/geo-helpers.lua')
include('DRAIMS/radio_logic.lua')

local THIS_PAGE = MCDU_Page:new({id=508})

local function source_to_str(x)
    if x == 1 then
        return "AUTO"
    elseif x == 2 then
        return "MAN"
    elseif x == 3 then
        return "RMP"
    else
        return "UKNWN"
    end
end

function THIS_PAGE:fill_data(mcdu_data, nav_info)

    if nav_info[1].visible and radio_vor_is_dme_valid(1) then
        nav_info[1].name = DRAIMS_common.radio.vor[1].id
        nav_info[1].freq = Round_fill(radio_vor_get_freq(1), 2)
    elseif nav_info[1].visible and radio_vor_is_dme_valid(2) then
        nav_info[1].name = DRAIMS_common.radio.vor[2].id
        nav_info[1].freq = Round_fill(radio_vor_get_freq(2), 2)
    end

    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local acf_lat, acf_lon = get(Aircraft_lat), get(Aircraft_long)
        local nearest_by_coords = AvionicsBay.navaids.get_by_coords(NAV_ID_DME, acf_lat, acf_lon)
        
        local i = 2
        for _,x in ipairs(nearest_by_coords) do
            local distance = GC_distance_kt(x.lat, x.lon, acf_lat, acf_lon)
            if distance < x.category then
                nav_info[i].visible = true
                nav_info[i].name    = x.id
                nav_info[i].freq    = Round_fill(x.freq/100, 2)
                i = i + 1
                if i == 4 then
                    break
                end
            end
        end
    end
    
    if nav_info[4].visible then
        nav_info[4].name = DRAIMS_common.radio.ils.id
        nav_info[4].freq = Round_fill(radio_ils_get_freq(), 2)
    end

    for i=1, 4 do
        if nav_info[i].visible then
            self:set_line(mcdu_data, MCDU_LEFT, i, "<"..nav_info[i].name , MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_CENTER, i,mcdu_format_force_to_small( nav_info[i].freq.."   ") , MCDU_LARGE, ECAM_GREEN)
        end
    end

end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data,"SELECTED NAVIDS")
    self:set_line(mcdu_data, MCDU_LEFT, 1, " VOR/DME  " .. source_to_str(radio_vor_get_tuning_source()) .. "  DESELECT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "[  ]*" , MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, " VOR/DME  AUTO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " VOR/DME  AUTO", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, " ILS      " .. source_to_str(radio_ils_get_tuning_source()), MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, " RADIONAV SELECTED", MCDU_SMALL, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " GPS SELECTED", MCDU_SMALL, ECAM_BLUE)

    local nav_info = {
        {visible = radio_vor_is_dme_valid(1) or radio_vor_is_dme_valid(2)},
        {visible = false},
        {visible = false},
        {visible = radio_ils_is_valid()},
    }

    THIS_PAGE:fill_data(mcdu_data, nav_info)

    self:set_line(mcdu_data, MCDU_LEFT, 5, "←DESELECT" , MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "←DESELECT" , MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "RETURN>" , MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 502)
end

function THIS_PAGE:R1(mcdu_data)
    mcdu_send_message(mcdu_data, "NOT IMPLEMENTED")
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
