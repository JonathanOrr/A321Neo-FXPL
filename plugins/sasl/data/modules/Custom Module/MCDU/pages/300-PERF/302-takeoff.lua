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
local eng_out_acc = 1000
local to_shift = nil
local prev_rwy = nil --used to detect delta on runway, do not delete

local THIS_PAGE = MCDU_Page:new({id=302})

function THIS_PAGE:render(mcdu_data)



    

    --I KNOW I SHOULDN'T PUT LOGICS HERE, BUT HELP ME IDK WHERE ELSE TO PUT THEM -HENRICK
    local dep_rwy = nil
    local rwy, sibl = FMGS_dep_get_rwy(false)
    if rwy ~= nil then
        dep_rwy = sibl and rwy.sibl_name or rwy.name
    end
    if dep_rwy ~= prev_rwy and prev_rwy ~= nil then --runway change delta detector
        FMGS_sys.perf.takeoff.v1_popped = FMGS_sys.perf.takeoff.v1
        FMGS_sys.perf.takeoff.vr_popped = FMGS_sys.perf.takeoff.vr
        FMGS_sys.perf.takeoff.v2_popped = FMGS_sys.perf.takeoff.v2
        FMGS_sys.perf.takeoff.v1 = nil
        FMGS_sys.perf.takeoff.vr = nil
        FMGS_sys.perf.takeoff.v2 = nil
        mcdu_send_message(mcdu_data, "CHECK TAKE OFF DATA")
    end
    prev_rwy = dep_rwy







    self:set_title(mcdu_data, "   TAKE OFF ")

    --change later, load and read drfs here

    --BIG LINES
    ----------
    --L1L2L3--
    ----------
    local vspd_displayed = {FMGS_sys.perf.takeoff.v1, FMGS_sys.perf.takeoff.vr, FMGS_sys.perf.takeoff.v2}
    local vspd_popped = {FMGS_sys.perf.takeoff.v1_popped, FMGS_sys.perf.takeoff.vr_popped, FMGS_sys.perf.takeoff.v2_popped}
    for i=1, 3 do
        self:set_line(mcdu_data, MCDU_LEFT, i, (vspd_displayed[i] == nil and "___" or vspd_displayed[i])..mcdu_format_force_to_small( vspd_popped[i] == nil and "" or vspd_popped[i]), MCDU_LARGE, vspd_displayed[i] == nil and ECAM_ORANGE or ECAM_BLUE)
    end

    ----------
    --  L4  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_format_force_to_small(FMGS_sys.perf.takeoff.trans_alt), MCDU_LARGE, ECAM_BLUE)

    ----------
    --  L5  --
    ----------
    local thrred = FMGS_sys.perf.takeoff.thr_red
    local user_thrred = FMGS_sys.perf.takeoff.user_thr_red
    local acc = FMGS_sys.perf.takeoff.acc
    local user_acc = FMGS_sys.perf.takeoff.user_acc
    self:set_line(mcdu_data, MCDU_LEFT, 5, " "..
    (user_thrred ~= nil and user_thrred or mcdu_format_force_to_small(thrred))..
    "/".. 
    (user_acc ~= nil and user_acc or mcdu_format_force_to_small(acc)),
     MCDU_LARGE, ECAM_BLUE)

    ----------
    --  L6  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<TO DATA", MCDU_LARGE, ECAM_WHITE)

    ----------
    --C1C2C3--
    ----------
    local fso_spd = {F_speed,S_speed,GD}
    self:set_line(mcdu_data, MCDU_CENTER, 1, "F="..string.format("%03.f", tostring(get(fso_spd[1]))).."     ", MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 2, "S="..string.format("%03.f", tostring(get(fso_spd[2]))).."     ", MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_CENTER, 3, "O="..string.format("%03.f", tostring(get(fso_spd[3]))).."     ", MCDU_LARGE, ECAM_GREEN)

    ----------
    --  R1  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 1, dep_rwy == nil and "---" or dep_rwy, MCDU_LARGE,  dep_rwy == nil and ECAM_WHITE or ECAM_GREEN)

    ----------
    --  R2  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, mcdu_format_force_to_small("[M]")..(to_shift == nil and "[   ]*" or to_shift), MCDU_LARGE, ECAM_BLUE)

    ----------
    --  R3  --
    ----------
    local flaps_ths = {FMGS_sys.perf.takeoff.flaps, FMGS_sys.perf.takeoff.ths}
    self:set_line(mcdu_data, MCDU_RIGHT, 3, (flaps_ths[1] == nil and "[]" or flaps_ths[1]).."/"..(flaps_ths[2] == nil and "[   ]" or (flaps_ths[2] < 0 and ("DN"..Round_fill(-flaps_ths[2],1)) or ("UP"..Round_fill(flaps_ths[2],1)) )), MCDU_LARGE, ECAM_BLUE)

    ----------
    --  R4  --
    ----------
    local flex_temp = FMGS_sys.perf.takeoff.flex_temp
    self:set_line(mcdu_data, MCDU_RIGHT, 4, (flex_temp == nil and "[ ]" or flex_temp), MCDU_LARGE, ECAM_BLUE)

    ----------
    --  R5  --
    ----------
    local engout = FMGS_sys.perf.takeoff.eng_out
    local user_engout = FMGS_sys.perf.takeoff.user_eng_out
    self:set_line(mcdu_data, MCDU_RIGHT, 5, user_engout ~= nil and user_engout or mcdu_format_force_to_small(engout) , MCDU_LARGE, ECAM_BLUE)


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
    if FMGS_sys.perf.takeoff.v1_popped == nil then
        local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0})
        if input == nil then return end
        input = tonumber(input)
        if input > 100 and input <= 175 then
            FMGS_sys.perf.takeoff.v1 = input
        else
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    else
        FMGS_sys.perf.takeoff.v1 = FMGS_sys.perf.takeoff.v1_popped
        FMGS_sys.perf.takeoff.v1_popped = nil
    end
