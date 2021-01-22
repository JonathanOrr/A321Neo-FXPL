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
include("FBW/FBW_subcomponents/fbw_system_subcomponents/flt_computers.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/mode_transition.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/lateral_augmentation.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/vertical_augmentation.lua")
include("FBW/FBW_subcomponents/fbw_system_subcomponents/law_reconfiguration.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/")
addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/fbw_system_subcomponents")

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
local last_kill_value = 0--used to put the controls to nuetural when killing the FBW
local kill_delta = 0--used to put the controls to nuetural when killing the FBW
local last_roll = 0
local last_pitch = 0
local last_vpath = 0

local function FBW_kill_switch_logic()
    kill_delta = get(FBW_kill_switch) - last_kill_value
    last_kill_value = get(FBW_kill_switch)
    if kill_delta == 1 then
        set(Roll_artstab, 0)
        set(Pitch_artstab, 0)
        print("FBW killed reseting controls")
    end
end

function update()
    FBW_kill_switch_logic()

    updateAll(components)

    --system subcomponents
    Fctl_computuers_status_computation(Fctl_computers_var_table)
    Compute_fctl_button_states()
    FBW_law_reconfiguration(FBW_law_var_table)
    if get(FBW_total_control_law) == FBW_NORMAL_LAW then
        FBW_normal_mode_transition(FBW_modes_var_table)
    else
        FBW_alternate_mode_transition(FBW_modes_var_table)
    end

    if get(DELTA_TIME) ~= 0 then
        --calculate true roll rate
        set(True_roll_rate, (get(Flightmodel_roll) - last_roll) / get(DELTA_TIME))
        --calculate true pitch rate
        set(True_pitch_rate, (get(Flightmodel_pitch) - last_pitch) / get(DELTA_TIME))
        --calculate Vpath pitch rate
        set(Vpath_pitch_rate, (get(Vpath) - last_vpath) / get(DELTA_TIME))
    end
    last_roll = get(Flightmodel_roll)
    last_pitch = get(Flightmodel_pitch)
    last_vpath = get(Vpath)
end
