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
local passenger_supply = false -- True if masks dropped
local high_alt_landing = false
local tmr_reset        = false

set(Override_oxygen, 1)
set(Oxygen_ckpt_psi, 1200 + math.random() * 100)

sasl.registerCommandHandler (MNTN_OXY_reset, 0, function(phase) if phase == SASL_COMMAND_BEGIN then tmr_reset = not tmr_reset end end)
sasl.registerCommandHandler (Oxygen_toggle_crew, 0, function(phase) if phase == SASL_COMMAND_BEGIN then crew_supply_valve = not crew_supply_valve end end)
sasl.registerCommandHandler (Oxygen_toggle_high_alt_ldg, 0, function(phase) if phase == SASL_COMMAND_BEGIN then high_alt_landing = not high_alt_landing end end)
sasl.registerCommandHandler (Oxygen_man_mask_on, 0, function(phase) if phase == SASL_COMMAND_BEGIN then passenger_supply = true end end)

function update_pushbuttons()
    pb_set(PB.ovhd.oxy_crew_supply, not crew_supply_valve, false)
    pb_set(PB.ovhd.oxy_passengers, false, passenger_supply)
    pb_set(PB.ovhd.oxy_high_alt_land, high_alt_landing, false)
    pb_set(PB.ovhd.mntn_oxy_tmr_reset, tmr_reset, false)
end

function update_pass_masks()
    if (not high_alt_landing and get(Cabin_alt_ft) > 14000) or (high_alt_landing and get(Cabin_alt_ft) > 16000) then
        passenger_supply = true
    end
    
    if tmr_reset then
        passenger_supply = false
    end
end

function update()
    set(Oxygen_pilot_feeling, get(Cabin_alt_ft))
    
    update_pushbuttons()
    update_pass_masks()
end
