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

local TIME_TO_ALIGN_SEC = 90
local baro_in_std = true

-- Toggle LS
sasl.registerCommandHandler (ISIS_cmd_LS, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then 
        set(ISIS_landing_system_enabled, get(ISIS_landing_system_enabled) == 1 and 0 or 1) 
    end 
end)
sasl.registerCommandHandler (ISIS_cmd_Knob_c, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) + 0.01, 28, 31))end baro_in_std = false end)
sasl.registerCommandHandler (ISIS_cmd_Knob_cc, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) - 0.01, 28, 31))end baro_in_std = false end)

sasl.registerCommandHandler (ISIS_cmd_RotaryPress, 0, function(phase) 
    if phase == SASL_COMMAND_BEGIN then 
        baro_in_std = not baro_in_std
    end 
end)

local isis_start_time = 0
local spd_tape_x = 37
local spd_tape_y = 241
local spd_tape_y_offset = -13
local spd_tape_per_reading = 20 --px per reading, 000 to 010 is 20px

local function draw_spd_stby()
    sasl.gl.drawRectangle(20, spd_tape_y - 22 , 85, 45, PFD_YELLOW)
    sasl.gl.drawText(Font_ECAMfont, 62, spd_tape_y + spd_tape_y_offset, "SPD", 34, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
end

local function draw_speed_tape()
    if get(Stby_IAS) > -20 and get(Stby_IAS) < 520 then --add conditions for standby flag to draw here\
        sasl.gl.drawTexture (ISIS_spd_pointer, 76, 219, 28, 45, {1, 1, 1})
        sasl.gl.setClipArea (0, 100, 76, 308)
        local airspeed_y_offset = get(Stby_IAS) * 4 -- 4 px per airspeed notch
        for i=-4, 104 do -- if you want to get the i for a certain airspeed, divided the airspeed by 5.

            local dashes_y = (spd_tape_y + spd_tape_per_reading * i - airspeed_y_offset)


            local curr_spd = i * 20

            if (curr_spd <= get(Stby_IAS) + 70) and (curr_spd >= get(Stby_IAS) - 50) and i*20 <= 520 and i*20 >= -20 then
                sasl.gl.drawText(Font_ECAMfont, spd_tape_x, dashes_y + spd_tape_y_offset + 60 * i, Fwd_string_fill( tostring(math.abs(i*20)), "0", 3) , 32, false, false, TEXT_ALIGN_CENTER, EFB_FULL_GREEN)
            end

            local curr_spd_for_dashes = i * 5
            if (curr_spd_for_dashes <= get(Stby_IAS) + 50) and (curr_spd_for_dashes >= get(Stby_IAS) - 50) then 
                if (i+2)%4 == 0 then -- if the airspeed notch should be displayed as a long dash
                    sasl.gl.drawWideLine(spd_tape_x+21, dashes_y, spd_tape_x+38, dashes_y, 3, EFB_FULL_GREEN) --long dashes
                else
                    if i < 50 then -- if airspeed below 250
                        sasl.gl.drawWideLine(spd_tape_x+32, dashes_y, spd_tape_x+38, dashes_y, 3, EFB_FULL_GREEN) --draw short dashes for every 5kt as it should
                    elseif (i+2)%2 == 0 then
                        local dashes_y_above_250 = (spd_tape_y + spd_tape_per_reading * i  - airspeed_y_offset) --draw short dashes only every 10kt
                        sasl.gl.drawWideLine(spd_tape_x+32, dashes_y_above_250, spd_tape_x+38, dashes_y_above_250, 3, EFB_FULL_GREEN)
                    end        
                end
            end
        end
        sasl.gl.resetClipArea ()
    else 
        draw_spd_stby()
    end
end

local alt_tape_x = 446
local alt_tape_per_reading = 20

local function draw_alt_stby()
    sasl.gl.drawRectangle(480-85, spd_tape_y - 22 , 85, 45, PFD_YELLOW)
    sasl.gl.drawText(Font_ECAMfont, 500-62, spd_tape_y + spd_tape_y_offset, "ALT", 34, false, false, TEXT_ALIGN_CENTER, ECAM_BLACK)
end

local function draw_alt_tape()
    if get(Stby_Alt) > -2000 and get(Stby_Alt) < 50000 then --add conditions for standby flag to draw here
        sasl.gl.setClipArea (403, 100, 97, 308)
        --sasl.gl.drawTexture (ISIS_spd_pointer, 76, 219, 28, 45, {1, 1, 1})
        local alt_y_offset = get(Stby_Alt) * 0.216 + 10 -- 0.216 px per altitude notch
        for i=-16, 400 do -- 4 i for 500ft, 1 i is 125ft.

            local dashes_y = (spd_tape_y - alt_y_offset)


            local curr_alt = i * 500

            if (curr_alt <= get(Stby_Alt) + 1000) and (curr_alt >= get(Stby_Alt) - 1000) and curr_alt <= 50000 and curr_alt >= -2000 then
                sasl.gl.drawText(Font_ECAMfont, alt_tape_x, dashes_y + 108 * i, Fwd_string_fill( tostring(math.abs(curr_alt)/100), "0", 3) , 32, false, false, TEXT_ALIGN_CENTER, EFB_FULL_GREEN)
            end

            local curr_alt_for_dashes = i * 500/4
            if curr_alt_for_dashes < (get(Stby_Alt) + 1000) and curr_alt_for_dashes > (get(Stby_Alt) -1000) then
                if i%4 == 0 then
                    sasl.gl.drawWideLine(alt_tape_x-38, dashes_y + 12 + i * 108/4, alt_tape_x-32, dashes_y + 12+ i * 108/4, 3, EFB_FULL_GREEN) --long dashes
                else
                    sasl.gl.drawWideLine(alt_tape_x-38, dashes_y + 12 + i * 108/4, alt_tape_x-18, dashes_y + 12+ i * 108/4, 3, EFB_FULL_GREEN) --long dashes
                end
            end
        end
        sasl.gl.resetClipArea ()
        sasl.gl.drawTexture(ISIS_alt_window, 350, 212, 150, 61, {1,1,1})
        sasl.gl.drawText(Font_ECAMfont, 500-62, spd_tape_y-11, math.floor(math.abs((get(Stby_Alt)/100)), 0), 34, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        local alt_100_looping = get(Stby_Alt)%100
        print(alt_100_looping)
        sasl.gl.setClipArea (450, 215, 45, 55)
            sasl.gl.drawTexture(ISIS_alt_scrolling, 452, 198 - 155*alt_100_looping/100, 36, 244, {1,1,1})
        sasl.gl.resetClipArea ()
    else 
        draw_alt_stby()
    end
    if get(Stby_Alt) < 0 then
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13 + 40, "N", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13, "E", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_ECAMfont, 385, spd_tape_y-13 - 40, "G", 40, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    end
end

local function draw_meters_display()
    Sasl_DrawWideFrame(214, 445, 194, 33, 2, 0, ECAM_GREEN)
    local meter_alt = math.floor(math.abs(get(Stby_Alt)) * 0.3048)
    sasl.gl.drawText (Font_AirbusDUL, 360, 451, meter_alt, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText (Font_AirbusDUL, 403, 449, "M", 35, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    if get(Stby_Alt) < 0 then
        sasl.gl.drawText (Font_AirbusDUL, 222, 451, "NEG", 32, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end
end

local att_x_center = 239
local att_y_center = 250

local function draw_att()
    sasl.gl.drawMaskStart ()
    sasl.gl.drawTexture(ISIS_horizon_mask, 0, 0, 500, 500, {1,1,1})
    sasl.gl.drawUnderMask(true)

    SASL_rotated_center_img_xcenter_aligned(
        ISIS_horizon,
        att_x_center,
        att_y_center,
        2000,
        700,
        90 - get(Capt_bank),
        get(Capt_pitch) * 6.125+8,
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
        -700/2+45,
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
        -700/2+44,
        ECAM_WHITE
    )
end

local function draw_barometer()
    if baro_in_std then
        set(Stby_Baro, 29.92)
        sasl.gl.drawText (Font_AirbusDUL, 240, 25, "STD", 36, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    else
        local baro_mmhg = Round(get(Stby_Baro),2)
        local baro_kpa  = Round(33.8639 * get(Stby_Baro),0)
        sasl.gl.drawText (Font_AirbusDUL, 240, 25, tostring(Round(baro_kpa,0)) .. "/" .. string.format("%.2f", tostring(baro_mmhg)), 36, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end
end

local function draw_background()
    sasl.gl.drawRectangle(0, 0, 500, 500, ECAM_BLACK)
end
local function legacy_code()
    if get(ISIS_powered) == 0 then
        return
    end
    if get(ISIS_ready) == 0 then
        -- Not ready, draw the countdown
        local remaning_time = math.ceil(TIME_TO_ALIGN_SEC - get(TIME) + isis_start_time)
        if remaning_time > 0 then
            sasl.gl.drawText (Font_AirbusDUL, 308, 103, remaning_time, 37, false, false, TEXT_ALIGN_RIGHT, ECAM_BLACK)
        end
    else
        -- Ready, draw the altitude in meters

        --if adirs_is_mach_ok(PFD_CAPT) then
        --    -- Mach number, this is available only if the ADR for the Capt is ok
        --    local good_mach = Round(adirs_get_mach(PFD_CAPT) * 100, 0)
        --    if good_mach < 100 then
        --        sasl.gl.drawText (Font_AirbusDUL, 60, 40, "." .. good_mach, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        --    else
        --        sasl.gl.drawText (Font_AirbusDUL, 60, 40, good_mach/100, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)            
        --    end
        --end
    end
end

function draw()
    sasl.gl.setRenderTarget(ISIS_popup_texture, true)
    --draw_background()

    draw_att()
    draw_speed_tape()
    legacy_code()
    draw_alt_tape()
    draw_meters_display()
    draw_barometer()

    sasl.gl.restoreRenderTarget()
    sasl.gl.drawTexture(ISIS_popup_texture, 0, 0, 500, 500, {1,1,1})
end

function update()

    if ((get(Stby_IAS) > 50 or get(All_on_ground) == 0) and get(HOT_bus_1_pwrd) == 1) or get(DC_ess_bus_pwrd) == 1 then
        set(ISIS_powered, 1)
    else
        set(ISIS_powered, 0)
        set(ISIS_ready, 0)
        isis_start_time = 0
        return
    end
    
    if isis_start_time == 0 then
        isis_start_time = get(TIME)
    end

    if get(TIME) - isis_start_time > TIME_TO_ALIGN_SEC then
        set(ISIS_ready, 1)
    else
        set(ISIS_ready, 1)
    end

end
