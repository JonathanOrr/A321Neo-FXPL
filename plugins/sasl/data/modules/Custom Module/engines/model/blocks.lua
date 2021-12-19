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

local function get_ISA_temp(alt_meter)
    return math.max(-56.5, 15 - 6.5 * alt_meter/1000)
end

function thrust_takeoff_computation(FN0, oat, crit_temp)

    local diff_temp = (oat-crit_temp)
    if diff_temp > 0 then
        return FN0 - FN0 * ENG.data.model.coeff_to_thrust_crit_temp * diff_temp
    else
        return FN0
    end
end

function thrust_penalty_computation(AI_engine, AI_wing, bleed, T_actual)
    AI_engine = AI_engine * ENG.data.model.perc_penalty_AI_engine
    AI_wing   = AI_wing   * ENG.data.model.perc_penalty_AI_wing
    bleed     = bleed     * ENG.data.model.perc_penalty_AI_bleed

    return T_actual * (AI_engine+AI_wing+bleed)
end

function thrust_main_equation(mach, T_takeoff, throttle, BPR, sigma, altitude_m)
    local l1,l2,l3,l4

    if mach > ENG.data.model.thr_mach_barrier then
        l1 = thr_k_coeff[1][1]
        l2 = thr_k_coeff[2][1]
        l3 = thr_k_coeff[3][1]
        l4 = thr_k_coeff[4][1]
    else
        l1 = thr_k_coeff[1][2]
        l2 = thr_k_coeff[2][2]
        l3 = thr_k_coeff[3][2]
        l4 = thr_k_coeff[4][2]
    end

    local k2 = delta * l1
    local k3_k4 = (l2 + l3 * delta) * mach
    local k1 = l4

    local T_ratio = k1 + k2 + k3_k4

    local alt_ratio_exp = (altitude_m > ENG.data.model.thr_alt_limit) and ENG.data.model.thr_alt_penalty[1] or ENG.data.model.thr_alt_penalty[2]
    local alt_ratio = sigma^alt_ratio_exp

    T_ratio = T_ratio * alt_ratio
    local T_max = T_takeoff * T_ratio
    local T_actual_th = T_max * throttle

    return T_actual_th, T_max
end

local function thrust_spool_derivative(n1)
    return math.max(0.5,-24.115 + 1.3727 * n1 - 0.011526 * n1^2);
end

local function delay_thrust(eng_state, thrust_target, T_max, N1_base_max)
    local T_ratio = T_max / eng_state.T_current_value
    local N1_spooled = N1_base_max * T_ratio
    local spd_N1 = thrust_spool_derivative(N1_spooled)
    local T_ratio_inv = spd_N1 / N1_base_max;
    local spd_T = T_max / T_ratio_inv

    eng_state.T_current_value = Set_anim_value_no_lim(eng_state.T_current_value, thrust_target, spd_T)
    return eng_state.T_current_value
end

local function delay_penalty(eng_state, thrust_target)
    eng_state.penalty_T_current_value = Set_anim_value_no_lim(eng_state.penalty_T_current_value, thrust_target, 1)
    return eng_state.penalty_T_current_value
end

function thrust_spool(eng_state, T_desired, T_penalty, T_max, N1_base_max)
    local T_theoric = delay_thrust(eng_state, T_desired, T_max, N1_base_max)
    local T_penalty_actual = delay_penalty(eng_state, T_penalty)

    local T_actual_spool = math.max(0, T_theoric - T_penalty_actual)

    local T_ratio = T_max / T_theoric
    local N1_spooled = N1_base_max * T_ratio

    return T_actual_spool, N1_spooled
end

function thrust_create_eng_state()
    return { T_current_value = 0, penalty_T_current_value =0 }
end