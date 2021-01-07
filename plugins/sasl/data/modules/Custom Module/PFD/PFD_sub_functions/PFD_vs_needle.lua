function PFD_draw_vs_needle(PFD_table)

    if is_vs_ok(PFD_table.Screen_ID) == false then
        sasl.gl.drawTexture(PFD_vs_mask, 0, 0, 900, 900, PFD_TAPE_GREY)
        if PFD_table.VS_blink_now == true then
            sasl.gl.drawText(Font_AirbusDUL_vert, size[1]/2+392, size[2]/2-10, "V/S", 42, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
        end

        return
    end

    sasl.gl.drawTexture(PFD_vs_bgd, 0, 0, 900, 900, ECAM_WHITE)
end