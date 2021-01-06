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


include('constants.lua')
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

function PFD_draw_pitch_scale(PFD_table)
    --draw the mask
    sasl.gl.drawMaskStart ()
    sasl.gl.drawTexture(PFD_pitch_scale_mask, 0, 0, 900, 900, {1,1,1})
    --draw under the mask
    sasl.gl.drawUnderMask(true)
    SASL_rotated_center_img_xcenter_aligned(PFD_normal_pitch_scale, size[1]/2-55, size[2]/2-7, 2870, 779, 90 - get(PFD_table.Bank), get(PFD_table.Pitch) * 10, -779/2, {1, 1, 1})
    SASL_rotated_center_img_xcenter_aligned(PFD_static_sky, size[1]/2-55, size[2]/2-7, 1575, 779, 90 - get(PFD_table.Bank), 0, -779/2, {1, 1, 1})
    SASL_rotated_center_img_xcenter_aligned(PFD_ground, size[1]/2-55, size[2]/2-7, 2228, 779, 90 - get(PFD_table.Bank), - 187 * (1 - Math_clamp(get(PFD_table.RA_ALT)/120 + get(PFD_table.Pitch)/18, 0, 1)), -779/2, {1, 1, 1})
    --terminate masked drawing
    sasl.gl.drawMaskEnd ()

    SASL_draw_img_xcenter_aligned(PFD_pitch_wings, size[1]/2-56, size[2]/2-44, 402, 47, {1,1,1})

    SASL_draw_img_xcenter_aligned(PFD_bank_angle, size[1]/2-56, size[2]/2+158, 366, 95, {1,1,1})
end

function PFD_draw_spd_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    if get(PFD_table.ADR_avail) == 0 then
        boarder_cl = get(PFD_table.ADR_blinking) == 1 and {0, 0, 0, 0} or {254/255, 47/255, 41/255, 1}
    elseif get(PFD_table.ADR_avail) == 1 then
        boarder_cl = ECAM_WHITE
    end

    --speed tape background
    sasl.gl.drawRectangle(size[1]/2-437, size[2]/2-244, 99, 473, {69/255, 86/255, 105/255})

    --clip to draw the speed tape
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.setClipArea(size[1]/2-437, size[2]/2-244, 99, 473)
        sasl.gl.drawTexture(PFD_spd_tape, size[1]/2-437, size[2]/2-244 - Math_rescale(30, 355, 460, 2785, get(PFD_table.IAS)), 99, 4096, {1,1,1})
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-338, size[2]/2-244, size[1]/2-338, size[2]/2+229, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-437, size[2]/2+231, size[1]/2-310, size[2]/2+231, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-437, size[2]/2-246, size[1]/2-310, size[2]/2-246, 4, boarder_cl)

    --speed needle
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.drawTexture(PFD_spd_needle, size[1]/2-370, size[2]/2-18, 56, 21, {1,1,1})
    end
end

function PFD_draw_alt_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    if get(PFD_table.ADR_avail) == 0 then
        boarder_cl = get(PFD_table.ADR_blinking) == 1 and {0, 0, 0, 0} or {254/255, 47/255, 41/255, 1}
    elseif get(PFD_table.ADR_avail) == 1 then
        boarder_cl = ECAM_WHITE
    end

    sasl.gl.drawRectangle(size[1]/2+217, size[2]/2-244, 75, 473, {69/255, 86/255, 105/255})

    --alt tape--
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.setClipArea(size[1]/2+209, size[2]/2-244, 84, 473)
        sasl.gl.drawTexture(PFD_alt_tap_1, size[1]/2+209, size[2]/2-244 - Math_rescale_lim_lower(-1500,   13,  3500, 2113, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_2, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(    4000, -177,  9500, 2132, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_3, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   10000, -157, 15500, 2153, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_4, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   16000, -137, 21500, 2173, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_5, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   22000, -117, 27500, 2193, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_6, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   28000,  -97, 33500, 2213, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_7, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   34000,  -77, 39500, 2233, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_8, size[1]/2+209, size[2]/2-244 - Math_rescale_lim_upper(40000,  -57, 45000, 2043, get(PFD_table.Baro_ALT)), 84, 2500, {1,1,1})
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2+294, size[2]/2-244, size[1]/2+294, size[2]/2+229, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+217, size[2]/2+231, size[1]/2+330, size[2]/2+231, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+217, size[2]/2-246, size[1]/2+330, size[2]/2-246, 4, boarder_cl)

    --print("ALT     " .. get(PFD_Capt_Baro_Altitude))
    --print("ALT 10K " .. Math_extract_digit(get(PFD_Capt_Baro_Altitude), 5) + Math_rescale(9980,  0, 10000, 1, get(PFD_Capt_Baro_Altitude) % 10000))
    --print("ALT 1K  " .. Math_extract_digit(get(PFD_Capt_Baro_Altitude), 4) + Math_rescale(980,   0, 1000,  1, get(PFD_Capt_Baro_Altitude) % 1000))
    --print("ALT 100 " .. Math_extract_digit(get(PFD_Capt_Baro_Altitude), 3) + Math_rescale(80,    0, 100,   1, get(PFD_Capt_Baro_Altitude) % 100))
    --print("ALT 10s " .. get(PFD_Capt_Baro_Altitude) % 100)

    --alt box--
    if get(PFD_table.ADR_avail) == 1 then
        sasl.gl.drawTexture(PFD_alt_box_bgd, size[1]/2+217, size[2]/2-48, 127, 83, {1,1,1})

        --draw tapes that goes though the box here(e.g RA ALT)
        sasl.gl.drawRectangle(size[1]/2+296, size[2]/2-244, 16, Math_clamp(Math_rescale_no_lim(0, 236, 500, 26, get(PFD_table.RA_ALT)), 0, 473), ECAM_RED)

        sasl.gl.drawTexture(PFD_alt_box, size[1]/2+217, size[2]/2-48, 127, 83, {1,1,1})

        --alt needle
        sasl.gl.drawWideLine(size[1]/2+153, size[2]/2-8, size[1]/2+211, size[2]/2-8, 6, {1, 1, 0})
    end
end

function PFD_draw_hdg_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    sasl.gl.drawRectangle(size[1]/2-260, size[2]/2-432, 407, 55, {69/255, 86/255, 105/255})

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-262, size[2]/2-432, size[1]/2-262, size[2]/2-377, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-264, size[2]/2-375, size[1]/2+151, size[2]/2-375, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+149, size[2]/2-432, size[1]/2+149, size[2]/2-377, 4, boarder_cl)

    --hdg needle
    sasl.gl.drawWideLine(size[1]/2-56, size[2]/2-388, size[1]/2-56, size[2]/2-340, 6, {1, 1, 0})
end

function PFD_draw_vs_needle(PFD_table)
    sasl.gl.drawTexture(PFD_vs_bgd, 0, 0, 900, 900, {1, 1, 1})
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
