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

include('engines/model/blocks.lua')
include('engines/n1_modes.lua')

function update_thrust(engine_state, inputs)
    -- inputs: throttle, alt_feet, oat, mach, sigma
    local altitude_m = inputs.alt_feet * 0.3048

    local thrust_N = ENG.data.max_thrust * 4.44822
    local crit_temp  = ENG.data.modes.toga_penalties.temp_function(inputs.alt_feet)
    local T_takeoff = thrust_takeoff_computation(thrust_N, inputs.oat, crit_temp)

    local BPR = ENG.data.bypass_ratio
    local T_actual_th, T_max = thrust_main_equation(inputs.mach, T_takeoff, inputs.throttle, BPR, inputs.sigma, altitude_m)

    engine_state.T_actual_th = T_actual_th
    engine_state.T_max       = T_max
end

function update_thrust_penalty(engine_state, inputs)
    -- inputs: sigma, AI_wing_on, AI_engine_on, bleed_ratio
    local T_penalty = thrust_penalty_computation(inputs.sigma, inputs.AI_engine_on and 1 or 0, inputs.AI_wing_on and 1 or 0, inputs.bleed_ratio, engine_state.T_actual_th)
    engine_state.T_penalty = T_penalty
end

function update_thrust_spooling(engine_state, inputs)
    -- inputs: oat, alt_feet, engine_is_available
    local N1_base_max = eng_N1_limit_takeoff_clean(inputs.oat, inputs.alt_feet)

    local T_desired = engine_state.T_actual_th
    local T_max     = engine_state.T_max
    local T_penalty = engine_state.T_penalty
    T_actual_spool, N1_spooled = thrust_spool(engine_state, T_desired, T_penalty, T_max, N1_base_max, inputs.engine_is_available)

    engine_state.T_actual_spool = T_actual_spool
    engine_state.N1_spooled = N1_spooled
end

function update_thrust_secondary(engine_state, inputs)
    -- inputs: oat, alt_feet, mach
    engine_state.N2   = ENG.data.n1_to_n2_fun(engine_state.N1_spooled)
    engine_state.NFAN = ENG.data.n1_to_nfan(engine_state.N1_spooled)
    engine_state.EGT  = ENG.data.n1_to_egt_fun(engine_state.N1_spooled, inputs.oat)

    local altitude_m = inputs.alt_feet * 0.3048
    local isa_diff   = inputs.oat - thrust_ISA_temp(altitude_m)
    engine_state.FF  = ENG.data.n1_to_FF(engine_state.N1_spooled, inputs.alt_feet, inputs.mach, isa_diff)

    engine_state.FF = math.max(0,engine_state.FF)
end

function update_thrust_reversal(engine_state, inputs)

    -- Compute the core thrust, this must not be considered for the reverser 
    local core_thrust = 1/(1+ENG.data.bypass_ratio) * engine_state.T_actual_spool

    -- Now, let's get the remaining thrust
    local full_rev_thr = math.max(0, engine_state.T_actual_spool - core_thrust)

    engine_state.T_core    = core_thrust
    engine_state.T_turbine = full_rev_thr

    if  inputs.reverser_status < 0.01 then
        return -- Nothing to do
    end

    -- And according to reverser position let's compute the forward thrust 
    local forward_thr = full_rev_thr * inputs.reverser_status
    local backward_thr = full_rev_thr * (1-inputs.reverser_status)

    -- Then, the forward is inclined of 45 deg approx so
    forward_thr = forward_thr * math.cos(math.pi/4)

    -- And update the thrust (this is negative when reversers out)
    engine_state.T_actual_spool = core_thrust + backward_thr - forward_thr

end

function engine_model_create_state()
    return { 
        T_actual_th = 0,
        T_max = 0,
        T_penalty = 0,
        T_actual_spool = 0,
        T_theoric = 0,
        T_penalty_actual = 0,
        N1_spooled = 0
    }
end
