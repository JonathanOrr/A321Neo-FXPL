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
-- Short description: General-purpose live PID viewer and tuner
-------------------------------------------------------------------------------

size = {720, 580}

local Font_Mono = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--==============================================================
-- LAYOUT
--==============================================================
-- Top bar (dropdown + buttons) sits at the top of the window.
-- Graph fills the middle. Controls panel fills the bottom.
--
--  y=550..578  Top bar
--  y=243..545  Graph
--  y=5..238    Controls panel
--==============================================================

local BAR_Y   = 550
local BAR_H   = 28

local GRAPH_X = 5
local GRAPH_Y = 243
local GRAPH_W = 710
local GRAPH_H = 302

local PANEL_X = 5
local PANEL_Y = 5
local PANEL_W = 710
local PANEL_H = 233

-- 4 equal columns across the panel
local COL_W   = 177
local FIELD_W = 110
local FIELD_H = 20
local BTN_W   = 16
local BTN_H   = 20
local FIELD_STEP = 0.001

local function col_x(col) return PANEL_X + (col - 1) * COL_W end

-- Graph settings row
local XLIM_X, XLIM_Y = col_x(1), 90
local YLIM_X, YLIM_Y = col_x(2), 90

-- {field_key, label, column, label_y, field_y}
local FIELD_LAYOUT = {
    {"P_gain",     "P GAIN",     1, 212, 190},
    {"I_gain",     "I GAIN",     2, 212, 190},
    {"D_gain",     "D GAIN",     3, 212, 190},
    {"B_gain",     "B GAIN",     4, 212, 190},
    {"FF_gain",    "FF GAIN",    1, 162, 140},
    {"err_freq",   "ERR FREQ",   2, 162, 140},
    {"dpvdt_freq", "DPVDT FREQ", 3, 162, 140},
}

--==============================================================
-- COLORS
--==============================================================
local COL_BG       = {0.10, 0.12, 0.14}
local COL_PANEL_BG = {0.12, 0.14, 0.16}
local COL_FIELD_BG = {0.08, 0.09, 0.11}
local COL_FIELD_BR = {0.35, 0.38, 0.42}
local COL_FOCUS_BR = UI_LIGHT_BLUE
local COL_BTN_BG   = {0.22, 0.25, 0.28}
local COL_GRID     = {0.22, 0.25, 0.28}
local COL_ZERO     = {0.32, 0.36, 0.40}
local COL_TEXT     = ECAM_WHITE
local COL_DIM      = ECAM_GREY
local COL_DD_BG    = {0.15, 0.18, 0.21}
local COL_DD_SEL   = {0.22, 0.35, 0.48}
local COL_LT_ON    = {0.05, 0.22, 0.07}

local TRACES = {
    {key = "P",   color = ECAM_WHITE},
    {key = "I",   color = UI_LIGHT_BLUE},
    {key = "D",   color = ECAM_GREEN},
    {key = "FF",  color = ECAM_MAGENTA},
    {key = "Sum", color = ECAM_ORANGE},
    {key = "Err", color = ECAM_RED},
}

local trace_visible = {}
for _, tr in ipairs(TRACES) do trace_visible[tr.key] = true end

local legend_hitboxes = {}

--==============================================================
-- CONTROLLER REGISTRY
--==============================================================
local CONTROLLERS = {
    {label = "CSTAR (Pitch)",   pid = FBW_PID_arrays.FBW_CSTAR_PID,          ff = FBW_PID_arrays.CSTAR_STABILITY_FF},
    {label = "Pitch Rate",      pid = FBW_PID_arrays.FBW_PITCH_RATE_PID,     ff = nil},
    {label = "Roll Rate",       pid = FBW_PID_arrays.FBW_ROLL_RATE_PID,      ff = nil},
    {label = "AoA Protection",  pid = FBW_PID_arrays.FBW_AoA_PID,            ff = FBW_PID_arrays.AoA_STABILITY_FF},
    {label = "Yaw Damper",      pid = FBW_PID_arrays.FBW_YAW_DAMPER_PID,     ff = nil},
    {label = "Normal Yaw",      pid = FBW_PID_arrays.FBW_NRM_YAW_PID,        ff = nil},
    {label = "Autotrim",        pid = FBW_PID_arrays.FBW_AUTOTRIM_PID,       ff = nil},
    {label = "MLA",             pid = FBW_PID_arrays.FBW_MLA_PID,            ff = nil},
    {label = "GLA",             pid = FBW_PID_arrays.FBW_GLA_PID,            ff = nil},
    {label = "APROT Rotation",  pid = FBW_PID_arrays.FBW_ROTATION_APROT_PID, ff = nil},
    {label = "APROT Flight",    pid = FBW_PID_arrays.FBW_FLIGHT_APROT_PID,   ff = nil},
    {label = "APROT Flare",     pid = FBW_PID_arrays.FBW_FLARE_APROT_PID,    ff = nil},
}

