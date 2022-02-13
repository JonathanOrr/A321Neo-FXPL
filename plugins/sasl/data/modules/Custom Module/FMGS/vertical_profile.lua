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

include("FLT_SYS/FBW/FAC_computation/common_functions.lua");
include("FMGS/predictors/engine_thrust.lua")
include("FMGS/predictors/drag.lua")
include("libs/speed_helpers.lua")
include('libs/air_helpers.lua')

local DEBUG_TO_FILE = false

local EARTH_GRAVITY = 9.80665
local QUANTUM_BASE_IN_SEC_CLB = 20  -- Predictions are build with this maximum granularity (lower is possible)
local QUANTUM_BASE_IN_SEC = 60  -- Predictions are build with this maximum granularity (lower is possible)

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
local the_big_array = nil   -- Contains all the legs regardless of type
local last_clb_idx  = nil
local first_des_idx = nil
local file_debug = nil

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


local function prepare_the_common_big_array_merge(array)
    if not (array and array.legs) then
        return
    end
    for i, leg in ipairs(array.legs) do
        if not leg.discontinuity then
            if leg.pred and not leg.pred.is_climb and not last_clb_idx then
                last_clb_idx = #the_big_array
            end
            table.insert(the_big_array, leg)
            if leg.pred and leg.pred.is_descent and not first_des_idx then
                first_des_idx = #the_big_array
            end
        end
    end
end

local function prepare_the_common_big_array()
    the_big_array = {}
    last_clb_idx = nil
    first_des_idx = nil

    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.dep_sid)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.dep_trans)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.arr_trans)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.arr_star)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.arr_via)
    prepare_the_common_big_array_merge(FMGS_sys.fpln.active.apts.arr_appr)

    -- Now I have to update the vertical constraints (CLIMB)
    local last_alt_cstr = 999999 
    if last_clb_idx and last_clb_idx > 0 then
        for i=last_clb_idx,1,-1  do
            if    the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_BELOW
               or the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_AT 
               or the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW
            then
                -- If altitude is Below or At (or the block) take it for the climb
                local alt = the_big_array[i].cstr_altitude1
                if the_big_array[i].cstr_altitude1_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end
            if not the_big_array[i].pred then
                the_big_array[i].pred = {}
            end
            the_big_array[i].pred.prop_clb_cstr = last_alt_cstr
        end
    end

    -- Now I have to update the vertical constraints (DESCENT)
    local last_alt_cstr = 999999 
    if first_des_idx and first_des_idx > 0 then
        for i=first_des_idx,#the_big_array  do
            if    the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_ABOVE
               or the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_AT
            then
                -- If altitude is Above or At take it for the descent
                local alt = the_big_array[i].cstr_altitude1
                if the_big_array[i].cstr_altitude1_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end
            if    the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND
               or the_big_array[i].cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW
            then
                -- If altitude is Above or At take it for the descent
                local alt = the_big_array[i].cstr_altitude2
                if the_big_array[i].cstr_altitude2_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end
            if not the_big_array[i].pred then
                the_big_array[i].pred = {}
            end
            the_big_array[i].pred.prop_des_cstr = last_alt_cstr
        end
    end

end

-------------------------------------------------------------------------------
-- Initial climb segments
-------------------------------------------------------------------------------

local function get_takeoff_N1()
    if get(Eng_N1_flex_temp) == 0 then
        return eng_N1_limit_takeoff(get(OTA), get(TAT), get(Capt_Baro_Alt), true, false, false)
    else
        return eng_N1_limit_flex(get(Eng_N1_flex_temp), get(OTA), get(Capt_Baro_Alt), true, false, false)
    end
end

local function get_ROC_after_TO(rwy_alt, v2, takeoff_weight)
    -- This is the climb from rwy alt to rwy_alt + 400

    local N1 = get_takeoff_N1()
    local oat = get(OTA)
    local density = get(Weather_Sigma)
    local _, tas, mach = convert_to_eas_tas_mach(v2, rwy_alt+200)   -- Let's use +200 to stay in the middle
    local thrust = predict_engine_thrust(mach, density, oat, rwy_alt+200, N1) * 2
    local drag   = predict_drag(density, tas, mach, takeoff_weight)
    fuel_consumption = ENG.data.n1_to_FF(1, density)*2
    return compute_vs(thrust,drag, takeoff_weight, tas), fuel_consumption
end


local function get_time_dist_from_V2_to_VSRS(rwy_alt, v2, takeoff_weight)
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

local function get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, ias, weight)
    local ref_alt = (end_alt+begin_alt)/2
    local density = get_density_ratio(ref_alt)
    local oat = get(OTA)
    local ota_pred = predict_temperature_at_alt(oat, get(Elevation_m)*3.28084, ref_alt)
    local _, tas, mach = convert_to_eas_tas_mach(ias, ref_alt)
    local thrust = predict_engine_thrust(mach, density, ota_pred, ref_alt, N1) * 2
    local drag   = predict_drag(density, tas, mach, weight)
    local vs = compute_vs(thrust,drag, weight, tas)

    local time = (end_alt-begin_alt) / vs * 60 -- seconds

    local gs = tas_to_gs(tas, vs, 0, 0)    -- TODO Wind

    fuel_consumption = ENG.data.n1_to_FF(1, density)*2
    return time, gs * time / 3600, fuel_consumption
end

local function get_time_dist_from_VSRS_to_VACC(begin_alt, end_alt, speed, weight)
    local N1 = get_takeoff_N1()

    local time, dist, fuel = get_time_dist_to_alt_constant_spd(begin_alt, end_alt, N1, speed, weight)

    return time, dist, fuel
end

-------------------------------------------------------------------------------
-- Climb
-------------------------------------------------------------------------------

local function predict_climb_thrust_net_avail(ias,altitude, weight)
    local oat_pred = predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1 = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local _, tas, mach = convert_to_eas_tas_mach(ias, altitude)
    local density = get_density_ratio(altitude)

    local thrust_per_engine = predict_engine_thrust(mach, density, oat_pred, altitude, N1)

    -- let's remove the drag now
    local drag = predict_drag(density, tas, mach, weight)

    if DEBUG_TO_FILE then
        file_debug:write("  INPUTS: ias=" .. ias .. "kts, altitude="..altitude.."ft, weight="..weight.."kg", "\n")
        file_debug:write("  COMPUTED: tas=" .. tas .. "kts, mach="..mach.."M, density (ratio)="..density.."", "\n")
        file_debug:write("  FINAL: thrust_each=" .. thrust_per_engine .. "N, drag="..drag.."N, net="..(thrust_per_engine * 2 - drag).."N", "\n")
    end
    return thrust_per_engine * 2 - drag
end

local function compute_fuel_consumption_climb(begin_alt, end_alt, begin_spd, end_spd)
    local ref_alt = (end_alt+begin_alt)/2
    local ref_spd = (end_spd+begin_spd)/2
    local oat = get(OTA)
    local oat_pred = predict_temperature_at_alt(oat, get(Elevation_m)*3.28084, ref_alt)
    local N1 = eng_N1_limit_clb(oat_pred, 0, ref_alt, true, false, false)
    local density = get_density_ratio(ref_alt)
    local _, tas, mach = convert_to_eas_tas_mach(ref_spd, ref_alt)

    fuel_consumption = ENG.data.n1_to_FF(N1/get_takeoff_N1(), density)*2
    return fuel_consumption

end

local function get_target_mach_cruise(alt_feet, gross_weight)
    local cost_index = FMGS_init_get_cost_idx()
    if not cost_index then
        cost_index = 0 -- Cost index default to zero
    end
    return math.min(0.80,alt_feet*(7.5000e-06-8.2500e-06 * cost_index/100) + 0.4875 + 0.3368 * cost_index / 100 
           + (2.3500e-06-2.5000e-06 *cost_index/100) * gross_weight -0.1592 +0.2075 * cost_index/100);
end

local function get_target_speed_climb(altitude, gross_weight)
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


-------------------------------------------------------------------------------
-- Cruise
-------------------------------------------------------------------------------
local function predict_cruise_N1_at_alt_ias(ias,altitude, weight)
    local oat_pred = predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1_max = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local _, tas, mach = convert_to_eas_tas_mach(ias, altitude)
    local density = get_density_ratio(altitude)
    local drag = predict_drag(density, tas, mach, weight)


    local N1_per_engine = predict_engine_N1(mach, density, oat_pred, altitude, drag/2)

    local fuel_consumption = ENG.data.n1_to_FF(N1_per_engine/get_takeoff_N1(), density)*2

    return N1_per_engine, fuel_consumption

end

local function predict_cruise_N1_at_alt_M(M, altitude, weight)
    local oat_pred = predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, altitude)
    local N1_max = eng_N1_limit_clb(oat_pred, 0, altitude, true, false, false)
    local tas = convert_to_tas(M, altitude)
    local density = get_density_ratio(altitude)
    local drag = predict_drag(density, tas, M, weight)


    local N1_per_engine = predict_engine_N1(M, density, oat_pred, altitude, drag/2)

    local fuel_consumption = ENG.data.n1_to_FF(N1_per_engine/get_takeoff_N1(), density)*2

    return N1_per_engine, fuel_consumption

end

local function approx_TOD_distance()  -- This is a very rough prediction, but it's ok for just the weight

    local total_legs = #the_big_array
    local toc_to_rwy_dist = 0
    for i=last_clb_idx,total_legs do
        local leg = the_big_array[i]
        toc_to_rwy_dist = toc_to_rwy_dist + (leg.computed_distance or 0)
    end

    -- we need about 100 nm at FL390 to reach 0 ft so...
    local cruise_alt = FMGS_sys.data.init.crz_fl
    local appprox_descent_nm = cruise_alt / 39000 * 100

    toc_to_rwy_dist = toc_to_rwy_dist - appprox_descent_nm
    if toc_to_rwy_dist <= 0 then
        return nil  -- Too close
    end

    return toc_to_rwy_dist
end

-------------------------------------------------------------------------------
-- Descent
-------------------------------------------------------------------------------
local function get_target_speed_descent(altitude)
    -- This function does not consider  the initial climb part or
    -- restrictions
    if altitude < FMGS_sys.data.init.alt_speed_limit_descent[2] then
        return FMGS_sys.data.init.alt_speed_limit_descent[1], nil
    end

    -- Otherwise it depends on the cost index
    local cost_index = FMGS_init_get_cost_idx()
    if not cost_index then
        cost_index = 0 -- Cost index default to zero
    end

    -- Interpolated data from here: https://ansperformance.eu/library/airbus-cost-index.pdf
    local optimal_speed = -0.0003333333333 * cost_index^3 + 0.0308928571429* cost_index^2 +0.7869047619048 * cost_index + 252.1142857142856
    local optimal_mach  = -0.000003392857143 * cost_index * cost_index + 0.000716428571429 * cost_index + 0.764485714285714
    return optimal_speed, optimal_mach
end


-------------------------------------------------------------------------------
-- Main functions
-------------------------------------------------------------------------------
local function vertical_profile_reset()
    FMGS_sys.data.pred.takeoff.gdot = nil
    FMGS_sys.data.pred.takeoff.ROC_init = nil

end

