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
-- File: ECAM_fctl.lua 
-- Short description: ECAM file for the F/CTL page 
-------------------------------------------------------------------------------

function draw_fctl_page()

    local is_G_ok = get(Hydraulic_G_press) >= 1450
    local is_B_ok = get(Hydraulic_B_press) >= 1450
    local is_Y_ok = get(Hydraulic_Y_press) >= 1450
    set(Ecam_fctl_is_rudder_ok, (is_G_ok or is_Y_ok or is_B_ok) and 1 or 0)
    set(Ecam_fctl_is_aileron_ok, (is_G_ok or is_B_ok) and 1 or 0)
    set(Ecam_fctl_is_elevator_R_ok, (is_Y_ok or is_B_ok) and 1 or 0)
    set(Ecam_fctl_is_elevator_L_ok, (is_G_ok or is_B_ok) and 1 or 0)
    set(Ecam_fctl_is_pitch_trim_ok, (is_G_ok or is_Y_ok) and 1 or 0)

    -- rudder
    Sasl_DrawWideFrame(410, size[2]/2-168, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(438, size[2]/2-168, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(466, size[2]/2-168, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2-164, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-164, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2-164, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- spdbrk
    Sasl_DrawWideFrame(410, size[2]/2+401, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(438, size[2]/2+401, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(466, size[2]/2+401, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2+405, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2+405, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2+405, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- elevators
    Sasl_DrawWideFrame(174, size[2]/2-193, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(203, size[2]/2-193, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2-189, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

    Sasl_DrawWideFrame(674, size[2]/2-193, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(703, size[2]/2-193, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2-189, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+267, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    -- pitch trim
    Sasl_DrawWideFrame(535, size[2]/2-12, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(563, size[2]/2-12, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+98, size[2]/2-8, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+125, size[2]/2-8, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

    -- ailerons
    Sasl_DrawWideFrame(174, size[2]/2+42, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(203, size[2]/2+42, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

    Sasl_DrawWideFrame(674, size[2]/2+42, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
    Sasl_DrawWideFrame(703, size[2]/2+42, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+267, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, string.format("%.1f", tostring(math.abs(get(Elev_trim_degrees)))), 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    if get(Elev_trim_degrees) >= 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "UP", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "DN", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
    end
end
