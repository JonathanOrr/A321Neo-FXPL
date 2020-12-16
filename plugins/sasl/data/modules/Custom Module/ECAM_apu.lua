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
-- File: ECAM_apu.lua
-- Short description: ECAM file for the APU page
-------------------------------------------------------------------------------

include('constants.lua')

local function draw_triangle(x,y)
    sasl.gl.drawWideLine(x, y, x-10, y-25, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(x-10, y-25, x+10, y-25, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(x+10, y-25, x, y, 3, ECAM_GREEN)
end

local function draw_apu_valve_and_needle()
    if get(Gen_APU_pwr) == 1 then
        SASL_draw_img_xcenter_aligned(ECAM_APU_triangle_img, size[1]/2-250, size[2]/2+325, 27, 20, ECAM_GREEN)
    end

    --APU gen box
    SASL_drawSegmentedImg(ECAM_APU_gen_img, size[1]/2-312, size[2]/2+178, 501, 139, 4, get(Ecam_apu_gen_state) + 1)

    --apu bleed valve
    --this is incorrect logic, the valve should go amber if the button position and the valve position disagrees\
    local valve_incorrect_pos = (get(Apu_bleed_xplane) == 0 and get(APU_bleed_switch_pos) == 1) or (get(Apu_bleed_xplane) == 1 and get(APU_bleed_switch_pos) == 0)
    local valve_color = valve_incorrect_pos and ECAM_ORANGE or ECAM_GREEN
    local valve_position = get(Apu_bleed_xplane) == 0 and 1 or 2
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_APU_valve_img, size[1]/2+261, size[2]/2+264, 120, 58, 2, valve_position, valve_color)
end

function draw_apu_page()
    sasl.gl.drawTexture(ECAM_APU_bgd_img, 0, 0, 900, 900, {1,1,1})
    sasl.gl.drawTexture(ECAM_APU_grey_lines_img, 0, 0, 900, 900, ECAM_LINE_GREY)

    draw_apu_valve_and_needle()

    --avail--
    if get(Apu_avail) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+300, "AVIAL", 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    --low pressure--
    if get(Apu_fuel_source) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-10, "FUEL LO PR", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --flap open
    if get(APU_flap) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-130, "FLAP OPEN", 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    --apu gen section--
    if get(Ecam_apu_gen_state) >= 2 then
        local color_amps = (-ELEC_sys.generators[3].curr_amps > 261) and ECAM_ORANGE or ECAM_GREEN
        local load_val = math.abs(math.floor(ELEC_sys.generators[3].curr_amps/261*100))
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+257, load_val, 23, false, false, TEXT_ALIGN_RIGHT, color_amps)

        local color_volt = (ELEC_sys.generators[3].curr_voltage < 105 or ELEC_sys.generators[3].curr_voltage > 120) and ECAM_ORANGE or ECAM_GREEN
        local voltage_val = math.floor(ELEC_sys.generators[3].curr_voltage)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+224, voltage_val, 23, false, false, TEXT_ALIGN_RIGHT, color_volt)

        local color_hz = (ELEC_sys.generators[3].curr_hz < 385 or ELEC_sys.generators[3].curr_hz > 410) and ECAM_ORANGE or ECAM_GREEN
        local hz_val = math.floor(ELEC_sys.generators[3].curr_hz)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+192, hz_val, 23, false, false, TEXT_ALIGN_RIGHT, color_hz)

        if ELEC_sys.buses.ac1_powered_by == 3 then
            sasl.gl.drawWideLine (size[1]/2-250, size[2]/2+320, size[1]/2-250, size[2]/2+345, 3, ECAM_GREEN )
            draw_triangle(size[1]/2-250, size[2]/2+370)
        end

    end

    --apu bleed--
    if get(Adirs_adr_is_ok[1]) == 0 or get(Adirs_adr_is_ok[2]) == 0 or (get(FAILURE_BLEED_BMC_1) == 1 and get(FAILURE_BLEED_BMC_2) == 1) or get(Apu_bleed_xplane) == 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, "XX", 26, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, math.floor(get(Apu_bleed_psi)), 26, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        if get(Apu_bleed_xplane) == 1 then
            sasl.gl.drawWideLine (size[1]/2+262, size[2]/2+318, size[1]/2+262, size[2]/2+345, 3, ECAM_GREEN )
            draw_triangle(size[1]/2+262, size[2]/2+370)
        end
    end

    local needle_color = ECAM_GREEN

    --needles--
    if get(Apu_master_button_state) == 1 or get(Apu_N1) > 1 then
        --N1
        if get(Apu_N1) >= 102 then
            needle_color = ECAM_ORANGE
        end
        if get(Apu_N1) >= 107 then
            needle_color = ECAM_RED
        end
        SASL_rotated_center_img_xcenter_aligned(ECAM_APU_needle_img, size[1]/2-200, size[2]/2-23, 4, 80, Math_rescale_lim_lower(0, -120, 100, 55, get(Apu_N1)), 0, 0, needle_color)

        --EGT
        needle_color = ECAM_GREEN
        if get(Apu_avail) == 0 then
            if get(APU_EGT) >= 1096 - 33 then
                needle_color = ECAM_ORANGE
            end
            if get(APU_EGT) >= 1096 then
                needle_color = ECAM_RED
            end
        end
        if get(Apu_avail) == 1 then
            if get(APU_EGT) >= 675 - 33 then
                needle_color = ECAM_ORANGE
            end
            if get(APU_EGT) >= 675 then
                needle_color = ECAM_RED
            end
        end
        SASL_rotated_center_img_xcenter_aligned(ECAM_APU_needle_img, size[1]/2-200, size[2]/2-225, 4, 80, Math_rescale_lim_lower(0, -120, 1000, 40, get(APU_EGT)), 0, 0, needle_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, math.floor(get(Apu_N1)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260, math.floor(get(APU_EGT)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(FAILURE_ENG_APU_LOW_OIL_P) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+115, size[2]/2-200, "LOW OIL\nLEVEL", 40, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end
end