end

function THIS_PAGE:L2(mcdu_data)
    if FMGS_sys.perf.takeoff.vr_popped == nil then
        local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0})
        if input == nil then return end
        input = tonumber(input)
        if input > 100 and input <= 175 then
            FMGS_sys.perf.takeoff.vr = input
        else
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    else
        FMGS_sys.perf.takeoff.vr = FMGS_sys.perf.takeoff.vr_popped
        FMGS_sys.perf.takeoff.vr_popped = nil
    end 
end

function THIS_PAGE:L3(mcdu_data)
    if FMGS_sys.perf.takeoff.v2_popped == nil then
        local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0})
        if input == nil then return end
        input = tonumber(input)
        if input > 100 and input <= 175 then
            FMGS_sys.perf.takeoff.v2 = input
        else
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    else
        FMGS_sys.perf.takeoff.v2 = FMGS_sys.perf.takeoff.v2_popped
        FMGS_sys.perf.takeoff.v2_popped = nil
    end 
end

function THIS_PAGE:L6(mcdu_data)

end

function THIS_PAGE:R3(mcdu_data)
    local entru_out_of_range_msg = false
    local a, b = mcdu_get_entry(mcdu_data, {"!"}, {"#####","###"}, false)

    if a ~= nil then
        a = tonumber(a)
        local a_is_in_range = a > 0.9 and a < 4.1
        if a_is_in_range then
            FMGS_sys.perf.takeoff.flaps = a
        else
            entru_out_of_range_msg = true
        end
    end

    if b ~= nil then

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

        local b_is_in_range = b >= -2.5 and b <= 2.5
        if b_is_in_range then
            FMGS_sys.perf.takeoff.ths = b
        else
            entru_out_of_range_msg = true
        end
    end

    if entru_out_of_range_msg then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end

    print(b)
end

function THIS_PAGE:R4(mcdu_data)
    local input = mcdu_get_entry(mcdu_data, {"number", length = 2, dp = 0}, false)
    if input ~= nil then
        input = tonumber(input)
        if input > 0 and input <= 80 then
            FMGS_sys.perf.takeoff.flex_temp = input
            set(Eng_N1_flex_temp, input)
        else
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    end
end

function THIS_PAGE:L5(mcdu_data)
    local entry_out_of_range_msg = false

    local a,b = mcdu_get_entry(mcdu_data,  {"!!!!","!!!!", "!!!","CLR"}, {"!!!!", "!!!",""}, false)
    if a ~= "CLR" then
        if a ~= nil then
            if a < 10000 then
                FMGS_sys.perf.takeoff.user_thr_red = a
            else
                entry_out_of_range_msg = true
            end
        end
        if b ~= nil then
            if b < 10000 then
                FMGS_sys.perf.takeoff.user_acc = b
            else
                entry_out_of_range_msg = true
            end
        end
    else
        FMGS_sys.perf.takeoff.user_thr_red = nil
        FMGS_sys.perf.takeoff.user_acc = nil
    end

    if entry_out_of_range_msg then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:R5(mcdu_data)
    local a = mcdu_get_entry(mcdu_data,  {"!!!!!","!!!!", "!!!","CLR"}, false)
    if a ~= nil then
        if a ~= "CLR" then
            a = tonumber(a)
            if a < 10000 then
                FMGS_sys.perf.takeoff.user_eng_out = a
            else
                mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
            end
        else
            FMGS_sys.perf.takeoff.user_eng_out = nil
        end
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
