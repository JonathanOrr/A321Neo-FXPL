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
-- File: ECAM_engines.lua 
-- Short description: ECAM file for the ENGINE page 
-------------------------------------------------------------------------------

size = {900, 900}

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_oil_press = 0,
    eng2_oil_press = 0,
    eng1_oil_temp = 0,
    eng2_oil_temp = 0,
    eng1_vib_n1 = 0,
    eng1_vib_n2 = 0,
    eng2_vib_n1 = 0,
    eng2_vib_n2 = 0,
    last_update = 0
}


local function draw_fuel_usage()
    local fuel_usage_1 = math.floor(get(Ecam_fuel_usage_1))
    local fuel_usage_2 = math.floor(get(Ecam_fuel_usage_2))

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 760, fuel_usage_1, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 760, fuel_usage_2, 36, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

end

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

local function draw_oil_qt_press_temp()

    local eng_1_oil_color = pulse_green(get(Eng_1_OIL_qty) < 2)
    local eng_2_oil_color = pulse_green(get(Eng_2_OIL_qty) < 2)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-153, 625, math.floor(get(Eng_1_OIL_qty)) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-136, 625, math.floor((get(Eng_1_OIL_qty)%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+223, 625, math.floor(get(Eng_2_OIL_qty)) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+240, 625, math.floor((get(Eng_2_OIL_qty)%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

    local eng_1_oil_color = pulse_green(get(Eng_1_OIL_press) > 90 or get(Eng_1_OIL_press) < 13)
    local eng_2_oil_color = pulse_green(get(Eng_2_OIL_press) > 90 or get(Eng_2_OIL_press) < 13)
    if get(Eng_1_OIL_press) < 7 then eng_1_oil_color = ECAM_RED end
    if get(Eng_2_OIL_press) < 7 then eng_2_oil_color = ECAM_RED end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-165, 525, params.eng1_oil_press, 36,
                     false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+213, 525, params.eng2_oil_press ,36,
                    false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

    local eng_1_oil_color = pulse_green(get(Eng_1_OIL_temp) > 140)
    local eng_2_oil_color = pulse_green(get(Eng_2_OIL_temp) > 140)
    if get(Eng_1_OIL_temp) > 155 then eng_1_oil_color = ECAM_AMBER end
    if get(Eng_2_OIL_temp) > 155 then eng_2_oil_color = ECAM_AMBER end

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 455, params.eng1_oil_temp ,36,
                     false, false, TEXT_ALIGN_CENTER, eng_1_oil_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 455, params.eng2_oil_temp ,36,
                    false, false, TEXT_ALIGN_CENTER, eng_2_oil_color)

end

local function draw_vibrations()

    local eng1_vib1_color = pulse_green(params.eng1_vib_n1 > 6)
    local eng1_vib2_color = pulse_green(params.eng1_vib_n2 > 4.3)
    local eng2_vib1_color = pulse_green(params.eng2_vib_n1 > 6)
    local eng2_vib2_color = pulse_green(params.eng2_vib_n2 > 4.3)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 385, math.floor(params.eng1_vib_n1) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 385, math.floor((params.eng1_vib_n1%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 385, math.floor(params.eng2_vib_n1) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 385, math.floor((params.eng2_vib_n1%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 350, math.floor(params.eng1_vib_n2) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 350, math.floor((params.eng1_vib_n2%1)*10), 28,
                    false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 350, math.floor(params.eng2_vib_n2) .. "." , 36,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 350, math.floor((params.eng2_vib_n2%1)*10) , 28,
                    false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)
end

local function draw_bleed()
    local bleed_1_press_color = get(L_bleed_press) < 21 and ECAM_ORANGE or ECAM_GREEN
    local bleed_2_press_color = get(L_bleed_press) < 21 and ECAM_ORANGE or ECAM_GREEN
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-188, 136, math.floor(get(L_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, bleed_1_press_color)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+192, 136, math.floor(get(R_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, bleed_2_press_color)
end

local function draw_special()

    if get(FAILURE_ENG_1_FUEL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 720, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_2_FUEL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 720, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_1_OIL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 490, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    if get(FAILURE_ENG_2_OIL_CLOG) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 490, "CLOG" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

local function draw_ignition()

      if get(Ecam_eng_igniter_eng_1) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-202, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
      if get(Ecam_eng_igniter_eng_1) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-177, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end

      if get(Ecam_eng_igniter_eng_2) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
      if get(Ecam_eng_igniter_eng_2) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+205, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
      end
end

local function draw_needle_and_valves()
    --oil quantity--
    SASL_draw_needle_adv(size[1]/2-187, size[2]/2+176, 58, 80, Math_rescale(0, 180, 17, 0, get(Eng_1_OIL_qty)), 3.5, ECAM_GREEN)
    SASL_draw_needle_adv(size[1]/2+187, size[2]/2+176, 58, 80, Math_rescale(0, 180, 17, 0, get(Eng_2_OIL_qty)), 3.5, ECAM_GREEN)
    --oil press--
    SASL_draw_needle_adv(size[1]/2-189, size[2]/2+78, 50, 80, Math_rescale(0, 180, 100, 0, get(Eng_1_OIL_press)), 3.5, ECAM_GREEN)
    SASL_draw_needle_adv(size[1]/2+189, size[2]/2+78, 50, 80, Math_rescale(0, 180, 100, 0, get(Eng_2_OIL_press)), 3.5, ECAM_GREEN)

    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_ENG_valve_img, size[1]/2-190, size[2]/2-272, 128, 80, 2, get(ENG_1_bleed_switch) == 1 and 2 or 1, ECAM_GREEN)
    SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_ENG_valve_img, size[1]/2+190, size[2]/2-272, 128, 80, 2, get(ENG_2_bleed_switch) == 1 and 2 or 1, ECAM_GREEN)
end

function draw_eng_page()
    sasl.gl.drawTexture(ECAM_ENG_bgd_img, 0, 0, 900, 900, {1,1,1})
    draw_fuel_usage()
    draw_oil_qt_press_temp()
    draw_vibrations()
    draw_special()
    draw_ignition()
    draw_bleed()
    draw_needle_and_valves()

end

-- Returns true if the FADEC has electrical power
local function fadec_has_elec_power(eng)
    if get(DC_ess_bus_pwrd) == 1 then
        return true
    end

    if eng == 1 and ((get(Gen_1_pwr) == 1) or get(DC_bat_bus_pwrd) == 1) then
        return true
    end

    if eng == 2 and ((get(Gen_2_pwr) == 1) or get(DC_bus_2_pwrd) == 1) then
        return true
    end
end

local start_elec_fadec = {0,0}
local start_shut_fadec = {0,0}
local xx_statuses = {false,false}

local function update_XX_dr_eng(eng)
    -- This logic is insanely complex

    if fadec_has_elec_power(eng) then
        if start_elec_fadec[eng] == 0 then
            start_elec_fadec[eng] = get(TIME)
        end
    else
        start_elec_fadec[eng] = 0
    end

    if (eng == 1 and get(Engine_1_master_switch) == 0) or (eng == 2 and get(Engine_2_master_switch) == 0) then
        if start_shut_fadec[eng] == 0 then
            start_shut_fadec[eng] = get(TIME)
        end
    else
        start_shut_fadec[eng] = 0
    end

    if (eng == 1 and get(Eng_1_N2) > 10) or (eng == 2 and get(Eng_2_N2) > 10) then
        xx_statuses[eng] = true
        return
    end

    local fire_pb_cond = (get(Fire_pb_ENG1_status) == 1 and eng == 1) or (get(Fire_pb_ENG2_status) == 1 and eng == 2)

    if fire_pb_cond or not fadec_has_elec_power(eng) then
        xx_statuses[eng] = false
        return
    end

    if get(TIME) - start_elec_fadec[eng] < 5 * 60 then
        xx_statuses[eng] = true
        return
    end

    if get(Engine_mode_knob) ~= 0 then
        xx_statuses[eng] = true
        return
    end

    if get(TIME) - start_shut_fadec[eng] < 5 * 60 then
        xx_statuses[eng] = true
        return
    end

    if get(Any_wheel_on_ground) == 0 then
        xx_statuses[eng] = true
        return
    end

    xx_statuses[eng] = false
end

local function update_XX_dr()

    update_XX_dr_eng(1)
    xx_statuses[1] = xx_statuses[1] and (get(FAILURE_ENG_FADEC_CH1, 1) == 0 or get(FAILURE_ENG_FADEC_CH2, 1) == 0)
    update_XX_dr_eng(2)
    xx_statuses[2] = xx_statuses[2] and (get(FAILURE_ENG_FADEC_CH1, 2) == 0 or get(FAILURE_ENG_FADEC_CH2, 2) == 0)

    set(EWD_engine_1_XX, xx_statuses[1] and 0 or 1)
    set(EWD_engine_2_XX, xx_statuses[2] and 0 or 1)
end

function ecam_update_eng_page()

    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_oil_press = math.floor(get(Eng_1_OIL_press))
        params.eng2_oil_press = math.floor(get(Eng_2_OIL_press))
        params.eng1_oil_temp  = math.floor(get(Eng_1_OIL_temp))
        params.eng2_oil_temp  = math.floor(get(Eng_2_OIL_temp))
        params.eng1_vib_n1    = get(Eng_1_VIB_N1)
        params.eng1_vib_n2    = get(Eng_1_VIB_N2)
        params.eng2_vib_n1    = get(Eng_2_VIB_N1)
        params.eng2_vib_n2    = get(Eng_2_VIB_N2)
        params.last_update = get(TIME)
    end

    update_XX_dr()

end

