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

local THIS_PAGE = MCDU_Page:new({id=302})

function THIS_PAGE:render(mcdu_data)

    self:set_title(mcdu_data, "  TAKE OFF",ECAM_WHITE)

    --change later, load and read drfs here

    --BIG LINES
    ----------
    --L1L2L3--
    ----------
    local a,b,c = FMGS_perf_get_v_speeds()
    local vspd_displayed = {a, b, c} -- v1 vr v2

    if FMGS_get_phase() < FMGS_PHASE_TAKEOFF then
        self:set_line(mcdu_data, MCDU_LEFT, 1, vspd_displayed[1] == nil and "___" or vspd_displayed[1], MCDU_LARGE, vspd_displayed[1] == nil and ECAM_ORANGE or ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, vspd_displayed[2] == nil and "___" or vspd_displayed[2], MCDU_LARGE, vspd_displayed[2] == nil and ECAM_ORANGE or ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 3, vspd_displayed[3] == nil and "___" or vspd_displayed[3], MCDU_LARGE, vspd_displayed[3] == nil and ECAM_ORANGE or ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 1, vspd_displayed[1] == nil and "---" or vspd_displayed[1], MCDU_LARGE, vspd_displayed[1] == nil and ECAM_WHITE or ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 2, vspd_displayed[2] == nil and "---" or vspd_displayed[2], MCDU_LARGE, vspd_displayed[2] == nil and ECAM_WHITE or ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 3, vspd_displayed[3] == nil and "---" or vspd_displayed[3], MCDU_LARGE, vspd_displayed[3] == nil and ECAM_WHITE or ECAM_GREEN)
    end
    ----------
    --  L4  --
    ----------
    if FMGS_perf_get_trans_alt() then
        self:set_line(mcdu_data, MCDU_LEFT, 4, FMGS_perf_get_user_trans_alt() == nil and mcdu_format_force_to_small(FMGS_perf_get_trans_alt()) or FMGS_perf_get_user_trans_alt(), MCDU_LARGE, FMGS_get_phase() >= FMGS_PHASE_TAKEOFF and ECAM_GREEN or ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small("[ ]"), MCDU_LARGE, FMGS_get_phase() >= FMGS_PHASE_TAKEOFF and ECAM_GREEN or ECAM_BLUE)
    end
    ----------
    --  L5  --
    ----------
    local j, k = FMGS_get_takeoff_thrust_reduction()
    local q, r = FMGS_get_takeoff_acc()
    self:set_line(mcdu_data, MCDU_LEFT, 5, " "..(k == nil and mcdu_format_force_to_small(j) or k) .."/".. (r == nil and mcdu_format_force_to_small(q) or r), MCDU_LARGE,FMGS_get_phase() >= FMGS_PHASE_TAKEOFF and ECAM_GREEN or ECAM_BLUE)

    ----------
    --  L6  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<TO DATA", MCDU_LARGE, ECAM_WHITE)

    ----------
    --C1C2C3--
    ----------
    local fso_spd = {F_speed,S_speed,GD}
    self:add_multi_line(mcdu_data, MCDU_CENTER, 1, "F=".."   ".."     ", MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 2, "S=".."   ".."     ", MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3, "O=".."   ".."     ", MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 1, "  "..string.format("%03.f", tostring(get(fso_spd[1]))).."     ", MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 2, "  "..string.format("%03.f", tostring(get(fso_spd[2]))).."     ", MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_CENTER, 3, "  "..string.format("%03.f", tostring(get(fso_spd[3]))).."     ", MCDU_LARGE, ECAM_GREEN)
    ----------
    --  R1  --
    ----------
    local dep_rwy = nil
    local rwy, sibl = FMGS_dep_get_rwy(false)
    if rwy ~= nil and sibl ~= false then
        dep_rwy = sibl and rwy.sibl_name or rwy.name
    end
    self:set_line(mcdu_data, MCDU_RIGHT, 1, dep_rwy == nil and "---" or dep_rwy, MCDU_LARGE,  dep_rwy == nil and ECAM_WHITE or ECAM_GREEN)

    ----------
    --  R2  --
    ----------
    self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, mcdu_format_force_to_small("[M]").."     ", MCDU_LARGE, ECAM_WHITE)

    if FMGS_get_phase() < FMGS_PHASE_TAKEOFF then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, (FMGS_get_takeoff_shift() == nil and "[  ]*" or FMGS_get_takeoff_shift()), MCDU_LARGE, ECAM_BLUE)
    else
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, (FMGS_get_takeoff_shift() == nil and "" or FMGS_get_takeoff_shift()), MCDU_LARGE, ECAM_GREEN)
    end

    ----------
    --  R3  --
    ----------
    local flaps_ths = {FMGS_get_takeoff_flaps(), FMGS_get_takeoff_ths()}
    local flaps_displayed = (flaps_ths[1] == nil and "[]" or flaps_ths[1]) -- FORMATING THE STRING FOR DISPLAY
    local trim_displayed = (flaps_ths[2] == nil and "[   ]" or (flaps_ths[2] < 0 and ("DN"..Round_fill(-flaps_ths[2],1)) or ("UP"..Round_fill(flaps_ths[2],1)) ))

    if FMGS_get_phase() < FMGS_PHASE_TAKEOFF then

        self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, flaps_displayed.."      ", MCDU_LARGE, ECAM_BLUE)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, "/     ", MCDU_LARGE, ECAM_BLUE)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, trim_displayed, MCDU_LARGE, ECAM_BLUE)

    elseif FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then -- If we are taking off, check if there is a user input. if yes, green. if no, blank.
        if flaps_ths[1] ~= nil then 
            self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, flaps_displayed.."      ", MCDU_LARGE, ECAM_GREEN)
            self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, "/     ", MCDU_LARGE, ECAM_GREEN)
        else
            self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, "", MCDU_LARGE, ECAM_BLUE)
        end
        if flaps_ths[2] ~= nil then 
            self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, trim_displayed, MCDU_LARGE, ECAM_GREEN)
        else
            self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, "", MCDU_LARGE, ECAM_BLUE)
        end
    end

    ----------
    --  R4  --
    ----------
    local flex_temp = FMGS_get_takeoff_flex_temp()
    if FMGS_get_phase() < FMGS_PHASE_TAKEOFF then
        self:set_line(mcdu_data, MCDU_RIGHT, 4, (flex_temp == nil and "[ ]°" or tostring(flex_temp).."°"), MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 4, (flex_temp == nil and "" or tostring(flex_temp).."°"), MCDU_LARGE, ECAM_GREEN)
    end

    local f, g = FMGS_get_takeoff_eng_out_alt()
    self:set_line(mcdu_data, MCDU_RIGHT, 5, g == nil and mcdu_format_force_to_small(f) or g, MCDU_LARGE, FMGS_get_phase() < FMGS_PHASE_TAKEOFF and ECAM_BLUE or ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)
    
    --SMALL LINES
    self:set_line(mcdu_data, MCDU_LEFT, 1, " V1", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, " VR", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, " V2", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "TRANS ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "THR RED/ACC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, " EFB REQ", MCDU_SMALL, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_CENTER, 1, "FLP RETR      ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 2, "SLT RETR      ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "   CLEAN      ", MCDU_SMALL, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "RWY ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "TO SHIFT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "FLAPS/THS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "FLEX TO TEMP", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "ENG OUT ACC", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)

end

function THIS_PAGE:L1(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0}, false)
    input = tonumber(input)
    if input == nil then return end
    if input >= 90 and input <= 350 then
        FMGS_perf_set_v1(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L2(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0}, false)
    input = tonumber(input)
    if input == nil then return end
    if input >= 90 and input <= 350 then
        FMGS_perf_set_vr(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L3(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0}, false)
    input = tonumber(input)
    if input == nil then return end
    if input >= 90 and input <= 350 then
        FMGS_perf_set_v2(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L4(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    if mcdu_data.clr then
        if FMGS_perf_get_user_trans_alt() == nil  then -- if there is already no user value but the user still tried to clear
            mcdu_send_message(mcdu_data, "NOT ALLOWED")  
        end
        FMGS_perf_set_user_trans_alt(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!!!","!!!!"}, false)
    if input == nil then return end
    input = tonumber(input)
    if input >= 0 and input <= 39000 then
        input = Round(input, -1)
        FMGS_perf_set_user_trans_alt(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L5(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    if mcdu_data.clr then

        local j, k = FMGS_get_takeoff_thrust_reduction() -- if there is already no user value but the user still tried to clear
        local q, r = FMGS_get_takeoff_acc()
        if k == nil and r == nil then
            mcdu_send_message(mcdu_data, "NOT ALLOWED")
        end
        FMGS_set_takeoff_thrust_reduction(nil)
        FMGS_set_takeoff_acc(nil)
        mcdu_data.clear_the_clear()
        return
    end

    local a,b = mcdu_get_entry(mcdu_data, {"!!!!!","!!!!"},{"!!!!!","!!!!"}, false)
    local entry_out_of_range_msg = false

    if a ~= nil then
        a = tonumber(a)           
        if a > 0 and a <= 39000 then
            a = Round(a, -1)
            FMGS_set_takeoff_thrust_reduction(a)
        else
            entry_out_of_range_msg = true
        end
    end

    if b ~= nil then
        b = tonumber(b)        
        if b > 0 and b <= 39000 then
            b = Round(b, -1)
            FMGS_set_takeoff_acc(b)
        else
            entry_out_of_range_msg = true
        end
    end

    if entry_out_of_range_msg then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_send_message(mcdu_data, "TELL HENRICK TO CODE IT")
end

function THIS_PAGE:R2(mcdu_data)
    -- TODO range of shift is 1 - rwy_length (see 22-20-50-30)

    if mcdu_data.clr then
        if FMGS_get_takeoff_shift() ~= nil then
            FMGS_set_takeoff_shift(nil)
            mcdu_data.clear_the_clear()
        else
            mcdu_send_message(mcdu_data, "NOT ALLOWED")
        end
        return
    end

    local rwy_length = FMGS_dep_get_rwy(false)
    if rwy_length then
        rwy_length = rwy_length.distance
    end

    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF or rwy_length == nil then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED") -- user should enter departure runway first
        return
    end

    local input = mcdu_get_entry(mcdu_data, {"!!!!","!!!","!!","!"}, false)
    if input == nil then return end
    input = tonumber(input)
    if input > 0 and input <= rwy_length then
        FMGS_set_takeoff_shift(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end


function THIS_PAGE:R3(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    local entru_out_of_range_msg = false
    local a, b = mcdu_get_entry(mcdu_data, {"!"}, {"#####","###"}, false)

    if a ~= nil then
        a = tonumber(a)
        local a_is_in_range = a > -0.1 and a < 4.1 -- 22-20-50-30 range is not limited
        if a_is_in_range then
            FMGS_set_takeoff_flaps(a)
        else
            entru_out_of_range_msg = true
        end
    end

    if b ~= nil then
        b = tostring(b)
        if #b == 5 then
            local lol_1_2_is_up = string.sub(b, 1, 2) == "UP"
            local lol_1_2_is_dn = string.sub(b, 1, 2) == "DN"
            local lol_4_5_is_up = string.sub(b, 4, 5) == "UP"
            local lol_4_5_is_dn = string.sub(b, 4, 5) == "DN"
    
            if lol_1_2_is_up and not lol_4_5_is_up then
                b = tonumber(string.sub(b, 3, 5))
            elseif lol_4_5_is_up and not lol_1_2_is_up then
                b = tonumber(string.sub(b, 1, 3))
            elseif lol_1_2_is_dn and not lol_4_5_is_dn then
                b = -tonumber(string.sub(b, 3, 5))
            elseif lol_4_5_is_dn and not lol_1_2_is_dn then
                b = -tonumber(string.sub(b, 1, 3))
            end
        elseif #b == 3 then
            local lol_1_2_is_up = string.sub(b, 1, 2) == "UP"
            local lol_1_2_is_dn = string.sub(b, 1, 2) == "DN"
            local lol_2_3_is_up = string.sub(b, 2, 3) == "UP"
            local lol_2_3_is_dn = string.sub(b, 2, 3) == "DN"
            if lol_1_2_is_up and not lol_2_3_is_up then
                b = tonumber(string.sub(b, 3, 3))
            elseif lol_2_3_is_up and not lol_1_2_is_up then
                b = tonumber(string.sub(b, 1, 1))
            elseif lol_1_2_is_dn and not lol_2_3_is_dn then
                b = -tonumber(string.sub(b, 3, 3))
            elseif lol_2_3_is_dn and not lol_1_2_is_dn then
                b = -tonumber(string.sub(b, 1, 1))
            end
        else 
            mcdu_send_message(mcdu_data, "FORMAT ERROR")
            return
        end

        b = tonumber(b)

        local b_is_in_range = b >= -2.5 and b <= 2.5
        if b_is_in_range then
            FMGS_set_takeoff_ths(b)
        else
            entru_out_of_range_msg = true
        end
    end

    if entru_out_of_range_msg then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:R4(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    if mcdu_data.clr and FMGS_get_takeoff_flex_temp() ~= nil then
        FMGS_set_takeoff_flex_temp(nil)
    end
    local input = mcdu_get_entry(mcdu_data, {"number", length = 2, dp = 0}, false)
    input = tonumber(input)
    if input == nil then return end
    if input > -99 and input <= 99 then
        FMGS_set_takeoff_flex_temp(input)
        set(Eng_N1_flex_temp, input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:R5(mcdu_data)
    if FMGS_get_phase() >= FMGS_PHASE_TAKEOFF then 
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    if mcdu_data.clr then
        local a,b = FMGS_get_takeoff_eng_out_alt()
        if b == nil then
            mcdu_send_message(mcdu_data, "NOT ALLOWED")
        end
        FMGS_set_takeoff_eng_out_alt(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!!!","!!!!"}, false)
    if input == nil then return end
    input = tonumber(input)
    if input >= 0 and input <= 39000 then
        FMGS_set_takeoff_eng_out_alt(input)
    else
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 303)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
