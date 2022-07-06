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
-- File: EWD.lua
-- Short description: Graphical file for EWD - It does not contain any logic
-------------------------------------------------------------------------------

position = {get(EWD_displaying_position, 1), get(EWD_displaying_position, 2), get(EWD_displaying_position, 3), get(EWD_displaying_position, 4)}
size = {900, 900}

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local PARAM_DELAY    = 0.1 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local MATCH_MSG_COLORS = { [0] = ECAM_WHITE, 
                           [1] = ECAM_RED,
                           [2] = ECAM_MAGENTA,
                           [3] = ECAM_ORANGE,
                           [4] = ECAM_GREEN,
                           [5] = ECAM_WHITE,
                           [6] = ECAM_BLUE,
                           [7] = ECAM_GREEN -- Blinking
                           }

local COLOR_FIXED_EL = ECAM_GREY

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
local last_params_update = 0
local params = {
    eng_n1 = {0, 0},
    eng1_n2 = 0,
    eng2_n2 = 0,
    eng_egt = {0, 0},
    eng1_ff = 0,
    eng2_ff = 0,
    last_update = 0
}

local eng_idle_start = 0  -- When the engines went to IDLE
local max_egt_overrun = { 0, 0 }
local max_n1_overrun = { 0, 0 }

-------------------------------------------------------------------------------
-- EWD - Helpers
-------------------------------------------------------------------------------
local function is_avail_box_shown(x)
    local thr_lever = x == 1 and get(Cockpit_throttle_lever_L) or get(Cockpit_throttle_lever_R)
    local avail_time = get(All_on_ground) == 1 and 10 or 60
    local thr_pos_cond = thr_lever <= 0.1
        
    return thr_pos_cond and get(EWD_engine_avail_ind_start, x) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_start, x) < avail_time
end

local function is_reverse_visible(x)
    local reverse_pos = x == 1 and get(Eng_1_reverser_deployment) or get(Eng_2_reverser_deployment)
    return reverse_pos > 0.01
end

local function get_reverse_color(x)
    local reverse_pos = x == 1 and get(Eng_1_reverser_deployment) or get(Eng_2_reverser_deployment)
    if get(EWD_flight_phase) >= PHASE_LIFTOFF and get(EWD_flight_phase) <= PHASE_FINAL then
        return ((math.floor(get(TIME)*2) % 2) == 1 and ECAM_RED or ECAM_ORANGE) -- Blink
    elseif reverse_pos > 0.98 then
        return ECAM_GREEN
    else
        return ECAM_ORANGE
    end
end


-------------------------------------------------------------------------------
-- EWD - Engines
-------------------------------------------------------------------------------
local function draw_arc_egt(x, y, red_angle, yellow_angle, current_angle, max_overrun_angle)

    -- Arc and other fixed stuffs
    sasl.gl.drawArc(x, y, 69, 72, 180-red_angle, red_angle, ECAM_WHITE)
    sasl.gl.drawWideLine(x-59, y, x-72, y, 2, ECAM_WHITE)
    sasl.gl.drawWideLine(x+59, y, x+72, y, 2, ECAM_RED)
    sasl.gl.drawWideLine(x, y+60, x, y+70, 2, ECAM_WHITE)

    -- Limits
    if red_angle and red_angle < 180 then
        sasl.gl.drawArc(x, y, 69, 72, 0, 180-red_angle, ECAM_RED)
    end

    if yellow_angle and yellow_angle < 180 then
        SASL_draw_needle_adv(x, y, 65, 74, 180-yellow_angle, 4, ECAM_ORANGE)
        SASL_draw_needle_adv(x, y, 73, 82, 180-yellow_angle-2, 10, ECAM_ORANGE)
    end

    -- Draw the needle
    local needle_color = ECAM_GREEN
    if red_angle and red_angle <= current_angle then
        needle_color = ECAM_RED
    elseif yellow_angle and yellow_angle <= current_angle then
        needle_color = ECAM_ORANGE
    end

    SASL_draw_needle_adv(x, y, 45, 80, 180-current_angle, 4, needle_color)
    if max_overrun_angle then
        SASL_draw_needle_adv(x, y, 55, 85, 180-max_overrun_angle, 4, ECAM_RED)
    end
end

