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
-- Short description: Sound management for GPWS
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
 
local SOUND_CONTINUOUS_PAUSE    = 1
local SOUND_SHOT_INTERVAL = 5

-------------------------------------------------------------------------------
-- New commands for FMOD
-------------------------------------------------------------------------------
local Sounds_GPWS_5_feet = sasl.createCommand("a321neo/sounds/gpws/feet_5", "")
local Sounds_GPWS_10_feet = sasl.createCommand("a321neo/sounds/gpws/feet_10", "")
local Sounds_GPWS_20_feet = sasl.createCommand("a321neo/sounds/gpws/feet_20", "")
local Sounds_GPWS_30_feet = sasl.createCommand("a321neo/sounds/gpws/feet_30", "")
local Sounds_GPWS_40_feet = sasl.createCommand("a321neo/sounds/gpws/feet_40", "")
local Sounds_GPWS_50_feet = sasl.createCommand("a321neo/sounds/gpws/feet_50", "")
local Sounds_GPWS_100_feet = sasl.createCommand("a321neo/sounds/gpws/feet_100", "")
local Sounds_GPWS_200_feet = sasl.createCommand("a321neo/sounds/gpws/feet_200", "")
local Sounds_GPWS_300_feet = sasl.createCommand("a321neo/sounds/gpws/feet_300", "")
local Sounds_GPWS_400_feet = sasl.createCommand("a321neo/sounds/gpws/feet_400", "")
local Sounds_GPWS_500_feet = sasl.createCommand("a321neo/sounds/gpws/feet_500", "")
local Sounds_GPWS_1000_feet = sasl.createCommand("a321neo/sounds/gpws/feet_1000", "")
local Sounds_GPWS_2000_feet = sasl.createCommand("a321neo/sounds/gpws/feet_2000", "")
local Sounds_GPWS_2500_feet = sasl.createCommand("a321neo/sounds/gpws/feet_2500", "")
local Sounds_GPWS_retard = sasl.createCommand("a321neo/sounds/gpws/retard", "")
local Sounds_GPWS_retard_retard = sasl.createCommand("a321neo/sounds/gpws/retardretard", "")

local Sounds_GPWS_100Above = sasl.createCommand("a321neo/sounds/gpws/100Above", "")
local Sounds_GPWS_Minimum = sasl.createCommand("a321neo/sounds/gpws/Minimum", "")

local Sounds_GPWS_dontsink = sasl.createCommand("a321neo/sounds/gpws/dontsink", "")
local Sounds_GPWS_glideslope = sasl.createCommand("a321neo/sounds/gpws/glideslope", "")
local Sounds_GPWS_glideslope_hard = sasl.createCommand("a321neo/sounds/gpws/glideslope_hard", "")
local Sounds_GPWS_inop = sasl.createCommand("a321neo/sounds/gpws/gpws_inop", "")
local Sounds_GPWS_terr_inop = sasl.createCommand("a321neo/sounds/gpws/terrain_inop", "")
local Sounds_GPWS_obsahead = sasl.createCommand("a321neo/sounds/gpws/obsahead", "")
local Sounds_GPWS_obsaheadpull = sasl.createCommand("a321neo/sounds/gpws/obsaheadpull", "")
local Sounds_GPWS_pullup = sasl.createCommand("a321neo/sounds/gpws/pullup", "")
local Sounds_GPWS_sinkrate = sasl.createCommand("a321neo/sounds/gpws/sinkrate", "")
local Sounds_GPWS_terr = sasl.createCommand("a321neo/sounds/gpws/terr", "")
local Sounds_GPWS_terrahead = sasl.createCommand("a321neo/sounds/gpws/terrahead", "")
local Sounds_GPWS_terrterr = sasl.createCommand("a321neo/sounds/gpws/terrterr", "")
local Sounds_GPWS_terraheadpull = sasl.createCommand("a321neo/sounds/gpws/terraheadpull", "")
local Sounds_GPWS_tlflaps = sasl.createCommand("a321neo/sounds/gpws/tlflaps", "")
local Sounds_GPWS_tlgear = sasl.createCommand("a321neo/sounds/gpws/tlgear", "")
local Sounds_GPWS_tlterr = sasl.createCommand("a321neo/sounds/gpws/tlterr", "")

