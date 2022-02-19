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
include('libs/svm.lua')

local function thrust_takeoff_computation(FN0, oat, crit_temp)

    local diff_temp = (oat-crit_temp)
    if diff_temp > 0 then
        return FN0 - FN0 * ENG.data.model.coeff_to_thrust_crit_temp * diff_temp
    else
        return FN0
    end
end


function predict_engine_thrust(mach, density, oat, altitude_feet, N1)

    -- First of all, let's get the maximum thrust at this altitude/temperature/etc.
    -- If the engine is set as TOGA
    local thrust_N = ENG.data.max_thrust * 4.44822
    local crit_temp  = ENG.data.modes.toga_penalties.temp_function(altitude_feet)
    local T_takeoff = thrust_takeoff_computation(thrust_N, oat, crit_temp)
    local _, T_max = thrust_main_equation(mach, T_takeoff, 0, ENG.data.bypass_ratio, density, altitude_feet*0.3048)
    local T_penalty = thrust_penalty_computation(density, 0, 0, 2/3, T_max)

    -- Now let's scale down on the requested N1
    local N1_base_max = eng_N1_limit_takeoff_clean(oat, oat, altitude_feet)
    local T_ratio = (N1/N1_base_max)^(1/ENG.data.model.n1_thrust_non_linearity)
    return (T_max-T_penalty) * T_ratio
end


function predict_engine_N1(mach, density, oat, altitude_feet, thrust)
    -- NOTE: This function does not take into account minimum N1!
    -- user predict_minimum_N1_engine when necessary


    if thrust < 0 then
        sasl.logWarning("engine_thrust.lua:predict_engine_N1: anomalous thrust input")
        return 0
    end

    -- First of all, let's get the maximum thrust at this altitude/temperature/etc.
    -- If the engine is set as TOGA
    local thrust_N = ENG.data.max_thrust * 4.44822
    local crit_temp  = ENG.data.modes.toga_penalties.temp_function(altitude_feet)
    local T_takeoff = thrust_takeoff_computation(thrust_N, oat, crit_temp)
    local _, T_max = thrust_main_equation(mach, T_takeoff, 0, ENG.data.bypass_ratio, density, altitude_feet*0.3048)
    local T_penalty = thrust_penalty_computation(density, 0, 0, 2/3, T_max)

    -- Now let's scale down on the requested N1
    local T_ratio = thrust / (T_max-T_penalty)
    local N1_base_max = eng_N1_limit_takeoff_clean(oat, oat, altitude_feet)

    local N1 = T_ratio^ENG.data.model.n1_thrust_non_linearity * N1_base_max

    return math.max(0, N1)
end

function predict_minimum_N1_engine(altitude_feet, oat, density, flaps, is_gear_open)

    -- Now let's check if the computed N1 is below the minimum:
    local idle_appr = ENG.data.min_n1_approach_idle(altitude_feet, oat)
    local comp_min_n1 = ENG.data.min_n1_idle(density)

    return math.max(idle_appr, comp_min_n1, ENG.data.min_n1_idle_hard)

end
