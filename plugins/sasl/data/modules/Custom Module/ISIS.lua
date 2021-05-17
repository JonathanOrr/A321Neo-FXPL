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
-- File: ISIS.lua 
-- Short description: The file containing the code for the ISIS widget
-------------------------------------------------------------------------------

position= {30,1311,500,500}
size = {500, 500}

include("ADIRS_data_source.lua")

local TIME_TO_ALIGN_SEC = 90

-- Toggle LS
sasl.registerCommandHandler (ISIS_cmd_LS, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ISIS_landing_system_enabled, get(ISIS_landing_system_enabled) == 1 and 0 or 1) end end)
sasl.registerCommandHandler (ISIS_cmd_Knob_c, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) + 0.01, 28, 31))end end)
sasl.registerCommandHandler (ISIS_cmd_Knob_cc, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then set(Stby_Baro, Math_clamp(get(Stby_Baro) - 0.01, 28, 31))end end)


local isis_start_time = 0
local spd_tape_x = 37
local spd_tape_y = 241
local spd_tape_y_offset = -13
local spd_tape_per_reading = 20 --px per reading, 000 to 010 is 20px

local function to_3_digits(number)
    return #tostring(math.abs(number)) < 3  and "0"..number or number --30 returns 030, 40 returns 040, etc. 230 returns 230 as always.
end

local function draw_speed_tape()

    local airspeed_y_offset = get(Stby_IAS) * 4 -- 4 px per airspeed notch
    for i=-4, 100 do
        
        local dashes_y = (spd_tape_y + spd_tape_per_reading * i - airspeed_y_offset)


        local curr_spd = i * 20

        if (curr_spd <= get(Stby_IAS) + 50) and (curr_spd >= get(Stby_IAS) - 50) and i*20 <= 500 then
            sasl.gl.drawText(Font_ECAMfont, spd_tape_x, dashes_y + spd_tape_y_offset + 60 * i, Fwd_string_fill( tostring(math.abs(i*20)), "0", 3) , 32, false, false, TEXT_ALIGN_CENTER, EFB_FULL_GREEN)
        end
        
        local curr_spd_for_dashes = i * 5
        if (curr_spd_for_dashes <= get(Stby_IAS) + 50) and (curr_spd_for_dashes >= get(Stby_IAS) - 50) then 
            if (i+2)%4 == 0 then
                sasl.gl.drawWideLine(spd_tape_x+21, dashes_y, spd_tape_x+38, dashes_y, 3, EFB_FULL_GREEN)
            else
                sasl.gl.drawWideLine(spd_tape_x+32, dashes_y, spd_tape_x+38, dashes_y, 3, EFB_FULL_GREEN)
            end
        end
    end

end


local function draw_background()
    sasl.gl.drawRectangle(0, 0, 500, 500, ECAM_BLACK)
end

function draw()

    --draw_background()

    draw_speed_tape()

    if get(ISIS_powered) == 0 then
        return
    end
    if get(ISIS_ready) == 0 then
        -- Not ready, draw the countdown
        local remaning_time = math.ceil(TIME_TO_ALIGN_SEC - get(TIME) + isis_start_time)
        if remaning_time > 0 then
            sasl.gl.drawText (Font_AirbusDUL, 308, 103, remaning_time, 37, false, false, TEXT_ALIGN_RIGHT, ECAM_BLACK)
        end
    else
        -- Ready, draw the altitude in meters
        local meter_alt = math.floor(get(Stby_Alt) * 0.3048)
        sasl.gl.drawText (Font_AirbusDUL, 350, 456, meter_alt, 28, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

        local baro_mmhg = Round(get(Stby_Baro),2)
        if baro_mmhg ~= 29.92 then
            local baro_kpa  = Round(33.8639 * get(Stby_Baro),0)
            sasl.gl.drawText (Font_AirbusDUL, 222, 40, string.format("%.2f", tostring(baro_kpa)) .. "/" .. string.format("%.2f", tostring(baro_mmhg)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        else
            sasl.gl.drawText (Font_AirbusDUL, 222, 40, "STD", 28, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        end

        --if adirs_is_mach_ok(PFD_CAPT) then
        --    -- Mach number, this is available only if the ADR for the Capt is ok
        --    local good_mach = Round(adirs_get_mach(PFD_CAPT) * 100, 0)
        --    if good_mach < 100 then
        --        sasl.gl.drawText (Font_AirbusDUL, 60, 40, "." .. good_mach, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        --    else
        --        sasl.gl.drawText (Font_AirbusDUL, 60, 40, good_mach/100, 27, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)            
        --    end
        --end
    end
end

function update()

    if ((get(Stby_IAS) > 50 or get(All_on_ground) == 0) and get(HOT_bus_1_pwrd) == 1) or get(DC_ess_bus_pwrd) == 1 then
        set(ISIS_powered, 1)
    else
        set(ISIS_powered, 0)
        set(ISIS_ready, 0)
        isis_start_time = 0
        return
    end
    
    if isis_start_time == 0 then
        isis_start_time = get(TIME)
    end

    if get(TIME) - isis_start_time > TIME_TO_ALIGN_SEC then
        set(ISIS_ready, 1)
    else
        set(ISIS_ready, 1)
    end

end
