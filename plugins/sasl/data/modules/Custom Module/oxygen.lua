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
-- File: oxygen.lua 
-- Short description: OXYGEN systems
-------------------------------------------------------------------------------
local crew_supply_valve= true  -- This is the main valve not the actual supply
local crew_is_using_oxygen = false
local passenger_supply = false -- True if masks dropped
local high_alt_landing = false
local tmr_reset        = false

local cmd_pilot_oxy = sasl.findCommand("sim/oxy/crew_valve_toggle");

set(Override_oxygen, 1)
set(Oxygen_ckpt_psi, 1200 + math.random() * 100)

sasl.registerCommandHandler (MNTN_OXY_reset, 0, function(phase) if phase == SASL_COMMAND_BEGIN then tmr_reset = not tmr_reset end end)
sasl.registerCommandHandler (Oxygen_toggle_crew, 0, function(phase) if phase == SASL_COMMAND_BEGIN then crew_supply_valve = not crew_supply_valve end end)
sasl.registerCommandHandler (Oxygen_toggle_high_alt_ldg, 0, function(phase) if phase == SASL_COMMAND_BEGIN then high_alt_landing = not high_alt_landing end end)
sasl.registerCommandHandler (Oxygen_man_mask_on, 0, function(phase) if phase == SASL_COMMAND_BEGIN then passenger_supply = true end end)
sasl.registerCommandHandler (cmd_pilot_oxy, 0, function(phase) if phase == SASL_COMMAND_BEGIN then crew_is_using_oxygen = not crew_is_using_oxygen end end)

local function update_pushbuttons()
    pb_set(PB.ovhd.oxy_crew_supply, not crew_supply_valve, false)
    pb_set(PB.ovhd.oxy_passengers, false, passenger_supply)
    pb_set(PB.ovhd.oxy_high_alt_land, high_alt_landing, false)
    pb_set(PB.ovhd.mntn_oxy_tmr_reset, tmr_reset, false)
end

local function update_pass_masks()
    if (not high_alt_landing and get(Cabin_alt_ft) > 14000) or (high_alt_landing and get(Cabin_alt_ft) > 16000) then
        passenger_supply = true
    end
    
    if tmr_reset then
        passenger_supply = false
    end
end

local function update_cockpit_oxygen()
    set(Oxygen_pilot_feeling, get(Cabin_alt_ft))

    if crew_is_using_oxygen and crew_supply_valve then
        Set_dataref_linear_anim(Oxygen_ckpt_psi, 0, 0, 1400, 1)
        if get(Oxygen_ckpt_psi) > 0 then
            set(Oxygen_pilot_on, 1)
            set(Oxygen_pilot_feeling, 0)    -- No need set anim value here, it's already in x plane blackout
        else
            set(Oxygen_pilot_on, 0)
        end
    end
end

function update()

    update_pushbuttons()
    update_pass_masks()
    update_cockpit_oxygen()
end
