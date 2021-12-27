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
include('libs/air_helpers.lua')

-------------------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------------------
local function compute_vs(T,D,W, tas)
    local gamma = ( T - D ) / W;
    return tas * math.sin(gamma) * 60
end

local function predict_temperature_at_alt(curr_ota, curr_alt_ft, ref_alt_ft)
    local curr_alt_m= curr_alt_ft*0.3048
    local ref_alt_m = ref_alt_ft*0.3048
    
    local isa_temp = math.max(-56.5, 15 - 6.5 * ref_alt_m/1000)
    local isa_temp_curr = math.max(-56.5, 15 - 6.5 * curr_alt_m/1000)
    return isa_temp+isa_temp_curr-curr_ota
end

local function get_density_ratio(ref_alt)   -- Get density according to ISA
    local temp_sea_level = 15+get(OTA)-Temperature_get_ISA()
    local press_sea_level = get(Weather_curr_press_sea_level) * 3386.38
    local density = get_air_density(ref_alt, FMGS_sys.data.init.tropo, temp_sea_level, press_sea_level)
    density = density_to_ratio(density)
    return density
end

-------------------------------------------------------------------------------
-- Initial climb segments
-------------------------------------------------------------------------------

local function get_ROC_after_TO(rwy_alt, v2, takeoff_weight)
    -- This is the climb from rwy alt to rwy_alt + 400

    local N1 = get(Eng_N1_flex_temp) == 0 and get(Eng_N1_max_detent_toga) or get(Eng_N1_max_detent_flex)
    local density = get(Weather_Sigma)
    local _, tas, mach = convert_to_eas_tas_mach(v2, rwy_alt+200)   -- Let's use +200 to stay in the middle
    local thrust = predict_engine_thrust(mach, density, get(OTA), rwy_alt+200, N1) * 2
    local drag   = predict_drag(density, tas, mach, 5)
    return compute_vs(thrust,drag, takeoff_weight, tas)
end


local function get_time_dist_from_V2_to_VSRS(rwy_alt, v2, takeoff_weight)
    local ref_alt = rwy_alt+400
    local density = get_density_ratio(ref_alt)
    local N1 = get(Eng_N1_flex_temp) == 0 and get(Eng_N1_max_detent_toga) or get(Eng_N1_max_detent_flex)
    local _, tas, mach = convert_to_eas_tas_mach(v2, ref_alt)
    local thrust = predict_engine_thrust(mach, density, get(OTA), ref_alt, N1) * 2
    local drag   = predict_drag(density, tas, mach, 0)
    local acc = (thrust - drag) / takeoff_weight    -- Acceleration in m/s2

    local time = kts_to_ms(10) / acc -- 10 knots
    local dist = 0.5 * acc * (time^2) + kts_to_ms(v2) * time
    return time, m_to_nm(dist)  -- Time, dist
end

local function get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, ias, weight)
    local density = get_density_ratio(begin_alt)
    local ota_pred = predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, end_alt-begin_alt)
    local _, tas, mach = convert_to_eas_tas_mach(ias, begin_alt)
    local thrust = predict_engine_thrust(mach, density, ota_pred, begin_alt, N1) * 2
    local drag   = predict_drag(density, tas, mach, 0)
    local vs = compute_vs(thrust,drag, weight, tas)

    local time = (end_alt-begin_alt) / vs * 60 -- seconds

    local gs = tas_to_gs(tas, vs, 0, 0)    -- TODO Wind

    return time, gs * time / 3600
end

local function get_time_dist_from_VSRS_to_VACC(begin_alt, end_alt, speed, weight)
    local N1 = get(Eng_N1_flex_temp) == 0 and get(Eng_N1_max_detent_toga) or get(Eng_N1_max_detent_flex)

    local time, dist = get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, speed, weight)

    return time, dist
end

-------------------------------------------------------------------------------
-- Main functions
-------------------------------------------------------------------------------
local function vertical_profile_reset()
    FMGS_sys.data.pred.takeoff.gdot = nil
    FMGS_sys.data.pred.takeoff.ROC_init = nil

end

local function vertical_profile_takeoff_update()

    -- Let's compute the predicted weight at T/O
    local total_to_weight = FMGS_sys.data.init.weights.zfw
                          + FMGS_sys.data.init.weights.block_fuel
                          - FMGS_sys.data.init.weights.taxi_fuel
    total_to_weight = 1000 * total_to_weight -- Change it to kgs


    local rwy_alt = FMGS_sys.fpln.active.apts.dep.alt

    FMGS_sys.data.pred.takeoff.gdot = compute_green_dot(total_to_weight, rwy_alt)

    if not FMGS_sys.perf.takeoff.v2 then
        return
    end

    -- Initial climb, from rwy altitude + 30 to 400
    FMGS_sys.data.pred.takeoff.ROC_init = get_ROC_after_TO(rwy_alt, FMGS_sys.perf.takeoff.v2, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_400ft = (400-30) / FMGS_sys.data.pred.takeoff.ROC_init * 60
    FMGS_sys.data.pred.takeoff.dist_to_400ft = FMGS_sys.data.pred.takeoff.time_to_400ft * FMGS_sys.perf.takeoff.v2 / 3600

    -- Acceleration at 400ft
    local time,dist = get_time_dist_from_V2_to_VSRS(rwy_alt+400, FMGS_sys.perf.takeoff.v2, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_sec_climb = time
    FMGS_sys.data.pred.takeoff.dist_to_sec_climb = dist

    -- Second part of the initial climb to takeoff acceleration altitude
    local acc_alt = FMGS_get_takeoff_acc()
    time,dist = get_time_dist_from_VSRS_to_VACC(rwy_alt+400, FMGS_sys.perf.takeoff.acc, FMGS_sys.perf.takeoff.v2+10, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_vacc = time
    FMGS_sys.data.pred.takeoff.dist_to_vacc = dist

end

function vertical_profile_climb_update()



end

function vertical_profile_update()
    -- Start with reset
    vertical_profile_reset()

    if not FMGS_sys.fpln.active or not FMGS_sys.fpln.active.apts.dep then
        -- No F/PLN or no departure airtport?
        return
    end

    if not FMGS_sys.data.init.weights.zfw or not FMGS_sys.data.init.weights.block_fuel or not FMGS_sys.data.init.weights.taxi_fuel then
        -- We need the weight and fuel my man
        return
    end

    -- Ok, we have everything, let's go!
    vertical_profile_takeoff_update()

end