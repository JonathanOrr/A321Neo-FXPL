include("libs/table.save.lua")

local EFB = {
    prefrences = {
        toggles = {
            syncqnh = false,
            pausetd = false,
            copilot = false,
        },
        sliders = {
            sound_int = 1,
            sound_ext = 1,
            display_aa = 0,
        },
        dropdowns = {
            nws = 0,
        },
        networking = {
            simbrief_id = ""
        },
    },
}   

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function EFB_PREFRENCES_set_syncqnh(boolean)
    EFB.prefrences.toggles.syncqnh = boolean
end

function EFB_PREFRENCES_get_syncqnh()
    return EFB.prefrences.toggles.syncqnh
end

function EFB_PREFRENCES_set_pausetd(boolean)
    EFB.prefrences.toggles.pausetd = boolean
end

function EFB_PREFRENCES_get_pausetd()
    return EFB.prefrences.toggles.pausetd
end

function EFB_PREFRENCES_set_copilot(boolean)
    EFB.prefrences.toggles.copilot = boolean
end

function EFB_PREFRENCES_get_copilot()
    return EFB.prefrences.toggles.copilot
end

function EFB_PREFRENCES_set_sound_int(value)
    EFB.prefrences.sliders.sound_int = value
end

function EFB_PREFRENCES_get_sound_int()
    return EFB.prefrences.sliders.sound_int
end

function EFB_PREFRENCES_set_sound_ext(value)
    EFB.prefrences.sliders.sound_ext = value
end

function EFB_PREFRENCES_get_sound_ext()
    return EFB.prefrences.sliders.sound_ext
end

function EFB_PREFRENCES_set_display_aa(value)
    EFB.prefrences.sliders.display_aa = value
end

function EFB_PREFRENCES_get_display_aa()
    return EFB.prefrences.sliders.display_aa
end

function EFB_PREFRENCES_set_nws(value)
    EFB.prefrences.dropdowns.nws = value
end

function EFB_PREFRENCES_get_nws()
    return EFB.prefrences.dropdowns.nws
end

function EFB_PREFRENCES_set_simbrief_id(value)
    EFB.prefrences.networking.simbrief_id = value
end

function EFB_PREFRENCES_get_simbrief_id()
    return EFB.prefrences.networking.simbrief_id
end

function EFB_PREFRENCES_SAVE()
    table.save(EFB, moduleDirectory .. "/Custom Module/saved_configs/EFB_preferences.cfg")
end

function EFB_PREFRENCES_LOAD()
    local table_load_buffer = table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_prefrences.cfg")
end

EFB_PREFRENCES_LOAD()

