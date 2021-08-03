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
-- File: ECAM_automation.lua 
-- Short description: ECAM file for managing the page switch 
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local ECAM_PAGE_ENG   = 1
local ECAM_PAGE_BLEED = 2
local ECAM_PAGE_PRESS = 3
local ECAM_PAGE_ELEC  = 4
local ECAM_PAGE_HYD   = 5
local ECAM_PAGE_FUEL  = 6
local ECAM_PAGE_APU   = 7
local ECAM_PAGE_COND  = 8
local ECAM_PAGE_DOOR  = 9
local ECAM_PAGE_WHEEL = 10
local ECAM_PAGE_FCTL  = 11
local ECAM_PAGE_STS   = 12
local ECAM_PAGE_CRUISE= 13

ECAM_STATUS_NORMAL       = 0  -- No buttons pressed, no warning, normal situation, page displayed depends on flight phase
ECAM_STATUS_SHOW_USER    = 1  -- User has pressed a page button
ECAM_STATUS_SHOW_ALL     = 2  -- ALL button has been pressed
ECAM_STATUS_SHOW_EWD     = 3  -- Dealing with EWD
ECAM_STATUS_SHOW_EWD_STS = 4  -- Dealing with EWD - final STS page


-------------------------------------------------------------------------------
-- Command registration
-------------------------------------------------------------------------------
sasl.registerCommandHandler (Ecam_btn_cmd_ENG,   0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_ENG) end )
sasl.registerCommandHandler (Ecam_btn_cmd_BLEED, 0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_BLEED) end )
sasl.registerCommandHandler (Ecam_btn_cmd_PRESS, 0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_PRESS) end )
sasl.registerCommandHandler (Ecam_btn_cmd_ELEC,  0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_ELEC) end )
sasl.registerCommandHandler (Ecam_btn_cmd_HYD,   0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_HYD) end )
sasl.registerCommandHandler (Ecam_btn_cmd_FUEL,  0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_FUEL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_APU,   0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_APU) end )
sasl.registerCommandHandler (Ecam_btn_cmd_COND,  0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_COND) end )
sasl.registerCommandHandler (Ecam_btn_cmd_DOOR,  0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_DOOR) end )
sasl.registerCommandHandler (Ecam_btn_cmd_WHEEL, 0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_WHEEL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_FCTL,  0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_FCTL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_STS,   0 , function(phase) ecam_user_press_page_button(phase,ECAM_PAGE_STS) end )

sasl.registerCommandHandler (Ecam_btn_cmd_ALL,   0 , function(phase) ecam_user_press_all(phase) end )
sasl.registerCommandHandler (Ecam_btn_cmd_CLR,   0 , function(phase) ecam_user_press_clr_status(phase) end )

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local timer_cruise_page         = sasl.createTimer()    -- Used in update_page_normal()
local timer_cruise_page_started = false
local page_normal_apu_last_show = 0
local page_normal_eng_last_show = 0
local page_normal_fctl_last_show = 0

local page_all_start_time       = 0
local press_start_time = 0

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

--used for ecam automation
local function Goto_ecam(page_num)
    set(Ecam_previous_page, get(Ecam_current_page))
    set(Ecam_current_page, page_num)
end

function ecam_user_press_page_button(phase, which_page)
    if phase == SASL_COMMAND_BEGIN and (get(DC_ess_bus_pwrd) == 1 or which_page == 12) then
        if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
            -- We are already in user mode

            if get(Ecam_current_page) == which_page then
                -- User is de-activating the page (s)he previously selected
                -- Resume normal mode, page will be changed automatically
                set(Ecam_current_status, ECAM_STATUS_NORMAL) 
                -- If another mode was selected, page will change automatically at next sasl run
            else
                Goto_ecam(which_page)
            end
        else
            -- Change the page in *any* case (forced by user)
            set(Ecam_current_status,ECAM_STATUS_SHOW_USER)
            Goto_ecam(which_page)
        end
        press_start_time = get(TIME)
    elseif phase == SASL_COMMAND_CONTINUE then  -- Fail of ecam
        if get(TIME) - press_start_time > 0.5 then            
            -- Ok, Transfer displays
            set(DMC_requiring_ECAM_EWD_swap, 1)
        end
    elseif phase == SASL_COMMAND_END then
        press_start_time = 0
        set(DMC_requiring_ECAM_EWD_swap, 0)
        if get(DMC_ECAM_can_override_EWD) == 1 and get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
            set(Ecam_current_status,ECAM_STATUS_NORMAL)
        end
    end
