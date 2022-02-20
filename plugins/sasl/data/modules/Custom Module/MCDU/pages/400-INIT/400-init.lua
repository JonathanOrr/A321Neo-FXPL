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

include("AOC/functions.lua")

local THIS_PAGE = MCDU_Page:new({id=400})


function THIS_PAGE:render(mcdu_data)

    self:set_title(mcdu_data, "INIT")
    self:set_lr_arrows(mcdu_data, true)
    
    -------------------------------------
    -- LEFT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, " CO RTE", MCDU_SMALL, ECAM_WHITE)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 1, "__________", MCDU_LARGE, ECAM_ORANGE)
    end

    -------------------------------------
    -- RIGHT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "FROM/TO  ", MCDU_SMALL, ECAM_WHITE)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "____/____", MCDU_LARGE, ECAM_ORANGE)
    else
        local apt_dep = FMGS_get_apt_dep()
        local apt_arr = FMGS_get_apt_arr()
        self:set_line(mcdu_data, MCDU_RIGHT, 1, apt_dep.id .. "/" .. apt_arr.id, MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- LEFT 2
    -------------------------------------

    self:set_line(mcdu_data, MCDU_LEFT, 2, "ALTN/CO RTE", MCDU_SMALL)

    local altn_apt = FMGS_get_apt_alt()
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "----/-------", MCDU_LARGE)
    elseif altn_apt == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "NONE", MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 2, altn_apt.id, MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "INIT ", MCDU_SMALL, ECAM_ORANGE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "REQUEST*", MCDU_LARGE, ECAM_ORANGE)
    
    -------------------------------------
    -- LEFT 3
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 3, "FLT NBR", MCDU_SMALL)

    if FMGS_init_get_flt_nbr() == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 3, "________", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 3, FMGS_init_get_flt_nbr(), MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- RIGHT 3
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "IRS INIT>", MCDU_LARGE)
    
    -------------------------------------
    -- LEFT 4
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 4, "PAX NBR", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 4, get(Nr_people_onboard), MCDU_LARGE, ECAM_BLUE)

    -------------------------------------
    -- LEFT 5
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 5, "COST INDEX", MCDU_SMALL)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 5, "---", MCDU_LARGE)
    elseif FMGS_init_get_cost_idx() == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 5, "___", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 5, FMGS_init_get_cost_idx(), MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- RIGHT 5
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "WIND>", MCDU_LARGE)

    -------------------------------------
    -- LEFT 6
    -------------------------------------
    local crz_fl, crz_temp   = FMGS_init_get_crz_fl_temp()
    self:set_line(mcdu_data, MCDU_LEFT, 6, "CRZ FL/TEMP", MCDU_SMALL)
    if not FMGS_are_main_apts_set() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "-----/---", MCDU_LARGE)
    elseif crz_fl == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "_____/___", MCDU_LARGE, ECAM_ORANGE)
    elseif FMGS_perf_get_trans_alt() and crz_fl >= FMGS_perf_get_trans_alt() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "FL"..Fwd_string_fill(tostring(crz_fl/100), "0", 3) .. "/" .. crz_temp, MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 6, tostring(crz_fl) .. "/" .. crz_temp, MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- RIGHT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "TROPO", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, FMGS_init_get_tropo_alt(), MCDU_LARGE, ECAM_BLUE)

end

function THIS_PAGE:L1(mcdu_data)
    mcdu_send_message(mcdu_data, "NOT IN DATABASE")
end

function THIS_PAGE:R1(mcdu_data)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        mcdu_send_message(mcdu_data, "AVIONICS BAY NOT READY")
        return
    end

    local input = mcdu_get_entry_simple(mcdu_data, {"####/####"}, true)
    if input == nil then
        return
    end
    
	local airp_origin_name = input:sub(1,4):upper()
    local airp_dest_name = input:sub(6,9):upper()
    
    FMGS_reset_dep_arr_airports()
    
    FMGS_set_apt_dep(airp_origin_name)
    FMGS_set_apt_arr(airp_dest_name)
    
    mcdu_reset_fpln(mcdu_data)

    if not FMGS_are_main_apts_set() then
        FMGS_reset_dep_arr_airports()
        mcdu_send_message(mcdu_data, "NOT IN DATABASE")
    else
        mcdu_data.entry = {text="", color=nil}
        mcdu_open_page(mcdu_data, 404)
    end
    
