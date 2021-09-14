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

local GEN_APU = 3  -- TODO only temporarily until GEN_xx as global constants has been discussed

local function draw_triangle(x,y)
    sasl.gl.drawWideLine(x, y, x-10, y-25, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(x-10, y-25, x+10, y-25, 3, ECAM_GREEN)
    sasl.gl.drawWideLine(x+10, y-25, x, y, 3, ECAM_GREEN)
end

local function draw_apu_valve_and_needle()

    --APU gen box according state 0: invisible (white header only, no border), 1: OFF (amber + OFF), 2: online (white + values), 3: failed (amber + values)
    SASL_drawSegmentedImg(ECAM_APU_gen_img, size[1]/2-312, size[2]/2+178, 501, 139, 4, get(Ecam_apu_gen_state) + 1)

    --apu bleed valve
    --this is incorrect logic, the valve should go amber if the button position and the valve position disagrees\
    local valve_incorrect_pos = (get(Apu_bleed_xplane) == 0 and get(APU_bleed_switch_pos) == 1) or (get(Apu_bleed_xplane) == 1 and get(APU_bleed_switch_pos) == 0)
    local valve_color = valve_incorrect_pos and ECAM_ORANGE or ECAM_GREEN
    local valve_position = get(Apu_bleed_xplane) == 0 and 1 or 2
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_APU_valve_img, size[1]/2+261, size[2]/2+264, 120, 58, 2, valve_position, valve_color)
end

local function draw_apu_page_bgd()
    sasl.gl.drawArc (248, 231 , 77, 80 , 7 , 207 , ECAM_WHITE)
    sasl.gl.drawArc (248, 431 , 77, 80 , 31 , 183 , ECAM_WHITE)
    sasl.gl.drawWideLine(325, 243, 340, 243, 4, ECAM_ORANGE)
    sasl.gl.drawWideLine(313, 472, 321, 479, 4, ECAM_ORANGE)
    sasl.gl.drawWideLine(213, 300, 218, 294, 4, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 198, 198, "0", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 288, 273, "10", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 226, 281, "7", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 297, 464, "10", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 198, 396, "0", 21, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    drawTextCentered(Font_ECAMfont, 396, 455, "N", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 396, 419, "%", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 396, 260, "EGT", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 396, 223, "°C", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    drawTextCentered(Font_ECAMfont, 710, 678, "BLEED", 27, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 747, 642, "PSI", 23, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawWideLine(711, 699, 711, 716, 4, ECAM_GREEN)
    drawTextCentered(Font_ECAMfont, 450, 870, "APU", 44, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(409, 850, 490, 850, 4, ECAM_WHITE)

    Sasl_DrawWideFrame(641, 627, 135, 72, 4, 0, ECAM_LINE_GREY)

    sasl.gl.drawWideLine(801, 517, 801, 563, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(112, 563, 801, 563, 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(112, 517, 112, 563, 4, ECAM_LINE_GREY)
end

local function round_to_5(value)
    local x = math.fmod(value,5)
    return x < 3 and value - x or value + 5 - x
end

function draw_apu_page()
    draw_apu_page_bgd()
    draw_apu_valve_and_needle()

    --avail--  TODO what happens in cooling phase to generator, bleed and AVAIL?
    local apu_avail = get(Apu_avail)
    if  apu_avail == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+300, "AVAIL", 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    --low pressure--
    if get(Apu_fuel_source) == 0 and get(Apu_master_button_state) == 1  then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-10, "FUEL LO PR", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    --flap open
    if get(APU_flap) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-130, "FLAP OPEN", 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    -- APU Generator - online or failed - show values
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

        -- if AC1 bus is powered by APU Generator
        if ELEC_sys.buses.ac1_powered_by == GEN_APU then
            SASL_draw_img_xcenter_aligned(ECAM_APU_triangle_img, size[1]/2-250, size[2]/2+325, 27, 20, ECAM_GREEN)
        end

    end

    --apu bleed-- display of XX depends only on ADR status, not on bleed switch according videos
    if ADIRS_sys[ADIRS_1].adr_status ~= ADR_STATUS_ON or ADIRS_sys[ADIRS_2].adr_status ~= ADR_STATUS_ON or (get(FAILURE_BLEED_BMC_1) == 1 and get(FAILURE_BLEED_BMC_2) == 1)  then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, "XX", 26, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, math.floor(get(Apu_bleed_psi)), 26, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        if get(Apu_bleed_xplane) == 1 then
            sasl.gl.drawWideLine (size[1]/2+262, size[2]/2+318, size[1]/2+262, size[2]/2+345, 3, ECAM_GREEN )
            draw_triangle(size[1]/2+262, size[2]/2+370)
        end
    end

    local needle_color = ECAM_GREEN
    local apu_n = get(Apu_N1)
    local apu_egt = get(APU_EGT)

    --needles--
    if get(Apu_master_button_state) == 1 or apu_n > 1 then
        --N1
        if apu_n >= 102 then
            needle_color = ECAM_ORANGE
        end
        if apu_n >= 107 then
            needle_color = ECAM_RED
        end
        -- TODO draw N needle as line
        SASL_rotated_center_img_xcenter_aligned(ECAM_APU_needle_img, size[1]/2-200, size[2]/2-23, 4, 80, Math_rescale_lim_lower(0, -120, 100, 55, apu_n), 0, 0, needle_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, math.floor(apu_n), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

        --EGT
        needle_color = ECAM_GREEN
        if apu_avail == 0 then
            if apu_egt >= 1096 - 33 then
                needle_color = ECAM_ORANGE
            end
            if apu_egt >= 1096 then
                needle_color = ECAM_RED
            end
        end
        if apu_avail == 1 then
            if apu_egt >= 675 - 33 then
                needle_color = ECAM_ORANGE
            end
            if apu_egt >= 675 then
                needle_color = ECAM_RED
            end
        end
        -- TODO draw EGT needle as line
        -- TODO draw EGT margins
        -- TODO TBD blend over from one value to the other by dimming? We would have to keep some state for that though
        -- acc videos EGT is displayed in 5 degree steps and the needle also moves in steps
        apu_egt = round_to_5(apu_egt)
        SASL_rotated_center_img_xcenter_aligned(ECAM_APU_needle_img, size[1]/2-200, size[2]/2-225, 4, 80, Math_rescale_lim_lower(0, -120, 1000, 40, apu_egt), 0, 0, needle_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260,apu_egt, 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260, "XX", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(FAILURE_ENG_APU_LOW_OIL_P) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+115, size[2]/2-200, "LOW OIL\nLEVEL", 40, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end
end
