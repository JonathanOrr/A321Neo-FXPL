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
-- File: wheel_autobrake.lua 
-- Short description: Autobrake logic
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

local AUTOBRK_OFF = 0
local AUTOBRK_LOW = 1
local AUTOBRK_MED = 2
local AUTOBRK_MAX = 3

local LO_DECEL_MSEC  = 1.7  -- m/s^2 of deceleration to maintain
local MED_DECEL_MSEC = 3    -- m/s^2 of deceleration to maintain
local LO_DELAY_SEC   = 4    -- Delay from the spoiler deploymen to the activation of autobrake
local MED_DELAY_SEC  = 2    -- Delay from the spoiler deploymen to the activation of autobrake

----------------------------------------------------------------------------------------------------
-- Command registering and handlers
----------------------------------------------------------------------------------------------------

sasl.registerCommandHandler (Toggle_lo_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_LOW)  end)
sasl.registerCommandHandler (Toggle_med_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MED) end)
sasl.registerCommandHandler (Toggle_max_autobrake, 0, function(phase) Toggle_autobrake(phase, AUTOBRK_MAX) end)


function Toggle_autobrake(phase, value)
	if phase == SASL_COMMAND_BEGIN then
		if get(Wheel_autobrake_status) ~= value then
		    if value ~= AUTOBRK_MAX or get(All_on_ground) == 1 then -- MAX can be set only on ground
    			set(Wheel_autobrake_status, value)
            end
		else
			set(Wheel_autobrake_status, AUTOBRK_OFF)
		end
    end
end

local function update_ab_datarefs()
    
	set(Autobrakes_lo_button_state,  get(Wheel_autobrake_status) == AUTOBRK_LOW and 1 or 0) --00
	set(Autobrakes_med_button_state, get(Wheel_autobrake_status) == AUTOBRK_MED and 1 or 0)--00
	set(Autobrakes_max_button_state, get(Wheel_autobrake_status) == AUTOBRK_MAX and 1 or 0)--00

end

function update_autobrake()

    update_ab_datarefs()

end
