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


local THIS_PAGE = MCDU_Page:new({id=608})

local TYPE_ORIGIN = 1
local TYPE_WPT    = 2
local TYPE_PPOS   = 3
local TYPE_DEST   = 4

function THIS_PAGE:render(mcdu_data)

    assert(mcdu_data.vert_rev_subject)

    -- Create the page data table if not existent (first open of the page)
    if not mcdu_data.page_data[608] then
        mcdu_data.page_data[608] = {}
    end

    local subject = mcdu_data.vert_rev_subject
    local subject_id = subject.data.id

    assert(subject_id)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    self:set_multi_title(mcdu_data, {
        {txt="VERT REV " .. mcdu_format_force_to_small("AT").."       ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="             " .. subject_id, col=main_col, size=MCDU_LARGE}
    })

    if subject.data.point_type == POINT_TYPE_DEP_SID
       or subject.data.point_type == POINT_TYPE_DEP_TRANS then
        mcdu_data.page_data[608].is_clb_or_desc = 1  -- CLIMB
    elseif subject.data.point_type == POINT_TYPE_ARR_APPR
        or subject.data.point_type == POINT_TYPE_ARR_STAR
        or subject.data.point_type == POINT_TYPE_ARR_VIA
        or subject.data.point_type == POINT_TYPE_ARR_TRANS
    then
        mcdu_data.page_data[608].is_clb_or_desc = 2  -- DESCENT
    elseif subject.data.flt_phase_user and subject.data.flt_phase_user.is_climb then
        mcdu_data.page_data[608].is_clb_or_desc = 1  -- CLIMB
    elseif subject.data.flt_phase_user and subject.data.flt_phase_user.is_descent then
        mcdu_data.page_data[608].is_clb_or_desc = 2  -- DESCENT
    elseif subject.data.flt_phase and subject.data.flt_phase.is_climb then
        mcdu_data.page_data[608].is_clb_or_desc = 1  -- CLIMB
    elseif subject.data.flt_phase and subject.data.flt_phase.is_descent then
        mcdu_data.page_data[608].is_clb_or_desc = 2  -- DESCENT

    else
        mcdu_data.page_data[608].is_clb_or_desc = 0
    end
    
    -------------------------------------
    -- LINE 1
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_format_force_to_small(" EFOB").. "=" .. mcdu_format_force_to_small("---.-  EXTRA").. "=" .. mcdu_format_force_to_small("---.-"), MCDU_LARGE)

    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "RTA>", MCDU_LARGE)

    -------------------------------------
    -- LEFT 2
    -------------------------------------

    if mcdu_data.page_data[608].is_clb_or_desc > 0 then
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            self:set_line(mcdu_data, MCDU_LEFT, 2, " CLB SPD LIM", MCDU_SMALL)
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            self:set_line(mcdu_data, MCDU_LEFT, 2, " DES SPD LIM", MCDU_SMALL)
        end

        local alt_speed_limit
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            alt_speed_limit = FMGS_init_get_alt_speed_limit_climb()
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            alt_speed_limit = FMGS_init_get_alt_speed_limit_descent()
        end
        if alt_speed_limit then
            -- ex: 210/5000 or 210/50.
            local text = alt_speed_limit[1].."/"..alt_speed_limit[2]
            text = (alt_speed_limit[1] == 250 and alt_speed_limit[2] == 10000) and mcdu_format_force_to_small(text) or text
            self:set_line(mcdu_data, MCDU_LEFT, 2, text, MCDU_LARGE, ECAM_MAGENTA)
        end
    end


    -------------------------------------
    -- LEFT 3
    -------------------------------------
    if subject.data.point_type ~= POINT_TYPE_PSUEDO then
        self:set_line(mcdu_data, MCDU_LEFT, 3, " SPD CSTR", MCDU_SMALL)
        if subject.data.cstr_speed_type and subject.data.cstr_speed_type == CIFP_CSTR_SPD_BELOW then
            -- The FMS speed limit is displayed here only if it's a BELOW constraint,
            -- otherwise is not showed
            self:set_line(mcdu_data, MCDU_LEFT, 3, subject.data.cstr_speed, MCDU_LARGE, ECAM_MAGENTA)
        else
            self:set_line(mcdu_data, MCDU_LEFT, 3, "*[   ]", MCDU_LARGE, ECAM_BLUE)
        end
    end


    -------------------------------------
    -- RIGHT 3
    -------------------------------------
    if subject.data.point_type ~= POINT_TYPE_PSUEDO then
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "ALT CSTR ", MCDU_SMALL)
        if subject.data.cstr_alt_type and subject.data.cstr_alt_type ~= CIFP_CSTR_ALT_NONE then
            -- The FMS speed limit is displayed here only if it's a BELOW constraint,
            -- otherwise is not showed

            local text = ""
            if subject.data.cstr_alt_type == CIFP_CSTR_ALT_ABOVE then
                text = "+" .. cifp_alt_to_text(subject.data.cstr_altitude1, subject.data.cstr_altitude1_fl, mcdu_data.page_data[608].is_clb_or_desc)
            elseif subject.data.cstr_alt_type == CIFP_CSTR_ALT_BELOW then
                text = "-" .. cifp_alt_to_text(subject.data.cstr_altitude1, subject.data.cstr_altitude1_fl, mcdu_data.page_data[608].is_clb_or_desc)
            elseif subject.data.cstr_alt_type == CIFP_CSTR_ALT_AT then
                text = " " .. cifp_alt_to_text(subject.data.cstr_altitude1, subject.data.cstr_altitude1_fl, mcdu_data.page_data[608].is_clb_or_desc)
            elseif subject.data.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW then
                text = cifp_alt_to_text(subject.data.cstr_altitude1, subject.data.cstr_altitude1_fl, mcdu_data.page_data[608].is_clb_or_desc) .. "-" .. cifp_alt_to_text(subject.data.cstr_altitude2, mcdu_data.page_data[608].is_clb_or_desc)
            elseif subject.data.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND then
                text = "+" .. cifp_alt_to_text(subject.data.cstr_altitude2, subject.data.cstr_altitude2_fl, mcdu_data.page_data[608].is_clb_or_desc)
            elseif subject.data.cstr_alt_type == CIFP_CSTR_ALT_GLIDE then
                self:set_line(mcdu_data, MCDU_RIGHT, 3, "GS INTCPT ", MCDU_SMALL)
                text = " " .. subject.data.cstr_altitude1
            else
                assert(false, "Unknown CSTR ALT TYPE")
            end

            self:set_line(mcdu_data, MCDU_RIGHT, 3, text, MCDU_LARGE, ECAM_MAGENTA)
        else
            self:set_line(mcdu_data, MCDU_RIGHT, 3, "*[   ]", MCDU_LARGE, ECAM_BLUE)
        end
    end

    -------------------------------------
    -- LEFT 4
    -------------------------------------
    if subject.data.point_type == POINT_TYPE_LEG then
        self:set_line(mcdu_data, MCDU_LEFT, 4, "MACH/START WPT", MCDU_SMALL)
        if subject.data.cstr_speed_mach then
            self:set_line(mcdu_data, MCDU_LEFT, 4, "." .. math.floor(100*subject.data.cstr_speed_mach) .. "/" .. mcdu_format_force_to_small(subject_id), MCDU_LARGE, ECAM_BLUE)
        else
            self:set_line(mcdu_data, MCDU_LEFT, 4, " [ ]/" .. mcdu_format_force_to_small(subject_id), MCDU_LARGE, ECAM_BLUE)
        end
    end

    -------------------------------------
    -- LEFT / RIGHT 5
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 5, "<WIND", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "STEP ALTS>", MCDU_LARGE)

    if mcdu_data.page_data[608].ask_clb_des then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "*CLB      " .. mcdu_format_force_to_small("or").. "      DES*", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)
    end
