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
-- File: ECAM_cond.lua 
-- Short description: ECAM file for the AIRCOND page 
-------------------------------------------------------------------------------


local function draw_cond_page_valves()
    if get(FAILURE_AIRCOND_TRIM_CKPT) == 0 then
        SASL_rotated_center_img_xcenter_aligned(ECAM_COND_arrows_img, size[1]/2-213, size[2]/2+106, 10, 39, Math_rescale(0, -40, 1, 40, get(Aircond_trim_valve, 1)), 0, 0, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-213, size[2]/2+106, "XX", 32, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_TRIM_CAB_FWD) == 0 then
        SASL_rotated_center_img_xcenter_aligned(ECAM_COND_arrows_img, size[1]/2-15, size[2]/2+106, 10, 39, Math_rescale(0, -40, 1, 40, get(Aircond_trim_valve, 2)), 0, 0, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-15, size[2]/2+106, "XX", 32, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_TRIM_CAB_AFT) == 0 then
        SASL_rotated_center_img_xcenter_aligned(ECAM_COND_arrows_img, size[1]/2+172, size[2]/2+106, 10, 39, Math_rescale(0, -40, 1, 40, get(Aircond_trim_valve, 3)), 0, 0, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+172, size[2]/2+106, "XX", 32, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_TRIM_CARGO_AFT) == 0 then
        SASL_rotated_center_img_xcenter_aligned(ECAM_COND_arrows_img, size[1]/2+167, size[2]/2-254, 10, 39, Math_rescale(0, -40, 1, 40, get(Aircond_trim_valve, 4)), 0, 0, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+167, size[2]/2-254, "XX", 32, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    --cabin hot air--
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_COND_valves_img, size[1]/2+306, size[2]/2+31, 120, 58, 2, get(Hot_air_valve_pos) == 0 and 2 or 1, get(FAILURE_AIRCOND_HOT_AIR_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)

    --aft cargo valves
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_COND_valves_img, size[1]/2+263, size[2]/2-75, 120, 58, 2, get(Cargo_isol_out_valve) == 0 and 2 or 1, get(FAILURE_AIRCOND_ISOL_CARGO_OUT_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_COND_valves_img, size[1]/2+167, size[2]/2-194, 120, 58, 2, get(Cargo_isol_in_valve) == 0 and 1 or 2, get(FAILURE_AIRCOND_ISOL_CARGO_IN_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)

    --cargo hot air--
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_COND_valves_img, size[1]/2+306, size[2]/2-311, 120, 58, 2, get(Hot_air_valve_pos_cargo) == 0 and 2 or 1, get(FAILURE_AIRCOND_HOT_AIR_CARGO_STUCK) == 0 and ECAM_GREEN or ECAM_ORANGE)
end

local function draw_an_arc(x,y)
    sasl.gl.drawArc (x, y , 35, 38 , 45 , 90 , ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, x+45, y, "H", 27, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, x-45, y, "C", 27, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
end

local function draw_cond_bgd()
    sasl.gl.drawWideLine(237, 555, 237, 509, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(435, 555, 435, 509, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(621, 555, 621, 509, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(237, 509, 727, 509, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(784, 509, 826, 509, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(617, 326, 617, 312, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(617, 235, 617, 256, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(617, 195, 617, 168, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(617, 168, 728, 168, 4, ECAM_GREEN)
    sasl.gl.drawWideLine(784, 168, 826, 168, 4, ECAM_GREEN)
    draw_an_arc(237,558)
    draw_an_arc(435, 558)
    draw_an_arc(621, 558)
    draw_an_arc(617, 197)
    sasl.gl.drawWideLine(237, 594, 237, 604, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(435, 594, 435, 604, 3, ECAM_WHITE)
    sasl.gl.drawWideLine(621, 594, 621, 604, 3, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 436, 721, "FWD", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 238, 721, "CKPT", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 626, 721, "AFT", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 562, 403, "AFT", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 786, 869, "TEMP:", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 850, 869, "°C", 30, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    drawTextCentered(Font_ECAMfont, 856, 526, "HOT", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 856, 526-33, "AIR", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 856, 184, "HOT", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 856, 184-33, "AIR", 30, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, 69, 870, "COND", 43, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(16, 850, 127, 850, 3, ECAM_WHITE)


    sasl.gl.drawWideLine(713, 900-524, 713,900-532, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(713, 900-532, 644,900-532, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(590, 900-532, 521,900-532, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(521, 900-532, 521,900-461, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(521, 900-461, 713,900-461, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(713, 900-461, 713,900-468, 4, ECAM_LINE_GREY)

    sasl.gl.drawTexture(ECAM_COND_grey_lines_img, 108, 627, 600, 128, ECAM_LINE_GREY)
end

function draw_cond_page()
    draw_cond_bgd()
    --cabin--
    --actual temperature
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-212, size[2]/2+210, Round(get(Cockpit_temp),0), 32, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-13, size[2]/2+210, Round(get(Front_cab_temp),0), 32, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+172, size[2]/2+210, Round(get(Aft_cab_temp),0), 32, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --duct temperatures
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-212, size[2]/2+170, Round(get(Aircond_injected_flow_temp,1),0), 32, true, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,1) > 80 and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2-13, size[2]/2+170, Round(get(Aircond_injected_flow_temp,2),0), 32, true, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,2) > 80 and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+172, size[2]/2+170, Round(get(Aircond_injected_flow_temp,3),0), 32, true, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,3) > 80 and ECAM_ORANGE or ECAM_GREEN)

    -- fan failure
    if get(FAILURE_AIRCOND_FAN_FWD) == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-180, size[2]/2+330, "FAN", 38, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_AIRCOND_FAN_AFT) == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+120, size[2]/2+330, "FAN", 38, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    
    local num_failed = get(FAILURE_AIRCOND_REG_1) + get(FAILURE_AIRCOND_REG_2)
    if num_failed == 2 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-50, size[2]/2+360, "PACK REG", 38, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif num_failed == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-50, size[2]/2+360, "ALTN MODE", 38, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end
    
    --cargo--
    --actual temperature
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+168, size[2]/2-59, Round(get(Aft_cargo_temp),0), 32, true, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    --duct temperatures
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+168, size[2]/2-92, Round(get(Aircond_injected_flow_temp,4),0), 32, true, false, TEXT_ALIGN_CENTER, get(Aircond_injected_flow_temp,4) > 80 and ECAM_ORANGE or ECAM_GREEN)

    draw_cond_page_valves()
end