local Sounds_GPWS_pitch = sasl.createCommand("a321neo/sounds/gpws/pitch", "")
local Sounds_GPWS_windshear = sasl.createCommand("a321neo/sounds/gpws/windshear", "")

local Sounds_alt_callout   = createGlobalPropertyi("a321neo/sounds/alt_callout", 0, false, true, false)

-------------------------------------------------------------------------------
-- Global variables - GPWS
-------------------------------------------------------------------------------

local callouts_sound = { source=Sounds_alt_callout, command=nil, duration = -0.5, continuous = false, interval = 0.1}

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

    
    -- Pitch Pitch -- The priority of this is not a big issue because it's active when all the other modes are
    -- not active
    { source=GPWS_mode_pitch, command=Sounds_GPWS_pitch, duration = 2, continuous = false, interval = 1 },
    
    callouts_sound,
    
    -- Gear/Flaps
    { source=GPWS_mode_4_tl_gear,   command=Sounds_GPWS_tlgear,        duration = 1.1, continuous = false },
    { source=GPWS_mode_4_tl_flaps,  command=Sounds_GPWS_tlflaps,       duration = 1.1, continuous = false },
    
    -- Sink Rate
    { source=GPWS_mode_1_sinkrate,  command=Sounds_GPWS_sinkrate,      duration = 0.9,   continuous = true },
    
    -- Don't sink
    { source=GPWS_mode_3_dontsink,  command=Sounds_GPWS_dontsink,      duration = 2,   continuous = false },
    
    -- Glideslope
    { source=GPWS_mode_5_glideslope_hard, command=Sounds_GPWS_glideslope_hard, duration = 1, continuous = true, interval = 3 },
    { source=GPWS_mode_5_glideslope,command=Sounds_GPWS_glideslope,    duration = 1,   continuous = false, interval = 3 },

}

local no_sound_before = 0 -- No other sound can be played before this time

-------------------------------------------------------------------------------
-- Global variables - Altitude callouts
-------------------------------------------------------------------------------

local radio_values = {
    -1000,
    5,
    10,
    20,
    30,
    40,
    50,
    100,
    200,
    300,
    400,
    500,
    1000,
    2000,
    2500,
    1000000000
}
local radio_values_dr = {
    Sounds_GPWS_5_feet, -- never triggered
    Sounds_GPWS_5_feet,
    Sounds_GPWS_10_feet,
    Sounds_GPWS_20_feet,
    Sounds_GPWS_30_feet,
    Sounds_GPWS_40_feet,
    Sounds_GPWS_50_feet,
    Sounds_GPWS_100_feet,
    Sounds_GPWS_200_feet,
    Sounds_GPWS_300_feet,
    Sounds_GPWS_400_feet,
    Sounds_GPWS_500_feet,
    Sounds_GPWS_1000_feet,
    Sounds_GPWS_2000_feet,
    Sounds_GPWS_2500_feet,
    Sounds_GPWS_2500_feet -- never triggered
}
local radio_values_current = 1

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
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


function play_gpws_sounds()

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
    
    if get(TIME) - no_sound_before >= 0 then
        if get(GPWS_req_inop) == 1 then
            sasl.commandOnce(Sounds_GPWS_inop)
            no_sound_before = get(TIME) + 3
            set(GPWS_req_inop, 0)
        elseif get(GPWS_req_terr_inop) == 1 then
            sasl.commandOnce(Sounds_GPWS_terr_inop)
            no_sound_before = get(TIME) + 3
            set(GPWS_req_terr_inop, 0)
        end
    end

end


function set_alt_callouts()

    if math.floor(get(Capt_ra_alt_ft)) <= radio_values[radio_values_current] then
        callouts_sound.command = radio_values_dr[radio_values_current]
        set(Sounds_alt_callout, 1)
        radio_values_current = radio_values_current - 1
    else
        set(Sounds_alt_callout, 0)
    end
    
    if math.floor(get(Capt_ra_alt_ft)) >= radio_values[radio_values_current+1]+10 then
        radio_values_current = radio_values_current + 1
    end

end