end

function THIS_PAGE:L2(mcdu_data)
    if mcdu_data.clr then   -- A clear is requested
        if mcdu_data.page_data[608].is_clb_or_desc == 1 then
            FMGS_init_reset_alt_speed_limit_climb()
            mcdu_data.clear_the_clear()
            return
        elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
            FMGS_init_reset_alt_speed_limit_descent()
            mcdu_data.clear_the_clear()
            return
        end
    else
        local a, b = mcdu_get_entry(mcdu_data, {"!!!"}, {"!!!!!","!!!!", "!!!","!!"}, false)
        b = tonumber(b)
        a = tonumber(a)
        if a~=nil and b~=nil then
            if b < 1000 then
                b = b * 100
            end
            if mcdu_data.page_data[608].is_clb_or_desc == 1 then
                FMGS_init_set_alt_speed_limit_climb(tonumber(a), b)
                return
            elseif mcdu_data.page_data[608].is_clb_or_desc == 2 then
                FMGS_init_set_alt_speed_limit_descent(tonumber(a), b)
                return
            end
        end
    end

    MCDU_Page:L2(mcdu_data) -- Error
end

function THIS_PAGE:L3(mcdu_data)
    local subject = mcdu_data.vert_rev_subject
    if mcdu_data.clr then   -- A clear is requested
        subject.data.cstr_speed_type = CIFP_CSTR_SPD_NONE
        mcdu_data.clear_the_clear()
        FMGS_refresh_pred()
    else
        local a = mcdu_get_entry(mcdu_data, {"!!!"}, false)
        a = tonumber(a)
        if a == nil then
            mcdu_send_message(mcdu_data, "FORMAT ERROR")
            return
        end

        if a > 400 or a < 120 then
            mcdu_send_message(mcdu_data, "OUT OF RANGE")
            return
        end
        if mcdu_data.page_data[608].is_clb_or_desc > 0 then
            subject.data.cstr_speed_type = CIFP_CSTR_SPD_BELOW
            subject.data.cstr_speed = a
        else
            mcdu_data.page_data[608].ask_clb_des = true
            mcdu_data.page_data[608].to_set_spd = {CIFP_CSTR_SPD_BELOW, a}
        end
        FMGS_refresh_pred()
    end
