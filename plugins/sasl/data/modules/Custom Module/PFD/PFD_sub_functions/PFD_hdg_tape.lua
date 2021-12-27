local function draw_hdg_tape_symbols(PFD_table)
    SASL_draw_img_center_aligned(PFD_trk_diamond, size[1]/2-55 + Math_rescale_no_lim(0, 0, 20, 169, adirs_get_track(PFD_table.Screen_ID) - adirs_get_hdg(PFD_table.Screen_ID)), size[2]/2-388, 17, 24, ECAM_GREEN)
end

function PFD_draw_hdg_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    --bgd
    sasl.gl.drawRectangle(size[1]/2-259, size[2]/2-432, 407, 55, ECAM_GREY)

    if adirs_is_hdg_ok(PFD_table.Screen_ID) == false then
        boarder_cl = PFD_table.HDG_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.HDG_blink_now == true then
            sasl.gl.drawText(Font_ECAMfont, size[1]/2-59, size[2]/2-420, "HDG", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-261, size[2]/2-432, size[1]/2-261, size[2]/2-377, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-263, size[2]/2-375, size[1]/2+152, size[2]/2-375, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+150, size[2]/2-432, size[1]/2+150, size[2]/2-377, 4, boarder_cl)

    if adirs_is_hdg_ok(PFD_table.Screen_ID) == true then
        sasl.gl.setClipArea(size[1]/2-259, size[2]/2-432, 407, 55)
        sasl.gl.drawTexture(PFD_hdg_tape, size[1]/2-259 - Math_rescale(0, 561, 360, 3609, adirs_get_hdg(PFD_table.Screen_ID)), size[2]/2-432, 4096, 110, ECAM_WHITE)
        sasl.gl.resetClipArea ()

        sasl.gl.setClipArea(size[1]/2-259, size[2]/2-432, 407, 100)
        draw_hdg_tape_symbols(PFD_table)
        sasl.gl.resetClipArea ()

        --hdg needle
        sasl.gl.drawWideLine(size[1]/2-55, size[2]/2-388, size[1]/2-55, size[2]/2-340, 6, ECAM_YELLOW)
    end
end
