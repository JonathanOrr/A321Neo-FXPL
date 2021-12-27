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

local BLEED_MIN_LIMIT = 21 -- controls color of bleed pressure indication
-- some logic during start or shutdown of FADEC is timer based
local start_elec_fadec = {0,0}
local start_shut_fadec = {0,0}

local xx_statuses = {false,false}        -- when *false* XX will be displayed instead of values
local manual_fadeec_on = {false, false}  -- FADEC power override from maintenance panel


sasl.registerCommandHandler (MNTN_FADEC_1_on,  0, function(phase) if phase == SASL_COMMAND_BEGIN then manual_fadeec_on[1] = not manual_fadeec_on[1] end end )
sasl.registerCommandHandler (MNTN_FADEC_2_on,  0, function(phase) if phase == SASL_COMMAND_BEGIN then manual_fadeec_on[2] = not manual_fadeec_on[2] end end )

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

local function get_press_red_limit(n2)
    -- TODO if N2 is < 10 this will has to be calculated in some other way TBC with manuals/sim
    if n2 < 15 then return 5 end
    return ENG.data.display.oil_press_low_red[1] + ENG.data.display.oil_press_low_red[2] * n2
end

local function get_press_amber_limit(n2)
    if n2 < 15 then return 7 end
    return ENG.data.display.oil_press_low_amber[1] + ENG.data.display.oil_press_low_amber[2] * n2
end

local function draw_oil_qt_press_temp_eng_1()

    if xx_statuses[1] then

        ------------------------------------------------------------------------------------
        -- ENG 1 OIL QTY
        ------------------------------------------------------------------------------------
        local oil_qty_1 = ENG.dyn[1].oil_qty 
        local eng_1_oil_color = pulse_green(oil_qty_1 < ENG.data.display.oil_qty_advisory)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-153, 625, math.floor(oil_qty_1) .. "." , 36,
                         false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-136, 625, math.floor((oil_qty_1%1)*10), 28,
                        false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

        ------------------------------------------------------------------------------------
        -- ENG 1 OIL PRESS
        ------------------------------------------------------------------------------------
        local eng_1_oil_color = pulse_green(
              params.eng1_oil_press > ENG.data.display.oil_press_high_adv or
              params.eng1_oil_press < ENG.data.display.oil_press_low_adv
              )

        --- N dependent limits may override actual color
        local press_red_limit = get_press_red_limit(ENG.dyn[1].n2)
        local press_amber_limit = get_press_amber_limit(ENG.dyn[1].n2)

        if params.eng1_oil_press < press_red_limit then
            eng_1_oil_color = ECAM_RED
        elseif params.eng1_oil_press < press_amber_limit then
            eng_1_oil_color = ECAM_ORANGE
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-165, 525, params.eng1_oil_press, 36,
                     false, false, TEXT_ALIGN_RIGHT, eng_1_oil_color)

        ------------------------------------------------------------------------------------
        -- ENG 1 OIL TEMP
        ------------------------------------------------------------------------------------
        local eng_1_oil_color = pulse_green(params.eng1_oil_temp > ENG.data.display.oil_temp_high_adv)
        if ENG.dyn[1].is_avail and params.eng1_oil_temp < 54 or  params.eng1_oil_temp > ENG.data.display.oil_temp_high_amber then
            eng_1_oil_color = ECAM_ORANGE
        end
        local temp = math.floor(params.eng1_oil_temp) - math.floor(params.eng1_oil_temp)%5
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 455,temp ,36,
                     false, false, TEXT_ALIGN_CENTER, eng_1_oil_color)

    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 625, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 525, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 455, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    end
end

