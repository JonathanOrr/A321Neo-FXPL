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
-- File: ISIS.lua 
-- Short description: The file containing the code for the ISIS widget
-------------------------------------------------------------------------------

position= {30,1311,500,500}
size = {500, 500}

include("ADIRS_data_source.lua")
include("DRAIMS/radio_logic.lua")

local TIME_TO_ALIGN_SEC = 90
local baro_in_std = false
local ls_enabled = false

local spd_tape_x = 37
local spd_tape_y = 241
local spd_tape_y_offset = -13
local spd_tape_per_reading = 20 --px per reading, 000 to 010 is 20px

local alt_tape_x = 446
local alt_tape_per_reading = 20

local att_x_center = 239
local att_y_center = 250

local att_reset_start_time = 0
local reset_button_start_time = 0
local reset_button_elapsed_time = 0

local att_has_to_be_realigned = false

local mach_displayed = false

-- Toggle LS
sasl.registerCommandHandler (ISIS_cmd_LS, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then 
        ls_enabled = not ls_enabled
    end 
end)
sasl.registerCommandHandler (ISIS_cmd_Knob_c, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) + 0.01, 28, 31))end baro_in_std = false end)
sasl.registerCommandHandler (ISIS_cmd_Knob_cc, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) - 0.01, 28, 31))end baro_in_std = false end)

sasl.registerCommandHandler (ISIS_cmd_RotaryPress, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then 
        baro_in_std = not baro_in_std
    end 
end)

sasl.registerCommandHandler (ISIS_cmd_rst, 0, function(phase)
    if phase == SASL_COMMAND_CONTINUE then
        reset_button_elapsed_time = reset_button_elapsed_time + get(DELTA_TIME)
    else
        reset_button_elapsed_time = 0
    end
end)


