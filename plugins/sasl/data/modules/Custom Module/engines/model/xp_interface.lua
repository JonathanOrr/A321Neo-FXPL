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
local n1_start_left = 0
local n1_start_right = 0

local pitch_moment = globalPropertyf("sim/flightmodel/forces/M_prop")
local yaw_moment = globalPropertyf("sim/flightmodel/forces/N_prop")
local total_eng_forces = globalPropertyf("sim/flightmodel/forces/faxil_prop")

function eng_model_enforce_n1(eng, n1)
    local N1_max = eng_N1_limit_takeoff_clean(get(OTA), get(ACF_elevation) * 3.28084)
    if eng == 1 then
        engine_1_state.N1_spooled = n1
        engine_1_state.T_theoric = n1 / N1_max * engine_1_state.T_max
        ENG.dyn[1].n1 = n1 or 0 -- Just to be safe, let's check it's not nil
    else
        engine_2_state.N1_spooled = n1
        engine_2_state.T_theoric = n1 / N1_max * engine_2_state.T_max
        ENG.dyn[2].n1 = n1 or 0 -- Just to be safe, let's check it's not nil
    end
end

local function initialize()
    engine_1_state = engine_model_create_state()
    engine_2_state = engine_model_create_state()

    local override_eng_forc = globalPropertyi("sim/operation/override/override_engine_forces")
    local override_eng = globalPropertyi("sim/operation/override/override_engines")
    set(override_eng_forc, 1)
    set(override_eng, 1)

    -- If we reboot in the middle of the flight SASL, we want to set the engines to the same N1 of
    -- before the boot
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        n1_start_left  = 50
        n1_start_right = 50
    end
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
        bleed_ratio = get(L_pack_Flow) / 3,
        reverser_status = get(Eng_1_reverser_deployment),
        engine_is_available = ENG.dyn[1].is_avail
    }
    
    local inputs_eng_2 = {
        throttle = get(Override_eng_2_lever),
        alt_feet = elev_feet,
        oat = get(OTA),
        mach = m,
        sigma = get(Weather_Sigma),
        AI_wing_on = AI_sys.comp[ANTIICE_WING_R].valve_status,
        AI_engine_on = AI_sys.comp[ANTIICE_ENG_2].valve_status,
        bleed_ratio = get(R_pack_Flow) / 3,
        reverser_status = get(Eng_2_reverser_deployment),
        engine_is_available = ENG.dyn[2].is_avail
    }

    -- THE ORDER OR THE NExT FUNCTION CALLS IS *IMPORTANT*
    update_thrust(engine_1_state, inputs_eng_1)
    update_thrust(engine_2_state, inputs_eng_2)

    if n1_start_left ~= 0 then
        eng_model_enforce_n1(1, n1_start_left)
        n1_start_left = 0
    end
    if n1_start_right ~= 0 then
        eng_model_enforce_n1(2, n1_start_right)
        n1_start_right = 0
    end

    update_thrust_penalty(engine_1_state, inputs_eng_1)
    update_thrust_penalty(engine_2_state, inputs_eng_2)
    update_thrust_spooling(engine_1_state, inputs_eng_1)
    update_thrust_spooling(engine_2_state, inputs_eng_2)
    update_thrust_reversal(engine_1_state, inputs_eng_1)
    update_thrust_reversal(engine_2_state, inputs_eng_2)
    update_thrust_secondary(engine_1_state, inputs_eng_1)
    update_thrust_secondary(engine_2_state, inputs_eng_2)

    ENG.dyn[1].n1 = engine_1_state.N1_spooled
    ENG.dyn[2].n1 = engine_2_state.N1_spooled

    set(total_eng_forces, -(engine_1_state.T_actual_spool + engine_2_state.T_actual_spool))
    update_moment()
end

function eng_model_get_FF(eng)
    local state = eng == 1 and engine_1_state or engine_2_state
    return state and state.FF or 0
end

function eng_model_get_N2(eng)
    local state = eng == 1 and engine_1_state or engine_2_state
    return state and state.N2 or 0
end

function eng_model_get_NFAN(eng)
    local state = eng == 1 and engine_1_state or engine_2_state
    return state and state.NFAN or 0
end


function update_moment()

    local thrust_total = engine_1_state.T_actual_spool + engine_2_state.T_actual_spool
    set(pitch_moment, thrust_total * ENG.data.model.CG_vert_displacement)

    local thrust_asymmetry = engine_1_state.T_actual_spool - engine_2_state.T_actual_spool
    set(yaw_moment, thrust_asymmetry * ENG.data.model.CG_lat_displacement)
end