local selected_idx  = 1
local dropdown_open = false
local live_tune_on  = false

--==============================================================
-- GRAPH STATE
--==============================================================
local graph = {dt = {}, data = {}, xlim = 5, ylim = 1.2}

local function graph_reset()
    graph.dt   = {}
    graph.data = {}
end

local function graph_update()
    if get(DELTA_TIME) == 0 then return end

    -- Trim samples that have scrolled past the time window
    local total = 0
    for i = 1, #graph.dt do total = total + graph.dt[i] end
    while total > graph.xlim and #graph.dt > 1 do
        total = total - graph.dt[1]
        table.remove(graph.dt, 1)
        for _, tr in ipairs(TRACES) do
            if graph.data[tr.key] then table.remove(graph.data[tr.key], 1) end
        end
    end

    -- Seed arrays on first call or after reset
    if not graph.data[TRACES[1].key] then
        for _, tr in ipairs(TRACES) do graph.data[tr.key] = {} end
    end

    local c   = CONTROLLERS[selected_idx]
    local pid = c.pid
    local ff  = c.ff
    local mx  = math.abs(pid.Max_out) > 0 and math.abs(pid.Max_out) or 1

    table.insert(graph.data["P"],   pid.Proportional   / mx)
    table.insert(graph.data["I"],   pid.Integral       / mx)
    table.insert(graph.data["D"],   pid.Derivative     / mx)
    table.insert(graph.data["FF"],  ff and (ff.feedfwd / mx) or 0)
    table.insert(graph.data["Sum"], pid.Desired_output / mx)
    table.insert(graph.data["Err"], pid.Error          / mx)
    table.insert(graph.dt, get(DELTA_TIME))
end

--==============================================================
-- INPUT STATE
--==============================================================
local focus_field  = nil
local input_buffer = ""
local cursor_t     = 0

local function field_get(key)
    local c = CONTROLLERS[selected_idx]
    if key == "FF_gain"    then return c.ff  and c.ff.FF_gain             or nil end
    if key == "err_freq"   then return c.pid.filter_inputs and c.pid.error_freq  or nil end
    if key == "dpvdt_freq" then return c.pid.filter_inputs and c.pid.dpvdt_freq  or nil end
    return c.pid[key]
end

local function field_write(key, val)
    local c = CONTROLLERS[selected_idx]
    if key == "FF_gain" then
        if c.ff then c.ff.FF_gain = val end
    elseif key == "err_freq" then
        if c.pid.filter_inputs then
            c.pid.error_freq = val
            if c.pid.er_filter_table then c.pid.er_filter_table.cut_frequency = val end
        end
    elseif key == "dpvdt_freq" then
        if c.pid.filter_inputs then
            c.pid.dpvdt_freq = val
            if c.pid.pv_filter_table then c.pid.pv_filter_table.cut_frequency = val end
        end
    elseif c.pid[key] ~= nil then
        c.pid[key] = val
    end
end

local function field_commit()
    if not focus_field then return end
    local v = tonumber(input_buffer)
    if v then field_write(focus_field, v) end
    focus_field  = nil
    input_buffer = ""
end

local function field_open(key)
    if not live_tune_on then return end
    local c = CONTROLLERS[selected_idx]
    if (key == "P_gain" or key == "I_gain" or key == "D_gain") and c.pid.Schedule_gains then return end
    local v = field_get(key)
    if v == nil then return end
    field_commit()
    focus_field  = key
    input_buffer = tostring(Round_fill(v, 6))
    cursor_t     = 0
end

local function field_adjust(key, delta)
    if not live_tune_on then return end
    local c = CONTROLLERS[selected_idx]
    if (key == "P_gain" or key == "I_gain" or key == "D_gain") and c.pid.Schedule_gains then return end
    local v = field_get(key)
    if v == nil then return end
    field_write(key, v + delta)
end

function onKeyDown(component, char, key, shiftDown, ctrlDown, altOptDown)
    if not focus_field then return false end
    if char == SASL_KEY_DELETE then
        input_buffer = string.sub(input_buffer, 1, -2)
    elseif char == SASL_VK_RETURN then
        field_commit()
    elseif char == SASL_VK_ESCAPE then
        focus_field  = nil
        input_buffer = ""
    else
        local c = string.char(char)
        if c:match("[0-9%.%-%+]") then input_buffer = input_buffer .. c end
    end
    return true
end

--==============================================================
-- DRAW HELPERS
--==============================================================
local function hit(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

local function draw_box(x, y, w, h, fill, border)
    sasl.gl.drawRectangle(x, y, w, h, fill)
    sasl.gl.drawLine(x,     y,     x + w, y,     border)
    sasl.gl.drawLine(x,     y + h, x + w, y + h, border)
    sasl.gl.drawLine(x,     y,     x,     y + h, border)
    sasl.gl.drawLine(x + w, y,     x + w, y + h, border)
end

local function draw_field_widget(x, y, key, label)
    local val       = field_get(key)
    local focused   = (focus_field == key)
    local c         = CONTROLLERS[selected_idx]
    local scheduled = c.pid.Schedule_gains and
                      (key == "P_gain" or key == "I_gain" or key == "D_gain")
    local editable  = live_tune_on and not scheduled and val ~= nil

    sasl.gl.drawText(Font_Mono, x, y + FIELD_H + 5, label, 10, false, false, TEXT_ALIGN_LEFT, COL_DIM)

    local border = focused and COL_FOCUS_BR or (editable and COL_FIELD_BR or {0.22, 0.24, 0.26})
    draw_box(x, y, FIELD_W, FIELD_H, COL_FIELD_BG, border)

    local text_col = editable and COL_TEXT or COL_DIM
    local text_str
    if val == nil then
        text_str = "N/A"
        text_col = COL_DIM
    elseif scheduled then
        text_str = "SCHED"
        text_col = ECAM_YELLOW
    elseif focused then
        local blink = math.floor(cursor_t * 2) % 2 == 0
        text_str = input_buffer .. (blink and "|" or " ")
    else
        text_str = Round_fill(val, 5)
    end
    sasl.gl.drawText(Font_Mono, x + 4, y + 5, text_str, 10, false, false, TEXT_ALIGN_LEFT, text_col)

    if editable then
        local mx = x + FIELD_W + 2
        local px = mx + BTN_W + 1
        draw_box(mx, y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
        sasl.gl.drawText(Font_Mono, mx + BTN_W / 2, y + 4, "-", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
        draw_box(px, y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
        sasl.gl.drawText(Font_Mono, px + BTN_W / 2, y + 4, "+", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
    end
end

--==============================================================
-- GRAPH DRAW
--==============================================================
local function graph_draw()
    local x, y, w, h = GRAPH_X, GRAPH_Y, GRAPH_W, GRAPH_H
    sasl.gl.setClipArea(x, y, w, h)
    sasl.gl.drawRectangle(x, y, w, h, UI_DARK_GREY)

    local zero_y = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h, 0)
    sasl.gl.drawLine(x, zero_y, x + w, zero_y, COL_ZERO)

    for i = 1, math.floor(graph.xlim) do
        local gx = Math_rescale_no_lim(0, x, graph.xlim, x + w, i)
        sasl.gl.drawLine(gx, y, gx, y + h, COL_GRID)
    end

    for _, v in ipairs({-1, 1}) do
        local gy = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h, v)
        sasl.gl.drawLine(x, gy, x + w, gy, COL_GRID)
    end

    for _, tr in ipairs(TRACES) do
        if trace_visible[tr.key] then
            local vals = graph.data[tr.key]
            if vals and #vals > 1 then
                local t = 0
                for i = 1, #graph.dt - 1 do
                    local x0 = Math_rescale_no_lim(0, x, graph.xlim, x + w, t)
                    local x1 = Math_rescale_no_lim(0, x, graph.xlim, x + w, t + graph.dt[i])
                    local y0 = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h, vals[i])
                    local y1 = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h, vals[i + 1])
                    sasl.gl.drawLine(x0, y0, x1, y1, tr.color)
                    t = t + graph.dt[i]
                end
            end
        end
    end

    -- Legend: click to toggle trace visibility
    legend_hitboxes = {}
    local lx  = x + 6
    local ly  = y + h - 17
    local sq  = 8
    for _, tr in ipairs(TRACES) do
        local vals  = graph.data[tr.key]
        local last  = vals and #vals > 0 and vals[#vals] or 0
        local label = tr.key .. ":" .. Round_fill(last, 3)
        local tw    = sasl.gl.measureText(Font_Mono, label, 10, false, false)
        local item_w = sq + 4 + tw + 8

        legend_hitboxes[#legend_hitboxes + 1] = {x = lx, y = ly - 2, w = item_w, h = sq + 4, key = tr.key}

        -- Filled square when visible, outlined square when hidden
        if trace_visible[tr.key] then
            sasl.gl.drawRectangle(lx, ly, sq, sq, tr.color)
        else
            sasl.gl.drawRectangle(lx, ly, sq, sq, UI_DARK_GREY)
            sasl.gl.drawLine(lx,      ly,      lx + sq, ly,      tr.color)
            sasl.gl.drawLine(lx,      ly + sq, lx + sq, ly + sq, tr.color)
            sasl.gl.drawLine(lx,      ly,      lx,      ly + sq, tr.color)
            sasl.gl.drawLine(lx + sq, ly,      lx + sq, ly + sq, tr.color)
        end

        local label_col = trace_visible[tr.key] and tr.color or COL_DIM
        sasl.gl.drawText(Font_Mono, lx + sq + 4, ly, label, 10, false, false, TEXT_ALIGN_LEFT, label_col)

        lx = lx + item_w
    end

    -- Y-axis scale labels
    local y_top = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h,  graph.ylim)
    local y_bot = Math_rescale_no_lim(-graph.ylim, y, graph.ylim, y + h, -graph.ylim)
    sasl.gl.drawText(Font_Mono, x + w - 2, zero_y + 2,  "0",                       9, false, false, TEXT_ALIGN_RIGHT, COL_DIM)
    sasl.gl.drawText(Font_Mono, x + w - 2, y_top   - 12, "+" .. Round_fill(graph.ylim, 1), 9, false, false, TEXT_ALIGN_RIGHT, COL_DIM)
    sasl.gl.drawText(Font_Mono, x + w - 2, y_bot   + 2,  "-" .. Round_fill(graph.ylim, 1), 9, false, false, TEXT_ALIGN_RIGHT, COL_DIM)

    sasl.gl.resetClipArea()
end

--==============================================================
-- CONTROLS PANEL DRAW
--==============================================================
local function panel_draw()
    sasl.gl.drawRectangle(PANEL_X, PANEL_Y, PANEL_W, PANEL_H, COL_PANEL_BG)

    if CONTROLLERS[selected_idx].pid.Schedule_gains then
        sasl.gl.drawText(Font_Mono, PANEL_X + PANEL_W / 2, 222,
            "GAIN-SCHEDULED  —  P/I/D values are instantaneous reads only",
            10, false, false, TEXT_ALIGN_CENTER, ECAM_YELLOW)
    end

    for _, fd in ipairs(FIELD_LAYOUT) do
        local key, label, col, _, fy = fd[1], fd[2], fd[3], fd[4], fd[5]
        draw_field_widget(col_x(col), fy, key, label)
    end

    -- Graph time window control
    sasl.gl.drawText(Font_Mono, XLIM_X, XLIM_Y + FIELD_H + 5, "TIME(s)", 10, false, false, TEXT_ALIGN_LEFT, COL_DIM)
    draw_box(XLIM_X, XLIM_Y, FIELD_W, FIELD_H, COL_FIELD_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, XLIM_X + 4, XLIM_Y + 5, Round_fill(graph.xlim, 0), 10, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
    local xlim_mx = XLIM_X + FIELD_W + 2
    local xlim_px = xlim_mx + BTN_W + 1
    draw_box(xlim_mx, XLIM_Y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, xlim_mx + BTN_W / 2, XLIM_Y + 4, "-", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
    draw_box(xlim_px, XLIM_Y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, xlim_px + BTN_W / 2, XLIM_Y + 4, "+", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)

    -- Graph Y-scale control
    sasl.gl.drawText(Font_Mono, YLIM_X, YLIM_Y + FIELD_H + 5, "Y SCALE", 10, false, false, TEXT_ALIGN_LEFT, COL_DIM)
    draw_box(YLIM_X, YLIM_Y, FIELD_W, FIELD_H, COL_FIELD_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, YLIM_X + 4, YLIM_Y + 5, Round_fill(graph.ylim, 2), 10, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
    local ylim_mx = YLIM_X + FIELD_W + 2
    local ylim_px = ylim_mx + BTN_W + 1
    draw_box(ylim_mx, YLIM_Y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, ylim_mx + BTN_W / 2, YLIM_Y + 4, "-", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
    draw_box(ylim_px, YLIM_Y, BTN_W, BTN_H, COL_BTN_BG, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, ylim_px + BTN_W / 2, YLIM_Y + 4, "+", 11, false, false, TEXT_ALIGN_CENTER, COL_TEXT)

    if not live_tune_on then
        sasl.gl.drawText(Font_Mono, col_x(3), YLIM_Y + FIELD_H + 5,
            "Enable LIVE TUNE to edit gains", 10, false, false, TEXT_ALIGN_LEFT, COL_DIM)
    end
end

--==============================================================
-- TOP BAR
--==============================================================
local DD_X = 5
local DD_Y = BAR_Y
local DD_W = 270
local DD_H = BAR_H

local LT_X = DD_X + DD_W + 8
local LT_Y = BAR_Y
local LT_W = 130
local LT_H = BAR_H

local RST_X = LT_X + LT_W + 8
local RST_Y = BAR_Y
local RST_W = 70
local RST_H = BAR_H

local DD_ITEM_H = 21
local N_CTRL    = #CONTROLLERS

local function topbar_draw()
    local dd_bg = dropdown_open and {0.28, 0.32, 0.36} or {0.18, 0.21, 0.24}
    draw_box(DD_X, DD_Y, DD_W, DD_H, dd_bg, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, DD_X + 6, DD_Y + 8,
        (dropdown_open and "▲  " or "▼  ") .. CONTROLLERS[selected_idx].label,
        12, false, false, TEXT_ALIGN_LEFT, COL_TEXT)

    local lt_bg  = live_tune_on and COL_LT_ON or {0.18, 0.20, 0.22}
    local lt_col = live_tune_on and ECAM_GREEN or COL_DIM
    draw_box(LT_X, LT_Y, LT_W, LT_H, lt_bg, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, LT_X + LT_W / 2, LT_Y + 8,
        live_tune_on and "TUNE: ON" or "TUNE: OFF",
        12, false, false, TEXT_ALIGN_CENTER, lt_col)

    draw_box(RST_X, RST_Y, RST_W, RST_H, {0.18, 0.20, 0.22}, COL_FIELD_BR)
    sasl.gl.drawText(Font_Mono, RST_X + RST_W / 2, RST_Y + 8,
        "RESET", 12, false, false, TEXT_ALIGN_CENTER, COL_TEXT)
end

-- Drawn last so the list overlays the graph
local function dropdown_list_draw()
    if not dropdown_open then return end

    local list_h = N_CTRL * DD_ITEM_H
    local list_y = DD_Y - list_h  -- opens downward (lower y = visually lower on screen)

    draw_box(DD_X, list_y, DD_W, list_h, COL_DD_BG, COL_FIELD_BR)

    for i, c in ipairs(CONTROLLERS) do
        -- Item i=1 is at the top (highest y), item N is at the bottom (list_y)
        local iy   = list_y + (N_CTRL - i) * DD_ITEM_H
        local fill = (i == selected_idx) and COL_DD_SEL or {0, 0, 0, 0}
        sasl.gl.drawRectangle(DD_X + 1, iy, DD_W - 2, DD_ITEM_H, fill)
        sasl.gl.drawText(Font_Mono, DD_X + 8, iy + 5, c.label, 11, false, false, TEXT_ALIGN_LEFT, COL_TEXT)
    end
end

--==============================================================
-- MOUSE HANDLER
--==============================================================
function onMouseDown(component, x, y, button, parentX, parentY)
    if button ~= MB_LEFT then return end

    -- When dropdown is open, any click closes it; item clicks also select
    if dropdown_open then
        local list_h = N_CTRL * DD_ITEM_H
        local list_y = DD_Y - list_h
        if hit(x, y, DD_X, list_y, DD_W, list_h) then
            local idx = N_CTRL - math.floor((y - list_y) / DD_ITEM_H)
            idx = Math_clamp(idx, 1, N_CTRL)
            if idx ~= selected_idx then
                selected_idx = idx
                graph_reset()
                focus_field  = nil
                input_buffer = ""
            end
        end
        dropdown_open = false
        return
    end

    -- Top bar buttons
    if hit(x, y, DD_X,  DD_Y,  DD_W,  DD_H)  then dropdown_open = true;               return end
    if hit(x, y, LT_X,  LT_Y,  LT_W,  LT_H)  then
        live_tune_on = not live_tune_on
        if not live_tune_on then field_commit() end
        return
    end
    if hit(x, y, RST_X, RST_Y, RST_W, RST_H) then graph_reset();                      return end

    -- Legend trace visibility toggles
    for _, hb in ipairs(legend_hitboxes) do
        if hit(x, y, hb.x, hb.y, hb.w, hb.h) then
            trace_visible[hb.key] = not trace_visible[hb.key]
            return
        end
    end

    -- Gain field boxes and +/- buttons
    for _, fd in ipairs(FIELD_LAYOUT) do
        local key, _, col, _, fy = fd[1], fd[2], fd[3], fd[4], fd[5]
        local fx = col_x(col)

        if hit(x, y, fx, fy, FIELD_W, FIELD_H) then
            field_open(key)
            return
        end

        if live_tune_on then
            local mx = fx + FIELD_W + 2
            local px = mx + BTN_W + 1
            if hit(x, y, mx, fy, BTN_W, BTN_H) then field_commit(); field_adjust(key, -FIELD_STEP); return end
            if hit(x, y, px, fy, BTN_W, BTN_H) then field_commit(); field_adjust(key,  FIELD_STEP); return end
        end
    end

    -- Graph time-window buttons
    local xlim_mx = XLIM_X + FIELD_W + 2
    local xlim_px = xlim_mx + BTN_W + 1
    if hit(x, y, xlim_mx, XLIM_Y, BTN_W, BTN_H) then graph.xlim = math.max(1,  graph.xlim - 1); graph_reset(); return end
    if hit(x, y, xlim_px, XLIM_Y, BTN_W, BTN_H) then graph.xlim = math.min(30, graph.xlim + 1);                return end

    -- Graph Y-scale buttons
    local ylim_mx = YLIM_X + FIELD_W + 2
    local ylim_px = ylim_mx + BTN_W + 1
    if hit(x, y, ylim_mx, YLIM_Y, BTN_W, BTN_H) then graph.ylim = math.max(0.1, Round_fill(graph.ylim - 0.1, 1)); return end
    if hit(x, y, ylim_px, YLIM_Y, BTN_W, BTN_H) then graph.ylim = Round_fill(graph.ylim + 0.1, 1);                return end

    -- Anything else: commit pending edit
    field_commit()
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    if not live_tune_on then return end
    for _, fd in ipairs(FIELD_LAYOUT) do
        local key, _, col, _, fy = fd[1], fd[2], fd[3], fd[4], fd[5]
        local fx = col_x(col)
        if hit(x, y, fx, fy, FIELD_W + 2 + 2 * (BTN_W + 1), FIELD_H) then
            field_adjust(key, value * FIELD_STEP)
            return
        end
    end
end

--==============================================================
-- SASL CALLBACKS
--==============================================================
function update()
    cursor_t = cursor_t + get(DELTA_TIME)
    if cursor_t >= 1 then cursor_t = cursor_t - 1 end

    graph_update()
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], COL_BG)
    panel_draw()
    graph_draw()
    topbar_draw()
    dropdown_list_draw()  -- drawn last so it overlays the graph
end
