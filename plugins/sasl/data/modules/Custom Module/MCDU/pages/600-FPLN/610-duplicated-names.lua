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

include('libs/geo-helpers.lua')

local THIS_PAGE = MCDU_Page:new({id=610})

local function get_list_navaids(name)
    local to_return = {}

    local airports = AvionicsBay.apts.get_by_name(name)
    for _,x in ipairs(airports) do
        table.insert(to_return, x)
    end
    
    local fixes    = AvionicsBay.fixes.get_by_name(name)
    for _,x in ipairs(fixes) do
        table.insert(to_return, x)
    end

    local navaid_types = {NAV_ID_NDB, NAV_ID_VOR, NAV_ID_LOC, NAV_ID_LOC_ALONE,
    NAV_ID_OM, NAV_ID_MM, NAV_ID_IM,  NAV_ID_DME_ALONE, NAV_ID_FPAP, NAV_ID_GLS,
    NAV_ID_LTPFTP}
    
    for _, type in ipairs(navaid_types) do
        local navaids  = AvionicsBay.navaids.get_by_name(type, name)
        for _,x in ipairs(navaids) do
            if type == NAV_ID_VOR or type == NAV_ID_LOC or type == NAV_ID_LOC_ALONE or type == NAV_ID_GS then
                x.freq = Round_fill(x.freq/100, 2)
            elseif type == NAV_ID_GLS then
                x.id = x.id .. " (GLS)"
            end
            table.insert(to_return, x)
        end
    end

    return to_return
end

function THIS_PAGE:render_list(mcdu_data, list_navaids)
    local my_coords = adirs_get_fms(mcdu_data.id)

    local line_id = 1

    for i, x in ipairs(list_navaids) do
        if i > mcdu_data.page_data[610].curr_page*5 then
            break
        elseif i > (mcdu_data.page_data[610].curr_page-1)*5 then

            local geo_distance
            if my_coords[1] then
                geo_distance = tostring(Round(GC_distance_kt(x.lat, x.lon, my_coords[1], my_coords[2])))
            else
                geo_distance = "XXX"
            end

            local lat_value = Fwd_string_fill(tostring(Round(math.abs(x.lat))), "0", 2)
            local lat_char = x.lat >= 0 and "N" or "S"

            local lon_value = Fwd_string_fill(tostring(Round(math.abs(x.lon))), "0", 3)
            local lon_char = x.lon >= 0 and "E" or "W"

            local lat_lon =  lat_value .. lat_char .. "/" .. lon_value .. lon_char

            local freq = x.freq and (Aft_string_fill(tostring(x.freq), " ", 6)) or "      "

            self:set_line(mcdu_data, MCDU_LEFT, line_id, Fwd_string_fill(geo_distance, " ", 5), MCDU_SMALL, ECAM_GREEN)
            if line_id == 1 then
                self:set_line(mcdu_data, MCDU_RIGHT, line_id, "NM LAT/LONG   FREQ ", MCDU_SMALL, ECAM_WHITE)
            else
                self:set_line(mcdu_data, MCDU_RIGHT, line_id, "NM                 ", MCDU_SMALL, ECAM_WHITE)
            end
            self:set_line(mcdu_data, MCDU_LEFT, line_id, "*" .. x.id, MCDU_LARGE, ECAM_BLUE)
            self:set_line(mcdu_data, MCDU_RIGHT, line_id, lat_lon .. "  " .. freq, MCDU_LARGE, ECAM_GREEN)
            line_id = line_id + 1
        end
    end
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "DUPLICATE NAMES")

    assert(mcdu_data.dup_names.req_text, "Provide me which navaid you want.")
    assert(mcdu_data.dup_names.return_page, "Provide me where to return")

    if not mcdu_data.page_data[610] then
        mcdu_data.page_data[610] = {
            list_navaids = {},
            list_navaids_len = 0,
            curr_page = 1
        }
    end

    if not(AvionicsBay.is_initialized() and AvionicsBay.is_ready()) then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "AVIONICSBAY INITIALIZING", MCDU_LARGE, ECAM_RED)
        self:set_line(mcdu_data, MCDU_LEFT, 3, "PLEASE WAIT", MCDU_LARGE, ECAM_RED)
        return
    end

    local list_navaids = get_list_navaids(mcdu_data.dup_names.req_text)

    mcdu_data.dup_names.not_found = false

    local nr_navaids = #list_navaids
    if nr_navaids == 0 then
        -- Not found
        mcdu_data.dup_names.not_found = true
        mcdu_send_message(mcdu_data, "NOT IN DATABASE", ECAM_WHITE)
        mcdu_open_page(mcdu_data, mcdu_data.dup_names.return_page)
        return
    elseif nr_navaids == 1 then
        mcdu_data.dup_names.selected_navaid = list_navaids[1]
        mcdu_data.dup_names.req_text = nil
        mcdu_open_page(mcdu_data, mcdu_data.dup_names.return_page)
        return
    end

    self:render_list(mcdu_data, list_navaids)

    mcdu_data.page_data[610].list_navaids = list_navaids
    mcdu_data.page_data[610].list_navaids_len = nr_navaids

    if mcdu_data.page_data[610].list_navaids_len > 5 then
        self:set_updn_arrows_bottom(mcdu_data, true)
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)

end

function THIS_PAGE:sel_navaid(mcdu_data, idx)

    idx = idx + 5 * (mcdu_data.page_data[610].curr_page - 1)

    if idx > mcdu_data.page_data[610].list_navaids_len then
        return false
    end

    mcdu_data.dup_names.selected_navaid = mcdu_data.page_data[610].list_navaids[idx]
    mcdu_open_page(mcdu_data, mcdu_data.dup_names.return_page)
    return true
end

function THIS_PAGE:L1(mcdu_data)
    if not self:sel_navaid(mcdu_data, 1) then
        MCDU_Page:L1(mcdu_data) -- Error
    end
end

function THIS_PAGE:L2(mcdu_data)
    if not self:sel_navaid(mcdu_data, 2) then
        MCDU_Page:L2(mcdu_data) -- Error
    end
end

function THIS_PAGE:L3(mcdu_data)
    if not self:sel_navaid(mcdu_data, 3) then
        MCDU_Page:L3(mcdu_data) -- Error
    end
end

function THIS_PAGE:L4(mcdu_data)
    if not self:sel_navaid(mcdu_data, 4) then
        MCDU_Page:L4(mcdu_data) -- Error
    end
end

function THIS_PAGE:L5(mcdu_data)
    if not self:sel_navaid(mcdu_data, 5) then
        MCDU_Page:L5(mcdu_data) -- Error
    end
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_data.dup_names.selected_navaid = nil
    mcdu_open_page(mcdu_data, mcdu_data.dup_names.return_page)
end

function THIS_PAGE:Slew_Up(mcdu_data)
    mcdu_data.page_data[610].curr_page = mcdu_data.page_data[610].curr_page + 1
    if (mcdu_data.page_data[610].curr_page-1) * 5 > mcdu_data.page_data[610].list_navaids_len then
        mcdu_data.page_data[610].curr_page = 1
    end
end

function THIS_PAGE:Slew_Down(mcdu_data)
    mcdu_data.page_data[610].curr_page = mcdu_data.page_data[610].curr_page - 1
    if mcdu_data.page_data[610].curr_page == 0 then
        mcdu_data.page_data[610].curr_page = math.floor(mcdu_data.page_data[610].list_navaids_len / 5) + 1
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
