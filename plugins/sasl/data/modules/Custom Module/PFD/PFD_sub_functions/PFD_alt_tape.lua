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
-- File: PFD_alt_tap.lua 
-- Short description: Altitude tape on PFD
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local MODE_QNH = 1
local MODE_QFE = 2
local MODE_STD = 3

local UNIT_INHG = 1
local UNIT_HPA  = 2

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function draw_altitude_numbers(string, ycord)
    for i=1, 3 do
        sasl.gl.drawText(Font_AirbusDUL, 680 + (i-1) * 20 , ycord, string.sub(string, i, i) , 36, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    end
end

local function draw_altitude_tape(altitude)

    -- 1000 ft is 420 pixels
    -- 1 ft is 0.42 pixel

    local i_lower_bound = Round(Math_rescale_no_lim(0, -8, 10000,92,altitude),0) -- so 1000ft is just 10 i
    local i_upper_bound = Round(Math_rescale_no_lim(0,  8, 10000,108,altitude),0)

    local altitude_offset = -altitude * 0.42

    for i = i_lower_bound,i_upper_bound do --so 1 i is 100ft, which is 42px
        local line_y = i * 42 + altitude_offset
        sasl.gl.drawWideLine(731, 442 + line_y, 744, 442 + line_y, 3, ECAM_WHITE) --long dashes
        if i%5 == 0 then
            draw_altitude_numbers(Fwd_string_fill( tostring(Round(math.abs(i*100) / 100  , 0)), "0", 3), 432 + line_y) -- so 1 i is 100ft, number intevral is 500ft, we add i*100 to the altitude number
            sasl.gl.drawTexture(PFD_alt_lovely_triangle, 658, 437 + line_y, 11, 14, ECAM_WHITE)
        end
    end

end

local function draw_alt_digits(PFD_table)
    local altitude = adirs_is_gps_alt_visible(PFD_table.Screen_ID) and adirs_get_gps_alt(PFD_table.Screen_ID) or adirs_get_alt(PFD_table.Screen_ID)
    local ALT_10K = Math_extract_digit(altitude, 5, true) + Math_rescale(9980,  0, 10000, 1, math.abs(altitude) % 10000)
    local ALT_1k =  Math_extract_digit(altitude, 4, true) + Math_rescale(980,   0, 1000,  1, math.abs(altitude) % 1000)
    local ALT_100 = Math_extract_digit(altitude, 3, true) + Math_rescale(80,    0, 100,   1, math.abs(altitude) % 100)
    local ALT_10s = math.abs(altitude) % 100

    sasl.gl.setClipArea(size[1]/2+217, size[2]/2-27, 78, 43)
    if ALT_10K ~= 0 then
        sasl.gl.drawTexture(PFD_big_alt_digit, size[1]/2+222, size[2]/2-27 - Math_rescale(0, 62, 10, 402, ALT_10K), 20, 506, ECAM_GREEN)
    end
    if ALT_10K ~= 0 or ALT_1k ~= 0 then
        sasl.gl.drawTexture(PFD_big_alt_digit, size[1]/2+247, size[2]/2-27 - Math_rescale(0, 62, 10, 402, ALT_1k),  20, 506, ECAM_GREEN)
    end
    sasl.gl.drawTexture(PFD_big_alt_digit, size[1]/2+272, size[2]/2-27 - Math_rescale(0, 62, 10, 402, ALT_100), 20, 506, ECAM_GREEN)
    sasl.gl.resetClipArea ()

    sasl.gl.setClipArea(size[1]/2+295, size[2]/2-43, 45, 75)
    sasl.gl.drawTexture(PFD_small_alt_digit, size[1]/2+303, size[2]/2-43 - Math_rescale(0, 0, 100, 130, ALT_10s), 30, 203, ECAM_GREEN)
    sasl.gl.resetClipArea ()
end

function PFD_draw_alt_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    if adirs_is_alt_ok(PFD_table.Screen_ID) == false and adirs_is_gps_alt_visible(PFD_table.Screen_ID) == false then
        boarder_cl = PFD_table.ALT_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.ALT_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+255, size[2]/2-20, "ALT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    sasl.gl.drawRectangle(size[1]/2+217, size[2]/2-244, 75, 212, PFD_TAPE_GREY)
    sasl.gl.drawRectangle(size[1]/2+217, size[2]/2+19, 75, 210, PFD_TAPE_GREY)
    sasl.gl.drawTexture(PFD_alt_shader, 667, 336, 76, 342, {1,1,1,PFD_SHADE_INTENSITY}) --The shader, ask Henrick if you don't know what is this

    local altitude = adirs_is_gps_alt_visible(PFD_table.Screen_ID) and adirs_get_gps_alt(PFD_table.Screen_ID) or adirs_get_alt(PFD_table.Screen_ID)

    --alt tape--
    if adirs_is_alt_ok(PFD_table.Screen_ID) == true or adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        sasl.gl.setClipArea(size[1]/2+209, size[2]/2-244, 84, 473)
         draw_altitude_tape(altitude)
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2+294, size[2]/2-244, size[1]/2+294, size[2]/2-32, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+294, size[2]/2+19, size[1]/2+294, size[2]/2+229, 4, boarder_cl)
    if adirs_is_alt_ok(PFD_table.Screen_ID) == false and adirs_is_gps_alt_visible(PFD_table.Screen_ID) == false then
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2+231, size[1]/2+296, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2-246, size[1]/2+296, size[2]/2-246, 4, boarder_cl)
    else
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2+231, size[1]/2+330, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2-246, size[1]/2+330, size[2]/2-246, 4, boarder_cl)
    end

    --alt box--
    if adirs_is_alt_ok(PFD_table.Screen_ID) == true or adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        sasl.gl.drawTexture(PFD_alt_box_bgd, size[1]/2+217, size[2]/2-48, 127, 83, {1,1,1})

        --draw tapes that goes though the box here(e.g RA ALT)
        sasl.gl.drawRectangle(size[1]/2+296, size[2]/2-244, 14, Math_clamp(Math_rescale_no_lim(0, 236, 500, 26, get(PFD_table.RA_ALT)), 0, 473), ECAM_RED)
        draw_alt_digits(PFD_table)

        if adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
            sasl.gl.drawWideLine(size[1]/2+300, size[2]/2+0, size[1]/2+336, size[2]/2+0, 3, ECAM_ORANGE)
            sasl.gl.drawWideLine(size[1]/2+300, size[2]/2-16, size[1]/2+336, size[2]/2-16, 3, ECAM_ORANGE)
        end
        -------------------------------------------------------------------------------------------------------------------------------------------------------------------

        sasl.gl.drawTexture(PFD_alt_box, size[1]/2+217, size[2]/2-48, 127, 83, PFD_YELLOW)

        --negative altitude indication
        if adirs_get_alt(PFD_table.Screen_ID) < 0 then
            sasl.gl.drawText(Font_AirbusDUL_vert, size[1]/2+220, size[2]/2-30, "NEG", 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end

        --alt needle
        sasl.gl.drawWideLine(size[1]/2+153, size[2]/2-8, size[1]/2+211, size[2]/2-8, 6, PFD_YELLOW)

        if adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+395, size[2]/2-22, "GPS", 42, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end
    end


end


function PFD_draw_alt_ref(PFD_table)

    -- All failed: no indication
    if not adirs_is_alt_ok(PFD_table.Screen_ID) and not adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        return
    end

    -- GPS Alt indication
    if adirs_is_gps_alt_visible(PFD_table.Screen_ID) then
        sasl.gl.drawText(Font_ECAMfont, 670, 120, "GPS ALT", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        return
    end

    local qnh_status = PFD_table.Screen_ID == PFD_CAPT and ADIRS_sys.qnh_capt or ADIRS_sys.qnh_fo

    -- STD
    if qnh_status.mode == MODE_STD then
        sasl.gl.drawText(Font_ECAMfont, 750, 120, "STD", 36, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        Sasl_DrawWideFrame(715, 117, 70, 35, 3, 1, {1., 1., 0.})
        return
    end

    -- QNH/QFE

    local text = "QNH"
    if qnh_status.mode == MODE_QFE then
        text = "QFE"
    end
    sasl.gl.drawText(Font_ECAMfont, 670, 120, text, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    local value = qnh_status.value * 100 -- e.g. 2992
    if qnh_status.unit == UNIT_HPA then
        value = math.floor(value * 0.338639)
    else
        value = math.floor(value) / 100
    end
    sasl.gl.drawText(Font_ECAMfont, 795, 120, value, 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

end