local function draw_oil_qt_press_temp_eng_2()
    if xx_statuses[2] then
        ------------------------------------------------------------------------------------
        -- ENG 2 OIL QTY
        ------------------------------------------------------------------------------------
        local oil_qty_2 = ENG.dyn[2].oil_qty 
        local eng_2_oil_color = pulse_green(oil_qty_2 < ENG.data.display.oil_qty_advisory)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+223, 625, math.floor(oil_qty_2) .. "." , 36,
                        false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+240, 625, math.floor((oil_qty_2%1)*10), 28,
                        false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

        ------------------------------------------------------------------------------------
        -- ENG 2 OIL PRESS
        ------------------------------------------------------------------------------------
        local eng_2_oil_color = pulse_green(
              params.eng2_oil_press > ENG.data.display.oil_press_high_adv or
              params.eng2_oil_press < ENG.data.display.oil_press_low_adv
              )

        local press_red_limit = get_press_red_limit(ENG.dyn[2].n2)
        local press_amber_limit = get_press_amber_limit(ENG.dyn[2].n2)

        if params.eng2_oil_press < press_red_limit then
            eng_2_oil_color = ECAM_RED
        elseif params.eng2_oil_press < press_amber_limit then
            eng_2_oil_color = ECAM_ORANGE
        end

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+213, 525, params.eng2_oil_press ,36,
                        false, false, TEXT_ALIGN_RIGHT, eng_2_oil_color)

        ------------------------------------------------------------------------------------
        -- ENG 2 OIL TEMP
        ------------------------------------------------------------------------------------
        local eng_2_oil_color = pulse_green(params.eng2_oil_temp > ENG.data.display.oil_temp_high_adv)
        if ENG.dyn[2].is_avail and params.eng2_oil_temp < 54 or  params.eng2_oil_temp > ENG.data.display.oil_temp_high_amber then
            eng_2_oil_color = ECAM_ORANGE
        end
        local temp = math.floor(params.eng2_oil_temp) - math.floor(params.eng2_oil_temp)%5
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 455, temp ,36,
                        false, false, TEXT_ALIGN_CENTER, eng_2_oil_color)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 625, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 525, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 455, "XX" , 36, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    end
end


local function draw_oil_qt_press_temp()
    if ENG.data then    -- In the first frame this value is not yet initialized
        draw_oil_qt_press_temp_eng_1()
        draw_oil_qt_press_temp_eng_2()
    end
end

local function draw_vibrations()


    if xx_statuses[1] and get(AC_bus_1_pwrd) == 1 then

        local eng1_vib1_color = params.eng1_vib_n1 > ENG.data.vibrations.max_n1_nominal and ECAM_ORANGE or ECAM_GREEN
        local eng1_vib2_color = params.eng1_vib_n2 > ENG.data.vibrations.max_n2_nominal and ECAM_ORANGE or ECAM_GREEN
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 385, math.floor(params.eng1_vib_n1) .. "." , 36,
                     false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 385, math.floor((params.eng1_vib_n1%1)*10), 28,
                        false, false, TEXT_ALIGN_RIGHT, eng1_vib1_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-175, 350, math.floor(params.eng1_vib_n2) .. "." , 36,
                         false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-155, 350, math.floor((params.eng1_vib_n2%1)*10), 28,
                        false, false, TEXT_ALIGN_RIGHT, eng1_vib2_color)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 385, "XX" , 36,
                     false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-187, 350, "XX" , 36,
                         false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    end

    if xx_statuses[2] and get(AC_bus_1_pwrd) == 1 then
        local eng2_vib1_color = params.eng2_vib_n1 > ENG.data.vibrations.max_n1_nominal and ECAM_ORANGE or ECAM_GREEN
        local eng2_vib2_color = params.eng2_vib_n2 > ENG.data.vibrations.max_n2_nominal and ECAM_ORANGE or ECAM_GREEN

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 385, math.floor(params.eng2_vib_n1) .. "." , 36,
                        false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 385, math.floor((params.eng2_vib_n1%1)*10) , 28,
                        false, false, TEXT_ALIGN_RIGHT, eng2_vib1_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, 350, math.floor(params.eng2_vib_n2) .. "." , 36,
                        false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+220, 350, math.floor((params.eng2_vib_n2%1)*10) , 28,
                        false, false, TEXT_ALIGN_RIGHT, eng2_vib2_color)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 385, "XX" , 36,
                        false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+187, 350, "XX" , 36,
                        false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
    end
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

local function ignition_section_visible()
    -- draw IGN only, if eng mode is in start position TODO check valve/gauge display conditions
    -- TODO after successful start (AVAIL) of BOTH engines the startup sequence display (IGN and PSI) section will disappear after some delay
    -- TODO show up again on auto restart and continuous ignition
    if( get(Engine_mode_knob) == 1) then
        return true
    end
    return false;
end

local function nacelle_section_visible()
    -- TODO handle visibililty of NACELLE display xor IGN section
    return false
end


local function draw_bleed_psi()
    local bleed_1_press_color = get(L_bleed_press) < BLEED_MIN_LIMIT and ECAM_ORANGE or ECAM_GREEN
    local bleed_2_press_color = get(R_bleed_press) < BLEED_MIN_LIMIT and ECAM_ORANGE or ECAM_GREEN
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-188, 136, math.floor(get(L_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, bleed_1_press_color)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+192, 136, math.floor(get(R_bleed_press)), 36, false, false, TEXT_ALIGN_CENTER, bleed_2_press_color)
end

