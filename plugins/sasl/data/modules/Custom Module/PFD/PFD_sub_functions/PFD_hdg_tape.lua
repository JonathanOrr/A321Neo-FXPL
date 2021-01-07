function PFD_draw_hdg_tape(PFD_table)
    local boarder_cl = ECAM_WHITE

    --bgd
    sasl.gl.drawRectangle(size[1]/2-260, size[2]/2-432, 407, 55, PFD_TAPE_GREY)

    if is_hdg_ok(PFD_table.Screen_ID) == false then
        boarder_cl = PFD_table.HDG_blink_now and ECAM_RED or {0, 0, 0, 0}
        if PFD_table.HDG_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-60, size[2]/2-420, "HDG", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end
    end

    --boarder lines
    sasl.gl.drawWideLine(size[1]/2-262, size[2]/2-432, size[1]/2-262, size[2]/2-377, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2-264, size[2]/2-375, size[1]/2+151, size[2]/2-375, 4, boarder_cl)
    sasl.gl.drawWideLine(size[1]/2+149, size[2]/2-432, size[1]/2+149, size[2]/2-377, 4, boarder_cl)

    if is_hdg_ok(PFD_table.Screen_ID) == true then
        sasl.gl.setClipArea(size[1]/2-260, size[2]/2-432, 407, 55)
        sasl.gl.drawTexture(PFD_hdg_tape, size[1]/2-260 - Math_rescale(0, 561, 360, 3609, get_hdg(PFD_table.Screen_ID)), size[2]/2-432, 4096, 110, ECAM_WHITE)
        sasl.gl.resetClipArea ()

        --hdg needle
        sasl.gl.drawWideLine(size[1]/2-56, size[2]/2-388, size[1]/2-56, size[2]/2-340, 6, PFD_YELLOW)
    end
end