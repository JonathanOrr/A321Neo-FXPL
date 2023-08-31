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
local THIS_PAGE = MCDU_Page:new({id=303})

local function fill_managed_data(managed_data_table, target_alt)
    -- To get the data, I'll iterate over the leg array and then linearly interpolate with the
    -- information available.

    managed_data_table[1] = nil
    managed_data_table[2] = nil
    managed_data_table[3] = nil

    if not target_alt then
        return
    end

    -- First of all, let's find the correct waypoint at the given altitude
    local legs = FMGS_sys.pred_internals.get_big_array()
    if not legs then
        return  -- No predictions available
    end

    local cumul_dist = 0
    local found_leg
    for i,leg in ipairs(legs) do
        if leg.pred then
            if leg.pred.altitude and leg.pred.altitude >= target_alt then
                found_leg = i - 1
                break
            end
            cumul_dist = cumul_dist + (leg.computed_distance or 0)
        end
    end

    if not found_leg then
        return -- Not found (too high)
    end

    if not (legs[found_leg] and legs[found_leg].pred) then
        return -- Missing prev leg (?)
    end

    local ias, mach, time, dist
    if legs[found_leg].pred.ias and legs[found_leg+1].pred.ias then
        ias = Math_rescale(legs[found_leg].pred.altitude or 0, legs[found_leg].pred.ias, legs[found_leg+1].pred.altitude, legs[found_leg+1].pred.ias, target_alt)
        ias = math.min(ias, legs[found_leg].pred.prop_spd_cstr or 999) -- This is not perfect, but ok
        if target_alt < FMGS_sys.data.init.alt_speed_limit_climb[2] then
            ias = math.min(ias, FMGS_sys.data.init.alt_speed_limit_climb[1])    -- This is not perfect but ok
        end
    end
    if legs[found_leg].pred.mach and legs[found_leg+1].pred.mach then
        mach = Math_rescale(legs[found_leg].pred.altitude or 0, legs[found_leg].pred.mach, legs[found_leg+1].pred.altitude, legs[found_leg+1].pred.mach, target_alt)
    end

    if legs[found_leg].pred.time and legs[found_leg+1].pred.time then
        time = Math_rescale(legs[found_leg].pred.altitude or 0, legs[found_leg].pred.time, legs[found_leg+1].pred.altitude, legs[found_leg+1].pred.time, target_alt)
    end

 
    local full_distance = legs[found_leg+1].temp_computed_distance or legs[found_leg+1].computed_distance
    if not full_distance and legs[found_leg+1].pred.is_toc then
        full_distance = legs[found_leg+1].pred.dist_prev_wpt
    end
    if full_distance then
        dist = Math_rescale(legs[found_leg].pred.altitude or 0, 0, legs[found_leg+1].pred.altitude, full_distance, target_alt)
    end

    managed_data_table[1] = (ias and Round(ias,0) or "---") .. "/" .. (mach and "."..Round(mach*100,0) or "---")

    managed_data_table[2] = time and mcdu_time_beautify(time) or nil

    managed_data_table[3] = Round(cumul_dist+(dist or 0), 0)

end

