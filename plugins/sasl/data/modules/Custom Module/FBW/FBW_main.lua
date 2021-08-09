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
-- File: FBW_main.lua
-- Short description: Fly-by-wire main file
-------------------------------------------------------------------------------

--include("FBW_subcomponents/limits_calculations.lua")
include("PID.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/mode_transition.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/law_reconfiguration.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/FLT_computer")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/sensor_filtering")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/lateral_augmentation")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/vertical_agumentation")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/yaw_augmentation")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/LAF_augmentation")

--xplane landing gear attitude correction--
local front_gear_length =  globalProperty("sim/aircraft/parts/acf_gear_leglen[0]")
local l_main_gear_length = globalProperty("sim/aircraft/parts/acf_gear_leglen[1]")
local r_main_gear_length = globalProperty("sim/aircraft/parts/acf_gear_leglen[2]")

--init
set(front_gear_length, 1.9)
set(l_main_gear_length, 2.23)
set(r_main_gear_length, 2.23)

function onPlaneLoaded()
    set(front_gear_length, 1.9)
    set(l_main_gear_length, 2.23)
    set(r_main_gear_length, 2.23)
end

function onAirportLoaded()
    set(front_gear_length, 1.9)
    set(l_main_gear_length, 2.23)
    set(r_main_gear_length, 2.23)
end

components = {
    rate_calculations {},

    filtering {},

    FLT_computer_main {},

    vertical_dynamics {},
    vertical_protections {},
    vertical_inputs {},
    vertical_controllers {},

    lateral_protections {},
    lateral_inputs {},
    lateral_controllers {},

    yaw_inputs {},
    yaw_controllers {},

    LAF_inputs {},
    LAF_controllers {},

    law_reconfiguration {},
    autothrust {},
    flight_controls {},
    limits_calculations {},

    lateral_augmentation {},
    vertical_augmentation {},
    yaw_augmentation {},
    LAF_augmentation {},
}

function update()
    updateAll(components)

    --Flight mode blending
    if get(FBW_total_control_law) == FBW_NORMAL_LAW or get(FBW_total_control_law) == FBW_ABNORMAL_LAW then
        FBW_normal_mode_transition(FBW_modes_var_table)
    elseif get(FBW_total_control_law) == FBW_DIRECT_LAW and get(FBW_alt_to_direct_law) == 0 then
        FBW_direct_mode_transition()
    else
        FBW_alternate_mode_transition(FBW_modes_var_table)
    end
end