end

function THIS_PAGE:R3(mcdu_data)
    local subject = mcdu_data.vert_rev_subject

    if subject.data.point_type == POINT_TYPE_PSUEDO then
        MCDU_Page:R3(mcdu_data) -- Error
        return
    end

    if mcdu_data.clr then   -- A clear is requested
        subject.data.cstr_alt_type = CIFP_CSTR_ALT_NONE
        mcdu_data.clear_the_clear()
        FMGS_refresh_pred()
    else
        local cstr_type = CIFP_CSTR_ALT_AT
        local entry = mcdu_data.entry.text
        if string.sub(entry, 1, 1) == "+" then
            cstr_type = CIFP_CSTR_ALT_ABOVE
        elseif string.sub(entry, 1, 1) == "-" then
            cstr_type = CIFP_CSTR_ALT_BELOW
        end
        local a = mcdu_parse_entry(string.sub(entry, cstr_type ~= CIFP_CSTR_ALT_AT and 2 or 1, -1), {"altitude"})
        a = tonumber(a)
        if a and a >= 500 and a <= 40000 then
            if mcdu_data.page_data[608].is_clb_or_desc > 0 then
                subject.data.cstr_alt_type  = cstr_type
                subject.data.cstr_altitude1 = a
                subject.data.cstr_altitude1_fl = false
            else
                mcdu_data.page_data[608].ask_clb_des = true
                mcdu_data.page_data[608].to_set_alt = {cstr_type, a}
            end
            mcdu_data.entry = {text="", color=nil}
            FMGS_refresh_pred()
        elseif a then
            mcdu_send_message(mcdu_data, "OUT OF RANGE")
            return -- Error
        else
            mcdu_send_message(mcdu_data, "FORMAT ERROR")
            return -- Error
        end
    end
end

function THIS_PAGE:L4(mcdu_data)

    if mcdu_data.vert_rev_subject.data.point_type == POINT_TYPE_LEG then
        if mcdu_data.clr then
            mcdu_data.vert_rev_subject.data.cstr_speed_mach = nil
            mcdu_open_page(mcdu_data, 600)
            return
        end

        local a = mcdu_get_entry(mcdu_data, {"!!", ".!!", "!.!!"}, false)
        a = tonumber(a)
        if a then
            if a >= 0.5 and a < 1 then
                mcdu_data.vert_rev_subject.data.cstr_speed_mach = a
                mcdu_open_page(mcdu_data, 600)
                return
            else
                mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
                return
            end
        else
            return
        end
    end

    MCDU_Page:L3(mcdu_data) -- Error
end
local function set_spd_cstr(mcdu_data, is_clb)
    local subject = mcdu_data.vert_rev_subject
    if mcdu_data.page_data[608].ask_clb_des and mcdu_data.page_data[608].to_set_spd then
        subject.data.cstr_speed_type = mcdu_data.page_data[608].to_set_spd[1]
        subject.data.cstr_speed = mcdu_data.page_data[608].to_set_spd[2]

        if not subject.data.flt_phase_user then
            subject.data.flt_phase_user = {}
        end
        if is_clb then
            subject.data.flt_phase_user.is_climb = true
        else
            subject.data.flt_phase_user.is_descent = true
        end
        mcdu_data.page_data[608].ask_clb_des = false
        mcdu_data.page_data[608].to_set_spd = nil
        return true
    end
    if mcdu_data.page_data[608].ask_clb_des and mcdu_data.page_data[608].to_set_alt then
        subject.data.cstr_alt_type = mcdu_data.page_data[608].to_set_alt[1]
        subject.data.cstr_altitude1 = mcdu_data.page_data[608].to_set_alt[2]
        subject.data.cstr_altitude1_fl = false

        if not subject.data.flt_phase_user then
            subject.data.flt_phase_user = {}
        end
        if is_clb then
            subject.data.flt_phase_user.is_climb = true
        else
            subject.data.flt_phase_user.is_descent = true
        end
        mcdu_data.page_data[608].ask_clb_des = false
        mcdu_data.page_data[608].to_set_alt = nil
        return true
    end
    return false
end

function THIS_PAGE:L6(mcdu_data)
    set_spd_cstr(mcdu_data, true)
    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:R6(mcdu_data)
    if set_spd_cstr(mcdu_data, false) then
        mcdu_open_page(mcdu_data, 600)
    else
        MCDU_Page:R6(mcdu_data) -- Error
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
