include("FBW_subcomponents/FCTL_SYS/slat_flaps_control.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/INPUT")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/AIL")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/GND_SPLR")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/SPLR")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/ELEV")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/FCTL_SYS/THS")

--initialise flight controls
set(Override_control_surfaces, 1)
set(Speedbrake_handle_ratio, 0)
set(THS_DEF, 0)

function onPlaneLoaded()
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
    set(THS_DEF, 0)
end

function onAirportLoaded()
    set(Override_control_surfaces, 1)
    set(Speedbrake_handle_ratio, 0)
    set(THS_DEF, 0)
end

function onModuleShutdown()--reset things back so other planes will work
    set(Override_control_surfaces, 0)
end

components = {
    INPUT_MAIN    {},
    AIL_MAIN      {},
    GND_SPLR_MAIN {},
    SPLR_MAIN     {},
    ELEV_MAIN     {},
    THS_MAIN      {},
    RUD_CTL       {},
}

function update()
    if get(Override_control_surfaces) == 1 then
        if get(DELTA_TIME) ~= 0 then
            updateAll(components)
            Slats_flaps_calc_and_control()
        end
    end
end