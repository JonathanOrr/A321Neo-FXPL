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

--colors
local RED = {1, 0, 0}
local ORANGE = {1, 0.55, 0.15}
local WHITE = {1.0, 1.0, 1.0}
local GREEN = {0.20, 0.98, 0.20}
local LIGHT_BLUE = {0, 0.708, 1}
local MAGENTA = {1, 0, 1}
local LIGHT_GREY = {0.2039, 0.2235, 0.247}
local DARK_GREY = {0.1568, 0.1803, 0.2039}

--dataref for live tunning
local live_tunning_P_K =          createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_P_K", 1, false, true, false)
local live_tunning_I_K =          createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_I_K", 1, false, true, false)
local live_tunning_D_K =          createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_D_K", 1, false, true, false)
local live_tunning_FF_K =         createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_FF_K", 1, false, true, false)
local live_tunning_P =            createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_P", 1, false, true, false)
local live_tunning_I =            createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_I", 0, false, true, false)
local live_tunning_D =            createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_D", 0, false, true, false)
local live_tunning_B =            createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_B", 0, false, true, false)
local live_tunning_FF =           createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_FF", 0, false, true, false)
local live_tunning_err_freq =     createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_err_freq", 0, false, true, false)
local live_tunning_dpvdt_freq =   createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_dpvdt_freq", 0, false, true, false)
local live_tunning_feedfwd_freq = createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_feedfwd_freq", 0, false, true, false)
local graph_time_limit =          createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_graph_time_limit", 5, false, true, false)
local graph_max_error =           createGlobalPropertyf("a321neo/dynamics/FBW/PID/live_tunning_graph_max_error", 5, false, true, false)

local Err_array = {}
local P_array   = {}
local I_array   = {}
local D_array   = {}
local FF_array  = {}
local Sum_array = {}
local DELTA_TIME_array = {}
local DELTA_TIME_sum = 0
local Graph_x_offset_sum = 0

local function Clear_PID_history()
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