local function draw_spd_stby()
    sasl.gl.drawRectangle(20, spd_tape_y - 22 , 85, 45, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 62, spd_tape_y + spd_tape_y_offset, "SPD", 34, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end

local function draw_speed_tape()
    if get(ISIS_IAS) > -20 and get(ISIS_IAS) < 520 then --add conditions for standby flag to draw here\
        sasl.gl.drawTexture (ISIS_spd_pointer, 76, 219, 28, 45, {1, 1, 1})
        sasl.gl.setClipArea (0, 100, 76, 308)
        local airspeed_y_offset = get(ISIS_IAS) * 4 -- 4 px per airspeed notch
        for i=-4, 104 do -- if you want to get the i for a certain airspeed, divided the airspeed by 5.

            local dashes_y = (spd_tape_y + spd_tape_per_reading * i - airspeed_y_offset)


            local curr_spd = i * 20

            if (curr_spd <= get(ISIS_IAS) + 70) and (curr_spd >= get(ISIS_IAS) - 50) and i*20 <= 520 and i*20 >= -20 then
                sasl.gl.drawText(Font_ECAMfont, spd_tape_x, dashes_y + spd_tape_y_offset + 60 * i, Fwd_string_fill( tostring(math.abs(i*20)), "0", 3) , 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
            end

            local curr_spd_for_dashes = i * 5
            if (curr_spd_for_dashes <= get(ISIS_IAS) + 50) and (curr_spd_for_dashes >= get(ISIS_IAS) - 50) then 
                if (i+2)%4 == 0 then -- if the airspeed notch should be displayed as a long dash
                    sasl.gl.drawWideLine(spd_tape_x+21, dashes_y, spd_tape_x+38, dashes_y, 3, ECAM_WHITE) --long dashes
                else
                    if i < 50 then -- if airspeed below 250
                        sasl.gl.drawWideLine(spd_tape_x+32, dashes_y, spd_tape_x+38, dashes_y, 3, ECAM_WHITE) --draw short dashes for every 5kt as it should
                    elseif (i+2)%2 == 0 then
                        local dashes_y_above_250 = (spd_tape_y + spd_tape_per_reading * i  - airspeed_y_offset) --draw short dashes only every 10kt
                        sasl.gl.drawWideLine(spd_tape_x+32, dashes_y_above_250, spd_tape_x+38, dashes_y_above_250, 3, ECAM_WHITE)
                    end        
                end
            end
        end
        sasl.gl.resetClipArea ()
    else 
        draw_spd_stby()
    end
end

local function draw_alt_stby()
    sasl.gl.drawRectangle(480-85, spd_tape_y - 22 , 85, 45, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 500-62, spd_tape_y + spd_tape_y_offset, "ALT", 34, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end

local function draw_mach_stby()
    sasl.gl.drawRectangle(41, 25 , 58, 41, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 41+58/2, 35, "M", 34, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end

local function draw_alt_tape()
    if get(ISIS_Altitude) > -2000 and get(ISIS_Altitude) < 50000 then --add conditions for standby flag to draw here
        sasl.gl.setClipArea (403, 100, 97, 308)
        --sasl.gl.drawTexture (ISIS_spd_pointer, 76, 219, 28, 45, {1, 1, 1})
        local alt_y_offset = get(ISIS_Altitude) * 0.216 + 10 -- 0.216 px per altitude notch
        for i=-16, 400 do -- 4 i for 500ft, 1 i is 125ft.

            local dashes_y = (spd_tape_y - alt_y_offset)


            local curr_alt = i * 500

            if (curr_alt <= get(ISIS_Altitude) + 1000) and (curr_alt >= get(ISIS_Altitude) - 1000) and curr_alt <= 50000 and curr_alt >= -2000 then
                sasl.gl.drawText(Font_ECAMfont, alt_tape_x, dashes_y + 108 * i, Fwd_string_fill( tostring(math.abs(curr_alt)/100), "0", 3) , 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
            end

            local curr_alt_for_dashes = i * 500/4
            if curr_alt_for_dashes < (get(ISIS_Altitude) + 1000) and curr_alt_for_dashes > (get(ISIS_Altitude) -1000) then
                if i%4 == 0 then
                    sasl.gl.drawWideLine(alt_tape_x-38, dashes_y + 12 + i * 108/4, alt_tape_x-32, dashes_y + 12+ i * 108/4, 3, ECAM_WHITE) --long dashes
                else
                    sasl.gl.drawWideLine(alt_tape_x-38, dashes_y + 12 + i * 108/4, alt_tape_x-18, dashes_y + 12+ i * 108/4, 3, ECAM_WHITE) --long dashes
                end
            end
        end
        sasl.gl.resetClipArea ()
        sasl.gl.drawTexture(ISIS_alt_window, 350, 212, 150, 61, {1,1,1})
        sasl.gl.drawText(Font_ECAMfont, 500-62, spd_tape_y-11, math.floor(math.abs((get(ISIS_Altitude)/100)), 0), 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        local alt_100_looping = get(ISIS_Altitude)%100
        sasl.gl.setClipArea (450, 215, 45, 55)
            sasl.gl.drawTexture(ISIS_alt_scrolling, 452, 198 - 155*alt_100_looping/100, 36, 244, {1,1,1})
        sasl.gl.resetClipArea ()
    else 
        draw_alt_stby()
    end
    if get(ISIS_Altitude) < 0 then
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13 + 40, "N", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13, "E", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13 - 40, "G", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)

    end
end

local function draw_meters_display()
    Sasl_DrawWideFrame(210, 441, 198, 37, 2, 0, ECAM_YELLOW)
    local meter_alt = math.floor(math.abs(get(ISIS_Altitude)) * 0.3048)
    sasl.gl.drawText (Font_AirbusDUL, 360, 446, meter_alt, 37, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText (Font_AirbusDUL, 403, 446, "M", 34, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    if get(ISIS_Altitude) < 0 then
        sasl.gl.drawText (Font_AirbusDUL, 218, 446, "NEG", 34, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

local function draw_attitude_reset()
    sasl.gl.drawRectangle(155, 180, 170, 34, ECAM_YELLOW)
    sasl.gl.drawText(Font_ECAMfont, 240, 184, "ATT RST", 34, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
end

local function draw_attitude_flag()
    sasl.gl.drawRectangle(198, 257, 84, 34, ECAM_RED)
    sasl.gl.drawText(Font_ECAMfont, 240, 261, "ATT", 34, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end



local time_remaining = 0

local function draw_10s_flag()
    local excessive_motion = math.abs(get(Capt_bank)) > 100 or math.abs(get(Capt_pitch)) > 75 or math.abs(get(Capt_IAS_trend)) > 0.5
    att_has_to_be_realigned = false
    sasl.gl.drawRectangle(157, 300, 166, 34, ECAM_YELLOW)
    if excessive_motion then
        att_reset_start_time = get(TIME) 
        time_remaining = 10
    else
        time_remaining = Fwd_string_fill(tostring(Round(math.ceil(att_reset_start_time - get(TIME) + 10), 0)), " ", 2)
    end
    sasl.gl.drawText(Font_ECAMfont, 240, 304, "ATT"..time_remaining.."s", 34, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
end

local function draw_att()
    if get(TIME) - att_reset_start_time < 11 then
        sasl.gl.drawRectangle(0, 0, 500, 500, {10/255, 15/255, 25/255})
        draw_10s_flag()
    else
        sasl.gl.drawMaskStart ()
        sasl.gl.drawTexture(ISIS_backlit, 0, 0, 500, 500, {0,0,0})
        sasl.gl.drawUnderMask(true)

        SASL_rotated_center_img_xcenter_aligned(
            ISIS_horizon,
            att_x_center,
            att_y_center,
            2000,
            700,
            90 - get(Capt_bank),
            get(Capt_pitch) * 6.8+8,
            -700/2,
            ECAM_WHITE
        )
        sasl.gl.drawMaskEnd ()

        sasl.gl.drawTexture(ISIS_horizon_wings, 0, 0, 500, 500, {1,1,1})

        SASL_rotated_center_img_xcenter_aligned(
            ISIS_roll_arrow,
            att_x_center,
            att_y_center,
            71,
            466,
            -get(Capt_bank),
            4,
            -700/2+33,
            ECAM_WHITE
        )
        SASL_rotated_center_img_xcenter_aligned(
            ISIS_SI,
            att_x_center,
            att_y_center,
            71,
            466,
            -get(Capt_bank),
            4 + Math_clamp(get(Slide_slip_angle),-10,10)*4,
            -700/2+32,
            ECAM_WHITE
        )
    end
    if att_has_to_be_realigned then
        draw_attitude_reset()
    end
end

local function draw_barometer()
    if baro_in_std then
        set(Stby_Baro, 29.92)
        sasl.gl.drawText (Font_AirbusDUL, 240, 25, "STD", 40, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    else
        local baro_mmhg = Round(get(Stby_Baro),2)
        local baro_kpa  = Round(33.8639 * get(Stby_Baro),0)
        sasl.gl.drawText (Font_AirbusDUL, 240, 25, tostring(Round(baro_kpa,0)) .. "/" .. string.format("%.2f", tostring(baro_mmhg)), 36, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end
end

local function draw_background()
    sasl.gl.drawRectangle(0, 0, 500, 500, ECAM_BLACK)
end

local function draw_mach()
    if get(ISIS_Mach) > 0.50 then
        mach_displayed = true
    elseif get(ISIS_Mach) < 0.45 then
        mach_displayed = false
    end
    if mach_displayed then
        if get(ISIS_Mach) > 1 then
            draw_mach_stby()
        else
            sasl.gl.drawText (Font_AirbusDUL, 83, 35, string.sub(Aft_string_fill(tostring(Round(get(ISIS_Mach),2)), "0", 4), 2, 4), 37, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end
    end
end

local function draw_ls()
    if ls_enabled then
        sasl.gl.drawTexture(ISIS_lsh, att_x_center-100, 96, 201, 21, {1,1,1})
        sasl.gl.drawTexture(ISIS_lsv, 328, 140, 21, 201, {1,1,1})

        --if get(ILS_1_glideslope_flag) == 0 then
        if radio_ils_is_valid() and radio_loc_is_valid() then
            sasl.gl.drawTexture(ISIS_localiser, att_x_center-16 + Math_clamp(46 * radio_get_ils_deviation_h()/0.8, -92, 92), 97, 32, 19, {1,1,1})
        end
        if radio_ils_is_valid() and radio_gs_is_valid() then
            sasl.gl.drawTexture(ISIS_glideslope, 329, 225 - Math_clamp(46 * radio_get_ils_deviation_v()/0.4, -92, 92), 19, 32, {1,1,1})
        end
    end
end

local function draw_backlit()
    sasl.gl.drawTexture(ISIS_backlit, 0, 0, 500, 500, {10/255, 15/255, 25/255})
end
    
local function is_isis_powered()
    return get(DC_ess_bus_pwrd) == 1 or (get(HOT_bus_1_pwrd) == 1 and get(ISIS_IAS) > 50)
end

local blinked_already = false
local blink_start_time = 0
local blinking_table = {
    {0, 1},
    {0.1, 0},
    {0.799, 0},
    {0.8, 1},
    {0.85, 0},
    {0.929, 0},
    {0.93, 1},
    {0.97, 1},
    {0.98, 0},
}

local function start_blinks()
    if not blinked_already and is_isis_powered() then
        blinked_already = true
        blink_start_time = get(TIME)
    elseif not is_isis_powered() then
        blinked_already = false
    end
    local elapsed_powered_time = get(TIME) - blink_start_time
    local black_white_hex = Table_interpolate(blinking_table, elapsed_powered_time)
    sasl.gl.drawRectangle(0, 0, 500, 500, {black_white_hex,black_white_hex,black_white_hex, elapsed_powered_time < 1 and 1 or 0})
end

function draw()
    sasl.gl.setRenderTarget(ISIS_popup_texture, true)
    --draw_background()

    if is_isis_powered() then
        draw_att()
        draw_backlit()
        draw_speed_tape()
        draw_alt_tape()
        draw_meters_display()
        draw_barometer()
        draw_mach()
        draw_ls() 
    else
        sasl.gl.drawRectangle(0, 0, 500, 500, ECAM_BLACK)
    end
    start_blinks()
    sasl.gl.restoreRenderTarget()
    sasl.gl.drawTexture(ISIS_popup_texture, 0, 0, 500, 500, {1,1,1})
end

function update()
    
    if ISIS_window:isVisible() then
        local window_x, window_y, window_width, window_height = ISIS_window:getPosition()
        ISIS_window:setPosition ( window_x , window_y , window_width, window_width)
    end

    if reset_button_elapsed_time > 2 then
        att_reset_start_time = get(TIME)
    end 
    if math.abs(get(Capt_bank)) > 100 or math.abs(get(Capt_pitch)) > 75 then -- if bank angle exceeds 100 or pitch exceeds 75
        att_has_to_be_realigned = true
    end
end
