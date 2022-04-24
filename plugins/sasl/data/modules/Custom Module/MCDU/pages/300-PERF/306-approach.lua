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
local THIS_PAGE = MCDU_Page:new({id=306})

local dest_within_180_nm = true
local qnh_in_inhg = false
local have_ils = true

function THIS_PAGE:render(mcdu_data)

    local activate_appr_phase = false

    self:set_multi_title(mcdu_data,{{txt="DEST                    ", col=ECAM_WHITE, size=MCDU_SMALL}, {txt="APPR  ", col=ECAM_WHITE, size=MCDU_LARGE}})
        -- 
    self:add_multi_line(mcdu_data, MCDU_LEFT, 1, " QNH    FLP RETR  FINAL", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, " TEMP   SLT RETR    MDA", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, "MAG WIND   CLEAN     DH", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 4, "TRANS ALT      LDG CONF", MCDU_SMALL, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 5, " VAPP      VLS", MCDU_SMALL, ECAM_WHITE)

    ------
    --L1--
    ------

    local displayed_qnh = FMGS_get_landing_qnh()
    displayed_qnh = tostring(displayed_qnh)
    local qnhcolour = ECAM_BLUE
    if displayed_qnh == "nil" then
        qnhcolour = dest_within_180_nm and ECAM_ORANGE or ECAM_BLUE
    else
        qnhcolour = ECAM_BLUE
    end
    if displayed_qnh == "nil" then
        displayed_qnh = dest_within_180_nm and (qnh_in_inhg == false and "____" or "__.__") or (qnh_in_inhg == false and "[   ]" or "[ . ]")
    else
        displayed_qnh = qnh_in_inhg and string.sub(displayed_qnh,1,2).."."..string.sub(displayed_qnh,3,4) or displayed_qnh
    end
    self:add_multi_line(mcdu_data, MCDU_LEFT, 1, displayed_qnh , MCDU_LARGE, qnhcolour)


    ------
    --L2--
    ------
    
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, FMGS_get_landing_apt_temp() == nil and "[ ]°" or FMGS_get_landing_apt_temp().."°" , MCDU_LARGE, ECAM_BLUE)

    ------
    --L3--
    ------

    local displayed_mag = FMGS_get_landing_wind_mag() == nil and "[ ]" or Fwd_string_fill(tostring(FMGS_get_landing_wind_mag()), "0", 3)
    local displayed_wind =  FMGS_get_landing_wind() == nil and "[ ]" or  FMGS_get_landing_wind()
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, displayed_mag.."°/"..displayed_wind , MCDU_LARGE, ECAM_BLUE)

    ------
    --L4--
    ------
    
    local a,b = FMGS_get_landing_trans_alt()
    self:add_multi_line(mcdu_data, MCDU_LEFT, 4, b ~= nil and b or mcdu_format_force_to_small(a), MCDU_LARGE, ECAM_BLUE)

    ------
    --L5--
    ------

    local c,d = FMGS_get_landing_vapp()
    self:add_multi_line(mcdu_data, MCDU_LEFT, 5, d~= nil and Round(d,0) or mcdu_format_force_to_small(Round(c,0)), MCDU_LARGE, ECAM_BLUE)

    ------
    --C5--
    ------

    self:add_multi_line(mcdu_data, MCDU_LEFT, 5, "           "..Round(FMGS_get_landing_vls(),0), MCDU_LARGE, ECAM_GREEN)

    ------
    --R2--
    ------

    self:add_multi_line(mcdu_data, MCDU_RIGHT, 2, FMGS_get_landing_mda() == nil and "[   ]" or FMGS_get_landing_mda() , MCDU_LARGE, ECAM_BLUE)

    ------
    --R3--
    ------

    if have_ils then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 3, FMGS_get_landing_dh() == nil and "[  ]" or FMGS_get_landing_dh() , MCDU_LARGE, ECAM_BLUE)
    end

    if FMGS_get_landing_config() == 4 then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 4, mcdu_format_force_to_small("CONF3*") , MCDU_LARGE, ECAM_BLUE)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 5, "FULL" , MCDU_LARGE, ECAM_BLUE)
    elseif FMGS_get_landing_config() == 3 then
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 4, "CONF3" , MCDU_LARGE, ECAM_BLUE)
        self:add_multi_line(mcdu_data, MCDU_RIGHT, 5, mcdu_format_force_to_small("FULL*") , MCDU_LARGE, ECAM_BLUE)
    end
    

    local fso_spd = {F_speed,S_speed,GD}
    self:add_multi_line(mcdu_data, MCDU_LEFT, 1, "            "..string.format("%03.f", tostring(get(fso_spd[1]))).."     " , MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "            "..string.format("%03.f", tostring(get(fso_spd[2]))).."     " , MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, "            "..string.format("%03.f", tostring(get(fso_spd[3]))).."     " , MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 1, "          F="                                                             , MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "          S="                                                             , MCDU_LARGE, ECAM_WHITE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 3, "          O="                                                             , MCDU_LARGE, ECAM_WHITE)


    ----------
    --  L6  --
    ----------
    if activate_appr_phase then
        self:set_line(mcdu_data, MCDU_LEFT, 6, " ACTIVATE", MCDU_SMALL, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←APPR PHASE", MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, " PREV", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 6, "<PHASE", MCDU_LARGE, ECAM_WHITE)
    end
    ----------
    --  R6  --
    ----------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT ", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "PHASE>", MCDU_LARGE, ECAM_WHITE)

end

function THIS_PAGE:L2(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_apt_temp(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!!!","!!!!","!!!","!!", "!"}, false)
    if input == nil then return end
    FMGS_set_landing_apt_temp(input)
end

function THIS_PAGE:L3(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_wind_mag(nil)
        FMGS_set_landing_wind(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local a,b = mcdu_get_entry(mcdu_data, {"!!!","!!!","!!", "!"}, {"!!", "!"}, false)
    local entry_out_of_range_msg = false
    if a ~= nil then
        a = tonumber(a)
        if a < 0 or a > 360 then
            entry_out_of_range_msg = true
        elseif a == 360 then
            a = 0
            FMGS_set_landing_wind_mag(a)
        else
            FMGS_set_landing_wind_mag(a)
        end
    end
    if b ~= nil then
        b = tonumber(b)
        if b < 0 or b > 50 then
            entry_out_of_range_msg = true
        else
            FMGS_set_landing_wind(b)
        end
    end
    if entry_out_of_range_msg then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end

function THIS_PAGE:L4(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_trans_alt(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!!!","!!!!","!!!","!!", "!"}, false)
    if input == nil then return end
    FMGS_set_landing_trans_alt(input)
end

function THIS_PAGE:L5(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_vapp(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!"}, false)
    input = tonumber(input)
    if input == nil then return end
    FMGS_set_landing_vapp(input)
end

function THIS_PAGE:R2(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_mda(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = mcdu_get_entry(mcdu_data, {"!!!!","!!!","!!", "!"}, false)
    if input == nil then return end
    input = tonumber(input)
    FMGS_set_landing_mda(input)
end

function THIS_PAGE:R3(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_dh(nil)
        mcdu_data.clear_the_clear()
        return
    end
    if have_ils then
        local input = mcdu_get_entry(mcdu_data, {"!!!!","!!!","!!", "!"}, false)
        if input == nil then return end
        FMGS_set_landing_dh(tonumber(input))
        FMGS_set_landing_mda(nil)
    end
end

function THIS_PAGE:R4(mcdu_data)
    FMGS_set_landing_config(3)
end

function THIS_PAGE:R5(mcdu_data)
    FMGS_set_landing_config(4)
end

function THIS_PAGE:L1(mcdu_data)
    if mcdu_data.clr then
        FMGS_set_landing_qnh(nil)
        mcdu_data.clear_the_clear()
        return
    end
    local input = 0
    if not qnh_in_inhg then
        input = mcdu_get_entry(mcdu_data, {"number", length = 4, dp = 0})
        if input == nil then return end
        input = tonumber(input)

        if input >= 745 and input <= 1100 then
            FMGS_set_landing_qnh(input)
        else
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    else
        input = mcdu_get_entry(mcdu_data, {"number", length = 2, dp = 2})
        if input == nil then return end
        input = tonumber(input)

        if input >= 22 and input <= 32.49 then
            input = input * 100 -- change 29.92 to 2992 as required in drawing format
            FMGS_set_landing_qnh(input)
        else 
            mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
        end
    end
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 305)
end

function THIS_PAGE:R6(mcdu_data)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE