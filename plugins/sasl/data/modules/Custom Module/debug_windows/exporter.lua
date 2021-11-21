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
-- File: exporter.lua
-- Short description: A debug window to export data to a csv file
-------------------------------------------------------------------------------

size = {200, 100}

local BTN_WIDTH  = 100
local BTN_HEIGHT = 35

local data_selection = 1    -- 1 Drag data
local is_running = false
local last_time = 0

local filewrite

local eng_thrust = globalProperty("sim/flightmodel/engine/POINT_thrust[1]")
local drag_dr = globalProperty("sim/flightmodel/forces/drag_path_axis")

local function write_drag_data()
    local mach = get(Capt_Mach)
    local density = get(Weather_Sigma)
    local N1 = get(Eng_1_N1)
    local eng_thr = get(eng_thrust)
    local tas = get(TAS_ms)
    local drag = get(drag_dr)

    filewrite:write(drag .. "," .. (eng_thr*2) .. "," .. density .. "," .. tas .. "," .. mach .. "," .. get(Alpha).."," .. get(Capt_IAS_trend) .. "," .. get(Capt_VVI) .. "\n")
end

function update()
    if not is_running then
        if filewrite then
            filewrite:close()
            filewrite = nil
        end
        return
    end

    if not filewrite then
        filewrite = io.open("output_data.csv", "a");
    end

    if get(TIME) - last_time > 0.5 then
        last_time = get(TIME)
        if data_selection == 1 then
            write_drag_data()
        end
    end

end

function onMouseDown (component , x , y , button , parentX , parentY)
    if x >=10 and x<=10+BTN_WIDTH and y >= size[2]-40 then
        is_running = not is_running
    end
    return 0
end

function draw()
    sasl.gl.drawFrame (10, size[2]-40, BTN_WIDTH, BTN_HEIGHT, is_running and UI_LIGHT_BLUE or UI_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 10+(BTN_WIDTH/2), size[2]-27, is_running and "STOP" or "START", 15, false, false, TEXT_ALIGN_CENTER,UI_WHITE)

end

