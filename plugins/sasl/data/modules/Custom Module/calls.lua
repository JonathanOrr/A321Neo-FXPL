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
-- File: calls.lua 
-- Short description: CALLS system
-------------------------------------------------------------------------------
local emer_call_ckpt_req = false

-- EMER
sasl.registerCommandHandler (CALLS_cmd_EMER, 0, function(phase) if phase == SASL_COMMAND_BEGIN then emer_call_ckpt_req = not emer_call_ckpt_req end end)

-- EVAC
local evac_is_on   = false
local cockpit_horn = false
local capt_pursue  = true
sasl.registerCommandHandler (EVAC_cmd_command,  0, function(phase) if phase == SASL_COMMAND_BEGIN then evac_is_on = not evac_is_on; if evac_is_on then cockpit_horn = true end end end)
sasl.registerCommandHandler (EVAC_cmd_horn_off, 0, function(phase) if phase == SASL_COMMAND_BEGIN then cockpit_horn = false end end)
sasl.registerCommandHandler (EVAC_cmd_capt_purs_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then capt_pursue = not capt_pursue end end)

-- CALLS
function hanlder_call(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(CabinIsReady, 1)
    end
end

sasl.registerCommandHandler (CALLS_cmd_FWD, 0, function(phase) hanlder_call(phase) end)
sasl.registerCommandHandler (CALLS_cmd_MID, 0, function(phase) hanlder_call(phase) end)
sasl.registerCommandHandler (CALLS_cmd_EXIT, 0, function(phase) hanlder_call(phase) end)
sasl.registerCommandHandler (CALLS_cmd_ALL, 0, function(phase) hanlder_call(phase) end)
sasl.registerCommandHandler (CALLS_cmd_AFT, 0, function(phase) hanlder_call(phase) end)

function update()
    -- EMER
    pb_set(PB.ovhd.calls_emer, emer_call_ckpt_req, emer_call_ckpt_req and ( (get(TIME) % 0.5) < 0.25))

    -- EVAC
    pb_set(PB.ovhd.evac_cmd, evac_is_on, evac_is_on and ( (get(TIME) % 0.5) < 0.25))
    set(EVAC_cabin_active, PB.ovhd.evac_cmd.status_bottom and 1 or 0)
    set(EVAC_cockpit_horn, cockpit_horn and 1 or 0)
    Set_dataref_linear_anim_nostop(EVAC_capt_purs_lever, capt_pursue and 1 or 0, 0, 1, 5)

    if get(CabinIsReady) == 1 and (
           get(EWD_flight_phase) == PHASE_AIRBONE 
        or get(EWD_flight_phase) == PHASE_ELEC_PWR
        or get(EWD_flight_phase) == PHASE_BELOW_80_KTS) then

        -- Reset cabin is ready
        set(CabinIsReady, 0)
    end

end

