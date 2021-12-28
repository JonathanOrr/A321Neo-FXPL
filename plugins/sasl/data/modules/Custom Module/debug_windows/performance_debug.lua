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
-- File: performance_debug.lua 
-- Short description: A debug window to check the component performance
-------------------------------------------------------------------------------

size = {400, 600}


local last_update = 0
local UPDATE_FREQ_SEC = 0.5
local delta_time = 0

function draw()

    if debug_performance_measure then
        sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-50, "PERF DEBUG OK", 24, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-30, "You have to set the variable in", 16, false, false, TEXT_ALIGN_LEFT,  ECAM_RED)
        sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-50, "`main_debug.lua` to use this feature.", 16, false, false, TEXT_ALIGN_LEFT,  ECAM_RED)    
        return
    end
    
    num = 0

    sasl.gl.drawText(Font_AirbusDUL, 10, size[2]-80, "COMPONENT", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)            
    sasl.gl.drawText(Font_AirbusDUL, 160, size[2]-80, "COST(FPS)", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)            
    sasl.gl.drawText(Font_AirbusDUL, 250, size[2]-80, "COST(ms)", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)            
    sasl.gl.drawText(Font_AirbusDUL, 330, size[2]-80, "PEAK(ms)", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)            
    
    if delta_time == 0 or get(TIME) - last_update > 1 then
        delta_time = get(DELTA_TIME)
        last_update = get(TIME)
    end
   
    for label,x in pairs(Perf_array) do
        local y = size[2]-110-num*15
        sasl.gl.drawText(Font_AirbusDUL, 10, y, label, 12, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        
        if x.last_delta ~= nil then 
            local sec = x.mov_avg / 50
            local ms = Round_fill(sec*1000, 2)
            local frames_num = 1/(delta_time - sec) - (1/delta_time)
            local frames = Round_fill(frames_num, 1)
            local ms_peak = Round_fill(x.peak*1000, 2)

            sasl.gl.drawText(Font_AirbusDUL, 230, y, frames, 14, false, false, TEXT_ALIGN_RIGHT, frames_num > 5 and ECAM_RED or (frames_num > 1 and ECAM_ORANGE or ECAM_GREEN))
            sasl.gl.drawText(Font_AirbusDUL, 310, y, ms, 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
            sasl.gl.drawText(Font_AirbusDUL, 390, y, ms_peak, 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        end
        num = num + 1
    end
    
end
