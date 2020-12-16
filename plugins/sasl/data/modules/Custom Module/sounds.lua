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
Sounds_GPWS_glideslope_hard = sasl.createCommand("a321neo/sounds/gpws/glideslope_hard", "")
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

local SOUND_CONTINUOUS_PAUSE    = 1
local SOUND_SHOT_INTERVAL = 5

local gpws_sounds = {

    -- Pull-UPs
    { source=GPWS_mode_1_pullup,    command=Sounds_GPWS_pullup,        duration = 0.9, continuous = true },
    { source=GPWS_mode_2_pullup,    command=Sounds_GPWS_pullup,        duration = 0.9, continuous = true },
    { source=GPWS_pred_terr_pull,   command=Sounds_GPWS_terraheadpull, duration = 2.0, continuous = true },
    { source=GPWS_pred_obst_pull,   command=Sounds_GPWS_obsaheadpull,  duration = 2.2, continuous = true },
    
    -- Terrain Clearence
    { source=GPWS_mode_2_terrterr,  command=Sounds_GPWS_terrterr,      duration = 1.2, continuous = false },
    { source=GPWS_mode_2_terr,      command=Sounds_GPWS_terr,          duration = 0.6, continuous = true },

    { source=GPWS_mode_4_a_terrain, command=Sounds_GPWS_tlterr,        duration = 1.2, continuous = false },
    { source=GPWS_mode_4_b_terrain, command=Sounds_GPWS_tlterr,        duration = 1.2, continuous = false },
    { source=GPWS_mode_4_c_terrain, command=Sounds_GPWS_tlterr,        duration = 1.2, continuous = false },

    -- TODO Minimum
    
    -- Predictive terrain
    { source=GPWS_pred_terr,        command=Sounds_GPWS_terrahead,     duration = 1.2, continuous = false, interval = 7 },
    { source=GPWS_pred_obst,        command=Sounds_GPWS_obsahead,      duration = 1.4, continuous = false, interval = 7 },

    -- TODO Altitude call out
    
    -- Gear/Flaps
    { source=GPWS_mode_4_tl_gear,   command=Sounds_GPWS_tlgear,        duration = 1.1, continuous = false },
    { source=GPWS_mode_4_tl_flaps,  command=Sounds_GPWS_tlflaps,       duration = 1.1, continuous = false },
    
    -- Sink Rate
    { source=GPWS_mode_1_sinkrate,  command=Sounds_GPWS_sinkrate,      duration = 0.7,   continuous = true },
    
    -- Don't sink
    { source=GPWS_mode_3_dontsink,  command=Sounds_GPWS_dontsink,      duration = 2,   continuous = false },
    
    -- Glideslope
    { source=GPWS_mode_5_glideslope,command=Sounds_GPWS_glideslope,    duration = 1,   continuous = false, interval = 3 },
    { source=GPWS_mode_5_glideslope_hard, command=Sounds_GPWS_glideslope_hard, duration = 1, continuous = true, interval = 3 },
    
    -- Pitch Pitch -- The priority of this is not a big issue because it's active when all the other modes are
    -- not active
    { source=GPWS_mode_pitch, command=Sounds_GPWS_pitch, duration = 2, continuous = false, interval = 1 },
}

local no_sound_before = 0

local function play_gpws_continuous(x)
    if get(TIME) - x.last_exec > x.duration + SOUND_CONTINUOUS_PAUSE then
        x.last_exec = get(TIME)
        no_sound_before = get(TIME) + x.duration + SOUND_CONTINUOUS_PAUSE
        sasl.commandOnce(x.command)
    end
end

local function play_gpws_shot(x)
    local interval = x.interval == nil and SOUND_SHOT_INTERVAL or x.interval
    
    if get(TIME) - x.last_exec > x.duration + interval then
        x.last_exec = get(TIME)
        sasl.commandOnce(x.command)
        no_sound_before = get(TIME) + x.duration + SOUND_CONTINUOUS_PAUSE
        return true -- Start playing, stop other sounds
    end

    if get(TIME) - x.last_exec > x.duration + SOUND_CONTINUOUS_PAUSE then
        return true -- Still playing, stop other sounds
    end
    return false
end


local function play_gpws_sounds()

    if get(TIME) - no_sound_before < 0 then
        return
    end

    for i,x in ipairs(gpws_sounds) do
        -- For each sound...
        if get(x.source) == 1 then
            -- Ok, we need to play this sound
            
            if x.last_exec == nil then
                x.last_exec = 0
            end
            
            if x.continuous then
                -- Continuous sounds always break the subsequent ones
                play_gpws_continuous(x)
                break
            elseif play_gpws_shot(x) then
                -- Non-Continuous sounds not necessarily block the others                    
                break
            end
        end
    end

end

function update()

    if get(AC_ess_bus_pwrd) == 1 then
        set(Sounds_elec_bus_delayed, 1) 
    else
        Set_dataref_linear_anim(Sounds_elec_bus_delayed, 0, 0, 1, 0.5)
    end

    Set_dataref_linear_anim(Sounds_blower_delayed, get(Ventilation_blower_running), 0, 1, 0.15)
    Set_dataref_linear_anim(Sounds_extract_delayed, get(Ventilation_extract_running), 0, 1, 0.15)

    play_gpws_sounds()

end
