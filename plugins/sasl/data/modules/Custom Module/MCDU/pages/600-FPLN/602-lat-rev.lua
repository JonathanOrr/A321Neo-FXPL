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

function THIS_PAGE:add_new_wpt(mcdu_data)

    -- LAT REV always creates a temporary flight plan
    if not FMGS_does_temp_fpln_exist() then
        FMGS_create_copy_temp_fpln()
    end

    -- How to add it depends on the type of navaid of the lateral revision
    if mcdu_data.lat_rev_subject.data.point_type == POINT_TYPE_LEG then
        local sel_navaid = mcdu_data.dup_names.selected_navaid
        local sel_navaid_type = avionics_bay_generic_wpt_to_fmgs_type(sel_navaid)
        local leg = {
                    ptr_type = sel_navaid_type, 
                    id=sel_navaid.id,
                    lat=sel_navaid.lat,
                    lon=sel_navaid.lon
                }
        FMGS_fpln_temp_leg_add(leg, mcdu_data.lat_rev_subject.data.ref_id+1)
        FMGS_fpln_temp_leg_add_disc(mcdu_data.lat_rev_subject.data.ref_id+2)
    end

end

function THIS_PAGE:render(mcdu_data)

    assert(mcdu_data.lat_rev_subject)

    -- Create the page data table if not existent (first open of the page)
    if not mcdu_data.page_data[602] then
        mcdu_data.page_data[602] = {}
    end

    -- If the following element exists, it means we are coming back from the
    -- 610-duplicated-names page.
    if mcdu_data.page_data[602].waiting_next_wpt then
        mcdu_data.page_data[602].waiting_next_wpt = false -- Reset the flag
        if not mcdu_data.dup_names.not_found and mcdu_data.dup_names.selected_navaid then
            -- If we are here, then we have a valid waypoint to add as "next wpt"
            self:add_new_wpt(mcdu_data)
            mcdu_open_page(mcdu_data, 600)
            return
        end

    end

    -- mcdu_data.lat_rev_subject
    --                          .type = 1 -- ORIGIN, 2 -- WPT, 3 -- PPOS, 4 -- DEST
    --                          .data
    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    local lrtype = mcdu_data.lat_rev_subject.type

    local subject_id, lat, lon
    if lrtype == TYPE_PPOS then
        subject_id = "PPOS"
        if GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV then
            lat,lon = get(Aircraft_lat), get(Aircraft_long)
        end
    else
        if mcdu_data.lat_rev_subject.data.discontinuity then
            subject_id = "DISCON"
        else
            subject_id = mcdu_data.lat_rev_subject.data.id
        end
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

function THIS_PAGE:R3(mcdu_data)
    if mcdu_data.lat_rev_subject.type ~= TYPE_PPOS then
        local input = mcdu_get_entry(mcdu_data)
        if #input > 0 and #input < 6 then
            mcdu_data.dup_names.req_text = input
            mcdu_data.dup_names.return_page = 602
            mcdu_data.page_data[602].waiting_next_wpt = true
            mcdu_open_page(mcdu_data, 610)
        else
            mcdu_send_message(mcdu_data, "FORMAT ERROR")
        end
    else
        MCDU_Page:R3(mcdu_data) -- Error
    end
end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 600)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
