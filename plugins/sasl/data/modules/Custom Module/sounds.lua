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
-- File: sounds.lua 
-- Short description: Sound management
-------------------------------------------------------------------------------

include('sounds_GPWS.lua')

Sounds_elec_bus_delayed = createGlobalPropertyf("a321neo/sounds/elec_bus_delayed", 0, false, true, false)
Sounds_blower_delayed   = createGlobalPropertyf("a321neo/sounds/blower_delayed", 0, false, true, false)
Sounds_extract_delayed  = createGlobalPropertyf("a321neo/sounds/extract_delayed", 0, false, true, false)

function thrust_rush()
    set(SOUND_rush_L , get(L_throttle_blue_dot) - get(Eng_1_N1))
    set(SOUND_rush_R , get(R_throttle_blue_dot) - get(Eng_2_N1))
end


function blower_extract_delay()
    if get(AC_ess_bus_pwrd) == 1 then
        set(Sounds_elec_bus_delayed, 1) 
    else
        Set_dataref_linear_anim(Sounds_elec_bus_delayed, 0, 0, 1, 0.5)
    end

    Set_dataref_linear_anim(Sounds_blower_delayed, get(Ventilation_blower_running), 0, 1, 0.15)
    Set_dataref_linear_anim(Sounds_extract_delayed, get(Ventilation_extract_running), 0, 1, 0.15)


    if get(AC_bus_1_pwrd) == 1 then
        set_alt_callouts()
        update_retard()
        play_gpws_sounds()
    end
end

function update()
    blower_extract_delay()
    thrust_rush()
end
