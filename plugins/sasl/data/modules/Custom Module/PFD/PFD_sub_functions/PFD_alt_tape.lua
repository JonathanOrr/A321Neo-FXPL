include('constants.lua')

local function draw_alt_digits(PFD_table)
    local ALT_10K = Math_extract_digit(get_alt(PFD_table.Screen_ID), 5, true) + Math_rescale(9980,  0, 10000, 1, math.abs(get_alt(PFD_table.Screen_ID)) % 10000)
    local ALT_1k =  Math_extract_digit(get_alt(PFD_table.Screen_ID), 4, true) + Math_rescale(980,   0, 1000,  1, math.abs(get_alt(PFD_table.Screen_ID)) % 1000)
    local ALT_100 = Math_extract_digit(get_alt(PFD_table.Screen_ID), 3, true) + Math_rescale(80,    0, 100,   1, math.abs(get_alt(PFD_table.Screen_ID)) % 100)
    local ALT_10s = math.abs(get_alt(PFD_table.Screen_ID)) % 100

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

    if is_alt_ok(PFD_table.Screen_ID) == false then
        boarder_cl = PFD_table.ALT_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.ALT_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+255, size[2]/2-20, "ALT", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    sasl.gl.drawRectangle(size[1]/2+217, size[2]/2-244, 75, 212, PFD_TAPE_GREY)
    sasl.gl.drawRectangle(size[1]/2+217, size[2]/2+19, 75, 210, PFD_TAPE_GREY)

    --alt tape--
    if is_alt_ok(PFD_table.Screen_ID) == true then
        sasl.gl.setClipArea(size[1]/2+209, size[2]/2-244, 84, 473)
        sasl.gl.drawTexture(PFD_alt_tap_1, size[1]/2+209, size[2]/2-244 - Math_rescale_lim_lower(-1500,   13,  3500, 2113, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_2, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(    4000, -177,  9500, 2132, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_3, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   10000, -157, 15500, 2153, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_4, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   16000, -137, 21500, 2173, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_5, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   22000, -117, 27500, 2193, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_6, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   28000,  -97, 33500, 2213, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_7, size[1]/2+209, size[2]/2-244 - Math_rescale_no_lim(   34000,  -77, 39500, 2233, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.drawTexture(PFD_alt_tap_8, size[1]/2+209, size[2]/2-244 - Math_rescale_lim_upper(40000,  -57, 45000, 2043, get_alt(PFD_table.Screen_ID)), 84, 2500, {1,1,1})
        sasl.gl.resetClipArea ()
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2+294, size[2]/2-244, size[1]/2+294, size[2]/2-32, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+294, size[2]/2+19, size[1]/2+294, size[2]/2+229, 4, boarder_cl)
    if is_alt_ok(PFD_table.Screen_ID) == false then
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2+231, size[1]/2+296, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2-246, size[1]/2+296, size[2]/2-246, 4, boarder_cl)
    else
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2+231, size[1]/2+330, size[2]/2+231, 4, boarder_cl)
        sasl.gl.drawWideLine(size[1]/2+217, size[2]/2-246, size[1]/2+330, size[2]/2-246, 4, boarder_cl)
    end

    --alt box--
    if is_alt_ok(PFD_table.Screen_ID) == true then
        sasl.gl.drawTexture(PFD_alt_box_bgd, size[1]/2+217, size[2]/2-48, 127, 83, {1,1,1})

        --draw tapes that goes though the box here(e.g RA ALT)
        sasl.gl.drawRectangle(size[1]/2+296, size[2]/2-244, 16, Math_clamp(Math_rescale_no_lim(0, 236, 500, 26, get(PFD_table.RA_ALT)), 0, 473), ECAM_RED)
        draw_alt_digits(PFD_table)
        -------------------------------------------------------------------------------------------------------------------------------------------------------------------

        sasl.gl.drawTexture(PFD_alt_box, size[1]/2+217, size[2]/2-48, 127, 83, PFD_YELLOW)

        --negative altitude indication
        if get_alt(PFD_table.Screen_ID) < 0 then
            sasl.gl.drawText(Font_AirbusDUL_vert, size[1]/2+220, size[2]/2-30, "NEG", 55, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        end

        --alt needle
        sasl.gl.drawWideLine(size[1]/2+153, size[2]/2-8, size[1]/2+211, size[2]/2-8, 6, PFD_YELLOW)
    end
end