local function draw_valve_and_ignition()
    if xx_statuses[1] then
        -- igniter indications A/B
        if get(Ecam_eng_igniter_eng_1) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-202, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
        if get(Ecam_eng_igniter_eng_1) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-177, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
        -- starter valve
        SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_ENG_valve_img, size[1]/2-190, size[2]/2-272, 128, 80, 2, ENG.dyn[1].starter_valve and 2 or 1, ECAM_GREEN)
    end
    if xx_statuses[2] then
        -- igniter indications A/B
        if get(Ecam_eng_igniter_eng_2) % 2 == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, 250, "A" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
        if get(Ecam_eng_igniter_eng_2) >= 2 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+205, 250, "B" , 36,
                     false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
        -- starter valve
        SASL_drawSegmentedImgColored_xcenter_aligned(ECAM_ENG_valve_img, size[1]/2+190, size[2]/2-272, 128, 80, 2, ENG.dyn[2].starter_valve and 2 or 1, ECAM_GREEN)
    end
end

local function draw_bleed_and_ignition()
    if(ignition_section_visible()) then
        draw_valve_and_ignition()
        draw_bleed_psi()
    end
end


local function draw_arcs_limits(x, y, red_angle, yellow_angle, current_angle, left_bottom_marker)

        -- Arc and other fixed stuffs
        sasl.gl.drawArc(x, y, 69, 72, 0, red_angle and red_angle or 180, ECAM_WHITE)
        if left_bottom_marker then
            sasl.gl.drawWideLine(x-59, y, x-72, y, 2, ECAM_WHITE)
        end
        sasl.gl.drawWideLine(x+59, y, x+72, y, 2, ECAM_WHITE)
        sasl.gl.drawWideLine(x, y+60, x, y+70, 2, ECAM_WHITE)

        -- Limits
        if red_angle and red_angle < 180 then
            sasl.gl.drawArc(x, y, 69, 72, red_angle, 180-red_angle, ECAM_RED)
        end

        if yellow_angle and yellow_angle < 180 then
            SASL_draw_needle_adv(x, y, 65, 74, yellow_angle, 4, ECAM_ORANGE)
            SASL_draw_needle_adv(x, y, 73, 82, yellow_angle+2, 10, ECAM_ORANGE)
        end

        -- Draw the needle
        local needle_color = ECAM_GREEN
        if red_angle and red_angle <= current_angle then
            needle_color = ECAM_RED
        elseif yellow_angle and yellow_angle <= current_angle then
            needle_color = ECAM_ORANGE
        end

        SASL_draw_needle_adv(x, y, 58, 80, current_angle, 3.5, needle_color)
end

local function draw_oil_qty_and_pressure_gauges()
    local oil_qty_max = ENG.data.display.oil_qty_scale
    local oil_qty_adv = ENG.data.display.oil_qty_advisory
    local oil_press_max = ENG.data.display.oil_press_scale

    if xx_statuses[1] then
        -- OIL QTY
        local oil_angle = Math_rescale(0, 180, oil_qty_max, 0, ENG.dyn[1].oil_qty)
        local oil_angle_adv = Math_rescale(0, 180, oil_qty_max, 0, oil_qty_adv)
        draw_arcs_limits(size[1]/2-187, size[2]/2+176, nil, oil_angle_adv, oil_angle, true)
        
        local oil_angle = Math_rescale(0, 180, oil_press_max, 0, ENG.dyn[1].oil_press)
        local oil_red_limit = math.max(0, get_press_red_limit(ENG.dyn[1].n2))
        local oil_angle_red = Math_rescale(0, 180, oil_press_max, 0, oil_red_limit)
        local oil_amber_limit = math.max(0, get_press_amber_limit(ENG.dyn[1].n2))
        local oil_angle_amber = Math_rescale(0, 180, oil_press_max, 0, oil_amber_limit)

        draw_arcs_limits(size[1]/2-189, size[2]/2+78, oil_angle_red, oil_angle_amber, oil_angle, false)

    end
    
    if xx_statuses[2] then
        -- OIL QTY
        local oil_angle = Math_rescale(0, 180, oil_qty_max, 0, ENG.dyn[2].oil_qty)
        local oil_angle_adv = Math_rescale(0, 180, oil_qty_max, 0, oil_qty_adv)
        draw_arcs_limits(size[1]/2+187, size[2]/2+176, nil, oil_angle_adv, oil_angle, true)

        local oil_angle = Math_rescale(0, 180, oil_press_max, 0, ENG.dyn[2].oil_press)
        local oil_red_limit = math.max(0, get_press_red_limit(ENG.dyn[2].n2))
        local oil_angle_red = Math_rescale(0, 180, oil_press_max, 0, oil_red_limit)
        local oil_amber_limit = math.max(0, get_press_amber_limit(ENG.dyn[2].n2))
        local oil_angle_amber = Math_rescale(0, 180, oil_press_max, 0, oil_amber_limit)

        draw_arcs_limits(size[1]/2+189, size[2]/2+78, oil_angle_red, oil_angle_amber, oil_angle, false)

    end
