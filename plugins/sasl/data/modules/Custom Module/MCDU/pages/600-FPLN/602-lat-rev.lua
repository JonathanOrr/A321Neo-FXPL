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


local THIS_PAGE = MCDU_Page:new({id=602})

local TYPE_ORIGIN = 1
local TYPE_WPT    = 2
local TYPE_PPOS   = 3
local TYPE_DEST   = 4

function THIS_PAGE:render(mcdu_data)

    assert(mcdu_data.lat_rev_subject)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    local lrtype = mcdu_data.lat_rev_subject.type

    -- mcdu_data.lat_rev_subject
    --                          .type = 1 -- ORIGIN, 2 -- WPT, 3 -- PPOS, 4 -- DEST
    --                          .data

    local subject_id, lat, lon
    if lrtype == TYPE_PPOS then
        subject_id = "PPOS"
        if GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV then
            lat,lon = get(Aircraft_lat), get(Aircraft_long)
        end
    else
        subject_id = mcdu_data.lat_rev_subject.data.id
        lat,lon = mcdu_data.lat_rev_subject.data.lat, mcdu_data.lat_rev_subject.data.lon
    end

    assert(subject_id)

    self:set_multi_title(mcdu_data, {
        {txt="LAT REV " .. mcdu_format_force_to_small("FROM").."      ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. subject_id, col=main_col, size=MCDU_LARGE}
    })

    if lat then
        self:set_line(mcdu_data, MCDU_CENTER, 1, mcdu_lat_lon_to_str(lat, lon), MCDU_SMALL, main_col)

        -------------------------------------
        -- RIGHT 1
        -------------------------------------
        if lrtype == TYPE_ORIGIN or lrtype == TYPE_PPOS then
            self:set_line(mcdu_data, MCDU_RIGHT, 1, "FIX INFO>")
        elseif lrtype == TYPE_DEST then
            self:set_line(mcdu_data, MCDU_RIGHT, 1, "ARRIVAL>")
        end
    end
    
    -------------------------------------
    -- LEFT 1
    -------------------------------------
    if lrtype == TYPE_ORIGIN then
        self:set_line(mcdu_data, MCDU_LEFT, 1, "<DEPARTURE", MCDU_LARGE)
    end

    -------------------------------------
    -- LEFT 2
    -------------------------------------
    if lrtype ~= TYPE_DEST then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "<OFFSET", MCDU_LARGE)
    end

    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    if lrtype ~= TYPE_DEST then
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "LL XING/INCR/NO", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "  [  ]°/[ ]°/[]", MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- LEFT 3
    -------------------------------------
    if lrtype == TYPE_WPT or lrtype == TYPE_PPOS then
        self:set_line(mcdu_data, MCDU_LEFT, 3, "<HOLD", MCDU_LARGE)
    end

    -------------------------------------
    -- RIGHT 3
    -------------------------------------
    if lrtype ~= TYPE_PPOS then
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "NEXT WPT ", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "  [     ]", MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- LEFT 4
    -------------------------------------
    if lrtype ~= TYPE_PPOS then
        self:set_line(mcdu_data, MCDU_LEFT, 4, " ENABLE", MCDU_SMALL, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "←ALTN", MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- RIGHT 4
    -------------------------------------
    if lrtype == TYPE_ORIGIN or lrtype == TYPE_WPT then
        self:set_line(mcdu_data, MCDU_RIGHT, 4, "NEW DEST ", MCDU_SMALL)
        self:set_line(mcdu_data, MCDU_RIGHT, 4, "     [  ]", MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- LEFT 5
    -------------------------------------
    if lrtype == TYPE_DEST then
        self:set_line(mcdu_data, MCDU_LEFT, 5, "<ALTN", MCDU_LARGE)
    end

    -------------------------------------
    -- RIGHT 5
    -------------------------------------
    if lrtype == TYPE_WPT then
        self:set_line(mcdu_data, MCDU_RIGHT, 5, "AIRWAYS>", MCDU_LARGE)
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)
end

function THIS_PAGE:L1(mcdu_data)
    if mcdu_data.lat_rev_subject.type == TYPE_ORIGIN then
        mcdu_open_page(mcdu_data, 603)
    else
        MCDU_Page:L1(mcdu_data) -- Error
    end
end

function THIS_PAGE:R1(mcdu_data)
    if mcdu_data.lat_rev_subject.type == TYPE_DEST then
        mcdu_open_page(mcdu_data, 605)
    else
        MCDU_Page:R1(mcdu_data) -- Error
    end
end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 600)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
