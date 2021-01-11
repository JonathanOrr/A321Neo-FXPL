function PFD_draw_LS(PFD_table)
    if get(PFD_table.LS_enabled) == 0 then
        return
    end

    if PFD_table.ILS_data.id ~= nil then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-380, PFD_table.ILS_data.id, 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    end
    if PFD_table.ILS_data.frequency ~= nil then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-410, math.floor(PFD_table.ILS_data.frequency / 100) .. ".", 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-365, size[2]/2-410, PFD_table.ILS_data.frequency / 100 % 1 * 100, 24, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
    end
    if PFD_table.DME_data.latitude ~= nil and PFD_table.DME_data.longitude ~= nil and PFD_table.DME_data.Navaid_ID ~= NAV_NOT_FOUND then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-445, size[2]/2-440, string.format("%.1f", tostring(Math_clamp_higher(PFD_table.Distance_to_dme, 999.9))), 34, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-325, size[2]/2-440, "NM", 24, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end

    SASL_draw_img_center_aligned(PFD_loc_scale, size[1]/2-55, size[2]/2-290, 352, 42, ECAM_WHITE)
    SASL_draw_img_center_aligned(PFD_gs_scale, size[1]/2+187, size[2]/2-7, 58, 352, ECAM_WHITE)
end