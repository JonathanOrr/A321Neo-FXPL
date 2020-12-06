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
-- File: source_switching.lua
-- Short description: Display switch logic
-------------------------------------------------------------------------------

include('constants.lua')

--declare states--
local PFD = 1
local ND = 2
local EWD = 3
local ECAM = 4

-- status
local pfd_nd_xfr_capt = false
local pfd_nd_xfr_fo   = false
local ecam_nd_xfr     = 0 -- -1, 0, 1
local eis_selector    = 0 -- -1, 0, 1
----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------

sasl.registerCommandHandler (DMC_PFD_ND_xfr_capt, 0, function(phase) if phase == SASL_COMMAND_BEGIN then pfd_nd_xfr_capt = not pfd_nd_xfr_capt end end)
sasl.registerCommandHandler (DMC_PFD_ND_xfr_fo,   0, function(phase) if phase == SASL_COMMAND_BEGIN then pfd_nd_xfr_fo = not pfd_nd_xfr_fo end end)

sasl.registerCommandHandler (DMC_ECAM_ND_xfr_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then ecam_nd_xfr = math.min(1,  ecam_nd_xfr + 1) end end)
sasl.registerCommandHandler (DMC_ECAM_ND_xfr_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then ecam_nd_xfr = math.max(-1, ecam_nd_xfr - 1) end end)

sasl.registerCommandHandler (DMC_EIS_selector_up, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eis_selector = math.min(1, eis_selector + 1) end end)
sasl.registerCommandHandler (DMC_EIS_selector_dn, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eis_selector = math.max(-1,  eis_selector - 1) end end)


----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------
function auto_update()
    set(Capt_pfd_displaying_status, 1)
    set(Capt_nd_displaying_status, 2)
    set(Fo_pfd_displaying_status, 1)
    set(Fo_nd_displaying_status, 2)
    set(EWD_displaying_status, 3)
    set(ECAM_displaying_status, 4)

    -- Automatic transfers
    if get(EWD_brightness_act) < 0.01 then
        set(ECAM_displaying_status, EWD)
    end

    if get(Capt_PFD_brightness_act) < 0.01 then
        set(Capt_nd_displaying_status, PFD)
    end

    if get(Fo_PFD_brightness_act) < 0.01 then
        set(Fo_nd_displaying_status, PFD)
    end

    -- Manual transfers
    if pfd_nd_xfr_capt and ecam_nd_xfr ~= -1 then
        if get(Capt_nd_displaying_status) == PFD then
            set(Capt_nd_displaying_status, ND)
            set(Capt_pfd_displaying_status, PFD)
        else
            set(Capt_nd_displaying_status, PFD)
            set(Capt_pfd_displaying_status, ND)                    
        end
    elseif pfd_nd_xfr_capt then
        if get(Capt_pfd_displaying_status) == PFD then
            set(Capt_pfd_displaying_status, ND)
        else
            set(Capt_pfd_displaying_status, PFD)
        end
    end

    if pfd_nd_xfr_fo and ecam_nd_xfr ~= 1 then
        if get(Fo_nd_displaying_status) == PFD then
            set(Fo_nd_displaying_status, ND)
            set(Fo_pfd_displaying_status, PFD)
        else
            set(Fo_nd_displaying_status, PFD)
            set(Fo_pfd_displaying_status, ND)                    
        end
    elseif pfd_nd_xfr_capt then
        if get(Fo_pfd_displaying_status) == PFD then
            set(Fo_pfd_displaying_status, ND)
        else
            set(Fo_pfd_displaying_status, PFD)
        end
    end
 
    -- From ECAM press button
    if get(DMC_requiring_ECAM_EWD_swap) == 1 then
        if get(EWD_brightness_act) < 0.01 then
            set(ECAM_displaying_status, ECAM)
        end
        if get(ECAM_brightness_act) < 0.01 then
            set(EWD_displaying_status, ECAM)
        end
    end
    
    
    -- Rotary knob 
    if ecam_nd_xfr == -1 then
        set(Capt_nd_displaying_status, get(ECAM_displaying_status))
        set(ECAM_displaying_status, ND)
    elseif ecam_nd_xfr == 1 then
        set(Fo_nd_displaying_status, get(ECAM_displaying_status))
        set(ECAM_displaying_status, ND)
    else
    
    end
 
end

function has_power(command) -- Still TODO

    if command == ECAM_displaying_status then
        if get(AC_bus_2_pwrd) == 0 then
            return false
        else
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.43, 0.43)   -- 50W (just hypothesis)
            return true
        end        
    end

    return true
end

function update_set(command, display)
    
    if get(command) == PFD then
        set(display, 1, PFD)
    else
        set(display, 0, PFD)
    end
    
    if get(command) == ND then
        set(display, 1, ND)
    else
        set(display, 0, ND)
    end
    
    if get(command) == EWD then
        set(display, 1, EWD)
    else
        set(display, 0, EWD)
    end
    
    if get(command) == ECAM then
        set(display, 1, ECAM)
    else
        set(display, 0, ECAM)
    end


end

function update_displays()
    update_set(Capt_pfd_displaying_status, Capt_pfd_show)
    update_set(Capt_nd_displaying_status,  Capt_nd_show)
    update_set(Fo_pfd_displaying_status,   Fo_pfd_show)
    update_set(Fo_nd_displaying_status,    Fo_nd_show)
    update_set(EWD_displaying_status,      EWD_show)
    update_set(ECAM_displaying_status,     ECAM_show)
end

function update_knobs()

    Set_dataref_linear_anim(DMC_position_ecam_nd, ecam_nd_xfr, -1, 1, 5)
    Set_dataref_linear_anim(DMC_position_dmc_eis, eis_selector, -1, 1, 5)

end

function update_dmc_status()
    set(Capt_pfd_valid, 1)
    set(Capt_nd_valid,  1)
    set(Fo_pfd_valid,   1)
    set(Fo_nd_valid,    1)
    set(EWD_valid,      1)
    set(ECAM_valid,     1)
    
    local dmc_1_fail = get(FAILURE_DISPLAY_DMC_1) == 1 or get(AC_ess_bus_pwrd) == 0
    local dmc_2_fail = get(FAILURE_DISPLAY_DMC_2) == 1 or get(AC_bus_2_pwrd) == 0
    local dmc_3_fail = get(FAILURE_DISPLAY_DMC_3) == 1 or not (get(AC_bus_1_pwrd) == 1 or (eis_selector == -1 and get(AC_ess_bus_pwrd) == 1))
    
    if eis_selector >= 0 and dmc_1_fail then
        set(Capt_pfd_valid, 0)
        set(Capt_nd_valid,  0)
    end

    if eis_selector <= 0 and dmc_2_fail then
        set(Fo_pfd_valid, 0)
        set(Fo_nd_valid,  0)
    end
    
    if eis_selector == -1 and dmc_3_fail then
        set(Capt_pfd_valid, 0)
        set(Capt_nd_valid,  0)
    end

    if eis_selector == 1 and dmc_3_fail then
        set(Fo_pfd_valid, 0)
        set(Fo_nd_valid,  0)
    end

    if (eis_selector == 0 and dmc_1_fail and dmc_2_fail) or (eis_selector == 1 and dmc_3_fail) then
        set(EWD_valid,  0)
        set(ECAM_valid,  0)
    end

end

function update()
    if get(Override_DMC) == 0 then
        auto_update()
    end

    update_displays()
    update_knobs()
    update_dmc_status()


end