function THIS_PAGE:render(mcdu_data)

    if not mcdu_data.page_data[303] then
        mcdu_data.page_data[303] = {
        }
    end

    local crz_fl = FMGS_init_get_crz_fl_temp()
    if (not mcdu_data.page_data[303].prediction_altitude) or (crz_fl and mcdu_data.page_data[303].prediction_altitude > crz_fl) then
        -- Sanitize and default crz altitude as prediction
        mcdu_data.page_data[303].prediction_altitude = crz_fl
    end

    local climb_speed_mode = true -- SPEED, TRUE IS MANAGED, FALSE IS SELECTED!
    local prediction_altitude = mcdu_data.page_data[303].prediction_altitude
    local managed_data = {nil, nil, nil} --FORMAT IS SPEED, ARRIVING UTC, DISTANCE
    local selected_data = {nil, nil,nil}
    local expedite_data = {nil, "---"} --ARRIVING UTC, DISTANCE
    local fms_is_in_climb_phase = false --IF THE FMS IS BEYOND TAKEOFF PHASE, WHICH IS AFTER DEPARTURE. USED TO DECIDE WETHER TO SHOW ACTIVATE APPR PHASE ON L6

    -- Compute stuff
    fill_managed_data(managed_data, prediction_altitude)

    
    ----------
    -- TITLE--
    ----------
    self:set_title(mcdu_data, " CLB", fms_is_in_climb_phase and ECAM_GREEN or ECAM_WHITE)
    ----------
    --  L1  --
    ----------
    
    self:set_line(mcdu_data, MCDU_LEFT, 1, "ACT MODE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, climb_speed_mode and "MANAGED" or "SELECTED", MCDU_LARGE, ECAM_GREEN)

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
    self:set_line(mcdu_data, MCDU_LEFT, 3, " "..(managed_data[1] and managed_data[1] or ""), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L4  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and " PRESEL" or " SELECTED", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, selected_data[1] == nil and "*[ ]" or  " "..selected_data[1], MCDU_LARGE, selected_data[1] == nil and ECAM_BLUE or ECAM_GREEN)

    ----------
    --  L5  --
    ----------

    self:set_line(mcdu_data, MCDU_LEFT, 5, mcdu_format_force_to_small(" EXPEDITE "), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L6  --
    ----------
    if fms_is_in_climb_phase then
        self:set_line(mcdu_data, MCDU_LEFT, 6, " ACTIVATE", MCDU_SMALL, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←APPR PHASE", MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, " PREV", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<PHASE", MCDU_LARGE, ECAM_WHITE)
    end

    ----------
    --  R1  --
    ----------
-- No derated option
--    self:set_line(mcdu_data, MCDU_RIGHT, 1, "DRT CLB", MCDU_SMALL, ECAM_WHITE)
--    self:set_line(mcdu_data, MCDU_RIGHT, 1, "[ ]", MCDU_LARGE, ECAM_BLUE)
    ----------
    --  R2  --
    ----------

    self:add_multi_line(mcdu_data, MCDU_RIGHT, 2,mcdu_format_force_to_small("PRED TO      "), MCDU_LARGE, ECAM_WHITE)
    if prediction_altitude then
        local to_print
        if prediction_altitude >= FMGS_perf_get_current_trans_alt() then
            to_print = "FL"..prediction_altitude/100
        else
            to_print = prediction_altitude
        end
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, to_print, MCDU_LARGE, ECAM_BLUE)
    else
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, "-----", MCDU_LARGE, ECAM_WHITE)
    end
    ----------
    --  R3  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 3,"DIST", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 3,managed_data[3] == nil and "" or managed_data[3], MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R4  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 4,selected_data[3] == nil and "" or selected_data[3], MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R5  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 5,mcdu_format_force_to_small(expedite_data[2]), MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R6  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)

    ----------
    --  C3  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3,"UTC", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3,managed_data[2] == nil and "" or Fwd_string_fill(tostring(managed_data[2]), "0", 4), MCDU_LARGE, ECAM_GREEN)

    ----------
    --  C4  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 4,selected_data[2] == nil and "" or Fwd_string_fill(tostring(selected_data[2]), "0", 4), MCDU_LARGE, ECAM_GREEN)
    ----------
    --  C5  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_CENTER, 5,expedite_data[1] == nil and "" or mcdu_format_force_to_small(Fwd_string_fill(tostring(expedite_data[2]), "0", 4)), MCDU_LARGE, ECAM_GREEN)
end

function THIS_PAGE:R2(mcdu_data)
    local input = mcdu_get_entry(mcdu_data, {"altitude"}, false)
    input = tonumber(input)
    if input == nil then
        return
    end
    local crz_fl = FMGS_init_get_crz_fl_temp()
    if input < 2000 or (crz_fl and input > crz_fl) then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    else
        mcdu_data.page_data[303].prediction_altitude = input
    end
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 302)
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 305)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE