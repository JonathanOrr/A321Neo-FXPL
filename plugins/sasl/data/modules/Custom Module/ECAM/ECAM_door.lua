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
-- File: ECAM_door.lua 
-- Short description: ECAM DOOR page 
-------------------------------------------------------------------------------


PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)

local params = {
    cabin_vs       = 0,
    oxygen_psi     = 0,
    last_update    = 0
}

local function get_color_green_blinking()
    if math.floor(get(TIME)) % 2 == 0 then
        return ECAM_GREEN
    else
        return ECAM_HIGH_GREEN
    end
end

local function draw_cabin_vs()
    if get(All_on_ground) == 0 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+150, size[2]-184, "V/S", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        SASL_drawSegmentedImgColored(ECAM_DOOR_vs_arrows_img, size[1]/2+182, size[2]/2+264, 56, 27, 2, params.cabin_vs >= 0 and 1 or 2, ECAM_GREEN)
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+327, size[2]-184, math.floor(params.cabin_vs), 36, true, false, TEXT_ALIGN_RIGHT, oxy_color)
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+385, size[2]-184, "FT/MIN", 32, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end
end

local function update_param()
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.cabin_vs       = get(Cabin_vs)
        params.oxygen_psi     = get(Oxygen_ckpt_psi)
        params.last_update    = get(TIME)
    end
end

local function draw_oxygen()

    -- TODO fix color
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+250, size[2]-50, "CKPT OXY", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    oxy_color = ECAM_GREEN
    if get(Oxygen_ckpt_psi) < 300 then
        oxy_color = ECAM_ORANGE
    elseif get(Oxygen_ckpt_psi) < 600 then
        oxy_color = get_color_green_blinking()
    end
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+300, size[2]-85, math.floor(params.oxygen_psi), 36, true, false, TEXT_ALIGN_RIGHT, oxy_color)

    if params.oxygen_psi < 1000 and get(All_on_ground) == 1 then
        sasl.gl.drawWideLine(size[1]/2+210, size[2]-90, size[1]/2+305, size[2]-90, 3, ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2+305, size[2]-60, size[1]/2+305, size[2]-90, 3, ECAM_ORANGE)
    end

    if get(FAILURE_OXY_REGUL_FAIL) == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+270, size[2]-130, "REGUL LO PR", 36, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_door_page_textures()
    --static doors
    SASL_draw_img_xcenter_aligned(ECAM_DOOR_statics_img, size[1]/2+2, size[2]/2-195, 295, 520, {1, 1, 1})

    --front doors
    SASL_drawSegmentedImg(ECAM_DOOR_l_cabin_door_img, size[1]/2-292, size[2]/2+187, 522, 33, 2, get(Door_1_l_ratio) >= 0.1 and 1 or 2)
    SASL_drawSegmentedImg(ECAM_DOOR_r_cabin_door_img, size[1]/2+38, size[2]/2+187, 522, 33, 2, get(Door_1_r_ratio) >= 0.1 and 1 or 2)

    --cargo doors
    SASL_drawSegmentedImg(ECAM_DOOR_cargo_door_img, size[1]/2+29, size[2]/2+93, 438, 33, 2, get(Cargo_1_ratio) >= 0.1 and 1 or 2)
    SASL_drawSegmentedImg(ECAM_DOOR_cargo_door_img, size[1]/2+29, size[2]/2-146, 438, 33, 2, get(Cargo_2_ratio) >= 0.1 and 1 or 2)

    --aft doors
    SASL_drawSegmentedImg(ECAM_DOOR_l_cabin_door_img, size[1]/2-292, size[2]/2-245, 522, 33, 2, get(Door_3_l_ratio) >= 0.1 and 1 or 2)
    SASL_drawSegmentedImg(ECAM_DOOR_r_cabin_door_img, size[1]/2+38, size[2]/2-245, 522, 33, 2, get(Door_3_r_ratio) >= 0.1 and 1 or 2)
end

local function draw_door_bgd()
    drawTextCentered(Font_ECAMfont, 451, 852, "DOOR/OXY", 43, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(340, 830, 561, 830, 3, ECAM_WHITE)
end

function draw_door_page()
    sasl.gl.drawTexture(ECAM_DOOR_grey_lines_img, 244, 169, 419, 639, ECAM_LINE_GREY)
    update_param()
    draw_oxygen()
    draw_cabin_vs()
    draw_door_page_textures()
    draw_door_bgd()
end

