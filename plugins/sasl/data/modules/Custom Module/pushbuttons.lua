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
-- File: pushbuttons.lua
-- Short description: Miscellanea related to graphics
-------------------------------------------------------------------------------

-- WARNING: This is a global file, pay attention when you declare new non-local variables or
-- functions, they will be defined in EVERY file!

----------------------------------------------------------------------------------------------------
-- Constants and variables
----------------------------------------------------------------------------------------------------

local DR_PATH_PREFIX = "a321neo/cockpit"
local DR_PATH_PREFIX_OVH = "overhead"
local DR_PATH_SUFFIX_TOP = "_top"
local DR_PATH_SUFFIX_BTM = "_bottom"

local ELEC_ALWAYS_ON = 0 -- The button has always power or it has special behaviour (like ext pwr)
local LIGHT_BUS_DC    = 1 -- Button is powered when any DC bus is available
local LIGHT_BUS_AC    = 2 -- Button is powered when any AC bus is available

PB = {
    ovhd = {
        elec_battery_1 = {
            -- Example - two datarefs will be created:
            -- - a321neo/cockpit/overhead/elec_battery_1_top
            -- - a321neo/cockpit/overhead/elec_battery_1_bottom
            bus = LIGHT_BUS_DC        
        },
        elec_battery_2 = {
            bus = LIGHT_BUS_DC
        }
    }

}

----------------------------------------------------------------------------------------------------
-- Initialization function
----------------------------------------------------------------------------------------------------
local function initialization()

    for dr_name,x in pairs(PB.ovhd) do
        x.status_top    = false
        x.status_bottom = false
        local base_string = DR_PATH_PREFIX .. "/" .. DR_PATH_PREFIX_OVH .. "/" .. dr_name 
        x.dr_top    = createGlobalPropertyf(base_string .. DR_PATH_SUFFIX_TOP , 0, false, true, false)
        x.dr_bottom = createGlobalPropertyf(base_string .. DR_PATH_SUFFIX_BTM , 0, false, true, false)
    end
    
end

initialization()

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------


local function has_elec_pwr(pb)
    if pb.bus == ELEC_ALWAYS_ON then
        return true
    elseif pb.bus == LIGHT_BUS_DC then
        return get(DC_bat_bus_pwrd) + get(DC_bus_1_pwrd) + get(DC_bus_2_pwrd) + get(DC_ess_bus_pwrd) > 0
    elseif pb.bus == LIGHT_BUS_AC then
        return get(AC_ess_bus_pwrd) + get(AC_bus_1_pwrd) + get(AC_bus_2_pwrd) > 0
    end
end

function pb_set(pb, cond_bottom, cond_top)
    if has_elec_pwr(pb) then
        pb.status_top = cond_top
        pb.status_bottom = cond_bottom
    else
        pb.status_top = false
        pb.status_bottom = false
    end

    -- TODO: Test
    local brightness = 1 -- TODO
    local target_top = (pb.status_top and 1 or 0) * brightness
    local target_bottom = (pb.status_bottom and 1 or 0) * brightness
    
    print(pb.status_top, pb.status_bottom)
    
    set(pb.dr_top, target_top)
    set(pb.dr_bottom, target_bottom)

end


