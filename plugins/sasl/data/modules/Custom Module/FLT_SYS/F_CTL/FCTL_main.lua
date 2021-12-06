addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/INPUT")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/SLAT_FLAP")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/AIL")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/GND_SPLR")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/SPLR")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/ELEV")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/THS")
addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/RUD")

--initialise flight controls
set(Override_control_surfaces, 1)
set(SPDBRK_HANDLE_RATIO, 0)
set(THS_DEF, 0)

function onPlaneLoaded()
    set(Override_control_surfaces, 1)
    set(SPDBRK_HANDLE_RATIO, 0)
    set(THS_DEF, 0)
end

function onAirportLoaded()
    set(Override_control_surfaces, 1)
    set(SPDBRK_HANDLE_RATIO, 0)
    set(THS_DEF, 0)
end

function onModuleShutdown()--reset things back so other planes will work
    set(Override_control_surfaces, 0)
end

components = {
    INPUT_MAIN    {},
    SLAT_FLAP_CTL {},
    AIL_MAIN      {},
    GND_SPLR_MAIN {},
    SPLR_MAIN     {},
    ELEV_MAIN     {},
    THS_MAIN      {},
    RUD_MAIN      {},
}

function update()
    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            updateAll(components)
        end
    end
end