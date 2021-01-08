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


include('display_common.lua')

--varibles--
local vvi_left_pixel_offset = 0
local vvi_number_display = 0

--colors
local PFD_BLACK = {0.0, 0.0, 0.0}
local PFD_WHITE = {1.0, 1.0, 1.0}
local PFD_BLUE = {0.004, 1.0, 1.0}
local PFD_GREEN = {0.184, 0.733, 0.219}
local PFD_ORANGE = {0.725, 0.521, 0.18}
local PFD_GREY = {0.3, 0.3, 0.3}
local vvi_cl = PFD_GREEN


function PFD_update_radioalt()
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

function PFD_update_tailstrike_indicators()

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

function PFD_update_bird()
    local rad_bank_angle = math.rad(get(Flightmodel_roll))
    set(PFD_Capt_bird_vert_pos, get(Alpha) / math.cos(rad_bank_angle) - get(Ground_track_delta) * math.sin(rad_bank_angle) )
    set(PFD_Capt_bird_horiz_pos, get(Ground_track_delta) * math.cos(rad_bank_angle))
end

function update()

    --PFD deltas
    set(Ground_track_delta, get(Ground_track) - get(Current_heading))

    vvi_cl = PFD_GREEN
    if get(VVI) > -1000 and get(VVI) < 1000 then
        --v/s -1000 to 1000
        vvi_left_pixel_offset = 442 + 150 * get(VVI)/1000

        vvi_number_display = Round(math.abs(math.floor(get(VVI))), -2)/100

        if vvi_number_display ~= 10 or vvi_number_display ~= 10 then
            vvi_number_display = "0" .. Round(math.abs(math.floor(get(VVI))), -2)/100
        end

        if get(VVI) > -100 and get(VVI) < 100 then
            vvi_number_display = "01"
        end

    elseif (get(VVI) > -2000 and get(VVI) < -1000) or (get(VVI) > 1000 and get(VVI) < 2000) then -- -2000 to 2000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(VVI)/1000, 292, 592)
        if get(VVI) > 0 then
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(VVI)-1000)/1000
        else
            vvi_left_pixel_offset = vvi_left_pixel_offset + 60 * (get(VVI)+1000)/1000
        end

        vvi_number_display = Round(math.abs(math.floor(get(VVI))), -3)/100
    elseif (get(VVI) > -6000 and get(VVI) < -2000) or (get(VVI) > 2000 and get(VVI) < 6000) then -- -6000 to 6000
        vvi_left_pixel_offset = Math_clamp(442 + 150 * get(VVI)/1000, 292, 592)
        if get(VVI) > 0 then
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(VVI)-1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(VVI)-2000)/4000, 172, 712)
        else
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(VVI)+1000)/1000, 232, 652)
            vvi_left_pixel_offset = Math_clamp(vvi_left_pixel_offset + 60 * (get(VVI)+2000)/4000, 172, 652)
        end

        vvi_number_display = Round(math.abs(math.floor(get(VVI))), -3)/100
    elseif get(VVI) < -6000 or get(VVI) > 6000 then -- -6000- and 6000+
        if get(VVI) > 0 then
            vvi_left_pixel_offset = 712
            vvi_cl = PFD_ORANGE
        else
            vvi_left_pixel_offset = 172
            vvi_cl = PFD_ORANGE
        end

        vvi_number_display = Round(math.abs(math.floor(get(VVI))), -3)/100
    end

    set(PFD_Capt_Ground_line, 0)
    set(PFD_Fo_Ground_line, 0)

    PFD_update_radioalt()
    PFD_update_tailstrike_indicators()
    PFD_update_bird()
end

function draw()
    --show and hide the V/S indicators according to the airdata
    --[[if get(Adirs_capt_has_ADR) == 1 then
        sasl.gl.drawWideLine(848, vvi_left_pixel_offset, 900, 442+(vvi_left_pixel_offset-size[2]/2)/2.5, 4, vvi_cl)
        if get(vvi) >= 0 then
            sasl.gl.drawRectangle(850, vvi_left_pixel_offset + 6, 34, 22, PFD_BLACK)
            sasl.gl.drawText(Font_AirbusDUL, 852, vvi_left_pixel_offset + 8, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
        else
            sasl.gl.drawRectangle(850, vvi_left_pixel_offset - 28, 34, 22, PFD_BLACK)
            sasl.gl.drawText(Font_AirbusDUL, 852, vvi_left_pixel_offset - 26, vvi_number_display, 23, false, false, TEXT_ALIGN_LEFT, vvi_cl)
        end
    end]]
end
