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

include('engines/model/glue.lua')

local engine_1_state = nil
local engine_2_state = nil

local total_eng_forces = globalPropertyf("sim/flightmodel/forces/faxil_prop")
local pitch_moment = globalPropertyf("sim/flightmodel/forces/M_prop")
local yaw_moment = globalPropertyf("sim/flightmodel/forces/N_prop")
local total_eng_forces = globalPropertyf("sim/flightmodel/forces/faxil_prop")

local function initialize()
    engine_1_state = engine_model_create_state()
    engine_2_state = engine_model_create_state()

    local override_eng = globalPropertyi("sim/operation/override/override_engine_forces")
    set(override_eng, 1)
end

initialize()

function update_engine_model()

    local elev_feet = get(ACF_elevation) * 3.28084

    -- TODO: Fix AI_wing, one engine can provide both wings AI!

    local m = get(Capt_Mach)
    m = m ~= m and 0 or m

    local inputs_eng_1 = {
        throttle = get(Override_eng_1_lever),
        alt_feet = elev_feet,
        oat = get(OTA),
        mach = m,
        sigma = get(Weather_Sigma),
        AI_wing_on = AI_sys.comp[ANTIICE_WING_L].valve_status,
        AI_engine_on = AI_sys.comp[ANTIICE_ENG_1].valve_status,
        bleed_ratio = get(L_pack_Flow) / 3
    }
    
    local inputs_eng_2 = {
        throttle = get(Override_eng_2_lever),
        alt_feet = elev_feet,
        oat = get(OTA),
        mach = m,
        sigma = get(Weather_Sigma),
        AI_wing_on = AI_sys.comp[ANTIICE_WING_R].valve_status,
        AI_engine_on = AI_sys.comp[ANTIICE_ENG_2].valve_status,
        bleed_ratio = get(R_pack_Flow) / 3
    }

    -- THE ORDER OR THE NExT FUNCTION CALL IS *IMPORTANT*
    update_thrust(engine_1_state, inputs_eng_1)
    update_thrust(engine_2_state, inputs_eng_2)
    update_thrust_penalty(engine_1_state, inputs_eng_1)
    update_thrust_penalty(engine_2_state, inputs_eng_2)
    update_thrust_spooling(engine_1_state, inputs_eng_1)
    update_thrust_spooling(engine_2_state, inputs_eng_2)
    update_thrust_secondary(engine_1_state, inputs_eng_1)
    update_thrust_secondary(engine_2_state, inputs_eng_2)

    print("ENG1", engine_1_state.T_actual_spool, engine_1_state.N1_spooled)
    print("ENG2", engine_2_state.T_actual_spool, engine_2_state.N1_spooled)

    set(Eng_1_N1, engine_1_state.N1_spooled)
    set(Eng_2_N1, engine_2_state.N1_spooled)

    set(total_eng_forces, -(engine_1_state.T_actual_spool + engine_2_state.T_actual_spool))
    update_moment()
end

function update_moment()

    local thrust_total = engine_1_state.T_actual_spool + engine_2_state.T_actual_spool
    set(pitch_moment, thrust_total * ENG.data.model.CG_vert_displacement)

    local thrust_asymmetry = engine_1_state.T_actual_spool - engine_2_state.T_actual_spool
    set(yaw_moment, thrust_asymmetry * ENG.data.model.CG_lat_displacement)
end


function eng_model_enforce_n1(eng, n1)
    local N1_max = eng_N1_limit_takeoff_clean(get(OTA), get(ACF_elevation) * 3.28084)
    if eng == 1 then
        engine_1_state.N1_spooled = n1
        engine_1_state.T_theoric = n1 / N1_max * engine_1_state.T_max
    else
        engine_2_state.N1_spooled = n1
        engine_2_state.T_theoric = n1 / N1_max * engine_2_state.T_max
    end
end