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
-- Cruise
-------------------------------------------------------------------------------
function predict_cruise_N1_at_alt_ias(ias,altitude, weight)
    local oat_pred = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1_max = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local _, tas, mach = convert_to_eas_tas_mach(ias, altitude)
    local density = get_density_ratio(altitude)
    local drag = predict_drag(density, tas, mach, weight)


    local N1_per_engine = predict_engine_N1(mach, density, oat_pred, altitude, drag/2)

    local fuel_consumption = ENG.data.n1_to_FF(N1_per_engine/get_takeoff_N1(), density)*2

    return N1_per_engine, fuel_consumption

end

function predict_cruise_N1_at_alt_M(M, altitude, weight)
    local oat_pred = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1_max = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local tas = convert_to_tas(M, altitude)
    local density = get_density_ratio(altitude)
    local drag = predict_drag(density, tas, M, weight)


    local N1_per_engine = predict_engine_N1(M, density, oat_pred, altitude, drag/2)

    local fuel_consumption = ENG.data.n1_to_FF(N1_per_engine/get_takeoff_N1(), density)*2

    return N1_per_engine, fuel_consumption

end

function approx_TOD_distance(the_big_array, last_clb_idx)  -- This is a very rough prediction, but it's ok for just the weight

    local total_legs = #the_big_array

    local toc_to_rwy_dist = 0
    for i=last_clb_idx,total_legs do
        local leg = the_big_array[i]
        if not leg then
            logWarning("This is very bad and crashing will occur. i=", i, "total_legs=", total_legs, "last_clb_idx=", last_clb_idx)
        end
        toc_to_rwy_dist = toc_to_rwy_dist + (leg.computed_distance or 0)
    end

    -- we need about 100 nm at FL390 to reach 0 ft so...
    local cruise_alt = FMGS_sys.data.init.crz_fl

    local final_toc_to_rwy_dist
    local emergency_exit = 0
    repeat
        cruise_alt = cruise_alt - 1000
        local approx_descent_nm = cruise_alt / 39000 * 100

        final_toc_to_rwy_dist = toc_to_rwy_dist - approx_descent_nm
    until final_toc_to_rwy_dist > 0 or cruise_alt < 0

    if cruise_alt <= 0 then
        return nil  -- Impossible situation
    end

    return final_toc_to_rwy_dist
end