local function draw_arc_egt_xx(x, y)

    -- Arc and other fixed stuffs
    sasl.gl.drawArc(x, y, 69, 72, 180, 0, ECAM_ORANGE)

    sasl.gl.drawText(Font_ECAMfont, x, y, "XX", 28, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
end

local function draw_engines_egt(x)
    local xx         = (x == 1 and get(EWD_engine_1_XX) or get(EWD_engine_2_XX)) == 1
    local avail      = ENG.dyn[x].is_avail
    local eng_mode = ENG.dyn[x].n1_mode
    local x_shift    = x == 1 and -215 or 125
    local x_shift_2  = x == 1 and -140 or 200
    local x_shift_3  = x == 1 and -170 or 170

    if xx then
        draw_arc_egt_xx(450+x_shift_3, 600)
        return
    end

    -- EGT
    local max_egt_scale = ENG.data.display.egt_scale
    local max_egt_red   = ENG.data.display.egt_red_limit
    local egt_yellow    = ENG.data.display.egt_amber_limit

    local egt_yellow_showed = avail and get(A_FLOOR_active) == 0 and (eng_mode == 3  or eng_mode == 4)
    local red_angle    = Math_rescale(0, 0, max_egt_scale, 180, max_egt_red)
    local yellow_angle = Math_rescale(0, 0, max_egt_scale, 180, egt_yellow)
    local curr_angle   = Math_rescale(0, 0, max_egt_scale, 180, params.eng_egt[x])
    local max_overrun_angle = max_egt_overrun[x]
    if max_overrun_angle == 0 then
        max_overrun_angle = nil
    end

    sasl.gl.drawMaskStart()
    sasl.gl.drawRectangle (size[1]/2+x_shift, size[2]/2+146, 80, 30, COLOR_FIXED_EL)
    sasl.gl.drawUnderMask(true)
    draw_arc_egt(450+x_shift_3, 600, red_angle, egt_yellow_showed and yellow_angle or nil, curr_angle, max_overrun_angle)
    sasl.gl.drawMaskEnd()

    local egt_color = params.eng_egt[x] > ENG.data.display.egt_red_limit and ECAM_RED or (egt_yellow_showed and params.eng_egt[x] > egt_yellow and ECAM_ORANGE or ECAM_GREEN)
    if egt_color == ECAM_RED then
        max_egt_overrun[x] = curr_angle
    elseif not avail and get(All_on_ground) == 1 then
        max_egt_overrun[x] = 0
    end
    sasl.gl.drawFrame (size[1]/2+x_shift, size[2]/2+146, 80, 33, COLOR_FIXED_EL)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+x_shift_2, size[2]/2+150, params.eng_egt[x], 28, true, false, TEXT_ALIGN_RIGHT, egt_color)

end

local function draw_arc_n1(x, y, red_angle, yellow_angle, current_angle, max_overrun_angle)

    local begin_value  = 15
    local length_arc = 215

    -- Arc and other fixed stuffs
    sasl.gl.drawArc(x, y, 73, 76, begin_value+red_angle, length_arc-red_angle, ECAM_WHITE)
    
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 20)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 50)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 60)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 70)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 80)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 90)+begin_value, 2, ECAM_WHITE)
    SASL_draw_needle_adv(x, y, 65, 73, Math_rescale(20, 205, 110, 0, 100)+begin_value, 2, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, x+35, y+25, "10", 20, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, x-47, y+17, "5", 20, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    
    -- Limits
    if red_angle and red_angle < 180 then
        sasl.gl.drawArc(x, y, 73, 76, begin_value, red_angle, ECAM_RED)
    end

    if yellow_angle and yellow_angle < 180 then
        SASL_draw_needle_adv(x, y, 65, 74, yellow_angle+begin_value, 4, ECAM_ORANGE)
        SASL_draw_needle_adv(x, y, 73, 82, yellow_angle+begin_value-2, 10, ECAM_ORANGE)
    end

    -- Draw the needle
    local needle_color = ECAM_GREEN
    if red_angle and red_angle > current_angle then
        needle_color = ECAM_RED
    elseif yellow_angle and yellow_angle > current_angle+0.1 then
        needle_color = ECAM_ORANGE
    end

    SASL_draw_needle_adv(x, y, 0, 85, current_angle+begin_value, 6, needle_color)
    if max_overrun_angle then
        SASL_draw_needle_adv(x, y, 55, 85, max_overrun_angle+begin_value, 4, ECAM_RED)
    end
end


local function draw_arc_n1_xx(x, y)

    -- Arc and other fixed stuffs
    sasl.gl.drawArc(x, y, 73, 76, 15, 210, ECAM_ORANGE)
end

local function draw_engines_draw_n1_upper_box(x, text, color)

    local lr_offset = (170+170) * (x-1)

    Sasl_DrawWideFrame(size[1]/2 - 195 + lr_offset, size[2]/2 + 305, 110, 35, 2, 0, ECAM_GREY)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2 - 140 + lr_offset, size[2]/2 + 310, text, 32, true, false, TEXT_ALIGN_CENTER, color)

end

local function draw_engines_draw_n1_lower_box(x, text, color, box_shown)

    local lr_offset = (170+170) * (x-1)
    if box_shown then
        Sasl_DrawWideFrame(size[1]/2 - 195 + lr_offset, size[2]/2 + 270, 110, 35, 2, 0, ECAM_GREY)
    end
    sasl.gl.drawText(Font_ECAMfont, size[1]/2 - 140 + lr_offset, size[2]/2 + 275, text, 32, true, false, TEXT_ALIGN_CENTER, color)

end

local function draw_blue_circle(i, blue_circle_angle)
    local lr_offset = (170+170) * (i-1)

    local angle_revisited = blue_circle_angle + 15

    local x = Get_rotated_point_x_pos(280+lr_offset, 84, angle_revisited)
    local y = Get_rotated_point_y_pos(775, 84, angle_revisited)

    sasl.gl.drawArc(x, y, 3, 6, 0, 360, ECAM_BLUE)

end

local function draw_athr_trend(i, curr_angle, target_angle)
    
    local begin_value = 15
    local x_shift_3  = i == 1 and -170 or 170
    
    sasl.gl.drawArc(450+x_shift_3, 775, 60, 64, target_angle+begin_value, curr_angle-target_angle, ECAM_GREEN)

    local coeff = target_angle > curr_angle and -1 or 1

    sasl.gl.drawArc(450+x_shift_3, 775, 42, 46, target_angle+begin_value-coeff*15, curr_angle-target_angle+coeff*15, ECAM_GREEN)
    sasl.gl.drawArc(450+x_shift_3, 775, 29, 33, target_angle+begin_value, curr_angle-target_angle, ECAM_GREEN)
    sasl.gl.drawArc(450+x_shift_3, 775, 14, 18, target_angle+begin_value, curr_angle-target_angle, ECAM_GREEN)

    SASL_draw_needle_adv(450+x_shift_3, 775, 0, 64, target_angle+begin_value, 4, ECAM_GREEN)
    SASL_draw_needle_adv(450+x_shift_3, 775, 0, 46, target_angle+begin_value-coeff*15, 4, ECAM_GREEN)
end

local function draw_engines_n1(x)
    local xx         = (x == 1 and get(EWD_engine_1_XX) or get(EWD_engine_2_XX)) == 1
    local avail      = ENG.dyn[x].is_avail
    local x_shift    = x == 1 and -215 or 125
    local x_shift_2  = x == 1 and -140 or 200
    local x_shift_3  = x == 1 and -170 or 170

    if xx then
        draw_arc_n1_xx(450+x_shift_3, 775)
        draw_engines_draw_n1_upper_box(x, "XX", ECAM_ORANGE)
        draw_engines_draw_n1_lower_box(x, "XX", ECAM_ORANGE, false)
        return
    end

    local athr_pos = get(ATHR_is_overriding) == 1 and get(ATHR_desired_N1, x) or math.min(get(Throttle_blue_dot, x), get(ATHR_desired_N1, x))

    local max_n1_scale = 110
    local max_n1_red   = ENG.data.display.n1_red_limit
    local red_angle    = Math_rescale(20, 205, max_n1_scale, 0, max_n1_red)
    local yellow_angle = Math_rescale(20, 205, max_n1_scale, 0, get(Eng_N1_max_detent_toga))
    local curr_angle   = Math_rescale(20, 205, max_n1_scale, 0, params.eng_n1[x])
    local athr_angle   = Math_rescale(20, 205, max_n1_scale, 0, get(ATHR_desired_N1, x))
    local blue_circle_angle = Math_rescale(20, 205, max_n1_scale, 0, get(Throttle_blue_dot, x))
    
    local max_overrun_angle = max_n1_overrun[x]
    if max_overrun_angle == 0 then
        max_overrun_angle = nil
    end

    draw_blue_circle(x, blue_circle_angle)
   
    sasl.gl.drawMaskStart()
    
    -- Mask contains the bottom N1 value background and the top for the AVAIL/Reverse
    local lr_offset = (170+170) * (x-1)
    if is_avail_box_shown(x) or is_reverse_visible(x) then
        sasl.gl.drawRectangle (size[1]/2 - 195 + lr_offset, size[2]/2 + 305, 110, 35, COLOR_FIXED_EL)
    end
    sasl.gl.drawRectangle (size[1]/2 - 195 + lr_offset, size[2]/2 + 270, 110, 35, COLOR_FIXED_EL)
    sasl.gl.drawUnderMask(true)

    -- Draw the arc
    draw_arc_n1(450+x_shift_3, 775, red_angle, yellow_angle, curr_angle, max_overrun_angle)
    -- Draw ath trend
    if get(ATHR_is_overriding) == 1 or get(ATHR_is_controlling) == 1 then
        draw_athr_trend(x, curr_angle, athr_angle)
    end
    sasl.gl.drawMaskEnd()
    
    -- REVERSE / AVAIL indication
    if is_reverse_visible(x) then
        draw_engines_draw_n1_upper_box(x, "REV", get_reverse_color(x))
    elseif is_avail_box_shown(x) then
        draw_engines_draw_n1_upper_box(x, "AVAIL", ECAM_GREEN)
    end

    -- Overrun symbol update
    local n1_color = red_angle > curr_angle and ECAM_RED or (yellow_angle > curr_angle+0.1 and ECAM_ORANGE or ECAM_GREEN)
    if n1_color == ECAM_RED then
        max_n1_overrun[x] = curr_angle
    elseif not avail and get(All_on_ground) == 1 then
        max_n1_overrun[x] = 0
    end

    -- N1 digits
    Sasl_DrawWideFrame(size[1]/2 - 195 + lr_offset, size[2]/2 + 270, 110, 35, 2, 0, ECAM_GREY)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+60+x_shift_3, size[2]/2+275, math.floor(params.eng_n1[x]) .. "." , 33, true, false, TEXT_ALIGN_RIGHT, n1_color)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2+75+x_shift_3, size[2]/2+275, math.floor((params.eng_n1[x]%1)*10)  , 26, true, false, TEXT_ALIGN_RIGHT, n1_color)

end

local function draw_engines_needles()

    draw_engines_egt(1)
    draw_engines_egt(2)
    draw_engines_n1(1)
    draw_engines_n1(2)

end


local function draw_engines_extra()

    -- N2 grey background box -- show as long ENG is starting up but not fully available
    if get(Engine_1_master_switch) == 1 and not ENG.dyn[1].is_avail and get(EWD_engine_1_XX) == 0 then
          sasl.gl.drawRectangle(size[1]/2-210, size[2]/2+70, 85, 32, ECAM_GREY)
    end
    if get(Engine_2_master_switch) == 1 and not ENG.dyn[2].is_avail and get(EWD_engine_2_XX) == 0 then
          sasl.gl.drawRectangle(size[1]/2+115, size[2]/2+70, 85, 32, ECAM_GREY)
    end

    if get(EWD_engine_1_XX) == 0 then
        --N2--
        local n2_color_1 = params.eng1_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-145, size[2]/2+75, math.floor(params.eng1_n2) .. "." , 33, true, false, TEXT_ALIGN_RIGHT, n2_color_1)
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-130, size[2]/2+75, math.floor((params.eng1_n2%1)*10) , 26, true, false, TEXT_ALIGN_RIGHT, n2_color_1)

        --FF--
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-130, size[2]/2+3, params.eng1_ff, 33, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, 280, size[2]/2+75, "XX", 33, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_ECAMfont, 280, size[2]/2+3,  "XX", 33, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end

    if get(EWD_engine_2_XX) == 0 then
        --N2--
        local n2_color_2 = params.eng2_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+180, size[2]/2+75, math.floor(params.eng2_n2) .. "." , 33, true, false, TEXT_ALIGN_RIGHT, n2_color_2)
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+195, size[2]/2+75, math.floor((params.eng2_n2%1)*10) , 26, true, false, TEXT_ALIGN_RIGHT, n2_color_2)

        --FF--
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+195, size[2]/2+3, params.eng2_ff, 33, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_ECAMfont, 620, size[2]/2+75, "XX", 33, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
        sasl.gl.drawText(Font_ECAMfont, 620, size[2]/2+3,  "XX", 33, true, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
    
    -- IDLE indication
    if eng_idle_start ~= 0 then
        color = ECAM_GREEN
        if get(TIME) - eng_idle_start < 10 then
            if (math.floor(get(TIME)*2)) % 2 == 1 then -- Blinking
                color = ECAM_HIGH_GREEN
            end
        end
        sasl.gl.drawText(Font_ECAMfont, size[1]/2, size[2]/2+380, "IDLE" , 33, true, false, TEXT_ALIGN_CENTER, color)        
    end
end


-------------------------------------------------------------------------------
-- EWD - Extra stuffs
-------------------------------------------------------------------------------

local function draw_coolings()
    if get(EWD_engine_cooling, 1) == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-410, size[2]/2+75, "COOLING" , 33, true, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        local min = math.floor(get(EWD_engine_cooling_time, 1) / 60)
        local sec = math.floor(get(EWD_engine_cooling_time, 1) % 60)
        if min < 10 then min = "0" .. min end
        if sec < 10 then sec = "0" .. sec end
        sasl.gl.drawText(Font_ECAMfont, size[1]/2-410, size[2]/2+40, min .. "'".. sec.. "\"" , 33, true, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    if get(EWD_engine_cooling, 2) == 1 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+410, size[2]/2+75, "COOLING" , 33, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        local min = math.floor(get(EWD_engine_cooling_time, 2) / 60)
        local sec = math.floor(get(EWD_engine_cooling_time, 2) % 60)
        if min < 10 then min = "0" .. min end
        if sec < 10 then sec = "0" .. sec end
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+410, size[2]/2+40, min .. "'".. sec.. "\"" , 33, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

end



local function draw_packs_wai_nai()
    if not ENG.dyn[1].is_avail and not ENG.dyn[2].is_avail then
        return
    end
    local max_eng_n1_mode = math.max(ENG.dyn[1].n1_mode, ENG.dyn[2].n1_mode) 
    
    -- PACKS / WAI / NAI indication
    if get(Any_wheel_on_ground) == 1 or max_eng_n1_mode < 3 or max_eng_n1_mode > 5 then
        local str = ""
        if get(Pack_L) == 1 or get(Pack_R) == 1 then
            str = "PACKS"
        end
        
        if AI_sys.switches[1] or AI_sys.switches[2] then
            if #str > 0 then
                str = str .. "/NAI"
            else
                str = "NAI"
            end    
        end
        
        if AI_sys.switches[3] then
            if #str > 0 then
                str = str .. "/WAI"
            else
                str = "WAI"
            end
        end
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+130, size[2]-35, str, 28, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

end

local function draw_extra_indication()
    draw_packs_wai_nai()

    -- A FLOOR
    if get(A_FLOOR_active) == 1 then
        sasl.gl.drawText(Font_ECAMfont, 30, size[2]-40, "A FLOOR", 32, true, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end

    local max_eng_n1_mode = math.min(ENG.dyn[1].n1_mode, ENG.dyn[2].n1_mode) 

    if max_eng_n1_mode == 0 then
        return
    end
    
    local displayed_mode = max_eng_n1_mode

    local n1_max = get(Eng_N1_max)
    
    if get(All_on_ground) == 1 and max_eng_n1_mode ~= 1 then
        if not ENG.dyn[1].is_avail and not ENG.dyn[1].is_avail then
            displayed_mode = 3 -- When engines OFF, the mode is CLB
            n1_max = get(Eng_N1_max_detent_clb)
        elseif get(Eng_N1_flex_temp) ~= 0 then
            displayed_mode = 6
            n1_max = get(Eng_N1_max_detent_flex)
        else
            displayed_mode = 1
            n1_max = get(Eng_N1_max_detent_toga)
        end
    end
    
    local mode_names = {"TOGA", "MCT", "CLB", "IDLE", "MREV", "FLEX", "GA SOFT"}

    sasl.gl.drawText(Font_ECAMfont, size[1]-80+6, size[2]-35+4, mode_names[displayed_mode], 33, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]-82+6, size[2]-70+4, math.floor(n1_max), 33, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]-50+6, size[2]-70+4,  "."..math.floor((n1_max%1)*10), 26, true, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_ECAMfont, size[1]-34+6, size[2]-70+4, "%", 26, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    if displayed_mode == 6 and get(Eng_N1_flex_temp) + 10 > get(OTA) then
        sasl.gl.drawText(Font_ECAMfont, size[1]-80, size[2]-100, math.floor(get(Eng_N1_flex_temp)) .. "°C", 26, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end    
end

local function draw_extras()

    -- STS BOX
    if get(EWD_box_sts) == 1 and get(EWD_arrow_overflow) == 0 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+88, size[2]/2-440, "STS", 30, true, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-442, 62, 28 , ECAM_WHITE)
    end 

    -- ADV BOX
    if get(EWD_box_adv) == 1 then
        local color = ECAM_WHITE

        -- Blinking the ADV box with a period of 2 seconds (1 second WHITE, 1 second gray)
        if math.floor(get(TIME)) % 2 == 0 then
            color = ECAM_GREY
        end
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+88, size[2]/2-165, "ADV", 30, true, false, TEXT_ALIGN_LEFT, color)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-167, 62, 28 , color)
    end

    -- overflow arrow
    if get(EWD_arrow_overflow) == 1 then
        sasl.gl.drawWideLine ( size[1]/2+118-4, size[2]/2-410 , size[1]/2+118-4 , size[2]/2-425 , 5 , ECAM_GREEN )
        sasl.gl.drawTriangle ( size[1]/2+106-4, size[2]/2-425 , size[1]/2+119-4 , size[2]/2-446 , size[1]/2+130-4, size[2]/2-425 , ECAM_GREEN )
    end
end

local function draw_fuel_stuffs()
    local fuel_on_board = math.floor(get(FOB))
    fuel_on_board = fuel_on_board - (fuel_on_board % 10)

    -- Check ECAM_fuel.lua to understand the following computation
    local not_all_fuel_available = (math.floor(get(Fuel_quantity[0])) > 0
                                    and (not Fuel_sys.tank_pump_and_xfr[5].status)
                                    and (not Fuel_sys.tank_pump_and_xfr[5].status) ) 
                                        or (get(FAILURE_FUEL, 7) == 1) or (get(FAILURE_FUEL, 8) == 1)

    color = ECAM_GREEN
    if get(FAILURE_FUEL_FQI_1_FAULT) == 1 and get(FAILURE_FUEL_FQI_2_FAULT) == 1  then
        fuel_on_board = "XX"
        color = ECAM_ORANGE
    end

    sasl.gl.drawText(Font_ECAMfont, 260, 326, fuel_on_board, 36, true, false, TEXT_ALIGN_RIGHT, color)
    if not_all_fuel_available then
        sasl.gl.drawWideLine(138, size[2]/2-125, 268, size[2]/2-125, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(138, size[2]/2-125, 138, size[2]/2-100, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(268, size[2]/2-125, 268, size[2]/2-100, 3 , ECAM_ORANGE)
    end
end

local function draw_slat_flap_legend()

    local slat_fail = not FCTL.SLAT_FLAP.STAT.SLAT.controlled and (get(All_on_ground) == 0 or (ENG.dyn[1].is_avail and ENG.dyn[2].is_avail))
    local flap_fail = not FCTL.SLAT_FLAP.STAT.FLAP.controlled and (get(All_on_ground) == 0 or (ENG.dyn[1].is_avail and ENG.dyn[2].is_avail))
    local slat_misaligned = false -- TODO if misaligned (and wingip brake)
    local flap_misaligned = false -- TODO if misaligned (and wingip brake)
    local a_lock = get(Slat_alpha_locked) == 1

    local slat_extra_text = slat_misaligned and " LOCKED" or ""
    local flap_extra_text = flap_misaligned and " LOCKED" or ""

    if get(Slats) > 0 or slat_fail or slat_misaligned then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+70, size[2]/2-70, "S" .. slat_extra_text, 30, true, false, TEXT_ALIGN_RIGHT, (slat_fail or slat_misaligned) and ECAM_ORANGE or ECAM_WHITE)
    end

    if get(Flaps_deployed_angle) > 0 or flap_fail or flap_misaligned then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+290, size[2]/2-70, "F" .. flap_extra_text, 30, true, false, TEXT_ALIGN_LEFT, (flap_fail or flap_misaligned) and ECAM_ORANGE or ECAM_WHITE)
    end

    if a_lock then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+75, size[2]/2-40, "A LOCK", 30, true, false, TEXT_ALIGN_LEFT, get(TIME) % 1 > 0.5 and ECAM_GREEN or ECAM_HIGH_GREEN)
    end

end

local function draw_slat_flap_indications()
    --make ecam slats or flaps indication yellow refer to FCOM 1.27.50 P6
    local slat_fail = not FCTL.SLAT_FLAP.STAT.SLAT.controlled and (get(All_on_ground) == 0 or (ENG.dyn[1].is_avail and ENG.dyn[2].is_avail))
    local flap_fail = not FCTL.SLAT_FLAP.STAT.FLAP.controlled and (get(All_on_ground) == 0 or (ENG.dyn[1].is_avail and ENG.dyn[2].is_avail))

    local slats_positions = { 0, 0.7, 0.7, 0.8, 0.8, 1 }
    local flaps_positions = { 0,   0,  10,  14,  21, 34}
    local slat_flap_configs = { "0", "1", "1+F", "2", "3", "FULL" }
    local slat_anim_ratio = {
        {0, 0},
        {0.7, 0.34},
        {0.8, 0.65},
        {1, 1}
    }
    local flaps_anim_ratio = {
        {0, 0},
        {10, 0.3},
        {14, 0.52},
        {21, 0.76},
        {34, 1}
    }

    --stop approximation--
    local rounded_slat_ratio = Round(get(Slats), 2)
    local rounded_flap_angle = Round(get(Flaps_deployed_angle), 2)

    local indication_text_cl = ECAM_GREEN
    if rounded_slat_ratio ~= slats_positions[get(Flaps_internal_config) + 1] or rounded_flap_angle ~= flaps_positions[get(Flaps_internal_config) + 1] then
        indication_text_cl = ECAM_BLUE
    else
        indication_text_cl = ECAM_GREEN
    end

    sasl.gl.drawTexture(EWD_wing_indic_img, size[1]/2 + 150, size[2]/2 - 73, 38, 21, ECAM_GREY)
    if get(Flaps_internal_config) > 0 or get(Slats) > 0 then
        sasl.gl.drawTexture(EWD_slat_tract_img, size[1]/2 + 15, size[2]/2 - 115, 94, 62, ECAM_WHITE)
    end
    if get(Flaps_internal_config) > 1 or get(Flaps_deployed_angle) > 0 then
        sasl.gl.drawTexture(EWD_flap_tract_img, size[1]/2 + 248, size[2]/2 - 115, 143, 63, ECAM_WHITE)
    end
    if rounded_slat_ratio ~= 0 or rounded_flap_angle ~= 0 then
        sasl.gl.drawText(Font_ECAMfont, size[1]/2+170, size[2]/2-120, slat_flap_configs[get(Flaps_internal_config) + 1], 34, true, false, TEXT_ALIGN_CENTER, indication_text_cl)
    end

    sasl.gl.setClipArea (size[1]/2 + 5, size[2]/2 - 122, 156, 71)
    sasl.gl.drawTexture(EWD_slat_img, size[1]/2+Math_rescale(0, 121, 1, 5, Table_interpolate(slat_anim_ratio, get(Slats))), size[2]/2-Math_rescale(0, 81, 1, 122, Table_interpolate(slat_anim_ratio, get(Slats))), 156, 71, slat_fail and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.resetClipArea ()
    sasl.gl.setClipArea (size[1]/2 + 178, size[2]/2 - 120, 219, 69)
    sasl.gl.drawTexture(EWD_flap_img, size[1]/2+Math_rescale(0, -8, 1, 178, Table_interpolate(flaps_anim_ratio, get(Flaps_deployed_angle))), size[2]/2-Math_rescale(0, 78, 1, 120, Table_interpolate(flaps_anim_ratio, get(Flaps_deployed_angle))), 219, 69, flap_fail and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.resetClipArea ()

    if rounded_slat_ratio ~= slats_positions[get(Flaps_internal_config) + 1] then
        SASL_drawSegmentedImg(EWD_slat_to_go_img, size[1]/2 + 12, size[2]/2 - 134, 2262, 63, 6, get(Flaps_internal_config) + 1)
    end
    if rounded_flap_angle ~= flaps_positions[get(Flaps_internal_config) + 1] then
        SASL_drawSegmentedImg(EWD_flap_to_go_img, size[1]/2 + 15, size[2]/2 - 134, 2262, 63, 6, get(Flaps_internal_config) + 1)
    end
    
    draw_slat_flap_legend()
end


-------------------------------------------------------------------------------
-- EWD - Memos
-------------------------------------------------------------------------------

local function draw_left_memo()
    local distance = 35

    for i=0,6 do
        if get(EWD_left_memo_group_colors[i]) > 0 then
            local color_id = get(EWD_left_memo_group_colors[i]) 
            sasl.gl.drawText(Font_ECAMfont, size[1]/2-439, size[2]/2-197-distance*i, get(EWD_left_memo_group[i]), 31, true, false, TEXT_ALIGN_LEFT, MATCH_MSG_COLORS[color_id])

            -- Print the underline
            width, height = sasl.gl.measureText(Font_ECAMfont, get(EWD_left_memo_group[i]), 31, true, false)
            if width > 0 then
                sasl.gl.drawWideLine(size[1]/2-439 + 1, size[2]/2-197-distance*i - 2, size[1]/2-439 + width + 2, size[2]/2-197-distance*i - 2, 1.5, MATCH_MSG_COLORS[color_id])
            end
        end

        if get(EWD_left_memo_colors[i]) > 0 then
            local color_id = get(EWD_left_memo_colors[i])
            sasl.gl.drawText(Font_ECAMfont, size[1]/2-439, size[2]/2-197-distance*i, get(EWD_left_memo[i]), 31, true, false, TEXT_ALIGN_LEFT, MATCH_MSG_COLORS[color_id])
        end
    end

end

local function draw_right_memo()
    local distance = 34

    for i=0,6 do
        if get(EWD_right_memo_colors[i]) > 0 then
            if get(EWD_right_memo_colors[i]) ~= 7 or get(TIME) % 2 > 1 then -- If color is COL_INDICATION_BLINKING we blink for 1 second every 2 seconds.
                local color_id = get(EWD_right_memo_colors[i])
                sasl.gl.drawText(Font_ECAMfont, size[1]/2+160, size[2]/2-197-distance*i, get(EWD_right_memo[i]), 31, true, false, TEXT_ALIGN_LEFT, MATCH_MSG_COLORS[color_id])
            else
                sasl.gl.drawText(Font_ECAMfont, size[1]/2+160, size[2]/2-197-distance*i, get(EWD_right_memo[i]), 31, true, false, TEXT_ALIGN_LEFT, ECAM_HIGH_GREEN)
            end
        end
    end
end

-------------------------------------------------------------------------------
-- EWD - Fixed things
-------------------------------------------------------------------------------
local function draw_fixed_objects()

    -- Horizontal left line memos
    sasl.gl.drawWideLine(10, 293, size[2]-375, 293, 3, COLOR_FIXED_EL)

    -- Horizontal right line memos
    sasl.gl.drawWideLine(size[2]-290, 293, size[2]-20, 293, 3, COLOR_FIXED_EL)

    -- Vertical right line memos
    sasl.gl.drawWideLine(size[2]-336, 270, size[2]-336, 40, 3, COLOR_FIXED_EL)

    -- N2 diagonals
    sasl.gl.drawWideLine(365, 535, 405, 545, 2, COLOR_FIXED_EL)
    sasl.gl.drawWideLine(size[2]-365, 535, size[2]-405, 545, 2, COLOR_FIXED_EL)

    -- FF diagonals
    sasl.gl.drawWideLine(365, 465, 405, 475, 2, COLOR_FIXED_EL)
    sasl.gl.drawWideLine(size[2]-365, 465, size[2]-405, 475, 2, COLOR_FIXED_EL)

    -- Fixed text
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 750, "N1", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 625, "EGT", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 535, "N2", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 465, "FF", 32, true, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 725, "%", 25, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 600, "°C", 25, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 505, "%", 25, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_ECAMfont, size[1]/2, 440, "KG/H", 25, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    sasl.gl.drawText(Font_ECAMfont, 15, 326, "FOB :", 34, true, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_ECAMfont, 299, 328, "KG", 25, true, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

end

-------------------------------------------------------------------------------
-- Main functions
-------------------------------------------------------------------------------

local function draw_ewd()
    draw_fixed_objects()
    draw_extra_indication()
    if ENG.data_is_loaded then
        draw_engines_needles()
        draw_engines_extra()
    end

    draw_left_memo()
    draw_right_memo()
    draw_extras()
    draw_fuel_stuffs()
    draw_coolings()
    draw_slat_flap_indications()
end

local skip_1st_frame_AA = true

function draw()
    if not skip_1st_frame_AA then
        sasl.gl.setRenderTarget(EWD_popup_texture, true, get(PANEL_AA_LEVEL_1to32))
    else
        sasl.gl.setRenderTarget(EWD_popup_texture, true)
    end
    skip_1st_frame_AA = false
    draw_ewd()
    sasl.gl.restoreRenderTarget()

    sasl.gl.drawTexture(EWD_popup_texture, 0, 0, 900, 900, {1,1,1})
end


function update()
    position = {get(EWD_displaying_position, 1), get(EWD_displaying_position, 2), get(EWD_displaying_position, 3), get(EWD_displaying_position, 4)}

    -- Update the parameter every PARAM_DELAY seconds
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng_n1[1] = ENG.dyn[1].n1
        params.eng_n1[2] = ENG.dyn[2].n1
        params.eng1_n2 = ENG.dyn[1].n2
        params.eng2_n2 = ENG.dyn[2].n2
        if params.eng_n1[1] < 5 then params.eng_n1[1] = 0 end
        if params.eng_n1[2] < 5 then params.eng_n1[2] = 0 end

        params.eng_egt[1] = math.floor(ENG.dyn[1].egt)
        params.eng_egt[2] = math.floor(ENG.dyn[2].egt)

        params.eng1_ff = math.floor(ENG.dyn[1].ff*360)*10
        params.eng2_ff = math.floor(ENG.dyn[2].ff*360)*10


        params.last_update = get(TIME)
    end

    if params.eng_n1[1] < ENG.dyn[1].n1_idle + 2 and params.eng_n1[2] < ENG.dyn[2].n1_idle + 2 and get(Any_wheel_on_ground) == 0 then
        if eng_idle_start == 0 then
            eng_idle_start = get(TIME)
        end
    else
        eng_idle_start = 0
    end

end

