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

--a32nx datarefs

function auto_update()
        set(Capt_pfd_displaying_status, 1)
        set(Capt_nd_displaying_status, 2)
        set(Fo_pfd_displaying_status, 1)
        set(Fo_nd_displaying_status, 2)
        set(EWD_displaying_status, 3)
        set(ECAM_displaying_status, 4)
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

function update()
    if get(Override_DMC) == 0 then
        auto_update()
    end

    update_displays()

end
