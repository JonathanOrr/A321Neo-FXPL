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

function draw_apu_page()
    sasl.gl.drawTexture(ECAM_APU_bgd_img, 0, 0, 900, 900, {1,1,1})
    sasl.gl.drawTexture(ECAM_APU_grey_lines_img, 0, 0, 900, 900, ECAM_LINE_GREY)

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
    if get(Adirs_adr_is_ok[1]) == 0 or get(Adirs_adr_is_ok[2]) == 0 or (get(FAILURE_BLEED_BMC_1) == 1 and get(FAILURE_BLEED_BMC_2) == 1) then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, "XX", 26, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+265, size[2]/2+187, math.floor(get(Apu_bleed_psi)), 26, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        if get(Ecam_bleed_apu_valve) >= 2 then
            sasl.gl.drawWideLine (size[1]/2+262, size[2]/2+318, size[1]/2+262, size[2]/2+345, 3, ECAM_GREEN )
            draw_triangle(size[1]/2+262, size[2]/2+370)
        end

    end

    --needles--
    if get(Ecam_apu_needle_state) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, math.floor(get(Apu_N1)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260, math.floor(get(APU_EGT)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    if get(FAILURE_ENG_APU_LOW_OIL_P) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+115, size[2]/2-200, "LOW OIL\nLEVEL", 40, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end
end

function ecam_update_apu_page()
    if get(Apu_master_button_state) == 1 or get(Apu_N1) > 1 then
        set(Ecam_apu_needle_state, 1)
    else
        set(Ecam_apu_needle_state, 0)
    end
end
