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
-- File: failures_manager.lua
-- Short description: Failure cascade management and master caution/warning
-------------------------------------------------------------------------------


local WARNING_BLINK_HZ = 4

local already_triggered_mc = false
local already_triggered_mw = false
local master_warning_active = false
local master_caution_active = false

sasl.registerCommandHandler (Failures_cancel_master_caution, 0,  function(phase) Failures_cancel_master_caution_handler(phase) end )
sasl.registerCommandHandler (Failures_cancel_master_warning, 0,  function(phase) Failures_cancel_master_warning_handler(phase) end )

function Failures_cancel_master_caution_handler(phase)
    if phase == SASL_COMMAND_BEGIN then
        master_caution_active = false
    end
end

function Failures_cancel_master_warning_handler(phase)
    if phase == SASL_COMMAND_BEGIN then
        master_warning_active = false
    end
end

local function update_master_wc()
    if get(ReqMasterCaution) == 1 then
        if not already_triggered_mc then
            master_caution_active = true
            already_triggered_mc  = true
        end
    else
        already_triggered_mc = false
    end

    if get(ReqMasterWarning) == 1 then
        if not already_triggered_mw then
            master_warning_active = true
            already_triggered_mw = true
        end
    else
        already_triggered_mw = false
    end

    if master_warning_active then
        if (math.floor(get(TIME) * WARNING_BLINK_HZ) % 2) == 0 then
            pb_set(PB.glare.master_warning, true, true)
        else
            pb_set(PB.glare.master_warning, false, false)
        end
    else
        pb_set(PB.glare.master_warning, false, false)    
    end

    if master_caution_active then
        pb_set(PB.glare.master_caution, true, true)
    else
        pb_set(PB.glare.master_caution, false, false)
    end

    set(ReqMasterCaution, 0)
    set(ReqMasterWarning, 0)
end

local function check_wc_voltage()
    if get(AC_ess_bus_pwrd) == 0 and get(AC_bus_2_pwrd) == 0 then
        -- No power for the FWC
        master_caution_active = false
        master_warning_active = false
        set(ReqMasterCaution, 0)
        set(ReqMasterWarning, 0)
    end
end

function update()
    set(XPlane_Auto_Failure, 0) -- Enforce the X-Plane failures to off: bad things happen if you don't
                                -- use our failure manager.

    check_wc_voltage()
    update_master_wc()
end

