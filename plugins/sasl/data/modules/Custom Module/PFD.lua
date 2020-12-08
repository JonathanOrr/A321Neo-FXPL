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
-- File: PFD.lua 
-- Short description: PFD graphical
-------------------------------------------------------------------------------

position = {30, 3166, 900, 900}
size = {900, 900}

include('constants.lua')

--varibles--
local vvi_left_pixel_offset = 0
local vvi_number_display = 0

--sim dataref--
local current_heading = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
local ground_track = globalProperty("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
local vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

--a32nx dataref--
local ground_track_delta = createGlobalPropertyf("a321neo/cockpit/PFD/ground_track_delta", 0, false, true, false)
local a_floor_speed = createGlobalPropertyf("a321neo/cockpit/PFD/a_floor_speed", 0, false, true, false) -- AFLOOR at 7.5 degrees AoA
local a_floor_speed_delta = createGlobalPropertyf("a321neo/cockpit/PFD/a_floor_speed_delta", 0, false, true, false)
local stall_speed = createGlobalPropertyf("a321neo/cockpit/PFD/stall_speed", 0, false, true, false) -- stall at 9 degrees AoA
local stall_speed_delta = createGlobalPropertyf("a321neo/cockpit/PFD/stall_speed_delta", 0, false, true, false)

--colors
local PFD_BLACK = {0.0, 0.0, 0.0}
local PFD_WHITE = {1.0, 1.0, 1.0}
local PFD_BLUE = {0.004, 1.0, 1.0}
local PFD_GREEN = {0.184, 0.733, 0.219}
local PFD_ORANGE = {0.725, 0.521, 0.18}
local PFD_GREY = {0.3, 0.3, 0.3}
local vvi_cl = PFD_GREEN

--max speed array
local max_speeds_kts = {
    280,
    230,
    215,
    200,
    185,
    177
}


local function update_radioalt() 
    local curr_radio_alt = math.floor(get(Capt_ra_alt_ft)) - 1
    
    local color = 0
    
    if get(DH_alt_ft) > 0 then  -- Decision Height is set
        if curr_radio_alt <= get(DH_alt_ft)+100 then
            color = 1
        end    
    else
        if curr_radio_alt <= 400 then
            color = 1
        end
    end
    
    set(PFD_Capt_radioalt_col, color)
    
    -- Rouding (rounding 10 feet above 50 feet, rounding 5 feet above 10 feet)
    if curr_radio_alt > 50 then
        curr_radio_alt = curr_radio_alt - curr_radio_alt % 10
    elseif curr_radio_alt > 10 then
        curr_radio_alt = curr_radio_alt - curr_radio_alt % 5
    end
    

    set(PFD_Capt_radioalt_val, curr_radio_alt)

    if curr_radio_alt > 2500 then
        set(PFD_Capt_radioalt_status, 0)
    elseif math.abs(get(Flightmodel_roll)) > 30 or math.abs(get(Flightmodel_pitch)) > 30 or get(FAILURE_radioalt_cap) == 1 then
        set(PFD_Capt_radioalt_status, 2)
    else
        set(PFD_Capt_radioalt_status, 1)    
    end


end

local function update_tailstrike_indicators()

    if get(Capt_ra_alt_ft) < 400 and get(EWD_flight_phase) == PHASE_FINAL then
        if get(Flightmodel_pitch) > 13 then
            set(PFD_Capt_tailstrike_ind, (math.floor(get(TIME)*2) % 2 == 1 ) and 1 or 0)
        else
            set(PFD_Capt_tailstrike_ind, 1)    
        end
    else
        set(PFD_Capt_tailstrike_ind, 0)
    end
end

local function update_bird()
    local rad_bank_angle = math.rad(get(Flightmodel_roll))
    set(PFD_Capt_bird_vert_pos, get(Alpha) / math.cos(rad_bank_angle) - get(ground_track_delta) * math.sin(rad_bank_angle) )
    set(PFD_Capt_bird_horiz_pos, get(ground_track_delta) * math.cos(rad_bank_angle))
    
    
end

function update()

    --PFD deltas
    set(ground_track_delta, get(ground_track) - get(current_heading))

    vvi_cl = PFD_GREEN
    if get(vvi) > -1000 and get(vvi) < 1000 then
        --v/s -1000 to 1000
        vvi_left_pixel_offset = 442 + 150 * get(vvi)/1000

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -2)/100

        if vvi_number_display ~= 10 or vvi_number_display ~= 10 then
            vvi_number_display = "0" .. Round(math.abs(math.floor(get(vvi))), -2)/100
        end

        if get(vvi) > -100 and get(vvi) < 100 then
            vvi_number_display = "01"
        end

    elseif (get(vvi) > -2000 and get(vvi) < -1000) or (get(vvi) > 1000 and get(vvi) < 2000) then -- -2000 to 2000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(vvi)/1000, 292, 592)
        if get(vvi) > 0 then
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(vvi)-1000)/1000
        else
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(vvi)+1000)/1000
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    elseif (get(vvi) > -6000 and get(vvi) < -2000) or (get(vvi) > 2000 and get(vvi) < 6000) then -- -6000 to 6000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(vvi)/1000, 292, 592)
        if get(vvi) > 0 then
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)-1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)-2000)/4000, 172, 712)
        else
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)+1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(vvi)+2000)/4000, 172, 652)
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    elseif get(vvi) < -6000 or get(vvi) > 6000 then -- -6000- and 6000+
        if get(vvi) > 0 then
            vvi_left_pixel_offset = 712
            vvi_cl = PFD_ORANGE
        else
            vvi_left_pixel_offset = 172
            vvi_cl = PFD_ORANGE
        end

        vvi_number_display = Round(math.abs(math.floor(get(vvi))), -3)/100
    end
    
    set(PFD_Capt_Ground_line, Math_clamp( get(Capt_ra_alt_ft)/120 + get(Flightmodel_pitch)/18, 0, 1))
    set(PFD_Fo_Ground_line, Math_clamp( get(Fo_ra_alt_ft)/120 + get(Flightmodel_pitch)/18, 0, 1))
    
    update_radioalt()
    update_tailstrike_indicators()
    update_bird()


end

function draw()

    --Draw_LCD_backlight(0, 0, 900, 900, 0.5, 1, get(Capt_PFD_brightness_act))
    if display_special_mode(size, Capt_pfd_valid) then
        return
    end

    --show and hide the V/S indicators according to the airdata
    if get(Adirs_capt_has_ADR) == 1 then
        sasl.gl.drawWideLine(848, vvi_left_pixel_offset, 900, 442+(vvi_left_pixel_offset-size[2]/2)/2.5, 4, vvi_cl)
        if get(vvi) >= 0 then
            sasl.gl.drawRectangle(850, vvi_left_pixel_offset + 6, 34, 22, PFD_BLACK)
            sasl.gl.drawText(Font_AirbusDUL, 852, vvi_left_pixel_offset + 8, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
        else
            sasl.gl.drawRectangle(850, vvi_left_pixel_offset - 28, 34, 22, PFD_BLACK)
            sasl.gl.drawText(Font_AirbusDUL, 852, vvi_left_pixel_offset - 26, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
        end
    end
    
    sasl.gl.drawRectangle(0, 0, 900, 900, {0, 0, 0, 1 - get(Capt_PFD_brightness_act)})
    
end
