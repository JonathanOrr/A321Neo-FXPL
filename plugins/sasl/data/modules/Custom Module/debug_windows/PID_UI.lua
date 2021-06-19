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
-- File: PID_UI.lua 
-- Short description: A window for PID debugging
-------------------------------------------------------------------------------

--size = {600, 260}

--colors
local RED = {1, 0, 0}
local ORANGE = {1, 0.55, 0.15}
local WHITE = {1.0, 1.0, 1.0}
local GREEN = {0.20, 0.98, 0.20}
local LIGHT_BLUE = {0, 0.708, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--dataref for live tunning
local live_tunning_P =    createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_P", 1, false, true, false)
local live_tunning_I =    createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_I", 0, false, true, false)
local live_tunning_D =    createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_D", 0, false, true, false)
local live_tunning_B =    createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_B", 0, false, true, false)
local live_tunning_freq = createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_freq", 0, false, true, false)

--fonts
local B612_MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--GRAPH PROPERTIES--
local graph_time_limit = 5 --seconds across the x axis
local graph_max_error = 15

Err_array = {}
P_array = {}
I_array = {}
D_array = {}
Sum_array = {}
DELTA_TIME_array = {}
DELTA_TIME_sum = 0
Graph_x_offset_sum = 0

Og_value_array = {}
Value_DELTA_TIME_array = {}
Value_DELTA_TIME_sum = 0
Value_x_offset_sum = 0

local graph_max_value = 5

function Clear_PID_history()
    for i = 1, #P_array do
        P_array[i] = P_array[i + 1]
    end
    for i = 1, #I_array do
        I_array[i] = I_array[i + 1]
    end
    for i = 1, #D_array do
        D_array[i] = D_array[i + 1]
    end
    for i = 1, #DELTA_TIME_array do
        DELTA_TIME_array[i] = DELTA_TIME_array[i + 1]
    end
end

function Update_PID_historys(x_pos, y_pos, width, height, PID_array)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    if get(DELTA_TIME) ~= 0 then

        DELTA_TIME_sum = 0

        for i = 1, #DELTA_TIME_array do
            DELTA_TIME_sum = DELTA_TIME_sum + DELTA_TIME_array[i]
        end

        if DELTA_TIME_sum < graph_time_limit then
            Err_array[#Err_array + 1] = PID_array.Error / graph_max_error
            P_array[#P_array + 1] = PID_array.Proportional / PID_array.Max_out
            I_array[#I_array + 1] = PID_array.Integral / PID_array.Max_out
            D_array[#D_array + 1] = PID_array.Derivative / PID_array.Max_out
            Sum_array[#Sum_array + 1] = PID_array.Desired_output / PID_array.Max_out
            DELTA_TIME_array[#DELTA_TIME_array + 1] = get(DELTA_TIME)
        end

        --larger than graph time limit clearing out all extra array items
        if DELTA_TIME_sum >= graph_time_limit then
            for i = 1, #DELTA_TIME_array do
            Err_array[i] = Err_array[i + 1]
            P_array[i] = P_array[i + 1]
            I_array[i] = I_array[i + 1]
            D_array[i] = D_array[i + 1]
            Sum_array[i] = Sum_array[i + 1]
            DELTA_TIME_array[i] = DELTA_TIME_array[i + 1]
            end
        end

    end
end

function Draw_PID_graph(x_pos, y_pos, width, height, P_color, I_color, D_color, Sum_color, show_P, show_I, show_D, show_Sum, show_Err)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    sasl.gl.drawRectangle(x_pos, y_pos, width, height, DARK_GREY)
    sasl.gl.drawLine(x_pos, CENTER_Y, END_X, CENTER_Y, LIGHT_GREY)

    Graph_x_offset_sum = 0

    for i = 1 ,#DELTA_TIME_array do
        Graph_x_offset_sum = Graph_x_offset_sum + DELTA_TIME_array[i] / graph_time_limit * width

        if i > 1 then
            --draw all PID array lines
            if show_Sum == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + Sum_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + Sum_array[i] * height / 2, Sum_color)
            end
            if show_D == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + D_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + D_array[i] * height / 2, D_color)
            end
            if show_I == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + I_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + I_array[i] * height / 2, I_color)
            end
            if show_P == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + P_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + P_array[i] * height / 2, P_color)
            end
            if show_Err == true then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + Err_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + Err_array[i] * height / 2, ECAM_RED)
            end
        end
    end
end

function Update_value_historys(value)

    if get(DELTA_TIME) ~= 0 then

        Value_DELTA_TIME_sum = 0

        for i = 1, #Value_DELTA_TIME_array do
            Value_DELTA_TIME_sum = Value_DELTA_TIME_sum + Value_DELTA_TIME_array[i]
        end

        if DELTA_TIME_sum < graph_time_limit then
            Og_value_array[#Og_value_array + 1] = value / graph_max_value
            Value_DELTA_TIME_array[#Value_DELTA_TIME_array + 1] = get(DELTA_TIME)
        end

        --larger than graph time limit clearing out all extra array items
        if DELTA_TIME_sum >= graph_time_limit then
            for i = 1, #Value_DELTA_TIME_array do
                Og_value_array[i] = Og_value_array[i + 1]
                Value_DELTA_TIME_array[i] = Value_DELTA_TIME_array[i + 1]
            end
        end

    end
end

function Draw_value_graph(x_pos, y_pos, width, height, value_color)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    Value_x_offset_sum = 0

    for i = 1 ,#Value_DELTA_TIME_array do
        Value_x_offset_sum = Value_x_offset_sum + Value_DELTA_TIME_array[i] / graph_time_limit * width

        if i > 1 then
            sasl.gl.drawLine(x_pos + Value_x_offset_sum - Value_DELTA_TIME_array[i] / graph_time_limit * width, CENTER_Y + Og_value_array[i - 1] * height / 2, x_pos + Value_x_offset_sum, CENTER_Y + Og_value_array[i] * height / 2, value_color)
        end
    end
end

local function init_tuning_PID(PID_array)
    set(live_tunning_P,    PID_array.P_gain)
    set(live_tunning_I,    PID_array.I_gain)
    set(live_tunning_D,    PID_array.D_gain)
    set(live_tunning_B,    PID_array.B_gain)
    set(live_tunning_freq, PID_array.filter_freq)
end

local function live_tune_PID(PID_array)
    if PID_array.Schedule_gains == true then
        return
    end

    PID_array.P_gain =                        get(live_tunning_P)
    PID_array.I_gain =                        get(live_tunning_I)
    PID_array.D_gain =                        get(live_tunning_D)
    PID_array.B_gain =                        get(live_tunning_B)
    PID_array.er_filter_table.cut_frequency = get(live_tunning_freq)
    PID_array.pv_filter_table.cut_frequency = get(live_tunning_freq)
end

local function draw_gain_values(PID_array, x_pos, y_pos, width, height, P_color, I_color, D_color)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 290, CENTER_Y + 130, "P GAIN: " .. Round_fill(PID_array.P_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, P_color)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 290, CENTER_Y + 115, "I GAIN: " .. Round_fill(PID_array.I_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, I_color)
    sasl.gl.drawText(Font_AirbusDUL, CENTER_X + 290, CENTER_Y + 100, "D GAIN: " .. Round_fill(PID_array.D_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, D_color)
end

init_tuning_PID(FBW_PID_arrays.FBW_YAW_DAMPER_PID_array)

function update()
    if PID_UI_window:isVisible() == true then
        sasl.setMenuItemState(Menu_debug, ShowHidePIDUI, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_debug, ShowHidePIDUI, MENU_UNCHECKED)
    end

    Update_PID_historys(0 + 5, 0 + 5, 400, 250, FBW_PID_arrays.FBW_YAW_DAMPER_PID_array)
    live_tune_PID(FBW_PID_arrays.FBW_YAW_DAMPER_PID_array)

    --update anything
    --Update_value_historys(get(Total_input_pitch) * 6 - FBW.rates.Pitch.x)
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)
    Draw_PID_graph(0 + 5, 0 + 5, 590, 290, WHITE, LIGHT_BLUE, GREEN, ORANGE, true, true, true, true, true)
    draw_gain_values(FBW_PID_arrays.FBW_YAW_DAMPER_PID_array, 0 + 5, 0 + 5, 590, 290, WHITE, LIGHT_BLUE, GREEN)


    --draw anything
    --Draw_value_graph(0 + 5, 0 + 5, 590, 290, PFD_YELLOW)
end
