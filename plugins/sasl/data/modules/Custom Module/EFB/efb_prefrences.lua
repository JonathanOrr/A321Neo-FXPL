include("libs/table.save.lua")

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

function EFB_PREFRENCES_set_sound_warn(value)
    EFB.prefrences.sliders.sound_warn = value
end

function EFB_PREFRENCES_get_sound_warn()
    return EFB.prefrences.sliders.sound_warn
end

function EFB_PREFRENCES_set_sound_enviro(value)
    EFB.prefrences.sliders.sound_enviro = value
end

function EFB_PREFRENCES_get_sound_enviro()
    return EFB.prefrences.sliders.sound_enviro
end

function EFB_PREFRENCES_set_brk_strength(value)
    EFB.prefrences.sliders.brk_strength = value
end

function EFB_PREFRENCES_get_brk_strength()
    return EFB.prefrences.sliders.brk_strength
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
    table.save(EFB, moduleDirectory .. "/Custom Module/saved_configs/EFB_prefrences.cfg")
end

function EFB_PREFRENCES_LOAD()
    local table_load_buffer = table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_prefrences.cfg")
    if table_load_buffer ~= nil then
        EFB = table_load_buffer
    end
end

EFB_PREFRENCES_LOAD()