local function vertical_profile_takeoff_update()

    local fuel_consumed = 0 -- We will return the total fuel consumption for the takeoff phase (including taxi)

    -- Let's compute the predicted weight at T/O
    local total_to_weight = FMGS_sys.data.init.weights.zfw
                          + FMGS_sys.data.init.weights.block_fuel
                          - FMGS_sys.data.init.weights.taxi_fuel
    total_to_weight = 1000 * total_to_weight -- Change it to kgs

    fuel_consumed = FMGS_sys.data.init.weights.taxi_fuel * 1000 -- In kgs

    local rwy_alt = FMGS_sys.fpln.active.apts.dep.alt

    FMGS_sys.data.pred.takeoff.gdot = compute_green_dot(total_to_weight, rwy_alt)

    local _,_,v2 = FMGS_perf_get_v_speeds()

    if not v2 then
        return nil
    end

    local fuel_consumption

    -- Initial climb, from rwy altitude + 30 to 400
    FMGS_sys.data.pred.takeoff.ROC_init, fuel_consumption = get_ROC_after_TO(rwy_alt, v2, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_400ft = (400-30) / FMGS_sys.data.pred.takeoff.ROC_init * 60
    FMGS_sys.data.pred.takeoff.dist_to_400ft = FMGS_sys.data.pred.takeoff.time_to_400ft * v2 / 3600
    fuel_consumed = fuel_consumed + fuel_consumption * FMGS_sys.data.pred.takeoff.time_to_400ft

    -- Acceleration at 400ft
    local time,dist,fuel_consumption = get_time_dist_from_V2_to_VSRS(rwy_alt+400, v2, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_sec_climb = time
    FMGS_sys.data.pred.takeoff.dist_to_sec_climb = dist
    fuel_consumed = fuel_consumed + fuel_consumption * time

    -- Second part of the initial climb to takeoff acceleration altitude
    local acc_alt = FMGS_get_takeoff_acc()
    time,dist,fuel_consumption = get_time_dist_from_VSRS_to_VACC(rwy_alt+400, FMGS_perf_get_current_takeoff_acc(), v2+10, total_to_weight)
    FMGS_sys.data.pred.takeoff.time_to_vacc = time
    FMGS_sys.data.pred.takeoff.dist_to_vacc = dist
    fuel_consumed = fuel_consumed + fuel_consumption * time

    return fuel_consumed
end

function vertical_profile_climb_update()

    ----------------------------------------------------
    -- README
    ----------------------------------------------------
    -- There's a pdf on Discord's dev server with the
    -- flowchar of this function
    ----------------------------------------------------

    local PERC_ACCELERATION = 0.6   -- (1-this) is the energy left for climbing when speed target is not matched

    -- Compute the initial weight as the takeoff weight - the fuel consumed at takeoff and initial climb
    local curr_weight = ( FMGS_sys.data.init.weights.zfw
                        + FMGS_sys.data.init.weights.block_fuel
                        - FMGS_sys.data.init.weights.taxi_fuel) * 1000
                        - FMGS_sys.data.pred.takeoff.total_fuel_kgs

    assert(curr_weight > FMGS_sys.data.init.weights.zfw)

    local _,_,v2 = FMGS_perf_get_v_speeds()

    local cruise_alt = FMGS_sys.data.init.crz_fl

    local curr_alt      = FMGS_perf_get_current_takeoff_acc()
    local curr_spd      = v2+10
    local curr_mach     = 0 -- It doesn't matter at the beginning to compute the mach
    local curr_dist     = 0
    local curr_time     = 0
    local A = 0 -- Horizontal acceleration
    local thrust_available = nil -- Will be set the first loop
    local skip_dist_reset = true

    local Q = QUANTUM_BASE_IN_SEC_CLB    -- This may be reduced if the leg is too short
    local i = 0
    local total_legs = #the_big_array

    -- First, let's understand where we are considering the initial climb
    curr_time =
        FMGS_sys.data.pred.takeoff.time_to_400ft+
        FMGS_sys.data.pred.takeoff.time_to_sec_climb+ 
        FMGS_sys.data.pred.takeoff.time_to_vacc

    local traveled_nm = 
        FMGS_sys.data.pred.takeoff.dist_to_400ft    +
        FMGS_sys.data.pred.takeoff.dist_to_sec_climb+
        FMGS_sys.data.pred.takeoff.dist_to_vacc
    
    if DEBUG_TO_FILE then
        file_debug:write("After takeoff phase we traveled for " .. traveled_nm .. " nm", "\n")
    end
    
    while traveled_nm > 0 do    -- How many WPTs we overflown during takeoff phase?
        i = i + 1
        traveled_nm = traveled_nm - the_big_array[i].computed_distance
    end

    curr_dist = traveled_nm + the_big_array[i].computed_distance

    if DEBUG_TO_FILE then
        file_debug:write("Therefore we are at the " .. i .. "-th waypoint with " .. curr_dist .. " nm remaining", "\n")
    end

    local runs = 0  -- Just for debugging the performance
    local total_fuel_cons = FMGS_sys.data.pred.takeoff.total_fuel_kgs

    -- We need to modify both i and last_clb_idx, so `for` is no good here
    while i <= last_clb_idx do
        runs = runs + 1

        if not skip_dist_reset then
            -- If we enter here, it means that the previous loop cycle ended
            -- with the end of the waypoin, so we have to go to the next and,
            -- therefore, reset the current_distance.
            curr_dist     = 0
        end
        skip_dist_reset = false
        -- Reset variables
        Q = QUANTUM_BASE_IN_SEC_CLB
        A = 0

        if DEBUG_TO_FILE then
            file_debug:write("Leg " .. i .. "-th: we are at " .. curr_spd .. " kts, " .. curr_alt .. "ft, " .. curr_weight .. "kg", "\n")
            file_debug:write("Leg " .. i .. "-th: thrust info follows", "\n")
        end

        thrust_available = predict_climb_thrust_net_avail(curr_spd,curr_alt,curr_weight)


        local leg = the_big_array[i]
        if not leg then
            logWarning("This is very bad and crashing will occur. i=", i, "total_legs=", total_legs, "last_clb_idx=", last_clb_idx)
        end
        local D = leg.computed_distance or 0 -- At this point, the distance should be already computed
                                             -- but a bit of defensive programming is not bad

        local target_speed, target_mach = get_target_speed_climb(curr_alt, curr_weight)

        -- Be sure the target speed is ok with the possible constraint
        if leg.cstr_speed_type == CIFP_CSTR_SPD_BELOW or leg.cstr_speed_type == CIFP_CSTR_SPD_AT then
            target_speed = math.min(target_speed, leg.cstr_speed)
        end

        if DEBUG_TO_FILE then
            file_debug:write("Leg " .. i .. "-th: target IAS is " .. target_speed .. "kts and target mach is " .. (target_mach and target_mach or 'NIL'), "\n")
        end

        -- If needed, let's compute the time to reach the target speed (in this case we are accelerating)
        if target_speed - curr_spd > 1 and (not target_mach or target_mach - curr_mach > 0.005) then
            -- In this case we need to accelerate and climb at the same time
            local thrust_for_acceleration = thrust_available * 0.6
            thrust_available = thrust_available - thrust_for_acceleration   -- This is the thurst dedicate to climb

            A = thrust_for_acceleration / curr_weight -- [m/s2]
            Q = 1   -- Reduce the quantum to increase the precision of the speed change

            if DEBUG_TO_FILE then
                file_debug:write("Leg " .. i .. "-th: speed change requested, quantum time goes to 1", "\n")
                file_debug:write("Leg " .. i .. "-th: thrust for acceleration " .. thrust_for_acceleration .. "N and thrust for climbing " .. thrust_available .. "N", "\n")
                file_debug:write("Leg " .. i .. "-th: acceleration is then " .. A .. " m/s", "\n")
            end
    
        end

        local new_alt, new_spd, new_mach, GS, VS
        local emergency_out = 0 -- This counter is to exit in case of an infinite loop (shouldn't happen, but, you know...)
        repeat
            emergency_out = emergency_out + 1
            if emergency_out > 1000 then
                break
            end
            if new_mach then
                local ACC_MACH_REDUCTION = 0.001    -- Reduction of acceleration to stay in mach limits
                                                    -- This affects only the loop number and precision of
                                                    -- the accelerations
                A = A - ACC_MACH_REDUCTION
                thrust_available = thrust_available - (-ACC_MACH_REDUCTION * curr_weight)   -- Reduce speed to remain in valid mach when climbing
            end

            local _, TAS, _ = convert_to_eas_tas_mach(curr_spd, curr_alt)
            -- Rate of climb at the beginning of the leg
            -- ROC = excess_power_force / weight_force * tas
            VS = ms_to_fpm(thrust_available / (curr_weight * EARTH_GRAVITY) * kts_to_ms(TAS)) -- [fpm]
            GS = tas_to_gs(TAS, VS, 0, 0)    -- TODO: Put wind here

            Q = math.min(Q, D/m_to_nm(kts_to_ms(GS)))   -- [s]
            Q = math.min(Q, (cruise_alt-curr_alt)/VS * 60)  -- [s]

            new_alt  = curr_alt + Q * VS / 60                  -- in [feet]
            new_spd  = curr_spd + ms_to_kts(Q * A)             -- in [kts]
            local _, _, _new_mach = convert_to_eas_tas_mach(new_spd, new_alt)
            new_mach = _new_mach
            
        until (not target_mach or new_mach < target_mach)

        if DEBUG_TO_FILE then
            file_debug:write("Leg " .. i .. "-th: solved in " .. emergency_out .. " iterations", "\n")
            file_debug:write("Leg " .. i .. "-th: final quantum is " .. Q .. "s", "\n")
        end

        if emergency_out > 1000 then
            logWarning("Emergency exit from repeat-until loop in vertical profile. This is no good.")
        end

        -- If any, enforce the altitude constraint
        if leg.pred.prop_clb_cstr then
            new_alt = math.min(new_alt, leg.pred.prop_clb_cstr)
        end
        -- Let's scompute the fuel consumption in this period
        local fuel_consump = compute_fuel_consumption_climb(curr_alt, new_alt, curr_spd, new_spd)   --[kg/s]
        total_fuel_cons = total_fuel_cons + fuel_consump * Q
        curr_weight = curr_weight - fuel_consump * Q    -- [kg]

        -- Ok, update the values
        curr_mach = new_mach
        curr_alt  = new_alt
        curr_spd  = new_spd
        curr_dist = curr_dist + m_to_nm(kts_to_ms(GS)) * Q  -- in [nm]
        curr_time = curr_time + Q

        if DEBUG_TO_FILE then
            file_debug:write("Leg " .. i .. "-th: new values: " .. new_mach .. "M, " .. new_spd .. "kts, " ..new_alt .. "ft, " .. curr_dist .. "nm, " .. curr_time .. "s, " .. curr_weight .. "kg", "\n")
        end

        if curr_alt >= cruise_alt then
            if DEBUG_TO_FILE then
                file_debug:write("Leg " .. i .. "-th: reached cruise ALT", "\n")
            end
    
            break
        end

        if curr_dist >= D then
            if DEBUG_TO_FILE then
                file_debug:write("Leg " .. i .. "-th: finished", "\n")
            end

            -- We finally reached the end of the leg, so let's update its predictions

            leg.pred.altitude = new_alt
            leg.pred.ias      = new_spd
            leg.pred.mach     = new_mach
            leg.pred.time     = curr_time
            leg.pred.fuel     = total_fuel_cons
            leg.pred.vs       = VS

            if i < total_legs then
                -- We didn't reach the TOC, so let's be sure the next wpt is
                -- predicted as a climb
                if not the_big_array[i+1].pred.is_climb then
                    if the_big_array[i+1].pred.is_descent then
                        -- Very bad here, we cannot climb to the cruise FLZ, we have no
                        -- sufficient time/space, break everything
                        if DEBUG_TO_FILE then
                            file_debug:write("Leg " .. i .. "-th: end of space", "\n")
                        end
                        return nil, nil, nil
                    end
                    the_big_array[i+1].pred.is_climb = true
                    last_clb_idx = last_clb_idx + 1
                end
            end

            -- Goto the next WPTs
        else
            if DEBUG_TO_FILE then
                file_debug:write("Leg " .. i .. "-th: still inside", "\n")
            end

            skip_dist_reset = true
            i = i - 1
        end
        i = i + 1
    end

    table.insert(the_big_array, i, {name="T/C", 
                                    pred={
                                           is_toc = true,
                                           is_climb = true,
                                           altitude=cruise_alt,
                                           ias=curr_spd,
                                           mach=curr_mach,
                                           time=curr_time,
                                           fuel=total_fuel_cons,
                                           vs=0,
                                           dist_prev_wpt=curr_dist,
                                           weight=curr_weight
                                        }})

    return total_fuel_cons, i+1
end

local function vertical_profile_cruise_update(idx_next_wpt)
    local TC = the_big_array[idx_next_wpt-1]
    local i = idx_next_wpt
    local cruise_alt = FMGS_sys.data.init.crz_fl
    local curr_spd      = TC.pred.ias
    local curr_mach     = TC.pred.mach
    local curr_dist     = TC.pred.dist_prev_wpt
    local curr_time     = TC.pred.time
    local curr_fuel     = TC.pred.fuel
    local curr_weight   = TC.pred.weight

    local leg = the_big_array[i]
    if not leg then
        logWarning("This is very bad and crashing will occur. i=", i, "total_legs=", total_legs, "last_clb_idx=", last_clb_idx)
    end 

    local D = leg.computed_distance or 0 -- At this point, the distance should be already computed

    if curr_dist > D then
        -- This may happen if we reached the TC and the same time the next waypoint. In that case, the
        -- previous function does not update the idx next wpt, so we have to do that
        leg.pred.altitude = curr_alt
        leg.pred.ias      = curr_spd
        leg.pred.mach     = curr_mach
        leg.pred.time     = curr_time
        leg.pred.fuel     = curr_fuel
        leg.pred.vs       = 0
        i = i + 1
    end

    -- So, we don't knwo where the TOD is at beginning, therefore, we have
    -- to estimate the distance to it. We will update later after descent is
    -- made the final part of the cruise segment if needed.
    -- NOTE: we have to compute the cruise (even if approx) before the descent
    -- or we won't know the weight at TOD!

    local max_dist = approx_TOD_distance()

    while i <= first_des_idx do
        if curr_dist >= max_dist then
            -- See comment above max_dist 
            break
        end

        leg = the_big_array[i]
        D = leg.computed_distance

        local dist_to_travel = D - curr_dist
        local managed_mach = get_target_mach_cruise(cruise_alt, curr_weight)
        local N1, FF = predict_cruise_N1_at_alt_M(managed_mach, cruise_alt, curr_weight)

        local TAS = convert_to_tas(managed_mach, cruise_alt)
        local GS = tas_to_gs(TAS, 0, 0, 0)    -- TODO: Put wind here

        local time_to_travel = dist_to_travel / m_to_nm(kts_to_ms(GS))

        leg.pred.altitude = cruise_alt
        leg.pred.mach = managed_mach
        leg.pred.time = curr_time + time_to_travel
        leg.pred.fuel = curr_fuel + FF * time_to_travel
        leg.pred.vs   = 0

        curr_weight = curr_weight - FF * time_to_travel
        curr_dist = 0

        i = i + 1
    end
end

local function vertical_profile_descent_update()
    -- For the descent phase we have to go back, so we start from the runways threshold and we climb up
    

end

function vertical_profile_update()

    if DEBUG_TO_FILE then
        file_debug = io.open("vertical-profile.log", "w")
    end

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

    if not FMGS_sys.data.init.crz_fl then
        -- We need also the Cruise FL...
        return
    end

    -- Ok, we have everything, let's go!
    local fuel_consumed = vertical_profile_takeoff_update() -- In Kgs
    FMGS_sys.data.pred.takeoff.total_fuel_kgs = fuel_consumed
    if not fuel_consumed or fuel_consumed > FMGS_sys.data.init.weights.block_fuel*1000 then
        return -- Cannot make any other prediction
    end

    prepare_the_common_big_array()
    FMGS_sys.data.pred.climb.total_fuel_kgs, idx_next_wpt = vertical_profile_climb_update()
    if not FMGS_sys.data.pred.climb.total_fuel_kgs then
        -- Error, like cruise FL is too high
        return  -- Cannot make any other prediction
    end

    vertical_profile_descent_update()


    FMGS_sys.data.pred.climb.total_fuel_kgs, idx_next_wpt = vertical_profile_cruise_update(idx_next_wpt)


end


FMGS_sys.pred_debug = { -- Just for debugging

    get_big_array = function()
        return the_big_array
    end
}