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

-- local snd_master_warning = sasl.al.loadSample("sounds/master_warning.wav")

Sounds_elec_bus_delayed = createGlobalPropertyf("a321neo/sounds/elec_bus_delayed", 0, false, true, false)
Sounds_blower_delayed   = createGlobalPropertyf("a321neo/sounds/blower_delayed", 0, false, true, false)
Sounds_extract_delayed  = createGlobalPropertyf("a321neo/sounds/extract_delayed", 0, false, true, false)

Sounds_GPWS_5_feet = sasl.createCommand("a321neo/sounds/gpws/feet_5", "")
Sounds_GPWS_10_feet = sasl.createCommand("a321neo/sounds/gpws/feet_10", "")
Sounds_GPWS_20_feet = sasl.createCommand("a321neo/sounds/gpws/feet_20", "")
Sounds_GPWS_30_feet = sasl.createCommand("a321neo/sounds/gpws/feet_30", "")
Sounds_GPWS_40_feet = sasl.createCommand("a321neo/sounds/gpws/feet_40", "")
Sounds_GPWS_50_feet = sasl.createCommand("a321neo/sounds/gpws/feet_50", "")
Sounds_GPWS_100_feet = sasl.createCommand("a321neo/sounds/gpws/feet_100", "")
Sounds_GPWS_200_feet = sasl.createCommand("a321neo/sounds/gpws/feet_200", "")
Sounds_GPWS_300_feet = sasl.createCommand("a321neo/sounds/gpws/feet_300", "")
Sounds_GPWS_400_feet = sasl.createCommand("a321neo/sounds/gpws/feet_400", "")
Sounds_GPWS_500_feet = sasl.createCommand("a321neo/sounds/gpws/feet_500", "")
Sounds_GPWS_1000_feet = sasl.createCommand("a321neo/sounds/gpws/feet_1000", "")
Sounds_GPWS_2000_feet = sasl.createCommand("a321neo/sounds/gpws/feet_2000", "")
Sounds_GPWS_2500_feet = sasl.createCommand("a321neo/sounds/gpws/feet_2500", "")
Sounds_GPWS_retard_feet = sasl.createCommand("a321neo/sounds/gpws/retard", "")

Sounds_GPWS_100Above = sasl.createCommand("a321neo/sounds/gpws/100Above", "")
Sounds_GPWS_Minimum = sasl.createCommand("a321neo/sounds/gpws/Minimum", "")

Sounds_GPWS_dontsink = sasl.createCommand("a321neo/sounds/gpws/dontsink", "")
Sounds_GPWS_glideslope = sasl.createCommand("a321neo/sounds/gpws/glideslope", "")
Sounds_GPWS_gpws = sasl.createCommand("a321neo/sounds/gpws/gpws", "")
Sounds_GPWS_inop = sasl.createCommand("a321neo/sounds/gpws/inop", "")
Sounds_GPWS_obsahead = sasl.createCommand("a321neo/sounds/gpws/obsahead", "")
Sounds_GPWS_obsaheadpull = sasl.createCommand("a321neo/sounds/gpws/obsaheadpull", "")
Sounds_GPWS_pullup = sasl.createCommand("a321neo/sounds/gpws/pullup", "")
Sounds_GPWS_sinkrate = sasl.createCommand("a321neo/sounds/gpws/sinkrate", "")
Sounds_GPWS_terr = sasl.createCommand("a321neo/sounds/gpws/terr", "")
Sounds_GPWS_terrahead = sasl.createCommand("a321neo/sounds/gpws/terrahead", "")
Sounds_GPWS_terrterr = sasl.createCommand("a321neo/sounds/gpws/terrterr", "")
Sounds_GPWS_terraheadpull = sasl.createCommand("a321neo/sounds/gpws/terraheadpull", "")
Sounds_GPWS_tlflaps = sasl.createCommand("a321neo/sounds/gpws/tlflaps", "")
Sounds_GPWS_tlgear = sasl.createCommand("a321neo/sounds/gpws/tlgear", "")
Sounds_GPWS_tlterr = sasl.createCommand("a321neo/sounds/gpws/tlterr", "")

Sounds_GPWS_pitch = sasl.createCommand("a321neo/sounds/gpws/pitch", "")
Sounds_GPWS_windshear = sasl.createCommand("a321neo/sounds/gpws/windshear", "")

function update()

    if get(AC_ess_bus_pwrd) == 1 then
        set(Sounds_elec_bus_delayed, 1) 
    else
        Set_dataref_linear_anim(Sounds_elec_bus_delayed, 0, 0, 1, 0.5)
    end

    Set_dataref_linear_anim(Sounds_blower_delayed, get(Ventilation_blower_running), 0, 1, 0.15)
    Set_dataref_linear_anim(Sounds_extract_delayed, get(Ventilation_extract_running), 0, 1, 0.15)

end
