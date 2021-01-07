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
-- File: ECAM_cruise.lua 
-- Short description: ECAM file for the CRUISE page 
-------------------------------------------------------------------------------

size = {900, 900}
include('constants.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_vib_n1 = 0,
    eng1_vib_n2 = 0,
    eng2_vib_n1 = 0,
    eng2_vib_n2 = 0,
    cabin_psi = 0,
    cabin_vs = 0,
    cabin_alt = 0,
    last_update = 0
}

local function pulse_green(condition)
    if condition then
        if get(TIME) % 1 > 0.5 then
            return ECAM_GREEN
        else
            return ECAM_HIGH_GREEN
        end
    else
        return ECAM_GREEN
    end
end

local function draw_fuel_usage()
    local fuel_usage_1 = math.floor(get(Ecam_fuel_usage_1))
    local fuel_usage_2 = math.floor(get(Ecam_fuel_usage_2))

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 760, fuel_usage_1, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 760, fuel_usage_2, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, 730, fuel_usage_1+fuel_usage_2, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

end

local function draw_oil_qt()

    local eng_1_oil_color = pulse_green(get(Eng_1_OIL_qty) < 2)
    local eng_2_oil_color = pulse_green(get(Eng_2_OIL_qty) < 2)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 650, math.floor(get(Eng_1_OIL_qty)) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 650, math.floor((get(Eng_1_OIL_qty)%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 650, math.floor(get(Eng_2_OIL_qty)) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 650, math.floor((get(Eng_2_OIL_qty)%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

end

local function draw_vibrations()
    local eng1_vib1_color = pulse_green(params.eng1_vib_n1 > 6)
    local eng1_vib2_color = pulse_green(params.eng1_vib_n2 > 4.3)
    local eng2_vib1_color = pulse_green(params.eng2_vib_n1 > 6)
    local eng2_vib2_color = pulse_green(params.eng2_vib_n2 > 4.3)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 560, math.floor(params.eng1_vib_n1) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 560, math.floor((params.eng1_vib_n1%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 560, math.floor(params.eng2_vib_n1) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 560, math.floor((params.eng2_vib_n1%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-150, 520, math.floor(params.eng1_vib_n2) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-135, 520, math.floor((params.eng1_vib_n2%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, 520, math.floor(params.eng2_vib_n2) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, 520, math.floor((params.eng2_vib_n2%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)
end

local function draw_temps()
    --temperatures 
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-330, size[2]/2-250, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-190, size[2]/2-250, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-70, size[2]/2-250, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
end

local function draw_press()

    --pressure info
    local color_psi = ECAM_GREEN
    if get(Cabin_delta_psi) < -0.4 or get(Cabin_delta_psi) > 8.5 then
        color_psi = ECAM_ORANGE
    elseif get(Cabin_delta_psi) > 1.5 and get(EWD_flight_phase) == PHASE_FINAL then
        color_psi = pulse_green(true)
    end

    local color_vs = ECAM_GREEN
    if get(Cabin_vs) > 1750 then
        color_vs = pulse_green(true)
    end

    local color_alt = ECAM_GREEN
    if get(Cabin_alt_ft) > 9950 then
        color_alt = ECAM_RED
    elseif get(Cabin_alt_ft) > 8800 then
        color_alt = pulse_green(true)
    end

    --cab vs arrow
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_CRUISE_vs_arrow_img, size[1]/2+198, size[2]/2-186, 56, 27, 2, params.cabin_vs >= 0 and 1 or 2, ECAM_GREEN)

    --cab press
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+10, size[2]/2-105, params.cabin_psi, 36, false, false, TEXT_ALIGN_RIGHT, color_psi)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-185, math.abs(params.cabin_vs), 36, false, false, TEXT_ALIGN_RIGHT, color_vs)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-290, params.cabin_alt, 36, false, false, TEXT_ALIGN_RIGHT, color_alt)
end

local function draw_ldg_elev()
    local y = size[2]/2-44

    if get(Press_ldg_elev_knob_pos) >= -2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+110, y, "MAN", 36, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+110, y, "AUTO", 36, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    if get(Press_mode_sel_is_man) == 0 then    -- Hide when MODE SEL NOT AUTO
        local selected = get(Press_ldg_elev_knob_pos) >= -2 and get(Press_ldg_elev_knob_pos)*1000 or 0 -- TODO ADD COMPUTED FROM MCDU HERE
        selected = selected - selected%50
        sasl.gl.drawText(Font_AirbusDUL, size[1]-110, y, "FT", 30, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]-130, y, selected, 36, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
end


function draw_cruise_page()
    sasl.gl.drawTexture(ECAM_CRUISE_bgd_img, 0, 0, 900, 900, {1,1,1})
    draw_temps()
    draw_press()
    draw_fuel_usage()
    draw_oil_qt()
    draw_vibrations()
    draw_ldg_elev()
end

function ecam_update_cruise_page()

    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_vib_n1    = get(Eng_1_VIB_N1)
        params.eng1_vib_n2    = get(Eng_1_VIB_N2)
        params.eng2_vib_n1    = get(Eng_2_VIB_N1)
        params.eng2_vib_n2    = get(Eng_2_VIB_N2)
        params.cabin_psi      = Round(get(Cabin_delta_psi),1)
        params.cabin_vs       = math.floor(get(Cabin_vs))
        params.cabin_alt      = math.floor(get(Cabin_alt_ft))
        params.last_update = get(TIME)
    end

end
