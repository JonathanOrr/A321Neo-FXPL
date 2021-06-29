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
-- File: clock.lua 
-- Short description: Clock & Chronometer instrument
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------------------------


position= {2200,1951,184,245}
size = {184, 245}
local SevenSegment = sasl.gl.loadFont("fonts/Segment7Standard.otf")

local CHRONO_STATE_RST = 2
local CHRONO_STATE_STP = 1
local CHRONO_STATE_RUN = 0
local CHRONO_SOURCE_SET = 2
local CHRONO_SOURCE_INT = 1
local CHRONO_SOURCE_GPS = 0



-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local clock_brightness = 0

local clock_is_showing_date = false
local chrono_state  = CHRONO_STATE_STP
local chrono_source = CHRONO_SOURCE_GPS

local et_time = 0 -- Elapsed time in seconds

local int_time = get(ZULU_hours) * 60 * 60 + get(ZULU_mins) * 60 + get(ZULU_secs) - 3 + 6 * math.random() -- Add a random error
local int_date_day = get(ZULU_day)
local int_date_month = get(ZULU_month)
local int_date_year = tonumber(os.date("%y"))
local int_time_sim_point = get(TIME)

local chrono_cumul = 0
local chrono_running = false

local what_is_changing = 0 -- 1: miuntes, 2:hour, 3:year, 4:day, 5:month

-------------------------------------------------------------------------------
-- Commands & Handlers
-------------------------------------------------------------------------------

sasl.registerCommandHandler (Chrono_cmd_state_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_state = math.max(0,chrono_state-1) end end )
sasl.registerCommandHandler (Chrono_cmd_state_up, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then
        chrono_state = math.min(2,chrono_state+1)
    elseif phase == SASL_COMMAND_END and chrono_state == 2 then
        chrono_state = 1
    end
end )
sasl.registerCommandHandler (Chrono_cmd_source_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_source = math.max(0,chrono_source-1); what_is_changing = 1 end end )
sasl.registerCommandHandler (Chrono_cmd_source_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_source = math.min(2,chrono_source+1); what_is_changing = 1  end end )
sasl.registerCommandHandler (Chrono_cmd_chr,       0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_running = not chrono_running end end )
sasl.registerCommandHandler (Chrono_cmd_rst,       0, function(phase) if phase == SASL_COMMAND_BEGIN then chrono_cumul = 0 end end )
sasl.registerCommandHandler (Chrono_cmd_date,      0, function(phase) if phase == SASL_COMMAND_BEGIN then 
        if chrono_source == CHRONO_SOURCE_SET then
            what_is_changing = (what_is_changing) % 5 + 1
            clock_is_showing_date = what_is_changing > 2
        else
            clock_is_showing_date = not clock_is_showing_date
        end
    end
end)

local function knob_change(phase, direction)
    if chrono_source ~= CHRONO_SOURCE_SET or phase ~= SASL_COMMAND_BEGIN then
        return
    end
    if what_is_changing == 1 and int_time%60+direction < 60 and int_time%60+direction > -1 then
        int_time = int_time + direction * 60
    elseif what_is_changing == 2 and int_time%3600+direction < 24 and int_time%3600+direction >= 0 then
        int_time = int_time + direction * 3600
    elseif what_is_changing == 3 and int_date_year+direction < 99 and int_date_year+direction >= 0 then
        int_date_year = int_date_year + direction
    elseif what_is_changing == 4 and int_date_day+direction < 31 and int_date_day+direction > 0  then
        int_date_day = int_date_day + direction
    elseif what_is_changing == 5 and int_date_month+direction < 13 and int_date_month+direction > 0 then
        int_date_month = int_date_month + direction
    end
end

sasl.registerCommandHandler (Chrono_cmd_date_up,      0, function(phase) knob_change(phase, 1) end)
sasl.registerCommandHandler (Chrono_cmd_date_dn,      0, function(phase) knob_change(phase, -1) end)
-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function update_anim()
    Set_dataref_linear_anim_nostop(Chrono_state_button, chrono_state, 0, 2, 10)
    Set_dataref_linear_anim_nostop(Chrono_source_button, chrono_source, 0, 2, 10)
end

function update_et()
    if chrono_state == CHRONO_STATE_RUN then
        et_time = et_time + get(DELTA_TIME)
    elseif chrono_state == CHRONO_STATE_RST then
        et_time = 0
    end
end

function update_chrono()
    if chrono_running then
        chrono_cumul = chrono_cumul + get(DELTA_TIME)
    end