end

function THIS_PAGE:L2(mcdu_data)
    if not FMGS_are_main_apts_set() then
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end
    
    local input = mcdu_get_entry_simple(mcdu_data, {"####/############", "####"}, true)
    if input == nil then
        return
    end
    
	local airp_name = input:sub(1,4):upper()
    
    FMGS_reset_alt_airports()
    
    FMGS_set_apt_alt(airp_name)
    
    if FMGS_get_apt_alt() == nil then
        mcdu_send_message(mcdu_data, "NOT IN DATABASE")
    else
        mcdu_data.entry = {text="", color=nil}
    end
    
end


function THIS_PAGE:L3(mcdu_data)
    local input = mcdu_get_entry(mcdu_data)
    if input and string.len(input) < 9 then
        FMGS_init_set_flt_nbr(input)
    else
        mcdu_send_message(mcdu_data, "FORMAT ERROR")
    end
end

function THIS_PAGE:R3(mcdu_data)
    mcdu_open_page(mcdu_data, 402)
end

function THIS_PAGE:L4(mcdu_data)
    local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0})
    if input == nil then
        return
    end

    input = tonumber(input)
    if input <= 0 or input >= 500 then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    else

        set(Nr_people_onboard, input)
    end
end

function THIS_PAGE:L5(mcdu_data)
    if not FMGS_are_main_apts_set() then
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
        return
    end

    local input = mcdu_get_entry(mcdu_data, {"number", length = 3, dp = 0})
    if input == nil then
        return
    elseif tonumber(input) <= 0 or tonumber(input) > 999 then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    else
        FMGS_init_set_cost_idx(tonumber(input))
    end
end

function THIS_PAGE:R5(mcdu_data)
    mcdu_open_page(mcdu_data, 403)
end


function THIS_PAGE:L6(mcdu_data)
    if not FMGS_are_main_apts_set() then --GUARD IT!!! No one can enter anythign when it shows ---/-- !!! You can only enter when it is ___/__ !!!
        mcdu_send_message(mcdu_data, "NOT ALLOWED")
    return end

    local input_a, input_b = mcdu_get_entry(mcdu_data, {"FL!!!","!!!!!","!!!!", "!!!"}, {"number", length = 2, dp = 0})
    local entry_out_of_range = false

    if input_a ~= nil or input_b ~= nil then
        local alt = 0
        if input_a ~= nil then
            if #input_a == 5 then
                if string.sub(input_a,1,2) == "FL" then --if it begins with FL
                    alt = tonumber(string.sub(input_a,3,5)) * 100
                else -- it is probably 5 number characters in feet
                    alt = tonumber(input_a)
                end
            elseif #input_a == 3 then --it is probably also a flight level, just without FL
                alt = tonumber(input_a) * 100
            elseif #input_a == 4 then --it is in feet
                alt = tonumber(input_a)
            end


            if alt >= 0 and alt <= 41000 then
                local crz_temp = math.floor(alt / 100 * -0.2 + 16)
                FMGS_init_set_crz_fl(alt, crz_temp)
            else
                entry_out_of_range = true
            end

        end
        if input_b ~= nil then
            FMGS_init_set_crz_fl(alt, tonumber(input_b))
        end
    end
    if entry_out_of_range then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    end
end


function THIS_PAGE:R6(mcdu_data)
    local input = mcdu_get_entry(mcdu_data, {"number", length = 5, dp = 0})
    if input == nil then
        return
    elseif tonumber(input) <= 0 or tonumber(input) > 60000 then
        mcdu_send_message(mcdu_data, "ENTRY OUT OF RANGE")
    else
        FMGS_init_set_tropo_alt(tonumber(input))
    end
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 401)
end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 401)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
