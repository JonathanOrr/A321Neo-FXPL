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

local n1_start_sim = {0, 0}

local pitch_moment = globalPropertyf("sim/flightmodel/forces/M_prop")
local yaw_moment = globalPropertyf("sim/flightmodel/forces/N_prop")
local total_eng_forces = globalPropertyf("sim/flightmodel/forces/faxil_prop")

function eng_model_enforce_n1(eng, n1)
    local N1_max = eng_N1_limit_takeoff_clean(get(OTA), get(OTA), get(ACF_elevation) * 3.28084)
    ENG.model_state[eng].N1_spooled = n1

    local T_ratio = (n1 / N1_max)^(1/ENG.data.model.n1_thrust_non_linearity)
    ENG.model_state[eng].T_theoric = T_ratio * ENG.model_state[eng].T_max
    ENG.dyn[eng].n1 = n1 or 0 -- Just to be safe, let's check it's not nil

    local inputs = {
        oat = get(OTA),
        alt_feet = get(Elevation_m),
        mach = get(Flightmodel_mach),
        throttle=0,
        sigma=get(Weather_Sigma)
    }
    update_thrust_secondary(ENG.model_state[eng], inputs)

end

function eng_model_enforce_n2(eng, n2)
    local n1 = ENG.data.n2_to_n1_fun(n2)
    n1 = math.min(n1,n2)    -- This is incorrect, but it's needed for the first seconds
    return eng_model_enforce_n1(eng, n1)
end

local function initialize()
    ENG.model_state = {}
    ENG.model_state[1] = engine_model_create_state()
    ENG.model_state[2] = engine_model_create_state()

    local override_eng_forc = globalPropertyi("sim/operation/override/override_engine_forces")
    local override_eng = globalPropertyi("sim/operation/override/override_engines")
    set(override_eng_forc, 1)
    set(override_eng, 1)

    -- If we reboot in the middle of the flight SASL, we want to set the engines to the same N1 of
    -- before the boot
    if get(Startup_running) == 1 or get(Capt_ra_alt_ft) > 20 then
        n1_start_sim[1] = 50
        n1_start_sim[2] = 50
    end
end

initialize()

local function update_engine_model_per(eng)
    local elev_feet = get(Elevation_m) * 3.28084
    if elev_feet > 50000 then
        -- Many parameters are off over this altitude, I'm sorry, engine failed
        ENG.dyn[eng].n1 = 0
        ENG.dyn[eng].is_avail = false
    end
    elev_feet = math.min(50000, elev_feet)  -- Model produces invalid data if the altitude is too high
    local m = get(Flightmodel_mach)
    m = m ~= m and 0 or m   -- Sometimes we get spurious NaN here
    m = math.min(0.95, m)   -- Model may produce invalid data in supersonic range (shouldn't the plane destroy at this speed?)

    local inputs = {
        throttle = eng == 1 and get(Override_eng_1_lever) or get(Override_eng_2_lever),
        alt_feet = elev_feet,
        oat = get(OTA),
        tat = get(TAT),
        mach = m,
        sigma = get(Weather_Sigma),
        AI_wing_on = AI_sys.comp[eng == 1 and ANTIICE_WING_L or ANTIICE_WING_R].valve_status,
        AI_engine_on = AI_sys.comp[eng == 1 and ANTIICE_ENG_1 or ANTIICE_ENG_2].valve_status,
        bleed_ratio = (eng == 1 and get(L_pack_Flow) or get(R_pack_Flow)) / 3,
        reverser_status = (eng == 1 and get(Eng_1_reverser_deployment) or get(Eng_2_reverser_deployment)),
        engine_is_available = ENG.dyn[eng].is_avail
    }

    -- THE ORDER OR THE NExT FUNCTION CALLS IS *IMPORTANT*
    update_thrust(ENG.model_state[eng], inputs)

    if n1_start_sim[eng] ~= 0 then
        eng_model_enforce_n1(eng, n1_start_sim[eng])
        n1_start_sim[eng] = 0
    end
        
    update_thrust_penalty(ENG.model_state[eng], inputs)
    update_thrust_spooling(ENG.model_state[eng], inputs)
    update_thrust_reversal(ENG.model_state[eng], inputs)
    update_thrust_secondary(ENG.model_state[eng], inputs)

    if 0 == get(Eng_is_starting, eng) then
        -- We update the N1 only if the engine is NOT starting
        ENG.dyn[eng].n1 = ENG.model_state[eng].N1_spooled
    else
        -- Instead, if it's starting, we update the internal state of N1
        -- with the current external one (enforced by the startup procedure)
        ENG.model_state[eng].N1_spooled = ENG.dyn[eng].n1
    end

end

function update_forces_and_moments()
    set(total_eng_forces, -(ENG.model_state[1].T_actual_spool + ENG.model_state[2].T_actual_spool))

    local thrust_total = ENG.model_state[1].T_actual_spool + ENG.model_state[2].T_actual_spool
    set(pitch_moment, thrust_total * ENG.data.model.CG_vert_displacement)

    local thrust_asymmetry = ENG.model_state[1].T_actual_spool - ENG.model_state[2].T_actual_spool
    set(yaw_moment, thrust_asymmetry * ENG.data.model.CG_lat_displacement)
end


function update_engine_model()
    update_engine_model_per(1)
    update_engine_model_per(2)
    update_forces_and_moments()
end

function eng_model_get_FF(eng)
    local state = ENG.model_state[eng]
    return state and state.FF or 0
end

function eng_model_get_N2(eng)
    local state = ENG.model_state[eng]
    return state and state.N2 or 0
end

function eng_model_get_NFAN(eng)
    local state = ENG.model_state[eng]
    return state and state.NFAN or 0
end
