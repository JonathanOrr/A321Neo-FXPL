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
-- File: engines_debug.lua
-- Short description: Engine debug window
-------------------------------------------------------------------------------

size = {800, 700}

local image_engine = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/debug_uis/engine_scheme.png", 0, 0, 300, 200)
local image_turbine = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/debug_uis/engine_turbine.png", 0, 0, 64, 64)

local function draw_avail(eng)
    local offset = eng == 1 and 0 or 400

    local color = ENG.dyn[eng].is_avail and ECAM_GREEN or ECAM_RED
    local text = ENG.dyn[eng].is_avail and "AVAIL" or "NOT AVAIL"
    sasl.gl.drawText(Font_B612MONO_regular, offset+70, 630, text, 14, false, false, TEXT_ALIGN_CENTER, color)

    local color = ENG.dyn[eng].is_failed and ECAM_RED or ECAM_GREEN
    local text = ENG.dyn[eng].is_failed and "FAILED" or "NOT FAILED"
    sasl.gl.drawText(Font_B612MONO_regular, offset+200, 630, text, 14, false, false, TEXT_ALIGN_CENTER, color)


    local color = ENG.dyn[eng].is_fadec_pwrd and ECAM_GREEN or ECAM_RED
    local text = ENG.dyn[eng].is_fadec_pwrd and "FADEC PWRD" or "FADEC OFF"
    sasl.gl.drawText(Font_B612MONO_regular, offset+330, 630, text, 14, false, false, TEXT_ALIGN_CENTER, color)


end

local function draw_static()
    sasl.gl.drawText(Font_B612MONO_regular, 200, 670, "ENGINE 1 (L)", 28, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]-200, 670, "ENGINE 2 (R)", 28, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawLine(size[1]/2, 680, size[1]/2, 20, UI_WHITE)

    sasl.gl.drawTexture(image_engine, 50, 400, 300, 200, {1,1,1})
    sasl.gl.drawTexture(image_engine, 450, 400, 300, 200, {1,1,1})

    sasl.gl.drawText(Font_B612MONO_regular, 200, 270, "THRUST MODEL", 20, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]-200, 270, "THRUST MODEL", 20, false, false, TEXT_ALIGN_CENTER, UI_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 200, 125, "FADEC", 20, false, false, TEXT_ALIGN_CENTER, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, size[1]-200, 125, "FADEC", 20, false, false, TEXT_ALIGN_CENTER, UI_WHITE)

end

local function draw_img_data()
    sasl.gl.drawText(Font_B612MONO_regular, 263, 585, "FF=" .. Round_fill(ENG.dyn[1].ff,2) .. "KG/s", 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})
    sasl.gl.drawText(Font_B612MONO_regular, 663, 585, "FF=" .. Round_fill(ENG.dyn[2].ff,2) .. "KG/s", 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})

    sasl.gl.drawText(Font_B612MONO_regular, 60, 585, "FADEC Throttle=" .. Fwd_string_fill(""..math.floor(get(Override_eng_1_lever) * 100), " ", 3) .. "%", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)
    sasl.gl.drawText(Font_B612MONO_regular, 460, 585, "FADEC Throttle=" .. Fwd_string_fill(""..math.floor(get(Override_eng_2_lever) * 100), " ", 3) .. "%", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)

    sasl.gl.drawText(Font_B612MONO_regular, 300, 505, " EGT", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)
    sasl.gl.drawText(Font_B612MONO_regular, 300, 485, Fwd_string_fill(""..math.floor(ENG.dyn[1].egt), " ", 4) .. "°C", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)

    sasl.gl.drawText(Font_B612MONO_regular, 700, 505, " EGT", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)
    sasl.gl.drawText(Font_B612MONO_regular, 700, 485, Fwd_string_fill(""..math.floor(ENG.dyn[2].egt), " ", 4) .. "°C", 12, false, false, TEXT_ALIGN_LEFT, ECAM_BLACK)

    sasl.gl.drawWideLine(235, 565, 255, 545, 2, {.7,0,0})
    sasl.gl.drawText(Font_B612MONO_regular, 250, 555, "Firewall VLV", 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})
    local fw_status_text = ENG.dyn[1].firewall_valve == 1 and "CLOSED" or (ENG.dyn[1].firewall_valve == 0 and "OPEN" or "TRANSIT")
    sasl.gl.drawText(Font_B612MONO_regular, 260, 540, fw_status_text, 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})

    sasl.gl.drawWideLine(635, 565, 655, 545, 2, {.7,0,0})
    sasl.gl.drawText(Font_B612MONO_regular, 650, 555, "Firewall VLV", 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})
    local fw_status_text = ENG.dyn[2].firewall_valve == 1 and "CLOSED" or (ENG.dyn[2].firewall_valve == 0 and "OPEN" or "TRANSIT")
    sasl.gl.drawText(Font_B612MONO_regular, 660, 540, fw_status_text, 12, false, false, TEXT_ALIGN_LEFT, {.7,0,0})


end

