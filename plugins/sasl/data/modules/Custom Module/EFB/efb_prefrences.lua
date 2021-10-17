include("libs/table.save.lua")

--Written 2021 September - October by Henrick Ku

-- The purpose of this script is to make efb functions callable anywhere from the aircraft via the access functions.
-- Below are some funcions, then a global table called "EFB" is used to bridge the function and the global cosmos.
-- DO NOT ATTEMPT TO CALL EFB_PREFRENCES FUNCTIONS DIRECTLY, use EFB.pref_xxxxx() instead.
-- The efb_graphics_table is used to store most of the states of the EFB, I hope to store more stuff here sooner or later to make it more structured.

local efb_graphics_table = {
    prefrences = {
        toggles = {
            syncqnh = true,
            pausetd = false,
            copilot = false,
        },
        sliders = {
            sound_int = 1,
            sound_ext = 1,
            sound_warn = 1,
            sound_enviro = 1,
            display_aa = 0,
            brk_strength = 1,
        },
        dropdowns = {
            nws = 0,
        },
        networking = {
            simbrief_id = ""
        },
    },
}   

function EFB_PREFRENCES_set_syncqnh(boolean)
    efb_graphics_table.prefrences.toggles.syncqnh = boolean
end
EFB.pref_set_syncqnh = EFB_PREFRENCES_set_syncqnh

function EFB_PREFRENCES_get_syncqnh()
    return efb_graphics_table.prefrences.toggles.syncqnh
end
EFB.pref_get_syncqnh = EFB_PREFRENCES_get_syncqnh

function EFB_PREFRENCES_set_pausetd(boolean)
    efb_graphics_table.prefrences.toggles.pausetd = boolean
end
EFB.pref_set_pausetd = EFB_PREFRENCES_set_pausetd

function EFB_PREFRENCES_get_pausetd()
    return efb_graphics_table.prefrences.toggles.pausetd
end
EFB.pref_get_pausetd = EFB_PREFRENCES_get_pausetd

function EFB_PREFRENCES_set_copilot(boolean)
    efb_graphics_table.prefrences.toggles.copilot = boolean
end
EFB.pref_set_copilot = EFB_PREFRENCES_set_copilot

function EFB_PREFRENCES_get_copilot()
    return efb_graphics_table.prefrences.toggles.copilot
end
EFB.pref_get_copilot = EFB_PREFRENCES_get_copilot

function EFB_PREFRENCES_set_sound_int(value)
    efb_graphics_table.prefrences.sliders.sound_int = value
end
EFB.pref_set_sound_int = EFB_PREFRENCES_set_sound_int

function EFB_PREFRENCES_get_sound_int()
    return efb_graphics_table.prefrences.sliders.sound_int
end
EFB.pref_get_sound_int = EFB_PREFRENCES_get_sound_int

function EFB_PREFRENCES_set_sound_ext(value)
    efb_graphics_table.prefrences.sliders.sound_ext = value
end
EFB.pref_set_sound_ext = EFB_PREFRENCES_set_sound_ext

function EFB_PREFRENCES_get_sound_ext()
    return efb_graphics_table.prefrences.sliders.sound_ext
end
EFB.pref_get_sound_ext = EFB_PREFRENCES_get_sound_ext

function EFB_PREFRENCES_set_sound_warn(value)
    efb_graphics_table.prefrences.sliders.sound_warn = value
end
EFB.pref_set_sound_warn = EFB_PREFRENCES_set_sound_warn

function EFB_PREFRENCES_get_sound_warn()
    return efb_graphics_table.prefrences.sliders.sound_warn
end
EFB.pref_get_sound_warn = EFB_PREFRENCES_get_sound_warn

function EFB_PREFRENCES_set_sound_enviro(value)
    efb_graphics_table.prefrences.sliders.sound_enviro = value
end
EFB.pref_set_sound_enviro = EFB_PREFRENCES_set_sound_enviro

function EFB_PREFRENCES_get_sound_enviro()
    return efb_graphics_table.prefrences.sliders.sound_enviro
end
EFB.pref_get_sound_enviro = EFB_PREFRENCES_get_sound_enviro

function EFB_PREFRENCES_set_brk_strength(value)
    efb_graphics_table.prefrences.sliders.brk_strength = value
end
EFB.pref_set_brk_strength = EFB_PREFRENCES_set_brk_strength

function EFB_PREFRENCES_get_brk_strength()
    return efb_graphics_table.prefrences.sliders.brk_strength
end
EFB.pref_get_brk_strength = EFB_PREFRENCES_get_brk_strength

function EFB_PREFRENCES_set_display_aa(value)
    efb_graphics_table.prefrences.sliders.display_aa = value
end
EFB.pref_set_display_aa = EFB_PREFRENCES_set_display_aa

function EFB_PREFRENCES_get_display_aa()
    return efb_graphics_table.prefrences.sliders.display_aa
end
EFB.pref_get_display_aa = EFB_PREFRENCES_get_display_aa

function EFB_PREFRENCES_set_nws(value)
    efb_graphics_table.prefrences.dropdowns.nws = value
end
EFB.pref_set_nws = EFB_PREFRENCES_set_nws

function EFB_PREFRENCES_get_nws()
    return efb_graphics_table.prefrences.dropdowns.nws
end
EFB.pref_get_nws = EFB_PREFRENCES_get_nws

function EFB_PREFRENCES_set_simbrief_id(value)
    efb_graphics_table.prefrences.networking.simbrief_id = value
end
EFB.pref_set_simbrief_id = EFB_PREFRENCES_set_simbrief_id

function EFB_PREFRENCES_get_simbrief_id()
    return efb_graphics_table.prefrences.networking.simbrief_id
end
EFB.pref_get_simbrief_id = EFB_PREFRENCES_get_simbrief_id

function EFB_PREFRENCES_SAVE()
    table.save(efb_graphics_table, moduleDirectory .. "/Custom Module/saved_configs/EFB_prefrences.cfg")
end
EFB.pref_save = EFB_PREFRENCES_SAVE

function EFB_PREFRENCES_LOAD()
    local table_load_buffer = table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_prefrences.cfg")
    if table_load_buffer ~= nil then
        efb_graphics_table = table_load_buffer
    else
        EFB.pref_save() -- if the table doesn't exist, save it now.
    end
end
EFB.pref_load = EFB_PREFRENCES_LOAD


-- so that we can load the saved values at the beginning of the flight.
EFB.pref_load()






