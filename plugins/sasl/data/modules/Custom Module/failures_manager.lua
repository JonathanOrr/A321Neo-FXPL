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
local is_fwc_1_ok = false
local is_fwc_2_ok = false

local xp_fail_dr_eng_1_stall = globalProperty("sim/operation/failures/rel_comsta0")
local xp_fail_dr_eng_2_stall = globalProperty("sim/operation/failures/rel_comsta1")

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
    
    if get(AtLeastOneMasterWarning) == 0 then
        master_warning_active = false
    end
    
    if get(AtLeastOneMasterCaution) == 0 then
        master_caution_active = false
    end
    
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
            pb_set(PB.glare.master_warning_capt, is_fwc_2_ok, is_fwc_1_ok)
            pb_set(PB.glare.master_warning_fo,   is_fwc_1_ok, is_fwc_2_ok)
        else
            pb_set(PB.glare.master_warning_capt, false, false)
            pb_set(PB.glare.master_warning_fo,   false, false)
        end
    else
        pb_set(PB.glare.master_warning_capt, false, false)
        pb_set(PB.glare.master_warning_fo,   false, false)
    end

    if master_caution_active then
        pb_set(PB.glare.master_caution_capt, is_fwc_2_ok, is_fwc_1_ok)
        pb_set(PB.glare.master_caution_fo,   is_fwc_1_ok, is_fwc_2_ok)
    else
        pb_set(PB.glare.master_caution_capt, false, false)
        pb_set(PB.glare.master_caution_fo,   false, false)
    end

    set(ReqMasterCaution, 0)
    set(ReqMasterWarning, 0)
end

local function set_fwc_status()
    is_fwc_1_ok = get(AC_ess_bus_pwrd) == 1 and get(FAILURE_DISPLAY_FWC_1) == 0 
    is_fwc_2_ok = get(AC_bus_2_pwrd) == 1 and get(FAILURE_DISPLAY_FWC_2) == 0 

    if not is_fwc_1_ok and not is_fwc_2_ok then
        -- No power for the FWC, reset
        master_caution_active = false
        master_warning_active = false
        set(ReqMasterCaution, 0)
        set(ReqMasterWarning, 0)
    end
end

local function update_xp_eng_fail_datarefs()
    set(xp_fail_dr_eng_1_stall, get(FAILURE_ENG_STALL, 1)*6)
    set(xp_fail_dr_eng_2_stall, get(FAILURE_ENG_STALL, 2)*6)
end

function update()
    set(XPlane_Auto_Failure, 0) -- Enforce the X-Plane failures to off: bad things happen if you don't
                                -- use our failure manager.

    set_fwc_status()
    update_master_wc()
    update_xp_eng_fail_datarefs()
end

