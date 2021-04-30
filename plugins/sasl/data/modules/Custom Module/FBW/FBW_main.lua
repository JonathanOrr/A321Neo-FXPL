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

FBW = {
    lateral = {
        protections = {},
        inputs = {},
    },
    vertical = {
        protections = {},
        inputs = {},
    },
    yaw = {
        protections = {},
        inputs = {},
    },
    filtered_sensors = {}
}

--include("FBW_subcomponents/limits_calculations.lua")
include("PID.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/flt_computers.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/mode_transition.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/vertical_augmentation.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/law_reconfiguration.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/sensor_filtering")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/lateral_augmentation")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents/yaw_augmentation")

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
    filtering {},

    lateral_protections {},
    lateral_inputs {},
    lateral_controllers {},

    yaw_inputs {},
    yaw_controllers {},

    law_reconfiguration {},
    autothrust {},
    flight_controls {},
    limits_calculations {},

    lateral_augmentation {},
    vertical_augmentation {},
    yaw_augmentation {},
}

--register commands
sasl.registerCommandHandler (Toggle_ELAC_1, 0, Toggle_elac_1_callback)
sasl.registerCommandHandler (Toggle_ELAC_2, 0, Toggle_elac_2_callback)
sasl.registerCommandHandler (Toggle_FAC_1, 0, Toggle_fac_1_callback)
sasl.registerCommandHandler (Toggle_FAC_2, 0, Toggle_fac_2_callback)
sasl.registerCommandHandler (Toggle_SEC_1, 0, Toggle_sec_1_callback)
sasl.registerCommandHandler (Toggle_SEC_2, 0, Toggle_sec_2_callback)
sasl.registerCommandHandler (Toggle_SEC_3, 0, Toggle_sec_3_callback)

--previous values
local last_roll = 0
local last_pitch = 0
local last_hdg = 0
local last_vpath = 0

function update()
    updateAll(components)

    --system subcomponents
    Fctl_computuers_status_computation(Fctl_computers_var_table)
    Compute_fctl_button_states()

    --Flight mode blending
    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        FBW_normal_mode_transition(FBW_modes_var_table)
    elseif get(FBW_total_control_law) == FBW_DIRECT_LAW and get(FBW_alt_to_direct_law) == 0 then
        FBW_direct_mode_transition()
    else
        FBW_alternate_mode_transition(FBW_modes_var_table)
    end

    if get(DELTA_TIME) ~= 0 then
        --calculate true roll rate
        set(True_roll_rate, (get(Flightmodel_roll) - last_roll) / get(DELTA_TIME))
        --calculate true pitch rate
        set(True_pitch_rate, (get(Flightmodel_pitch) - last_pitch) / get(DELTA_TIME))
        --calculate true yaw rate
        set(True_yaw_rate, (get(Flightmodel_true_heading) - last_hdg) / get(DELTA_TIME))
        --calculate Vpath pitch rate
        set(Vpath_pitch_rate, (get(Vpath) - last_vpath) / get(DELTA_TIME))
    end
    last_roll = get(Flightmodel_roll)
    last_pitch = get(Flightmodel_pitch)
    last_hdg = get(Flightmodel_true_heading)
    last_vpath = get(Vpath)
end
