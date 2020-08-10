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

local ECAM_STATUS_NORMAL       = 0  -- No buttons pressed, no warning, normal situation, page displayed depends on flight phase
local ECAM_STATUS_SHOW_USER    = 1  -- User has pressed a page button
local ECAM_STATUS_SHOW_ALL     = 2  -- ALL button has been pressed
local ECAM_STATUS_SHOW_EWD     = 3  -- Dealing with EWD
local ECAM_STATUS_SHOW_EWD_STS = 4  -- Dealing with EWD - final STS page

-------------------------------------------------------------------------------
-- Commands
-------------------------------------------------------------------------------

-- Buttons with light (check cockpit_datarefs.lua for light datarefs):
local Ecam_btn_cmd_ENG   = createCommand("a321neo/cockpit/ecam/buttons/cmd_eng", "ENG pushbutton")
local Ecam_btn_cmd_BLEED = createCommand("a321neo/cockpit/ecam/buttons/cmd_bleed", "BLEED pushbutton")
local Ecam_btn_cmd_PRESS = createCommand("a321neo/cockpit/ecam/buttons/cmd_press", "PRESS pushbutton")
local Ecam_btn_cmd_ELEC  = createCommand("a321neo/cockpit/ecam/buttons/cmd_elec", "ELEC pushbutton")
local Ecam_btn_cmd_HYD   = createCommand("a321neo/cockpit/ecam/buttons/cmd_hyd", "HYD pushbutton")
local Ecam_btn_cmd_FUEL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fuel", "FUEL pushbutton")
local Ecam_btn_cmd_APU   = createCommand("a321neo/cockpit/ecam/buttons/cmd_apu", "APU pushbutton")
local Ecam_btn_cmd_COND  = createCommand("a321neo/cockpit/ecam/buttons/cmd_cond", "COND pushbutton")
local Ecam_btn_cmd_DOOR  = createCommand("a321neo/cockpit/ecam/buttons/cmd_door", "DOOR pushbutton")
local Ecam_btn_cmd_WHEEL = createCommand("a321neo/cockpit/ecam/buttons/cmd_wheel", "WHEEL pushbutton")
local Ecam_btn_cmd_FCTL  = createCommand("a321neo/cockpit/ecam/buttons/cmd_fctl", "FCTL pushbutton")
local Ecam_btn_cmd_CLR   = createCommand("a321neo/cockpit/ecam/buttons/cmd_clr", "CLR pushbutton")
local Ecam_btn_cmd_STS   = createCommand("a321neo/cockpit/ecam/buttons/cmd_sts", "STS pushbutton")

-- No light buttons:
local Ecam_btn_cmd_TOCFG = createCommand("a321neo/cockpit/ecam/buttons/cmd_toconfig", "T.O CONFIG pushbutton")
local Ecam_btn_cmd_EMERC = createCommand("a321neo/cockpit/ecam/buttons/cmd_emercanc", "EMER CANC pushbutton")
local Ecam_btn_cmd_ALL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_all", "ALL pushbutton")
local Ecam_btn_cmd_RCL   = createCommand("a321neo/cockpit/ecam/buttons/cmd_rcl", "RCL pushbutton")

