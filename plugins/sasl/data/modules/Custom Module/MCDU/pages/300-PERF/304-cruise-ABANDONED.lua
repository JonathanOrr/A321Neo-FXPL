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
local THIS_PAGE = MCDU_Page:new({id=304})

function THIS_PAGE:render(mcdu_data)

    local fms_is_in_cruise_phase = false --IF THE FMS IS BEYOND CLIMB PHASE, WHICH IS AFTER CLIMB. USED TO DECIDE WETHER TO SHOW ACTIVATE APPR PHASE ON L6
    local cruise_speed_mode = true -- SPEED, TRUE IS MANAGED, FALSE IS SELECTED!
    local managed_data = {250} -- SPEED
    local step_climb_data = {nil,nil,nil,nil} --AT WHICH WPT, TARGET ALTITUDE, TIME REACHING WPT, DISTANCE FROM WPT
    --CAUTION!!!! ONLY FEED DATA TO UTC AND DIST ON THE MANAGED ROW, WHEN THERE IS A STEP CLIMB PLANNED!
    local selected_data = {nil}
    local arrival_data = {nil,nil} --UTC, EFOB
    local descend_cabin_vs = -350


    ----------
    -- TITLE--
    ----------
    self:set_title(mcdu_data, " CRZ", fms_is_in_cruise_phase and ECAM_GREEN or ECAM_WHITE)

    ----------
    --  L1  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 1, "ACT MODE   UTC DEST EFOB", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, cruise_speed_mode and "MANAGED" or "SELECTED", MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L2  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 2, " CI", MCDU_SMALL, ECAM_WHITE)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "---", MCDU_LARGE)
    elseif not FMGS_init_get_cost_idx() then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "___", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 2, FMGS_init_get_cost_idx(), MCDU_LARGE, ECAM_BLUE)
    end

    ----------
    --  L3  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 3, " MANAGED", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " "..managed_data[1], MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L4  --
    ----------
    if not fms_is_in_cruise_phase then
        self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and " PRESEL" or " SELECTED", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and "*[ ]" or  " "..selected_data[1], MCDU_LARGE, selected_data[1] == nil and ECAM_BLUE or ECAM_GREEN)
    end

    ----------
    --  L6  --
    ----------
    if fms_is_in_cruise_phase then
        self:set_line(mcdu_data, MCDU_LEFT, 6, " ACTIVATE", MCDU_SMALL, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←APPR PHASE", MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, " PREV", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<PHASE", MCDU_LARGE, ECAM_WHITE)
    end

    ----------
    --  C1  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 5,arrival_data[1] == nil and "----" or mcdu_format_force_to_small(Fwd_string_fill(tostring(expedite_data[2]), "0", 4)), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  R1  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 1, arrival_data[2], MCDU_LARGE, ECAM_WHITE)

    if step_climb_data[1] ~= nil then -- IF A PLAN FOR STEPPING EXISTS
        ----------
        --  R2  --
        ----------
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "AT "..step_climb_data[1], MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "STEP TO FL"..step_climb_data[2]/100, MCDU_LARGE, ECAM_WHITE)

        ----------
        --  R3  --
        ----------
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "UTC      DIST", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, Fwd_string_fill(tostring(step_climb_data[3]), "0", 4).."      "..Fwd_string_fill(tostring(step_climb_data[4]), "0", 4), MCDU_LARGE, ECAM_WHITE)
    end


    ----------
    --  R5  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "DES CABIN RATE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, descend_cabin_vs.."FT/MN", MCDU_LARGE, ECAM_WHITE)

    ----------
    --  R6  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 303)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE