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

position= {30,2226,900,900}
size = {900, 900}

include('constants.lua')
include('display_common.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)
local last_params_update = 0

local params = {
    eng1_n1 = 0,
    eng2_n1 = 0,
    eng1_n2 = 0,
    eng2_n2 = 0,
    eng1_egt = 0,
    eng2_egt = 0,
    eng1_ff = 0,
    eng2_ff = 0,
    last_update = 0
}

local eng_idle_start = 0  -- When the engines went to IDLE

local match_msg_colors = {}
match_msg_colors[0] = ECAM_WHITE
match_msg_colors[1] = ECAM_RED
match_msg_colors[2] = ECAM_MAGENTA
match_msg_colors[3] = ECAM_ORANGE
match_msg_colors[4] = ECAM_GREEN
match_msg_colors[5] = ECAM_WHITE
match_msg_colors[6] = ECAM_BLUE
match_msg_colors[7] = ECAM_GREEN -- Blinking

local time_blinking = sasl.createTimer()
sasl.startTimer(time_blinking)

function Draw_reverse_indication()
    -- ENG1 Reverse
    if get(Eng_1_reverser_deployment) > 0.01 then
        Draw_LCD_backlight(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 2, 0, ECAM_LINE_GREY)
        if get(EWD_flight_phase) >= 5 and get(EWD_flight_phase) <= 7 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - 142, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, (math.floor(get(TIME)*2) % 2) == 1 and ECAM_RED or ECAM_ORANGE )-- Blink
        elseif get(Eng_1_reverser_deployment) > 0.98 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - 142, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)-- Green
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - 142, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)-- Amber
        end
    end

    -- ENG2 Reverse    
    if get(Eng_2_reverser_deployment) > 0.01 then
        Draw_LCD_backlight(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 2, 0, ECAM_LINE_GREY)
        if get(EWD_flight_phase) >= 5 and get(EWD_flight_phase) <= 7 then
            -- Blink
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + 208, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, (math.floor(get(TIME)*2) % 2) == 1 and ECAM_RED or ECAM_ORANGE )-- Blink
        elseif get(Eng_2_reverser_deployment) > 0.98 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + 208, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)-- Green
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + 208, size[2]/2 + 315, "REV", 30, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)-- Amber
        end
    end
end

function update()

    -- Update the parameter every PARAM_DELAY seconds
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.eng1_n1 = get(Eng_1_N1)
        params.eng2_n1 = get(Eng_2_N1)
        params.eng1_n2 = get(Eng_1_N2)
        params.eng2_n2 = get(Eng_2_N2)
        if params.eng1_n1 < 5 then params.eng1_n1 = 0 end
        if params.eng2_n1 < 5 then params.eng2_n1 = 0 end

        params.eng1_egt = math.floor(get(Eng_1_EGT_c))
        params.eng2_egt = math.floor(get(Eng_2_EGT_c))

        params.eng1_ff = math.floor(get(Eng_1_FF_kgs)*360)*10
        params.eng2_ff = math.floor(get(Eng_2_FF_kgs)*360)*10


        params.last_update = get(TIME)
    end

    if params.eng1_n1 < get(Eng_N1_idle) + 2 and params.eng2_n1 < get(Eng_N1_idle) + 2 and get(Any_wheel_on_ground) == 0 then
        if eng_idle_start == 0 then
            eng_idle_start = get(TIME)
        end
    else
        eng_idle_start = 0
    end

end


function Draw_extra_indication()

    if get(EWD_flight_phase) == PHASE_1ST_ENG_ON and (get(Pack_L) == 1 or get(Pack_R) == 1) then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+70, size[2]-30, "PACKS", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    -- A FLOOR
    if true then    -- TODO Jon please add here a condition
        sasl.gl.drawText(Font_AirbusDUL, 30, size[2]-40, "A FLOOR", 32, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end

    if get(Eng_N1_mode) == 0 then
        return
    end
    mode_names = {"TOGA", "MCT", "CLB", "IDLE", "MREV", "FLEX", "GA SOFT"}

    local n1_max = get(Eng_N1_max)
    --draw needle limits--
    if get(L_sim_throttle) < 0 then
        SASL_draw_needle_adv(size[1]/2 - 175, size[2]/2 + 333, 68, 85, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_N1_max_detent_toga) * 0.7), 6, ECAM_ORANGE)
    else
        SASL_draw_needle_adv(size[1]/2 - 175, size[2]/2 + 333, 68, 85, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_N1_max_detent_toga)), 6, ECAM_ORANGE)
    end
    if get(R_sim_throttle) < 0 then
        SASL_draw_needle_adv(size[1]/2 + 175, size[2]/2 + 333, 68, 85, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_N1_max_detent_toga) * 0.7), 6, ECAM_ORANGE)
    else
        SASL_draw_needle_adv(size[1]/2 + 175, size[2]/2 + 333, 68, 85, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_N1_max_detent_toga)), 6, ECAM_ORANGE)
    end

    --draw blue dots
    sasl.gl.drawRotatedTextureCenter ( EWD_req_thrust_img, Math_rescale_lim_lower(20, -132, 100, 42, get(L_throttle_blue_dot)), size[1]/2 - 175, size[2]/2 + 333, size[1]/2 - 184, size[2]/2 + 331, 18, 97, {1, 1, 1})
    sasl.gl.drawRotatedTextureCenter ( EWD_req_thrust_img, Math_rescale_lim_lower(20, -132, 100, 42, get(R_throttle_blue_dot)), size[1]/2 + 175, size[2]/2 + 333, size[1]/2 + 166, size[2]/2 + 331, 18, 97, {1, 1, 1})

    sasl.gl.drawText(Font_AirbusDUL, size[1]-80, size[2]-30, mode_names[get(Eng_N1_mode)], 32, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-65, size[2]-55, math.floor(n1_max) .. ".", 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-50, size[2]-55, math.floor((n1_max%1)*10), 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-35, size[2]-55, "%", 24, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    if get(Eng_N1_mode) == 6 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-80, size[2]-80, math.floor(get(Eng_N1_flex_temp)) .. "°C", 24, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    end    
end

function Draw_engines_needles()
    -----------TODO-----------
    --[[amber blicking of the N1 needle when N1 exceeds amber limit
    show trends only when AT is engaged]]

    --define a few properties that showed frequently
    local eng_1_needle_x = size[1]/2 - 175
    local eng_2_needle_x = size[1]/2 + 175
    local eng_1_n1_needle_y = size[2]/2 + 333
    local eng_2_n1_needle_y = size[2]/2 + 333
    local eng_1_n1_needle_cl = ECAM_GREEN
    local eng_2_n1_needle_cl = ECAM_GREEN
    local eng_1_egt_needle_y = size[2]/2 + 156
    local eng_2_egt_needle_y = size[2]/2 + 156
    local eng_1_egt_needle_cl = ECAM_GREEN
    local eng_2_egt_needle_cl = ECAM_GREEN

    --draw trends and needles
    --eng 2 N1

    if get(EWD_engine_1_XX) == 1 then
        Draw_LCD_backlight(size[1]/2 - 265, size[2]/2 - 35, 180, 450, 0.5, 1, get(EWD_brightness_act))
        sasl.gl.drawTexture(EWD_engine_xx_img, size[1]/2 - 280, size[2]/2 - 35, 210, 480, {1, 1, 1})
    end
    if get(EWD_engine_2_XX) == 1 then
        Draw_LCD_backlight(size[1]/2 + 85, size[2]/2 - 35, 180, 450, 0.5, 1, get(EWD_brightness_act))
        sasl.gl.drawTexture(EWD_engine_xx_img, size[1]/2 + 70, size[2]/2 - 35, 210, 480, {1, 1, 1})
    end

    if get(EWD_engine_1_XX) == 0 then
        SASL_draw_needle(eng_1_needle_x, eng_1_n1_needle_y, 88, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), 4, eng_1_n1_needle_cl)
        if get(L_throttle_blue_dot) - get(Eng_1_N1) <= -4 or get(L_throttle_blue_dot) - get(Eng_1_N1) >= 4 then
            SASL_draw_needle(eng_1_needle_x, eng_1_n1_needle_y, 64, Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)), 3, eng_1_n1_needle_cl)
            sasl.gl.drawArc(eng_1_needle_x, eng_1_n1_needle_y, 62, 65, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), eng_1_n1_needle_cl)
            sasl.gl.drawArc(eng_1_needle_x, eng_1_n1_needle_y, 47, 50, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), eng_1_n1_needle_cl)
            sasl.gl.drawArc(eng_1_needle_x, eng_1_n1_needle_y, 32, 35, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), eng_1_n1_needle_cl)
            sasl.gl.drawArc(eng_1_needle_x, eng_1_n1_needle_y, 17, 20, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_1_N1)), eng_1_n1_needle_cl)
        end
        if get(L_throttle_blue_dot) - get(Eng_1_N1) <= -4 then
            SASL_draw_needle(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) + 20, 3, eng_1_n1_needle_cl)
            sasl.gl.drawWideLine(
                Get_rotated_point_x_pos(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) + 20),
                Get_rotated_point_y_pos(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) + 20),
                Get_rotated_point_x_pos(eng_1_needle_x, eng_1_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot))),
                Get_rotated_point_y_pos(eng_1_needle_x, eng_1_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot))),
                3,
                eng_1_n1_needle_cl
            )
        elseif get(L_throttle_blue_dot) - get(Eng_1_N1) >= 4 then
            SASL_draw_needle(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - 20, 3, eng_1_n1_needle_cl)
            sasl.gl.drawWideLine(
                Get_rotated_point_x_pos(eng_1_needle_x, eng_1_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot))),
                Get_rotated_point_y_pos(eng_1_needle_x, eng_1_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot))),
                Get_rotated_point_x_pos(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - 20),
                Get_rotated_point_y_pos(eng_1_needle_x, eng_1_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(L_throttle_blue_dot)) - 20),
                3,
                eng_1_n1_needle_cl
            )
        end
    end

    --eng 2 N1
    if get(EWD_engine_2_XX) == 0 then
        SASL_draw_needle(eng_2_needle_x, eng_2_n1_needle_y, 88, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), 4, eng_2_n1_needle_cl)
        if get(R_throttle_blue_dot) - get(Eng_2_N1) <= -4  or get(R_throttle_blue_dot) - get(Eng_2_N1) >= 4 then
            SASL_draw_needle(eng_2_needle_x, eng_2_n1_needle_y, 64, Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)), 3, eng_2_n1_needle_cl)
            sasl.gl.drawArc(eng_2_needle_x, eng_2_n1_needle_y, 62, 65, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), eng_2_n1_needle_cl)
            sasl.gl.drawArc(eng_2_needle_x, eng_2_n1_needle_y, 47, 50, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), eng_2_n1_needle_cl)
            sasl.gl.drawArc(eng_2_needle_x, eng_2_n1_needle_y, 32, 35, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), eng_2_n1_needle_cl)
            sasl.gl.drawArc(eng_2_needle_x, eng_2_n1_needle_y, 17, 20, Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - Math_rescale_lim_lower(20, 222, 100, 48, get(Eng_2_N1)), eng_2_n1_needle_cl)
        end
        if get(R_throttle_blue_dot) - get(Eng_2_N1) <= -4 then
            SASL_draw_needle(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) + 20, 3, eng_2_n1_needle_cl)
            sasl.gl.drawWideLine(
                Get_rotated_point_x_pos(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) + 20),
                Get_rotated_point_y_pos(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) + 20),
                Get_rotated_point_x_pos(eng_2_needle_x, eng_2_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot))),
                Get_rotated_point_y_pos(eng_2_needle_x, eng_2_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot))),
                3,
                eng_1_n1_needle_cl
            )
        elseif get(R_throttle_blue_dot) - get(Eng_2_N1) >= 4 then
            SASL_draw_needle(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - 20, 3, eng_2_n1_needle_cl)
            sasl.gl.drawWideLine(
                Get_rotated_point_x_pos(eng_2_needle_x, eng_2_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot))),
                Get_rotated_point_y_pos(eng_2_needle_x, eng_2_n1_needle_y, 48, Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot))),
                Get_rotated_point_x_pos(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - 20),
                Get_rotated_point_y_pos(eng_2_needle_x, eng_2_n1_needle_y, 48 / math.cos(math.rad(20)), Math_rescale_lim_lower(20, 222, 100, 48, get(R_throttle_blue_dot)) - 20),
                3,
                eng_1_n1_needle_cl
            )
        end
    end

    if get(EWD_engine_1_XX) == 0 then
        --eng 1 egt--
        SASL_draw_needle_adv(eng_1_needle_x, eng_1_egt_needle_y, 48, 78, Math_rescale_lim_lower(0, 180, 1000, 55, get(Eng_1_EGT_c)), 4, eng_1_egt_needle_cl)
    end
    if get(EWD_engine_2_XX) == 0 then
        --eng 2 egt
        SASL_draw_needle_adv(eng_2_needle_x, eng_2_egt_needle_y, 48, 78, Math_rescale_lim_lower(0, 180, 1000, 55, get(Eng_2_EGT_c)), 4, eng_2_egt_needle_cl)
    end
end

function Draw_engines()

    -- N2 background box --
    if get(Engine_1_master_switch) == 1 and get(Engine_1_avail) == 0 and get(EWD_engine_1_XX) == 0 then
          sasl.gl.drawRectangle(size[1]/2-210, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end
    if get(Engine_2_master_switch) == 1 and get(Engine_2_avail) == 0 and get(EWD_engine_2_XX) == 0 then
          sasl.gl.drawRectangle(size[1]/2+115, size[2]/2+70, 85, 32, {0.2,0.2,0.2})
    end

    if get(EWD_engine_1_XX) == 0 then
        --N1-- -- TODO COLORS
        Draw_LCD_backlight(size[1]/2 - 195, size[2]/2 + 275, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 - 195, size[2]/2 + 275, 100, 35, 2, 0, ECAM_LINE_GREY)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, size[2]/2+280, math.floor(params.eng1_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-100, size[2]/2+280, math.floor((params.eng1_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        --EGT--
        local egt_color_1 = params.eng1_egt > 1050 and ECAM_RED or (params.eng1_egt > 1000 and ECAM_ORANGE or ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-140, size[2]/2+150, params.eng1_egt, 28, false, false, TEXT_ALIGN_RIGHT, egt_color_1)

        --N2--
        local n2_color_1 = params.eng1_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-145, size[2]/2+75, math.floor(params.eng1_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, n2_color_1)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+75, math.floor((params.eng1_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, n2_color_1)

        --FF--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2+3, params.eng1_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

    if get(EWD_engine_2_XX) == 0 then
        --N1-- -- TODO COLORS
        Draw_LCD_backlight(size[1]/2 + 155, size[2]/2 + 275, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 + 155, size[2]/2 + 275, 100, 35, 2, 0, ECAM_LINE_GREY)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+235, size[2]/2+280, math.floor(params.eng2_n1) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+280, math.floor((params.eng2_n1%1)*10)  , 24, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        --EGT--
        local egt_color_2 = params.eng2_egt > 1050 and ECAM_RED or (params.eng2_egt > 1000 and ECAM_ORANGE or ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+210, size[2]/2+150, params.eng2_egt, 28, false, false, TEXT_ALIGN_RIGHT, egt_color_2)

        --N2--
        local n2_color_2 = params.eng2_n2 > 117 and ECAM_RED or ECAM_GREEN
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+180, size[2]/2+75, math.floor(params.eng2_n2) .. "." , 30, false, false, TEXT_ALIGN_RIGHT, n2_color_2)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+75, math.floor((params.eng2_n2%1)*10) , 24, false, false, TEXT_ALIGN_RIGHT, n2_color_2)

        --FF--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+195, size[2]/2+3, params.eng2_ff, 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end


    -- AVAIL box --
    if get(EWD_engine_avail_ind_1_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_1_start) < 10 then
        Draw_LCD_backlight(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 - 195, size[2]/2 + 310, 100, 35, 2, 0, ECAM_LINE_GREY)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2 - 142, size[2]/2 + 315, "AVAIL", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    if get(EWD_engine_avail_ind_2_start) ~= 0 and get(TIME) - get(EWD_engine_avail_ind_2_start) < 10 then
        Draw_LCD_backlight(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 0.5, 1, get(EWD_brightness_act))
        Sasl_DrawWideFrame(size[1]/2 + 155, size[2]/2 + 310, 100, 35, 2, 0, ECAM_LINE_GREY)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2 + 208, size[2]/2 + 315, "AVAIL", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    end

    -- IDLE indication
    if eng_idle_start ~= 0 then
        color = ECAM_GREEN
        if get(TIME) - eng_idle_start < 10 then
            if (math.floor(get(TIME)*2)) % 2 == 1 then -- Blinking
                color = ECAM_HIGH_GREEN
            end
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2+380, "IDLE" , 30, false, false, TEXT_ALIGN_CENTER, color)        
    end
end


function Draw_coolings()
    if get(EWD_engine_cooling, 1) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-410, size[2]/2+75, "COOLING" , 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        local min = math.floor(get(EWD_engine_cooling_time, 1) / 60)
        local sec = math.floor(get(EWD_engine_cooling_time, 1) % 60)
        if min < 10 then min = "0" .. min end
        if sec < 10 then sec = "0" .. sec end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-410, size[2]/2+40, min .. "'".. sec.. "\"" , 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    if get(EWD_engine_cooling, 2) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+410, size[2]/2+75, "COOLING" , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        local min = math.floor(get(EWD_engine_cooling_time, 2) / 60)
        local sec = math.floor(get(EWD_engine_cooling_time, 2) % 60)
        if min < 10 then min = "0" .. min end
        if sec < 10 then sec = "0" .. sec end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+410, size[2]/2+40, min .. "'".. sec.. "\"" , 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

end


function Draw_left_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_left_memo_group_colors[i]) > 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo_group[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_group_colors[i])])

            -- Print the underline
            width, height = sasl.gl.measureText(Font_AirbusDUL, get(EWD_left_memo_group[i]), 30, false, false)
            if width > 0 then
                sasl.gl.drawWideLine(size[1]/2-430 + 1, size[2]/2-200-distance*i - 5, size[1]/2-430 + width + 2, size[2]/2-200-distance*i - 5, 3, match_msg_colors[get(EWD_left_memo_group_colors[i])])
            end
        end

        if get(EWD_left_memo_colors[i]) > 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-430, size[2]/2-200-distance*i, get(EWD_left_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_left_memo_colors[i])])
        end
    end

end

function Draw_right_memo()
    local distance = 38

    for i=0,6 do
        if get(EWD_right_memo_colors[i]) > 0 then
            if get(EWD_right_memo_colors[i]) ~= 7 or get(TIME) % 2 > 1 then -- If color is COL_INDICATION_BLINKING we blink for 1 second every 2 seconds.
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2+160, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, match_msg_colors[get(EWD_right_memo_colors[i])])
            else
                sasl.gl.drawText(Font_AirbusDUL, size[1]/2+160, size[2]/2-200-distance*i, get(EWD_right_memo[i]), 30, false, false, TEXT_ALIGN_LEFT, ECAM_HIGH_GREEN)            
            end
        end
    end
end

function Draw_extras()

    -- STS BOX
    if get(EWD_box_sts) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+88, size[2]/2-440, "STS", 30, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-442, 62, 28 , ECAM_WHITE)
    end 

    -- ADV BOX
    if get(EWD_box_adv) == 1 then
        local color = ECAM_WHITE

        -- Blinking the ADV box with a period of 2 seconds (1 second WHITE, 1 second gray)
        if math.floor(sasl.getElapsedSeconds(time_blinking)) % 2 == 0 then
            color = ECAM_HIGH_GREY
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+88, size[2]/2-165, "ADV", 30, false, false, TEXT_ALIGN_LEFT, color)    
        sasl.gl.drawFrame ( size[1]/2+87, size[2]/2-167, 62, 28 , color)
    end

    -- overflow arrow (this is not visible if STS box is visible)
    if get(EWD_box_sts) == 0 and get(EWD_arrow_overflow) == 1 then
        sasl.gl.drawWideLine ( size[1]/2+118, size[2]/2-410 , size[1]/2+118 , size[2]/2-425 , 5 , ECAM_GREEN )
        sasl.gl.drawTriangle ( size[1]/2+106, size[2]/2-425 , size[1]/2+119 , size[2]/2-446 , size[1]/2+130, size[2]/2-425 , ECAM_GREEN )
    end
