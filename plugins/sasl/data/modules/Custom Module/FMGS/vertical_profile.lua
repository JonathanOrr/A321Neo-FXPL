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
-- File: vertical_profile.lua
-- Short description: Vertical profile computation
-------------------------------------------------------------------------------

include("FBW/FBW_subcomponents/FBW_SYS/FAC_computation/common_functions.lua");
include("FMGS/predictors/engine_thrust.lua")
include("FMGS/predictors/drag.lua")
include("libs/speed_helpers.lua")


local function request_climb_gradient(aircraft_mass, altitude)
    local empty_gradient = Table_extrapolate(climb_gradient[EMPTY], altitude)
    local full_gradient = Table_extrapolate(climb_gradient[FULL], altitude)
    local predicted_gradient = Math_rescale_no_lim(EMPTY_WEIGHT, empty_gradient, FULL_WEIGHT, full_gradient, aircraft_mass)
    return predicted_gradient
end

local function request_climb_distance(aircraft_mass, start_alt, end_alt)
    distance = (end_alt - start_alt) / math.tan(math.rad(request_climb_gradient(aircraft_mass, start_alt))) -- computing required climb distance from start_alt directly to end_alt
    distance = distance* 0.00016457883 -- back into nautical miles
    return distance
end


local function get_ROC_after_TO(rwy_alt, v2, takeoff_weight)
    -- This is the climb from rwy alt to rwy_alt + 400

    local N1 = get(Eng_N1_flex_temp) == 0 and get(Eng_N1_max_detent_toga) or get(Eng_N1_max_detent_flex)
    local density = get(Weather_Sigma)
    local _, tas, mach = convert_to_eas_tas_mach(v2, rwy_alt+200)   -- Let's use +200 to stay in the middle
    local thrust = predict_engine_thrust(mach, density, N1) * 2
    local drag   = predict_drag(density, tas, mach, 5)
    local gamma = ( thrust - drag ) / takeoff_weight;
    return tas * math.sin(gamma) * 60
end


function vertical_profile_update()
    -- Start with reset
    FMGS_sys.data.pred.takeoff.gdot = nil
    FMGS_sys.data.pred.takeoff.ROC_init = nil

    if not FMGS_sys.fpln.active or not FMGS_sys.fpln.active.apts.dep then
        return
    end

    if not FMGS_sys.data.init.weights.zfw or not FMGS_sys.data.init.weights.block_fuel or not FMGS_sys.data.init.weights.taxi_fuel then
        return
    end

    local total_to_weight = FMGS_sys.data.init.weights.zfw
                          + FMGS_sys.data.init.weights.block_fuel
                          - FMGS_sys.data.init.weights.taxi_fuel
    total_to_weight = 1000 * total_to_weight -- Change it to kgs

    local rwy_alt = FMGS_sys.fpln.active.apts.dep.alt

    FMGS_sys.data.pred.takeoff.gdot = compute_green_dot(total_to_weight, rwy_alt)

    if not FMGS_sys.perf.takeoff.v2 then
        return
    end

    FMGS_sys.data.pred.takeoff.ROC_init = get_ROC_after_TO(rwy_alt, FMGS_sys.perf.takeoff.v2, total_to_weight)
end