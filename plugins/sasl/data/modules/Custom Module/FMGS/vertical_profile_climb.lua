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

-------------------------------------------------------------------------------
-- Initial climb segments
-------------------------------------------------------------------------------

function get_takeoff_N1()
    if get(Eng_N1_flex_temp) == 0 then
        return eng_N1_limit_takeoff(get(OTA), get(TAT), get(Capt_Baro_Alt), true, false, false)
    else
        return eng_N1_limit_flex(get(Eng_N1_flex_temp), get(OTA), get(Capt_Baro_Alt), true, false, false)
    end
end

function get_ROC_after_TO(rwy_alt, v2, takeoff_weight)
    -- This is the climb from rwy alt to rwy_alt + 400

    local N1 = get_takeoff_N1()
    local oat = get(OTA)
    local density = get(Weather_Sigma)
    local _, tas, mach = convert_to_eas_tas_mach(v2, rwy_alt+200)   -- Let's use +200 to stay in the middle
    local thrust = predict_engine_thrust(mach, density, oat, rwy_alt+200, N1) * 2
    local drag   = predict_drag_w_gf(density, tas, mach, takeoff_weight, FMGS_sys.perf.flaps or 2, true)
    fuel_consumption = ENG.data.n1_to_FF(1, density)*2
    return air_compute_vs(thrust,drag, takeoff_weight, tas), fuel_consumption
end


function get_time_dist_from_V2_to_VSRS(rwy_alt, v2, takeoff_weight)
    local ref_alt = rwy_alt+400
    local oat = get(OTA)
    local density = get_density_ratio(ref_alt)
    local N1 = get_takeoff_N1()
    local _, tas, mach = convert_to_eas_tas_mach(v2, ref_alt)
    local thrust = predict_engine_thrust(mach, density, oat, ref_alt, N1) * 2
    local drag   = predict_drag(density, tas, mach, takeoff_weight)
    local acc = (thrust - drag) / takeoff_weight    -- Acceleration in m/s2

    local time = kts_to_ms(10) / acc -- 10 knots
    local dist = 0.5 * acc * (time^2) + kts_to_ms(v2) * time
    fuel_consumption = ENG.data.n1_to_FF(1, density)*2
    return time, m_to_nm(dist), fuel_consumption  -- Time, dist, fuel
end

function get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, ias, weight)
    local ref_alt = (end_alt+begin_alt)/2
    local density = get_density_ratio(ref_alt)
    local oat = get(OTA)
    local ota_pred = air_predict_temperature_at_alt(oat, get(Elevation_m)*3.28084, ref_alt)
    local _, tas, mach = convert_to_eas_tas_mach(ias, ref_alt)
    local thrust = predict_engine_thrust(mach, density, ota_pred, ref_alt, N1) * 2
    local drag   = predict_drag(density, tas, mach, weight)
    local vs = air_compute_vs(thrust,drag, weight, tas)

    local time = (end_alt-begin_alt) / vs * 60 -- seconds

    local wind_spd = get(Wind_SPD)
    local wind_dir = get(Wind_HDG)
    wind_dir = wind_to_relative(wind_dir, (FMGS_sys.fpln.active.apts.dep_rwy[2] and 180 or 0) + FMGS_sys.fpln.active.apts.dep_rwy[1].bearing) -- Transofrm it to relative

    local gs = tas_to_gs(tas, vs, wind_spd, wind_dir)

    fuel_consumption = ENG.data.n1_to_FF(1, density)*2
    return time, gs * time / 3600, fuel_consumption
end

function get_time_dist_from_VSRS_to_VACC(begin_alt, end_alt, speed, weight)
    local N1 = get_takeoff_N1()

    local time, dist, fuel = get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, speed, weight)

    return time, dist, fuel
end


-------------------------------------------------------------------------------
-- Climb
-------------------------------------------------------------------------------

function predict_climb_thrust_net_avail(ias,altitude, weight)
    local oat_pred = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1 = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local _, tas, mach = convert_to_eas_tas_mach(ias, altitude)
    local density = get_density_ratio(altitude)

    local thrust_per_engine = predict_engine_thrust(mach, density, oat_pred, altitude, N1)

    -- let's remove the drag now
    local drag = predict_drag(density, tas, mach, weight)

    return thrust_per_engine * 2 - drag
end

function compute_fuel_consumption_climb(begin_alt, end_alt, begin_spd, end_spd)
    local ref_alt = (end_alt+begin_alt)/2
    local ref_spd = (end_spd+begin_spd)/2
    local oat = get(OTA)
    local oat_pred = air_predict_temperature_at_alt(oat, get(Elevation_m)*3.28084, ref_alt)
    local N1 = eng_N1_limit_clb(oat_pred, 0, ref_alt, true, false, false)
    local density = get_density_ratio(ref_alt)
    local _, tas, mach = convert_to_eas_tas_mach(ref_spd, ref_alt)

    fuel_consumption = ENG.data.n1_to_FF(N1/get_takeoff_N1(), density)*2
    return fuel_consumption

end

function get_target_mach_cruise(alt_feet, gross_weight)
    local cost_index = FMGS_init_get_cost_idx()
    if not cost_index then
        cost_index = 0 -- Cost index default to zero
    end
    return math.min(0.80,alt_feet*(7.5000e-06-8.2500e-06 * cost_index/100) + 0.4875 + 0.3368 * cost_index / 100 
           + (2.3500e-06-2.5000e-06 *cost_index/100) * gross_weight -0.1592 +0.2075 * cost_index/100);
end

function get_target_speed_climb(altitude, gross_weight)
    -- This function does not consider  the initial climb part or
    -- restrictions
    if altitude < FMGS_sys.data.init.alt_speed_limit_climb[2] then
        return FMGS_sys.data.init.alt_speed_limit_climb[1], nil
    end

    -- Otherwise it depends on the cost index
    local cost_index = FMGS_init_get_cost_idx()
    if not cost_index then
        cost_index = 0 -- Cost index default to zero
    end

    -- Interpolated data from here: https://ansperformance.eu/library/airbus-cost-index.pdf
    local optimal_speed = math.min(340,0.645 * cost_index + 308)
    local optimal_mach  = math.min(0.8, 0.765 + 0.001683333 * cost_index - 0.00007895833 * cost_index^2 + 0.000001828125 * cost_index^3 - 1.822917e-8*cost_index^4 + 6.510417e-11*cost_index^5)
    local cruise_mach = get_target_mach_cruise(altitude, gross_weight)
    optimal_mach = math.min(optimal_mach, cruise_mach)
    return optimal_speed, optimal_mach
end