local function draw_img_over(engine)
    local offset = engine == 1 and 0 or 400
    sasl.gl.drawWideLine(offset+130, 450, offset+130, 325, 2, {0,.6,.9})
    sasl.gl.drawWideLine(offset+130, 325, offset+250, 325, 2, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 315, "NFAN = " .. Fwd_string_fill(""..Round_fill(ENG.dyn[engine].nfan, 2), " ", 6) .. " %", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 300, "       " .. Fwd_string_fill(""..math.floor(ENG.dyn[engine].nfan * ENG.data.fan_n1_rpm_max / 100), " ", 4) .. " RPM", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})

    sasl.gl.drawWideLine(offset+180, 490, offset+180, 350, 2, {0,.6,.9})
    sasl.gl.drawWideLine(offset+180, 350, offset+250, 350, 2, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 345, "  N1 = " .. Fwd_string_fill(""..Round_fill(ENG.dyn[engine].n1, 2), " ", 6) .. " %", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 330, "       " .. Fwd_string_fill(""..math.floor(ENG.dyn[engine].n1 * ENG.data.fan_n1_rpm_max / 100), " ", 4) .. " RPM", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})

    sasl.gl.drawWideLine(offset+210, 490, offset+210, 380, 2, {0,.6,.9})
    sasl.gl.drawWideLine(offset+210, 380, offset+250, 380, 2, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 375, "  N2 = " .. Fwd_string_fill(""..Round_fill(ENG.dyn[engine].n2, 2), " ", 6) .. " %", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})
    sasl.gl.drawText(Font_B612MONO_regular, offset+260, 360, "       " .. Fwd_string_fill(""..math.floor(ENG.dyn[engine].n2 * ENG.data.fan_n1_rpm_max / 100), " ", 4) .. " RPM", 12, false, false, TEXT_ALIGN_LEFT, {0,.6,.9})

end

local function draw_turbine(eng)
    local offset = eng == 1 and 0 or 400
    local fan_angle = get(Eng_fan_angle, eng)
    sasl.gl.drawWideLine(offset+25+32, 390, offset+25+32, 500, 2, UI_WHITE)
    sasl.gl.drawWideLine(offset+25+32, 500, offset+25+90, 500, 2, UI_WHITE)
    sasl.gl.drawRotatedTexture(image_turbine, fan_angle, offset+25, 325, 64, 64, {1,1,1})
end

local function draw_thrust_model(eng)
    local offset = eng == 1 and 0 or 400
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 250, "Thrust Actual Total     = " .. Fwd_string_fill(Round_fill(ENG.model_state[eng].T_actual_spool/1000,1), " ", 5) .. " kN", 12, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 230, "   - Thrust Core        = " .. Fwd_string_fill(Round_fill(ENG.model_state[eng].T_core/1000,1), " ", 5) .. " kN", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 210, "   - Thrust Fan         = " .. Fwd_string_fill(Round_fill(ENG.model_state[eng].T_turbine/1000,1), " ", 5) .. " kN", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 190, "Thrust AI/Bleed Penalty = " .. Fwd_string_fill(Round_fill(ENG.model_state[eng].T_penalty_actual/1000,1), " ", 5) .. " kN", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 170, "Thrust Current Max      = " .. Fwd_string_fill(Round_fill(ENG.model_state[eng].T_max/1000,1), " ", 5) .. " kN" , 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 150, "Thrust Rated Max        = " .. Fwd_string_fill(Round_fill(ENG.data.max_thrust*4.44822/1000,1), " ", 5) .. " kN" , 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)
end

local function draw_fadec_section(eng)
    local offset = eng == 1 and 0 or 400
    -- 0: not visible, 1: TOGA, 2:MCT, 3:CLB, 4: IDLE, 5: MREV, 6: FLEX, 7: SOFT GA
    local text = ""
    if ENG.dyn[eng].n1_mode == 0 then
        text="N/A"
    elseif ENG.dyn[eng].n1_mode == 1 then
        text="TOGA"
    elseif ENG.dyn[eng].n1_mode == 2 then
        text="MCT"
    elseif ENG.dyn[eng].n1_mode == 3 then
        text="CLB"
    elseif ENG.dyn[eng].n1_mode == 4 then
        text="IDLE"
    elseif ENG.dyn[eng].n1_mode == 5 then
        text="MREV"
    elseif ENG.dyn[eng].n1_mode == 6 then
        text="FLEX"
    elseif ENG.dyn[eng].n1_mode == 7 then
        text="SOFT GA"
    else
        text="????"
    end

    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 110, "N1 Mode = " .. text, 12, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    sasl.gl.drawText(Font_B612MONO_regular, offset+200, 110, "N1 Idle = " .. Fwd_string_fill(""..Round_fill(ENG.dyn[eng].n1_idle, 1), " ", 5) .. " %", 12, false, false, TEXT_ALIGN_LEFT, UI_WHITE)

    local throttle = eng==1 and  get(Override_eng_1_lever) or get(Override_eng_2_lever)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 90, "Pilot Target N1 = " .. Fwd_string_fill(""..Round_fill(get(Throttle_blue_dot, eng), 1), " ", 5) .. " %", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 70, "A/T   Target N1 = " .. Fwd_string_fill(""..Round_fill(get(ATHR_desired_N1, eng), 1), " ", 5) .. " %", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, offset+10, 50, "FADEC Throttle  = " .. Fwd_string_fill(""..Round_fill(throttle*100, 1), " ", 5) .. " %", 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)


end

function draw()
    draw_static()
    draw_img_data()
    draw_img_over(1)
    draw_img_over(2)
    draw_turbine(1)
    draw_turbine(2)
    draw_avail(1)
    draw_avail(2)
    draw_thrust_model(1)
    draw_thrust_model(2)
    draw_fadec_section(1)
    draw_fadec_section(2)
end