end

function ecam_user_press_clr_status(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER and get(Ecam_current_page) == ECAM_PAGE_STS then
        if get(Ecam_arrow_overflow) == 1 then
            set(Ecam_sts_scroll_page, get(Ecam_sts_scroll_page) + 1)
        else
            set(Ecam_sts_scroll_page, 0)
        end
        return  -- Not the mode we are interested in
    end
    
    if get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD_STS then
        set(Ecam_sts_scroll_page, 0)
        return  -- Not the mode we are interested in
    end
    
    if get(Ecam_is_sts_clearable) == 0 then
        return  -- STS not clearable, i.e. CLR goes to EWD
    end
    
    if get(Ecam_arrow_overflow) == 1 then
        -- We have overflow, so CLR will scroll page until the end
        set(Ecam_sts_scroll_page, get(Ecam_sts_scroll_page) + 1)
        return
    end
    
    
    -- Ok we finished scrolling ECAM, so we can clear the status page, by resuming normal mode
    set(Ecam_is_sts_clearable, 0)
    set(Ecam_current_status, ECAM_STATUS_NORMAL)
    set(Ecam_sts_scroll_page, 0)
    
end

function ecam_update_advisory_conditions()
    local at_least_one = false
    
    local cond_hyd = (get(Hydraulic_G_qty) >= 0.18 and get(Hydraulic_G_qty) < 0.82) or
                     (get(Hydraulic_B_qty) >= 0.31 and get(Hydraulic_B_qty) < 0.76) or
                     (get(Hydraulic_Y_qty) >= 0.22 and get(Hydraulic_Y_qty) < 0.8)
    
    if cond_hyd then at_least_one = true; set(Ecam_advisory_HYD, 1) end
    
    local cond_press = (get(Cabin_delta_psi) > 1.5 and get(EWD_flight_phase) == PHASE_FINAL) or
                       (get(Cabin_vs) > 1750) or
                       (get(Cabin_alt_ft) > 8800 and get(Cabin_alt_ft) < 9950)

    if cond_press then at_least_one = true; set(Ecam_advisory_PRESS, 1) end
    
    local cond_door = get(Oxygen_ckpt_psi) < 600 and get(Oxygen_ckpt_psi) >= 300

    if cond_door then at_least_one = true; set(Ecam_advisory_DOOR, 1) end

    local adv_1 = ENG.data.display.oil_press_low_amber[1] + ENG.data.display.oil_press_low_amber[2] * get(Eng_1_N2)
    local adv_2 = ENG.data.display.oil_press_low_amber[1] + ENG.data.display.oil_press_low_amber[2] * get(Eng_2_N2)

    local cond_eng_1 =  get(Eng_1_OIL_qty) < ENG.data.display.oil_qty_advisory or
                        get(Eng_1_OIL_press) > ENG.data.display.oil_press_high_adv or
                        get(Eng_1_OIL_press) < adv_1 or
                        get(Eng_1_OIL_temp) > ENG.data.display.oil_temp_high_adv or
                        get(Eng_1_VIB_N1) > ENG.data.vibrations.max_n1_nominal or
                        get(Eng_1_VIB_N2) > ENG.data.vibrations.max_n2_nominal

    local cond_eng_2 =  get(Eng_2_OIL_qty) < ENG.data.display.oil_qty_advisory or
                        get(Eng_2_OIL_press) > ENG.data.display.oil_press_high_adv or
                        get(Eng_2_OIL_press) < adv_2 or
                        get(Eng_2_VIB_N1) > ENG.data.vibrations.max_n1_nominal or
                        get(Eng_2_VIB_N2) > ENG.data.vibrations.max_n2_nominal


    local cond_engines = (get(Engine_1_avail) == 1 and cond_eng_1) or (get(Engine_2_avail) == 1 and cond_eng_2)

    if cond_engines then at_least_one = true; set(Ecam_advisory_ENG, 1) end       

    if at_least_one then
        set(EWD_box_adv, 1)
    end
    
end

local function ecam_update_leds_advisory()
    
    if get(TIME) % 1 < 0.5 then
        if get(Ecam_advisory_ENG) == 1   then at_least_one = true; set(Ecam_btn_light_ENG, 1)   end
        if get(Ecam_advisory_BLEED) == 1 then at_least_one = true; set(Ecam_btn_light_BLEED, 1) end
        if get(Ecam_advisory_PRESS) == 1 then at_least_one = true; set(Ecam_btn_light_PRESS, 1) end
        if get(Ecam_advisory_ELEC) == 1  then at_least_one = true; set(Ecam_btn_light_ELEC, 1)  end
        if get(Ecam_advisory_HYD) == 1   then at_least_one = true; set(Ecam_btn_light_HYD, 1)   end
        if get(Ecam_advisory_FUEL) == 1  then at_least_one = true; set(Ecam_btn_light_FUEL, 1)  end
        if get(Ecam_advisory_APU) == 1   then at_least_one = true; set(Ecam_btn_light_APU, 1)   end
        if get(Ecam_advisory_COND) == 1  then at_least_one = true; set(Ecam_btn_light_COND, 1)  end
        if get(Ecam_advisory_DOOR) == 1  then at_least_one = true; set(Ecam_btn_light_DOOR, 1)  end
        if get(Ecam_advisory_WHEEL) == 1 then at_least_one = true; set(Ecam_btn_light_WHEEL, 1) end
        if get(Ecam_advisory_FCTL) == 1  then at_least_one = true; set(Ecam_btn_light_FCTL, 1)  end
    end
    
    set(Ecam_advisory_ENG, 0)
    set(Ecam_advisory_BLEED, 0)
    set(Ecam_advisory_PRESS, 0)
    set(Ecam_advisory_ELEC, 0)
    set(Ecam_advisory_HYD, 0)
    set(Ecam_advisory_FUEL, 0)
    set(Ecam_advisory_APU, 0)
    set(Ecam_advisory_COND, 0)
    set(Ecam_advisory_DOOR, 0)
    set(Ecam_advisory_WHEEL, 0)
    set(Ecam_advisory_FCTL, 0)

end

-- This function update the pushbutton leds status
function ecam_update_leds()

    set(EWD_box_adv, 0)
    
    -- Let's turn off all the leds
    set(Ecam_btn_light_ENG,  0)
    set(Ecam_btn_light_BLEED,0)
    set(Ecam_btn_light_PRESS,0)
    set(Ecam_btn_light_ELEC, 0)
    set(Ecam_btn_light_HYD,  0)
    set(Ecam_btn_light_FUEL, 0)
    set(Ecam_btn_light_APU,  0)
    set(Ecam_btn_light_COND, 0)
    set(Ecam_btn_light_DOOR, 0)
    set(Ecam_btn_light_WHEEL,0)
    set(Ecam_btn_light_FCTL, 0)
    set(Ecam_btn_light_CLR,  0)
    set(Ecam_btn_light_STS,  0)
    
    ecam_update_advisory_conditions()
    
    if get(DC_ess_bus_pwrd) == 0 then
        -- No power for leds
        return
    end
    
    if get(Cockpit_annnunciators_test) == 1 then
        set(Ecam_btn_light_ENG,  1)
        set(Ecam_btn_light_BLEED,1)
        set(Ecam_btn_light_PRESS,1)
        set(Ecam_btn_light_ELEC, 1)
        set(Ecam_btn_light_HYD,  1)
        set(Ecam_btn_light_FUEL, 1)
        set(Ecam_btn_light_APU,  1)
        set(Ecam_btn_light_COND, 1)
        set(Ecam_btn_light_DOOR, 1)
        set(Ecam_btn_light_WHEEL,1)
        set(Ecam_btn_light_FCTL, 1)
        set(Ecam_btn_light_CLR,  1)
        set(Ecam_btn_light_STS,  1)
    end

    if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER
       or get(Ecam_current_status) == ECAM_STATUS_SHOW_ALL then
        -- Let's turn on the led of the current page
        if get(Ecam_current_page) == ECAM_PAGE_ENG then
            set(Ecam_btn_light_ENG, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_BLEED then
            set(Ecam_btn_light_BLEED, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_PRESS then
            set(Ecam_btn_light_PRESS, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_ELEC then
            set(Ecam_btn_light_ELEC, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_HYD then
            set(Ecam_btn_light_HYD, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_FUEL then
            set(Ecam_btn_light_FUEL, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_APU then
            set(Ecam_btn_light_APU, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_COND then
            set(Ecam_btn_light_COND, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_DOOR then
            set(Ecam_btn_light_DOOR, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_WHEEL then
            set(Ecam_btn_light_WHEEL, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_FCTL then
            set(Ecam_btn_light_FCTL, 1)
        elseif get(Ecam_current_page) == ECAM_PAGE_STS then
            set(Ecam_btn_light_STS, 1)
        end
    end
    
    if get(Ecam_current_status) == ECAM_STATUS_SHOW_EWD or get(Ecam_current_status) == ECAM_STATUS_SHOW_EWD_STS or get(EWD_is_clerable) == 1 then
        set(Ecam_btn_light_CLR, 1)
    end

    ecam_update_leds_advisory()
end



-- Update the page when no pushbuttons are pressed, no ecam messages, no status, etc,
local function update_page_normal()

    local curr_time = get(TIME)

    -- APU has a special way to handle it, and it overrides the other pages
    -- It stays visible for 10 seconds after the condition is not more valid
    if  (get(Apu_master_button_state) == 1 and get(Apu_avail) == 0) or (curr_time - page_normal_apu_last_show) < 10  then
        -- APU is starting, so show the page
        Goto_ecam(ECAM_PAGE_APU)
        if get(Apu_master_button_state) == 1 and get(Apu_avail) == 0 then
            page_normal_apu_last_show = curr_time
        end
        return
    end

    -- Engine has also a special way to handle it, and it overrides the other pages.
    -- It stays visible for 10 seconds after the knob to be repositioned to 0
    if get(Engine_mode_knob) ~= 0 or (curr_time - page_normal_eng_last_show) < 10 then
        Goto_ecam(ECAM_PAGE_ENG)
        if get(Engine_mode_knob) ~= 0  then
            page_normal_eng_last_show = curr_time
        end
        return
    end

    if get(EWD_flight_phase) == 0 or get(EWD_flight_phase) == 1 then
        Goto_ecam(ECAM_PAGE_DOOR)
    elseif get(EWD_flight_phase) == 2 then
        local sidestick_roll = globalProperty("sim/joystick/yoke_roll_ratio")
        local sidestick_pitch = globalProperty("sim/joystick/yoke_pitch_ratio")
        local rudder_pos = globalProperty("sim/joystick/yoke_heading_ratio")
    
        -- Check: https://aviation.stackexchange.com/questions/46018/what-are-the-mechanical-deflection-angles-for-airbus-side-stick-controllers
        -- for angles
        if math.abs(get(sidestick_roll)*20) > 3 or math.abs(get(sidestick_pitch)*16) > 3 or (get(rudder_pos)*30) > 22 then
            Goto_ecam(ECAM_PAGE_FCTL)
            page_normal_fctl_last_show = get(TIME)
        elseif get(TIME) - page_normal_fctl_last_show < 20 then
            Goto_ecam(ECAM_PAGE_FCTL)
        else
            Goto_ecam(ECAM_PAGE_WHEEL)
        end
    elseif get(EWD_flight_phase) >= 3 and get(EWD_flight_phase) <= 5 then
        Goto_ecam(ECAM_PAGE_ENG)
    elseif get(EWD_flight_phase) == 6 then
    
        -- Check FCOM for the following conditions
        is_takeoff_power  = get(Eng_1_N1) >= 74 or get(Eng_2_N1) >= 74
        top_condition     = get(Flaps_deployed_angle) > 0 or is_takeoff_power
        bottom_condition  = get(Flaps_deployed_angle) == 0 and not is_takeoff_power
        if top_condition and not timer_cruise_page then
            sasl.resetTimer(timer_cruise_page)
            sasl.startTimer(timer_cruise_page)
        end
        timer_has_expired = sasl.getElapsedSeconds(timer_cruise_page) >= 60
        final_condition = (top_condition and timer_has_expired) or bottom_condition

        if get(Gear_handle) == 1 and get(Capt_baro_alt_ft) < 16000 then
            Goto_ecam(ECAM_PAGE_WHEEL)
        else
            if final_condition then
                Goto_ecam(ECAM_PAGE_CRUISE)
            else
                Goto_ecam(ECAM_PAGE_ENG)
            end
        end
    elseif get(EWD_flight_phase) >= 7 and get(EWD_flight_phase) <= 9 then
        Goto_ecam(ECAM_PAGE_WHEEL)
    elseif get(EWD_flight_phase) == 10 then
        Goto_ecam(ECAM_PAGE_DOOR)
    else
        logWarning("ERROR: This condition should never happen")
    end    
end

function ecam_user_press_all(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
            local next_page = (get(Ecam_current_page) % 12) + 1
            set(Ecam_current_page, next_page)
            set(Ecam_current_status, ECAM_STATUS_SHOW_ALL)
            page_all_start_time = get(TIME)
        end
    elseif phase == SASL_COMMAND_CONTINUE and get(Ecam_current_status) ~= ECAM_STATUS_SHOW_ALL then
        set(Ecam_current_status, ECAM_STATUS_SHOW_ALL)
        page_all_start_time = get(TIME)
    elseif phase == SASL_COMMAND_END then
        if get(Ecam_current_status) == ECAM_STATUS_SHOW_ALL then
            set(Ecam_current_status, ECAM_STATUS_SHOW_USER)
        end
    end
end

local function update_page_all(phase)

    if get(TIME) - page_all_start_time >= 1 then
        page_all_start_time = get(TIME)
        local curr_page = get(Ecam_current_page)
        local next_page = (curr_page % 12) + 1
        set(Ecam_current_page, next_page)
    end
end

-- This function update the page when ecam automatic is in action
function ecam_update_page()
    if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
        -- User is forcing a page, nothing to do
        return
    end

    if get(Ecam_is_sts_clearable) == 1 then
        if get(Ecam_status_is_normal) == 1  then
            -- We dont need to clear the STS page if it is normal (this happens when a fault disappear)
            set(Ecam_is_sts_clearable, 0)
            set(Ecam_EDW_requested_page, 0)
            set(Ecam_current_status, ECAM_STATUS_NORMAL)
        else
            -- We didn't cleared the sts page, so let's go there and change mode
            set(Ecam_current_status, ECAM_STATUS_SHOW_EWD_STS)
            Goto_ecam(ECAM_PAGE_STS)
            return
        end
    end
    
    if get(Ecam_EDW_requested_page) == 0 then
        -- If EDW does not have requested a page, we have normal situation or ALL button
        if get(Ecam_current_status) == ECAM_STATUS_NORMAL then
            update_page_normal()
            return
        end
        
        if get(Ecam_current_status) == ECAM_STATUS_SHOW_ALL then
            update_page_all()
            return
        end
    else
        -- Otherwise we have two cases:
        -- - Show the page of affected system
        -- - Show the status page to clear
        if get(Ecam_EDW_requested_page) ~= ECAM_PAGE_STS then
            set(Ecam_current_status, ECAM_STATUS_SHOW_EWD)
            Goto_ecam(get(Ecam_EDW_requested_page))
        else
            set(Ecam_current_status, ECAM_STATUS_SHOW_EWD_STS)
            Goto_ecam(ECAM_PAGE_STS)
        end
    end
    
end

