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
-- File: fire_eng_apu.lua
-- Short description: Fire protection for engines and APU
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local TIME_TO_DISCH = 2
local TIME_TO_EXTINGUISH_APU = 5 + math.random() * 10

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local apu_still_on_fire = false
local apu_squib_triggered = false
local apu_squib_triggered_time = 0

FIRE_sys.apu_block_position  = false
FIRE_sys.apu_squib_discharged = false
FIRE_sys.apu_on_test = false

----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------

sasl.registerCommandHandler (FIRE_cmd_push_APU, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then 
        FIRE_sys.apu_block_position = not FIRE_sys.apu_block_position
    end
end)

sasl.registerCommandHandler (FIRE_cmd_APU_A, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if FIRE_sys.apu_block_position and not apu_squib_triggered then
            apu_squib_triggered = true
            apu_squib_triggered_time = get(TIME)
        end
    end
end)

sasl.registerCommandHandler (FIRE_cmd_test_APU, 0, function(phase)
    if phase == SASL_COMMAND_CONTINUE then
        FIRE_sys.apu_on_test = true
    else
        FIRE_sys.apu_on_test = false
    end
end)



----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function update_pbs()
    pb_set(PB.ovhd.fire_apu_block, apu_still_on_fire or FIRE_sys.apu_on_test, false)
    pb_set(PB.ovhd.fire_apu_ag,    FIRE_sys.apu_squib_discharged or FIRE_sys.apu_on_test, FIRE_sys.apu_block_position or FIRE_sys.apu_on_test)
end

local function update_drs()
    Set_dataref_linear_anim_nostop(Fire_pb_APU_lever, FIRE_sys.apu_block_position and 1 or 0, 0, 1, 10)
    
end


local function update_fire()

    apu_still_on_fire = get(FAILURE_FIRE_APU) == 1

    if apu_squib_triggered_time ~= 0 then
        if get(TIME) - apu_squib_triggered_time > TIME_TO_DISCH then    
            FIRE_sys.apu_squib_discharged = true
        end
        if get(TIME) - apu_squib_triggered_time > TIME_TO_EXTINGUISH_APU then    
            apu_still_on_fire = false
        end
    end 
end

----------------------------------------------------------------------------------------------------
-- Main update function
----------------------------------------------------------------------------------------------------

function update()
    perf_measure_start("fire_eng_apu:update()")

    update_fire()
    update_pbs()
    update_drs()
    
    perf_measure_stop("fire_eng_apu:update()")
end