-------------------------------------------------------------------------------
-- Command registration
-------------------------------------------------------------------------------
sasl.registerCommandHandler (Ecam_btn_cmd_ENG,   0 , function(phase) user_press_page_button(phase,ECAM_PAGE_ENG) end )
sasl.registerCommandHandler (Ecam_btn_cmd_BLEED, 0 , function(phase) user_press_page_button(phase,ECAM_PAGE_BLEED) end )
sasl.registerCommandHandler (Ecam_btn_cmd_PRESS, 0 , function(phase) user_press_page_button(phase,ECAM_PAGE_PRESS) end )
sasl.registerCommandHandler (Ecam_btn_cmd_ELEC,  0 , function(phase) user_press_page_button(phase,ECAM_PAGE_ELEC) end )
sasl.registerCommandHandler (Ecam_btn_cmd_HYD,   0 , function(phase) user_press_page_button(phase,ECAM_PAGE_HYD) end )
sasl.registerCommandHandler (Ecam_btn_cmd_FUEL,  0 , function(phase) user_press_page_button(phase,ECAM_PAGE_FUEL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_APU,   0 , function(phase) user_press_page_button(phase,ECAM_PAGE_APU) end )
sasl.registerCommandHandler (Ecam_btn_cmd_COND,  0 , function(phase) user_press_page_button(phase,ECAM_PAGE_COND) end )
sasl.registerCommandHandler (Ecam_btn_cmd_DOOR,  0 , function(phase) user_press_page_button(phase,ECAM_PAGE_DOOR) end )
sasl.registerCommandHandler (Ecam_btn_cmd_WHEEL, 0 , function(phase) user_press_page_button(phase,ECAM_PAGE_WHEEL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_FCTL,  0 , function(phase) user_press_page_button(phase,ECAM_PAGE_FCTL) end )
sasl.registerCommandHandler (Ecam_btn_cmd_STS,   0 , function(phase) user_press_page_button(phase,ECAM_PAGE_STS) end )

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local timer_cruise_page         = sasl.createTimer()    -- Used in update_page_normal()
local timer_cruise_page_started = false
local page_normal_apu_last_show = 0
local page_normal_eng_last_show = 0

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
function user_press_page_button(phase, which_page)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
        -- We are already in user mode

        if get(Ecam_current_page) == which_page then
            -- User is de-activating the page (s)he previously selected
            set(Ecam_current_status, ECAM_STATUS_NORMAL)    -- Resume normal mode, page will be changed automatically
        else
            Goto_ecam(which_page)        
        end
    else
        -- Change the page in *any* case (forced by user)
        set(Ecam_current_status,ECAM_STATUS_SHOW_USER)
        Goto_ecam(which_page)
    end

end

-- This function update the pushbutton leds status
function ecam_update_leds()

    -- Let's turn off all the leds
    set(Ecam_btn_light_ENG,  0)
    set(Ecam_btn_light_BLEED,0)
    set(Ecam_btn_light_PRESS,0)
    set(Ecam_btn_light_ELEC, 0)
    set(Ecam_btn_light_FUEL, 0)
    set(Ecam_btn_light_APU,  0)
    set(Ecam_btn_light_COND, 0)
    set(Ecam_btn_light_DOOR, 0)
    set(Ecam_btn_light_WHEEL,0)
    set(Ecam_btn_light_FCTL, 0)
    set(Ecam_btn_light_CLR,  0)
    set(Ecam_btn_light_STS,  0)

    -- Let's turn on the led of the current page
    if get(Ecam_current_page) == ECAM_PAGE_ENG then
        set(Ecam_btn_light_ENG, 1)
    elseif get(Ecam_current_page) == ECAM_PAGE_BLEED then
        set(Ecam_btn_light_BLEED, 1)
    elseif get(Ecam_current_page) == ECAM_PAGE_PRESS then
        set(Ecam_btn_light_PRESS, 1)
    elseif get(Ecam_current_page) == ECAM_PAGE_ELEC then
        set(Ecam_btn_light_ELEC, 1)
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

    -- TODO CLR led
    
    -- TODO Advisory blinking leds

end



-- Update the page when no pushbuttons are pressed, no ecam messages, no status, etc,
function update_page_normal()

    local curr_time = get(TIME)

    -- APU has a special way to handle it, and it overrides the other pages
    -- It stays visible for 10 seconds after the condition is not more valid
    if  (get(Apu_start_position) > 0 and get(Apu_avail) == 0) or (curr_time - page_normal_apu_last_show) < 10  then
        -- APU is starting, so show the page
        Goto_ecam(ECAM_PAGE_APU)
        if get(Apu_start_position) > 0 and get(Apu_avail) == 0 then
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
        -- TODO Add sidestick deflection
        Goto_ecam(ECAM_PAGE_WHEEL)
    elseif get(EWD_flight_phase) >= 3 and get(EWD_flight_phase) <= 5 then
        Goto_ecam(ECAM_PAGE_ENG)
    elseif get(EWD_flight_phase) == 6 then
    
        -- Check FCOM for the following conditions
        is_takeoff_power  = get(Eng_1_N1) >= 74 or get(Eng_2_N1) >= 74
        top_condition     = get(Flaps_handle_deploy_ratio) > 0 or is_takeoff_power
        bottom_condition  = get(Flaps_handle_deploy_ratio) == 0 and not is_takeoff_power
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
        print("ERROR: This condition should never happen")
    end    
end

-- This function update the page when ecam automatic is in action
function update_page()
    if get(Ecam_current_status) == ECAM_STATUS_SHOW_USER then
        -- User is forcing a page, nothing to do
        return
    end
    
    if get(Ecam_current_status) == ECAM_STATUS_NORMAL then
        update_page_normal()
    else
    
    end

end