end

function Draw_fuel_stuffs()
    local fuel_on_board = math.floor(get(FOB))

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

    sasl.gl.drawText(Font_AirbusDUL, 240, size[2]/2-120, fuel_on_board, 36, false, false, TEXT_ALIGN_RIGHT, color)
    if not_all_fuel_available then
        sasl.gl.drawWideLine(120, size[2]/2-125, 250, size[2]/2-125, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(120, size[2]/2-125, 120, size[2]/2-100, 3 , ECAM_ORANGE)
        sasl.gl.drawWideLine(250, size[2]/2-125, 250, size[2]/2-100, 3 , ECAM_ORANGE)
    end
end

function Draw_slat_flap_indications()
    local slats_positions = {
        0,
        0.7,
        0.7,
        0.8,
        0.8,
        1
    }
    local flaps_positions = {
        0,
        0,
        10,
        14,
        21,
        25
    }
    local slat_flap_configs = {
        "0",
        "1",
        "1+F",
        "2",
        "3",
        "FULL"
    }
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
        {25, 1}
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

    sasl.gl.drawTexture(EWD_wing_indic_img, size[1]/2 + 150, size[2]/2 - 73, 38, 21, ECAM_LINE_GREY)
    if get(Flaps_internal_config) > 0 or get(Slats) > 0 then
        sasl.gl.drawTexture(EWD_slat_tract_img, size[1]/2 + 15, size[2]/2 - 115, 94, 62, ECAM_WHITE)
    end
    if get(Flaps_internal_config) > 1 or get(Flaps_deployed_angle) > 0 then
        sasl.gl.drawTexture(EWD_flap_tract_img, size[1]/2 + 248, size[2]/2 - 115, 143, 63, ECAM_WHITE)
    end
    if rounded_slat_ratio ~= 0 or rounded_flap_angle ~= 0 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+170, size[2]/2-120, slat_flap_configs[get(Flaps_internal_config) + 1], 34, false, false, TEXT_ALIGN_CENTER, indication_text_cl)
    end

    sasl.gl.setClipArea (size[1]/2 + 5, size[2]/2 - 122, 156, 71)
    sasl.gl.drawTexture(EWD_slat_img, size[1]/2+Math_rescale(0, 121, 1, 5, Table_interpolate(slat_anim_ratio, get(Slats))), size[2]/2-Math_rescale(0, 81, 1, 122, Table_interpolate(slat_anim_ratio, get(Slats))), 156, 71, get(Slats_ecam_amber) == 0 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.resetClipArea ()
    sasl.gl.setClipArea (size[1]/2 + 178, size[2]/2 - 120, 219, 69)
    sasl.gl.drawTexture(EWD_flap_img, size[1]/2+Math_rescale(0, -8, 1, 178, Table_interpolate(flaps_anim_ratio, get(Flaps_deployed_angle))), size[2]/2-Math_rescale(0, 78, 1, 120, Table_interpolate(flaps_anim_ratio, get(Flaps_deployed_angle))), 219, 69, get(Flaps_ecam_amber) == 0 and ECAM_GREEN or ECAM_ORANGE)
    sasl.gl.resetClipArea ()

    if rounded_slat_ratio ~= slats_positions[get(Flaps_internal_config) + 1] then
        SASL_drawSegmentedImg(EWD_slat_to_go_img, size[1]/2 + 12, size[2]/2 - 134, 2262, 63, 6, get(Flaps_internal_config) + 1)
    end
    if rounded_flap_angle ~= flaps_positions[get(Flaps_internal_config) + 1] then
        SASL_drawSegmentedImg(EWD_flap_to_go_img, size[1]/2 + 15, size[2]/2 - 134, 2262, 63, 6, get(Flaps_internal_config) + 1)
    end
end

function draw()
    if display_special_mode(size, EWD_valid) then
        sasl.gl.drawRectangle(0, 0, 900, 900, {0,0,0, 1 - get(EWD_brightness_act)})
        return
    end

    Draw_LCD_backlight(0, 0, 900, 900, 0.5, 1, get(EWD_brightness_act))
    sasl.gl.drawTexture(EWD_background_img, 0, 0, 900, 900, {1, 1, 1})

    Draw_extra_indication()
    Draw_engines_needles()
    Draw_engines()
    Draw_reverse_indication()
    Draw_left_memo()
    Draw_right_memo()
    Draw_extras()
    Draw_fuel_stuffs()
    Draw_coolings()
    Draw_slat_flap_indications()
end