end

function update()
    clock_brightness = Set_anim_value(clock_brightness, get(DC_ess_bus_pwrd), 0, 1, 10)
    update_anim()
    update_et()
    update_chrono()
end

local function fz(x)
    if x < 10 then
        return "0" .. x
    else
        return x
    end
end

local function get_int_data()
    if clock_is_showing_date then
        return fz(int_date_month) .. fz(int_date_day) .. fz(int_date_year)
    else
        local time_to_output = get(TIME) - int_time_sim_point + int_time
        return fz(get(math.floor(time_to_output/3600) % 24)) .. fz(math.floor(time_to_output/60) % 60) .. fz(math.floor(time_to_output) % 60)
    end
end

local function get_gps_data()

    local year = tonumber(os.date("%y"))
    if GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV then
        if clock_is_showing_date then
            return fz(get(ZULU_month)) .. fz(get(ZULU_day)) .. fz(year)
        else
            return fz(get(ZULU_hours)) .. fz(get(ZULU_mins)) .. fz(get(ZULU_secs))
        end
    else
        -- No GPS info? No party
        return "------"
    end
end

local function draw_backlight()
    Draw_blue_LED_backlight(size[1]/2 - 80, size[2]/2+26, 130, 46, 0.5, 1, clock_brightness)
    Draw_blue_LED_backlight(size[1]/2 - 80, size[2]/2-24, 170, 46, 0.5, 1, clock_brightness)
    Draw_blue_LED_backlight(size[1]/2 - 80, size[2]/2-80, 130, 46, 0.5, 1, clock_brightness)
end

local function draw_chr(is_visible, min, sec)
    Draw_white_LED_num_and_letter(size[1]/2 - 46, size[2]/2+32, is_visible and min or "", 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    Draw_white_LED_num_and_letter(size[1]/2 + 12, size[2]/2+32, is_visible and sec or "", 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    Draw_white_LED_num_and_letter(size[1]/2 - 16, size[2]/2+32, is_visible and ":" or "", 0, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
end

local function draw_et(is_visible, hr, min)
    Draw_white_LED_num_and_letter(size[1]/2 - 46, size[2]/2-73, is_visible and hr or "", 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    Draw_white_LED_num_and_letter(size[1]/2 + 12, size[2]/2-73, is_visible and min or "", 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    Draw_white_LED_num_and_letter(size[1]/2 - 16, size[2]/2-73, is_visible and ":" or "", 0, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
end

local function draw_clock()
    local clock_str = ""
    if chrono_source == CHRONO_SOURCE_GPS then
        clock_str = get_gps_data()
    elseif chrono_source == CHRONO_SOURCE_INT then
        clock_str = get_int_data()
    else
        if what_is_changing > 2 then
            clock_str = get_int_data()
        else
            clock_str = string.sub(get_int_data(),0,4)
        end
    end

    local is_colon_visible =  not clock_is_showing_date and clock_str ~= "------" 
    Draw_white_LED_num_and_letter(69, 102, is_colon_visible and ":" or "", 0, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)

    if get(TIME) % 0.75 < 0.5 or chrono_source ~= CHRONO_SOURCE_SET or (what_is_changing ~= 2 and what_is_changing ~= 5) then
        Draw_white_LED_num_and_letter(40, 102, string.sub(clock_str,1,2), 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    end
    if get(TIME) % 0.75 < 0.5 or chrono_source ~= CHRONO_SOURCE_SET or (what_is_changing ~= 1 and what_is_changing ~= 4) then
        Draw_white_LED_num_and_letter(97, 102, string.sub(clock_str,3,4), 2, 55, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    end
    if get(TIME) % 0.75 < 0.5 or chrono_source ~= CHRONO_SOURCE_SET or (what_is_changing ~= 3) then
        Draw_white_LED_num_and_letter(151, 105, string.sub(clock_str,5,6), 2, 45, TEXT_ALIGN_CENTER, 0.2, 1, clock_brightness)
    end
end

function draw()

    draw_backlight()

    -- ET
    local min = fz(math.floor(et_time / 60) % 60)
    local hr  = fz(math.floor(et_time / 3600) % 60)
    draw_et(et_time > 0, hr, min)

    -- CHRONO
    local min = fz(math.floor(chrono_cumul/60)%99)
    local sec = fz(math.floor(chrono_cumul)%60)
    draw_chr(chrono_cumul > 0, min, sec)

    -- CLOCK
    draw_clock()
end