local function Update_PID_historys(x_pos, y_pos, width, height, PID, FF_PID)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    if get(DELTA_TIME) ~= 0 then

        DELTA_TIME_sum = 0

        for i = 1, #DELTA_TIME_array do
            DELTA_TIME_sum = DELTA_TIME_sum + DELTA_TIME_array[i]
        end

        if DELTA_TIME_sum < get(graph_time_limit) then
            Err_array[#Err_array + 1] = PID.Error / get(graph_max_error)
            P_array[#P_array + 1] = PID.Proportional / PID.Max_out
            I_array[#I_array + 1] = PID.Integral / PID.Max_out
            D_array[#D_array + 1] = PID.Derivative / PID.Max_out
            if FF_PID ~= nil then
                FF_array[#FF_array + 1] = FF_PID.feedfwd / PID.Max_out
            end
            Sum_array[#Sum_array + 1] = PID.Desired_output / PID.Max_out
            DELTA_TIME_array[#DELTA_TIME_array + 1] = get(DELTA_TIME)
        end

        --larger than graph time limit clearing out all extra array items
        if DELTA_TIME_sum >= get(graph_time_limit) then
            for i = 1, #DELTA_TIME_array do
                Err_array[i] = Err_array[i + 1]
                P_array[i] = P_array[i + 1]
                I_array[i] = I_array[i + 1]
                D_array[i] = D_array[i + 1]
                if FF_PID ~= nil then
                    FF_array[i] = FF_array[i + 1]
                end
                Sum_array[i] = Sum_array[i + 1]
                DELTA_TIME_array[i] = DELTA_TIME_array[i + 1]
            end
        end
    end
end

local function Draw_PID_graph(x_pos, y_pos, width, height, P_color, I_color, D_color, Sum_color, show_P, show_I, show_D, show_Sum, show_Err, FF_color, show_FF)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    sasl.gl.drawRectangle(x_pos, y_pos, width, height, DARK_GREY)
    sasl.gl.drawLine(x_pos, CENTER_Y, END_X, CENTER_Y, LIGHT_GREY)

    for i = 1, math.floor(get(graph_time_limit)) do
        local per_sec_gap = END_X / get(graph_time_limit)
        sasl.gl.drawLine(per_sec_gap * i, y_pos, per_sec_gap * i, END_Y, LIGHT_GREY)
    end

    Graph_x_offset_sum = 0

    for i = 1 ,#DELTA_TIME_array do
        Graph_x_offset_sum = Graph_x_offset_sum + DELTA_TIME_array[i] / get(graph_time_limit) * width

        if i > 1 then
            --draw all PID array lines
            if show_Sum then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + Sum_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + Sum_array[i] * height / 2, Sum_color)
            end
            if show_FF then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + FF_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + FF_array[i] * height / 2, FF_color)
            end
            if show_D then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + D_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + D_array[i] * height / 2, D_color)
            end
            if show_I then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + I_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + I_array[i] * height / 2, I_color)
            end
            if show_P then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + P_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + P_array[i] * height / 2, P_color)
            end
            if show_Err then
                sasl.gl.drawLine(x_pos + Graph_x_offset_sum - DELTA_TIME_array[i] / get(graph_time_limit) * width, CENTER_Y + Err_array[i - 1] * height / 2, x_pos + Graph_x_offset_sum, CENTER_Y + Err_array[i] * height / 2, ECAM_RED)
            end
        end
    end
end

local function init_tuning_PID(PID_array)
    set(live_tunning_P,    PID_array.P_gain)
    set(live_tunning_I,    PID_array.I_gain)
    set(live_tunning_D,    PID_array.D_gain)
    set(live_tunning_B,    PID_array.B_gain)

    if PID_array.filter_inputs then
        set(live_tunning_err_freq,   PID_array.error_freq)
        set(live_tunning_dpvdt_freq, PID_array.dpvdt_freq)
    end
end

local function init_ff_tunning(FF_PID)
    set(live_tunning_FF, FF_PID.FF_gain)

    if FF_PID.filter_feedfwd then
        set(live_tunning_feedfwd_freq, FF_PID.feedfwd_freq)
    end
end

local function live_tune_PID(PID_array)
    if PID_array.Schedule_gains then return end

    PID_array.P_gain =  get(live_tunning_P)  * get(live_tunning_P_K)
    PID_array.I_gain =  get(live_tunning_I)  * get(live_tunning_I_K)
    PID_array.D_gain =  get(live_tunning_D)  * get(live_tunning_D_K)
    PID_array.B_gain =  get(live_tunning_B)
end

local function live_filter_modification(PID_array)
    if PID_array.filter_inputs then
        if PID_array.er_filter_table ~= nil then
            PID_array.er_filter_table.cut_frequency = get(live_tunning_err_freq)
        end
        if PID_array.pv_filter_table ~= nil then
            PID_array.pv_filter_table.cut_frequency = get(live_tunning_dpvdt_freq)
        end
    end
end

local function live_FF_tuning(FF_PID)
    FF_PID.FF_gain = get(live_tunning_FF) * get(live_tunning_FF_K)

    if FF_PID.feedfwd_filter_table ~= nil then
        FF_PID.feedfwd_filter_table.cut_frequency = get(live_tunning_feedfwd_freq)
    end
end

local function draw_gain_values(PID_array, x_pos, y_pos, width, height, P_color, I_color, D_color)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2
    local END_X = x_pos + width
    local END_Y = y_pos + height

    sasl.gl.drawText(Font_ECAMfont, CENTER_X + 290, CENTER_Y + 130, "P GAIN: " .. Round_fill(PID_array.P_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, P_color)
    sasl.gl.drawText(Font_ECAMfont, CENTER_X + 290, CENTER_Y + 115, "I GAIN: " .. Round_fill(PID_array.I_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, I_color)
    sasl.gl.drawText(Font_ECAMfont, CENTER_X + 290, CENTER_Y + 100, "D GAIN: " .. Round_fill(PID_array.D_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, D_color)
end

local function draw_FF_gain_values(FF_PID, x_pos, y_pos, width, height, FF_color)
    local CENTER_X = (2 * x_pos + width) / 2
    local CENTER_Y = (2 * y_pos + height) / 2

    sasl.gl.drawText(Font_ECAMfont, CENTER_X + 290, CENTER_Y + 85, "FF GAIN: " .. Round_fill(FF_PID.FF_gain, 4), 12, false, false, TEXT_ALIGN_RIGHT, FF_color)
end

init_tuning_PID(FBW_PID_arrays.FBW_CSTAR_PID)
init_ff_tunning(FBW_PID_arrays.CSTAR_STABILITY_FF)

local function update_data()
    Update_PID_historys(0 + 5, 0 + 5, 400, 250, FBW_PID_arrays.FBW_CSTAR_PID, FBW_PID_arrays.CSTAR_STABILITY_FF)

    --live_tune_PID(FBW_PID_arrays.FBW_CSTAR_PID)
    live_filter_modification(FBW_PID_arrays.FBW_CSTAR_PID)
    --live_FF_tuning(FBW_PID_arrays.CSTAR_STABILITY_FF)
end

function draw()
    update_data()

    sasl.gl.drawRectangle(0, 0, size[1], size[2], LIGHT_GREY)
    Draw_PID_graph(0 + 5, 0 + 5, 590, 290, WHITE, LIGHT_BLUE, GREEN, ORANGE, true, true, true, true, true, MAGENTA, true)

    draw_gain_values(FBW_PID_arrays.FBW_CSTAR_PID, 0 + 5, 0 + 5, 590, 290, WHITE, LIGHT_BLUE, GREEN)
    draw_FF_gain_values(FBW_PID_arrays.CSTAR_STABILITY_FF, 0 + 5, 0 + 5, 590, 290, MAGENTA)
end