end

local function draw_eng_bgd()
    sasl.gl.drawWideLine(338, 157+205   , 368   ,   160+205     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(338, 157+242   , 368   ,   160+242     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(338, 157+326   , 368   ,   160+326     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(338, 157+620   , 368   ,   160+620     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(900-338, 157+205   , 900-368   ,   160+205     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(900-338, 157+242   , 900-368   ,   160+242     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(900-338, 157+326   , 900-368   ,   160+326     , 4, ECAM_LINE_GREY)
    sasl.gl.drawWideLine(900-338, 157+620   , 900-368   ,   160+620     , 4, ECAM_LINE_GREY)

    drawTextCentered(Font_ECAMfont, 450, 789, "F.USED", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 450, 751, "KG", 27, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 450, 688, "OIL", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 450, 636, "QT", 27, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 450, 535, "PSI", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 450, 478, "°C", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    drawTextCentered(Font_ECAMfont, 450, 398, "VIB N1", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    drawTextCentered(Font_ECAMfont, 450+30, 360, "N2", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    if(ignition_section_visible()) then
        sasl.gl.drawWideLine(338, 157       , 368   ,   160         , 4, ECAM_LINE_GREY)
        sasl.gl.drawWideLine(900-338, 157       , 900-368   ,   160         , 4, ECAM_LINE_GREY)
        drawTextCentered(Font_ECAMfont, 450, 258, "IGN", 30, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        drawTextCentered(Font_ECAMfont, 450, 150, "PSI", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end
    -- TODO NAC temperature advisory threshold reached - draw engine nacelle temperature indication instead of startup section of cause since
    -- position is the same

    drawTextCentered(Font_ECAMfont, 93, 870, "ENGINE", 44, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawWideLine(8, 850, 176, 850, 4, ECAM_WHITE)
end

function draw_eng_page()
    draw_eng_bgd()
    draw_fuel_usage()
    draw_oil_qt_press_temp()
    draw_vibrations()
    draw_special()
    draw_bleed_and_ignition()
    draw_oil_qty_and_pressure_gauges()

end

-- Returns true if the FADEC has electrical power
local function fadec_has_elec_power(eng)
    if eng == 1 then
        return ENG.dyn[1].is_fadec_pwrd == 1
    end

    if eng == 2 then
        return ENG.dyn[2].is_fadec_pwrd == 1
    end
end

local function update_XX_dr_eng(eng)
    -- This logic is insanely complex

    if fadec_has_elec_power(eng) then
        if start_elec_fadec[eng] == 0 then
            start_elec_fadec[eng] = get(TIME)
        end
        if manual_fadeec_on[eng] then
            xx_statuses[eng] = true
            return
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

    if (eng == 1 and ENG.dyn[1].n2 > 10) or (eng == 2 and ENG.dyn[2].n2 > 10) then
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
    xx_statuses[1] = xx_statuses[1] and (get(FAILURE_ENG_FADEC_CH1, 1) == 0 or get(FAILURE_ENG_FADEC_CH2, 1) == 0) and (get(Fire_pb_ENG1_status) == 0)
    update_XX_dr_eng(2)
    xx_statuses[2] = xx_statuses[2] and (get(FAILURE_ENG_FADEC_CH1, 2) == 0 or get(FAILURE_ENG_FADEC_CH2, 2) == 0) and (get(Fire_pb_ENG2_status) == 0)

    set(EWD_engine_1_XX, xx_statuses[1] and 0 or 1)
    set(EWD_engine_2_XX, xx_statuses[2] and 0 or 1)
end

local function update_pbs() 
    pb_set(PB.ovhd.mntn_fadec_1_pwr, manual_fadeec_on[1], false)
    pb_set(PB.ovhd.mntn_fadec_2_pwr, manual_fadeec_on[2], false)
end

function ecam_update_eng_page()

    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_oil_press = math.floor(ENG.dyn[1].oil_press)
        params.eng2_oil_press = math.floor(ENG.dyn[2].oil_press)
        params.eng1_oil_temp  = math.floor(ENG.dyn[1].oil_temp)
        params.eng2_oil_temp  = math.floor(ENG.dyn[2].oil_temp)
        params.eng1_vib_n1    = ENG.dyn[1].vib_n1
        params.eng1_vib_n2    = ENG.dyn[1].vib_n2
        params.eng2_vib_n1    = ENG.dyn[2].vib_n1
        params.eng2_vib_n2    = ENG.dyn[2].vib_n2
        params.last_update = get(TIME)
    end

    update_XX_dr()
    update_pbs()
end

