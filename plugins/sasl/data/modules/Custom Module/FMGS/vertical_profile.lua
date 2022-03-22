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


-------------------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------------------

function get_density_ratio(ref_alt)   -- Get density according to ISA
    local temp_sea_level = 15+get(OTA)-air_temperature_get_ISA()
    local press_sea_level = get(Weather_curr_press_sea_level) * 3386.38
    local density = air_get_density(ref_alt, FMGS_sys.data.init.tropo, temp_sea_level, press_sea_level)
    density = air_density_to_ratio(density)
    return density
end



include('FMGS/vertical_profile_climb.lua')
include('FMGS/vertical_profile_cruise.lua')
include('FMGS/vertical_profile_descent.lua')


local EARTH_GRAVITY = 9.80665
local QUANTUM_BASE_IN_SEC_CLB = 20  -- Predictions are build with this maximum granularity (lower is possible)
local QUANTUM_BASE_IN_SEC = 60  -- Predictions are build with this maximum granularity (lower is possible)


-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------
local the_big_array = nil   -- Contains all the legs regardless of type
local last_clb_idx  = nil
local first_des_idx = nil
local computed_des_idx = nil    -- Last index of the descent that has been computed
local file_debug = nil

-------------------------------------------------------------------------------
-- Array creation
-------------------------------------------------------------------------------

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
    local last_spd_cstr = 999
    if last_clb_idx and last_clb_idx > 0 then
        for i=last_clb_idx,1,-1  do
            local leg = the_big_array[i]
            if not leg.pred then
                leg.pred = {}
            end

            -- Altitude
            if    leg.cstr_alt_type == CIFP_CSTR_ALT_BELOW
               or leg.cstr_alt_type == CIFP_CSTR_ALT_AT 
               or leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW
            then
                -- If altitude is Below or At (or the block) take it for the climb
                local alt = leg.cstr_altitude1
                if leg.cstr_altitude1_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end

            leg.pred.prop_clb_cstr = last_alt_cstr

            -- Speed
            if leg.cstr_speed_type == CIFP_CSTR_SPD_BELOW or leg.cstr_speed_type == CIFP_CSTR_SPD_AT then
                local spd = leg.cstr_speed
                if spd < last_spd_cstr then
                    last_spd_cstr = spd
                end
            end

            leg.pred.prop_spd_cstr = last_spd_cstr

        end
    end

    -- Now I have to update the vertical constraints (DESCENT)
    local last_alt_cstr = 999999 
    local last_spd_cstr = 999
    if first_des_idx and first_des_idx > 0 then
        for i=first_des_idx,#the_big_array  do
            local leg = the_big_array[i]

            if    leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE
               or leg.cstr_alt_type == CIFP_CSTR_ALT_AT
            then
                -- If altitude is Above or At take it for the descent
                local alt = leg.cstr_altitude1
                if leg.cstr_altitude1_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end
            if    leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND
               or leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW
            then
                -- If altitude is Above or At take it for the descent
                local alt = leg.cstr_altitude2
                if leg.cstr_altitude2_fl then
                    alt = alt * 100
                end
                if alt < last_alt_cstr then
                    last_alt_cstr = alt
                end
            end
            if not leg.pred then
                leg.pred = {}
            end
            the_big_array[i].pred.prop_des_cstr = last_alt_cstr

            -- Speed
            if leg.cstr_speed_type == CIFP_CSTR_SPD_BELOW or leg.cstr_speed_type == CIFP_CSTR_SPD_AT then
                local spd = leg.cstr_speed
                if spd < last_spd_cstr then
                    last_spd_cstr = spd
                end
            end

            leg.pred.prop_spd_cstr = last_spd_cstr
        end
    end

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

    
    while traveled_nm > 0 do    -- How many WPTs we overflown during takeoff phase?
        i = i + 1
        traveled_nm = traveled_nm - the_big_array[i].computed_distance
    end

    curr_dist = traveled_nm + the_big_array[i].computed_distance

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


        thrust_available = predict_climb_thrust_net_avail(curr_spd,curr_alt,curr_weight)


        local leg = the_big_array[i]
        if not leg then
            logWarning("This is very bad and crashing will occur. i=", i, "total_legs=", total_legs, "last_clb_idx=", last_clb_idx)
        end
        local D = leg.computed_distance or 0 -- At this point, the distance should be already computed
                                             -- but a bit of defensive programming is not bad

        local target_speed, target_mach = get_target_speed_climb(curr_alt, curr_weight)

        -- Be sure the target speed is ok with the possible constraint
        target_speed = math.min(target_speed, leg.pred.prop_spd_cstr)

        -- If needed, let's compute the time to reach the target speed (in this case we are accelerating)
        if target_speed - curr_spd > 1 and (not target_mach or target_mach - curr_mach > 0.005) then
            -- In this case we need to accelerate and climb at the same time
            local thrust_for_acceleration = thrust_available * PERC_ACCELERATION
            thrust_available = thrust_available - thrust_for_acceleration   -- This is the thurst dedicate to climb

            A = thrust_for_acceleration / curr_weight -- [m/s2]
            Q = 1   -- Reduce the quantum to increase the precision of the speed change

    
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

        if curr_alt >= cruise_alt then
    
            break
        end

        if curr_dist >= D then

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
                        return nil, nil, nil
                    end
                    the_big_array[i+1].pred.is_climb = true
                    last_clb_idx = last_clb_idx + 1
                end
            end

            -- Goto the next WPTs
        else

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
        logWarning("This is very bad and crashing will occur. i=", i, "total_legs=", total_legs, "idx_next_wpt=", idx_next_wpt)
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

    local max_dist = approx_TOD_distance(the_big_array, last_clb_idx)  -- This is the max dist from the TOC to the TOD

    local cumul_dist = curr_dist
    local stop_idx = computed_des_idx and computed_des_idx or first_des_idx
    while i <= stop_idx do
        if cumul_dist >= max_dist then
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


        curr_weight = curr_weight - FF * time_to_travel
        curr_dist = 0
        cumul_dist = cumul_dist + dist_to_travel
        curr_time = curr_time + time_to_travel
        curr_fuel = curr_fuel + FF * time_to_travel

        leg.pred.altitude = cruise_alt
        leg.pred.mach = managed_mach
        leg.pred.vs   = 0
        leg.pred.time = curr_time
        leg.pred.fuel = curr_fuel

        i = i + 1
    end

    return curr_weight
end

local function vertical_profile_descent_update_step1_fuel(init_weight, init_alt, TAS, mach, VS, flaps, gear)
    local excess_thrust = fpm_to_ms(VS) * (init_weight * EARTH_GRAVITY) / kts_to_ms(TAS) -- [N]

    -- Let's compute also the GS (we need this later)
    local GS = tas_to_gs(TAS, VS, 0, 0)    -- TODO: Put wind here

    -- Time to compute the drag and therefore the thrust we need
    local oat = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, init_alt)
    local density = get_density_ratio(init_alt)
    local drag = predict_drag_w_gf(density, TAS, mach, init_weight, flaps, gear)

    local needed_thrust = math.max(0, drag + excess_thrust)
    local N1_per_engine = predict_engine_N1(mach, density, oat, init_alt, needed_thrust/2)

    local N1_minimum = predict_minimum_N1_engine(init_alt, oat, density, flaps, gear)

    if N1_minimum > N1_per_engine then
        -- We have a limit due to engine N1 minimum, thus we have to reduce our vertical speed
        sasl.logWarning("N1 engine idle is higher for approach. We cannot sustain the vvertical path angle.")
        -- TODO: Should I send a message to the pilots?
        N1_per_engine = N1_minimum  -- TODO: Should I change the V/S?
    end

    local fuel_consumption = ENG.data.n1_to_FF(N1_per_engine/get_takeoff_N1(), density)*2

    return N1_per_engine, GS, fuel_consumption
end

local function approach_backupdate_legs(begin_alt, VS, dist, mach, ias_start, ias_end, GS, fuel_consumption)

    dist = - dist -- Fix dist sign

    local next_wpt_dist

    repeat
        computed_des_idx = computed_des_idx - 1
        next_wpt_dist  = the_big_array[computed_des_idx].computed_distance 
        if the_big_array[computed_des_idx].pred.is_partial then
            next_wpt_dist  = next_wpt_dist - the_big_array[computed_des_idx].pred.partial_dist
        end
        local this_wpt_time = nm_to_m(math.min(dist,next_wpt_dist)) / kts_to_ms(GS)

        begin_alt = begin_alt - VS * this_wpt_time / 60
        local ias = math.min(Math_lerp(ias_end, ias_start, next_wpt_dist / dist), FMGS_sys.data.init.alt_speed_limit_descent[1])
        the_big_array[computed_des_idx].pred.altitude = begin_alt
        the_big_array[computed_des_idx].pred.ias      = ias
        the_big_array[computed_des_idx].pred.mach     = mach
        the_big_array[computed_des_idx].pred.vs       = VS

        if the_big_array[computed_des_idx].pred.is_partial then
            the_big_array[computed_des_idx].pred.time     = the_big_array[computed_des_idx].pred.time + this_wpt_time
            the_big_array[computed_des_idx].pred.fuel     = the_big_array[computed_des_idx].pred.fuel + fuel_consumption*this_wpt_time
        else
            the_big_array[computed_des_idx].pred.time     = this_wpt_time
            the_big_array[computed_des_idx].pred.fuel     = fuel_consumption*this_wpt_time
        end

        dist = dist - next_wpt_dist
    until dist <= 0

    if dist ~= 0 then
        the_big_array[computed_des_idx].pred.is_partial = true
        if not the_big_array[computed_des_idx].pred.partial_dist then
            the_big_array[computed_des_idx].pred.partial_dist = 0
        end
        the_big_array[computed_des_idx].pred.partial_dist = the_big_array[computed_des_idx].pred.partial_dist + (next_wpt_dist + dist)
        computed_des_idx = computed_des_idx + 1
    end

end

local function vertical_profile_descent_update_step1(weight_at_rwy)

    -- The the rwy altitude
    local rwy_alt = FMGS_sys.fpln.active.apts.arr.alt

    local flaps = 5  -- TODO: flaps from perf appr page
    local VAPP = compute_vapp(weight_at_rwy)

    -- Ok, now the landing slope
    local angle = FMGS_sys.data.pred.appr.final_angle

    -- Now I need the engine power needed to keep Vapp and slope
    local _, TAS, mach = convert_to_eas_tas_mach(VAPP, rwy_alt)
    -- Rate of climb at the beginning of the leg
    -- ROC = excess_power_force / weight_force * tas
    local VS = -ms_to_fpm(kts_to_ms(TAS) * math.sin(math.rad(angle)))

    local N1, GS, fuel_consumption = vertical_profile_descent_update_step1_fuel(weight_at_rwy, rwy_alt, TAS, mach, VS, flaps, true)

    local time = 1000 / VS * 60;
    local dist = m_to_nm(kts_to_ms(GS) * time)
    -- I can now update the last waypoint
    FMGS_sys.data.pred.appr.steps[1].time  = time
    FMGS_sys.data.pred.appr.steps[1].dist  = dist
    FMGS_sys.data.pred.appr.steps[1].ias   = VAPP
    FMGS_sys.data.pred.appr.steps[1].N1    = N1
    FMGS_sys.data.pred.appr.steps[1].fuel  = fuel_consumption * time
    FMGS_sys.data.pred.appr.steps[1].alt   = 1000
    FMGS_sys.data.pred.appr.steps[1].vs    = VS

    -- Update the runway leg
    computed_des_idx = #the_big_array -- rwy index
    the_big_array[computed_des_idx].pred.altitude = rwy_alt
    the_big_array[computed_des_idx].pred.ias      = VAPP
    the_big_array[computed_des_idx].pred.mach     = mach
    the_big_array[computed_des_idx].pred.time     = 0
    the_big_array[computed_des_idx].pred.fuel     = 0
    the_big_array[computed_des_idx].pred.vs       = VS

    -- Update the other legs
    approach_backupdate_legs(rwy_alt, VS, dist, mach, VAPP, VAPP, GS, fuel_consumption)

    return - fuel_consumption * time
end


local function vertical_profile_descent_update_step234(weight, i_step)
    local alt = FMGS_sys.data.pred.appr.steps[i_step-1].alt

    local flaps_start, flaps_end
    if i_step < 4 then
        flaps_start = 6 - i_step  -- TODO: flaps from perf appr page
        flaps_end   = 7 - i_step -- TODO: flaps from perf appr page
    else
        flaps_start = 3
        flaps_end   = 3
    end
    local gear = true -- i_step < 4
    local V_START
    if i_step == 2 then
        V_START = 1.28 * FBW.FAC_COMPUTATION.Extract_vs1g(weight, flaps_start, gear)
    elseif i_step == 3 then
        -- F speed
        V_START = 1.22 * FBW.FAC_COMPUTATION.Extract_vs1g(weight, 2, false)
    elseif i_step == 4 then
        -- S speed
        V_START = 1.23 * FBW.FAC_COMPUTATION.Extract_vs1g(weight, 0, false)
    end

    local V_END = FMGS_sys.data.pred.appr.steps[i_step-1].ias
    local V_AVG = (V_START+V_END)/2
    if V_START < V_END then
        -- This is possible for i_step == 4
        V_START = V_END
        V_AVG   = V_START
    end

    -- Ok, now the landing slope
    local angle = FMGS_sys.data.pred.appr.final_angle

    -- Now I need the engine power needed to keep Vapp and slope
    local _, TAS, mach = convert_to_eas_tas_mach(V_AVG, alt)
    -- Rate of climb at the beginning of the leg
    -- ROC = excess_power_force / weight_force * tas
    local VS = -ms_to_fpm(kts_to_ms(TAS) * math.sin(math.rad(angle)))
    local GS = tas_to_gs(TAS, VS, 0, 0)    -- TODO: Put wind here

    local excess_thrust = -fpm_to_ms(VS) * (weight * EARTH_GRAVITY) / kts_to_ms(TAS) -- [N]

    -- Time to compute the drag and therefore the thrust we need
    local oat = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, alt)
    local density = get_density_ratio(alt)
    local drag = predict_drag_w_gf(density, TAS, mach, weight, flaps_end, gear)

    -- In this case I assume to be at idle...
    local N1_minimum = predict_minimum_N1_engine(alt, oat, density, flaps_end, gear)
    local thrust_idle = predict_engine_thrust(mach, density, oat, alt, N1_minimum) * 2
    
    local net_force_horizontal = thrust_idle - drag + excess_thrust
    local decel = net_force_horizontal / weight    -- Acceleration in m/s2

    if net_force_horizontal >= 0 then
        -- TOO STEEP DESCENT
        -- TODO advise pilots?
        net_force_horizontal = 0

        sasl.logWarning("Step " .. i_step .. " too steep descent: " .. decel )
    end

    local time
    local dist
    local ias
    if i_step <= 3 then
        time = kts_to_ms(V_START - V_END) / decel
        dist = m_to_nm(kts_to_ms(GS) * time)
        ias = V_START
    elseif i_step == 4 then
        local curr_dist   = -FMGS_sys.data.pred.appr.steps[3].dist
        local target_dist = FMGS_sys.data.pred.appr.fdp_dist_to_rwy or curr_dist
        time = -nm_to_m(math.max(0, target_dist - curr_dist)) / kts_to_ms(GS)
        dist = curr_dist-target_dist
        ias = ms_to_kts(kts_to_ms(V_END) + decel * time)
        if ias > V_START then
            -- We are descending too fast, we need to increase engines
            ias = V_START
            local decel_i_want = kts_to_ms(V_START-V_END) / time
            local more_thrust_i_need = -(decel-decel_i_want) * weight
            local new_thrust = thrust_idle + more_thrust_i_need
            N1_minimum = predict_engine_N1(mach, density, oat, alt, new_thrust/2)
        end
    end

    local fuel_consumption = ENG.data.n1_to_FF(N1_minimum/get_takeoff_N1(), density)*2

    -- I can now update the last waypoint
    FMGS_sys.data.pred.appr.steps[i_step].time  = FMGS_sys.data.pred.appr.steps[i_step-1].time + time
    FMGS_sys.data.pred.appr.steps[i_step].dist  = FMGS_sys.data.pred.appr.steps[i_step-1].dist + dist
    FMGS_sys.data.pred.appr.steps[i_step].fuel  = FMGS_sys.data.pred.appr.steps[i_step-1].fuel + fuel_consumption * time
    FMGS_sys.data.pred.appr.steps[i_step].N1    = N1_minimum
    FMGS_sys.data.pred.appr.steps[i_step].ias   = ias
    FMGS_sys.data.pred.appr.steps[i_step].alt   = FMGS_sys.data.pred.appr.steps[i_step-1].alt + VS * time / 60
    FMGS_sys.data.pred.appr.steps[i_step].vs    = VS

    approach_backupdate_legs(FMGS_sys.data.pred.appr.steps[i_step-1].alt, VS, dist, mach, V_START, V_END, GS, fuel_consumption)

    return - fuel_consumption * time
end

local function vertical_profile_descent_update_step567(weight, i_step)
    local alt = FMGS_sys.data.pred.appr.steps[i_step-1].alt

    local flaps_start, flaps_end
    if i_step == 5 then
        flaps_end  = 3
    elseif i_step == 6 then
        flaps_end  = 2
    elseif i_step == 7 then
        flaps_end  = 0
    end
    local gear = false
    local V_START
    if i_step == 5 then
        -- S speed
        V_START = 1.23 * FBW.FAC_COMPUTATION.Extract_vs1g(weight, 0, false)
    elseif i_step == 6 then
        -- GDOT
        V_START = compute_green_dot(weight, alt)
    elseif i_step == 7 then
        V_START = FMGS_sys.data.init.alt_speed_limit_descent[1]
    end

    local V_END = FMGS_sys.data.pred.appr.steps[i_step-1].ias


    -- Comply with the speed constraint if possible
    V_START = math.min(V_START, the_big_array[computed_des_idx-1].pred.prop_spd_cstr)
    V_START = math.max(V_START, V_END)

    local V_AVG = (V_START+V_END)/2

    local _, TAS, mach = convert_to_eas_tas_mach(V_AVG, alt)

    -- Time to compute the drag and therefore the thrust we need
    local oat = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, alt)
    local density = get_density_ratio(alt)
    local drag = predict_drag_w_gf(density, TAS, mach, weight, flaps_end, gear)

    -- In this case I assume to be at idle...
    local N1_minimum = predict_minimum_N1_engine(alt, oat, density, flaps_end, gear)
    local thrust_idle = predict_engine_thrust(mach, density, oat, alt, N1_minimum) * 2
    local fuel_consumption = ENG.data.n1_to_FF(N1_minimum/get_takeoff_N1(), density)*2

    local net_force = thrust_idle - drag
    local net_force_vertical = net_force * 0.4  -- TODO: This can be tuned to meet alt/speed constraints
    local net_force_horizontal = net_force - net_force_vertical

    local decel = net_force_horizontal / weight    -- Acceleration in m/s2
    local time  = kts_to_ms(V_START-V_END) / decel
    
    local VS = ms_to_fpm(net_force_vertical / (weight * EARTH_GRAVITY) * kts_to_ms(TAS)) -- [fpm]
    local GS = tas_to_gs(TAS, VS, 0, 0)    -- TODO: Put wind here
    local dist = m_to_nm(kts_to_ms(GS) * time)

    -- I can now update the last waypoint
    FMGS_sys.data.pred.appr.steps[i_step].time  = FMGS_sys.data.pred.appr.steps[i_step-1].time + time
    FMGS_sys.data.pred.appr.steps[i_step].dist  = FMGS_sys.data.pred.appr.steps[i_step-1].dist + dist
    FMGS_sys.data.pred.appr.steps[i_step].fuel  = FMGS_sys.data.pred.appr.steps[i_step-1].fuel + fuel_consumption * time
    FMGS_sys.data.pred.appr.steps[i_step].N1    = N1_minimum
    FMGS_sys.data.pred.appr.steps[i_step].ias   = V_START
    FMGS_sys.data.pred.appr.steps[i_step].alt   = FMGS_sys.data.pred.appr.steps[i_step-1].alt + VS * time / 60
    FMGS_sys.data.pred.appr.steps[i_step].vs    = VS

    approach_backupdate_legs(FMGS_sys.data.pred.appr.steps[i_step-1].alt, VS, dist, mach, V_START, V_END, GS, fuel_consumption)

    return - fuel_consumption * time
end

local function vertical_profile_descent_update_step89(weight, idx)
    local curr_alt, V_END, V_START, MACH_LIMIT
    
    if idx == 8 then
        curr_alt = FMGS_sys.data.pred.appr.steps[7].alt
        V_END   = FMGS_sys.data.pred.appr.steps[7].ias
        V_START = FMGS_sys.data.init.alt_speed_limit_descent[1]
    else
        curr_alt = the_big_array[computed_des_idx].pred.altitude
        V_END    = the_big_array[computed_des_idx].pred.ias
        V_START, MACH_LIMIT  = get_target_speed_descent()
    end
    assert(V_START)
    assert(V_END)

    local initial_dist_to_consider = 0
    if the_big_array[computed_des_idx-1].pred.is_partial then
        initial_dist_to_consider = the_big_array[computed_des_idx-1].pred.partial_dist
    end

    local upper_limit = idx == 8 and FMGS_sys.data.init.alt_speed_limit_descent[2] or FMGS_sys.data.init.crz_fl

    while curr_alt < upper_limit do
        computed_des_idx = computed_des_idx - 1
        local leg = the_big_array[computed_des_idx]

        -- Comply with the speed constraint if possible
        if leg.pred.prop_spd_cstr then
            V_START = math.min(V_START, leg.pred.prop_spd_cstr)
        end
        V_START = math.max(V_START, V_END)
        local V_AVG = (V_START+V_END)/2

        local _, TAS, mach = convert_to_eas_tas_mach(V_AVG, curr_alt)

        -- Time to compute the drag and therefore the thrust we need
        local oat = air_predict_temperature_at_alt(get(OTA), get(Elevation_m)*3.28084, curr_alt)
        local density = get_density_ratio(curr_alt)
        local drag = predict_drag(density, TAS, mach, weight)

        -- In this case I assume to be at idle...
        local N1_minimum = predict_minimum_N1_engine(curr_alt, oat, density, 0, false)
        local thrust_idle = predict_engine_thrust(mach, density, oat, curr_alt, N1_minimum) * 2
        local fuel_consumption = ENG.data.n1_to_FF(N1_minimum/get_takeoff_N1(), density)*2
        local net_force = thrust_idle - drag

        local wpt_dist = leg.computed_distance or 0
        local dist_to_next_wpt = wpt_dist - initial_dist_to_consider
        initial_dist_to_consider = 0

        local VS   = the_big_array[computed_des_idx+1].pred.vs
        local time = 0
        local GS   = tas_to_gs(TAS, 0, 0, 0) -- TODO: Put wind here
        local decel_we_need = 0
        if dist_to_next_wpt > 0 then

            -- First of all let's check if we have to decelerate
            local no_descent_GS = GS -- Approx
            local this_wpt_time_approx = nm_to_m(dist_to_next_wpt / kts_to_ms(no_descent_GS))
            decel_we_need = kts_to_ms(V_START-V_END) / this_wpt_time_approx
            local h_force_we_need = decel_we_need * weight

            local v_force = net_force - h_force_we_need
            while v_force > 0 do -- We cannot decelerate so fast, so let's halve the h_force to continue the descent
                h_force_we_need = h_force_we_need / 2
                v_force = net_force - h_force_we_need  
            end

            -- Ok now compute the descent parameters
            local decel = h_force_we_need / weight

            VS = ms_to_fpm(v_force / (weight * EARTH_GRAVITY) * kts_to_ms(TAS)) -- [fpm]
            GS = tas_to_gs(TAS, VS, 0, 0)    -- TODO: Put wind here
            time  = nm_to_m(dist_to_next_wpt) / kts_to_ms(GS)
        end 

        curr_alt = curr_alt - VS * time / 60

        local overshoot = false
        if curr_alt > upper_limit and VS ~= 0 then
            -- We overshoot the target, so let's recompute the time to
            -- target:
            time = time + (curr_alt - upper_limit) / VS * 60    -- get smaller, VS is negative
            -- and update distance and previous:
            leg.pred.is_partial   = true
            leg.pred.partial_dist = dist_to_next_wpt - m_to_nm(time * kts_to_ms(GS))

            curr_alt = upper_limit
            overshoot = true
            computed_des_idx = computed_des_idx + 1
        end

        V_START = V_END + ms_to_kts(decel_we_need * time)

        assert(V_START)

        if leg.pred.is_climb then
            FMGS_sys.data.pred.invalid = true
            return weight
        else
            leg.pred.is_descent = true
        end

        leg.pred.altitude = curr_alt
        leg.pred.ias      = V_START
        leg.pred.mach     = mach
        leg.pred.vs       = VS

        if not leg.pred.is_partial or overshoot then
            leg.pred.time     = time
            leg.pred.fuel     = fuel_consumption * time
        else
            leg.pred.time     = leg.pred.time + time
            leg.pred.fuel     = leg.pred.fuel + fuel_consumption * time
        end
        weight = weight + fuel_consumption * time
    end

    -- Add the TOP of DESCENT PSEUDO WPT
    if idx == 9 then
        local last_leg = the_big_array[computed_des_idx-1]
        table.insert(the_big_array, computed_des_idx, {name="T/D",
                                    computed_distance = last_leg.computed_distance - last_leg.pred.partial_dist,
                                    pred={
                                           is_tod = true,
                                           is_descent = true,
                                           altitude=upper_limit,
                                           ias=last_leg.pred.ias,
                                           mach=last_leg.pred.mach,
                                           time=last_leg.pred.time,
                                           fuel=last_leg.pred.fuel,
                                           vs=last_leg.pred.vs,
                                           dist_prev_wpt=last_leg.pred.partial_dist,
                                           weight=weight
                                        }}
        )
        last_leg.pred.vs = 0
        last_leg.pred.is_descent = false
        last_leg.pred.time = 0  -- To be recomputed by cruise
        last_leg.pred.fuel = 0  -- To be recomputed by cruise
        last_leg.computed_distance = last_leg.pred.partial_dist
    end

    return weight
end

local function vertical_profile_descent_update(approx_weight_at_TOD)
    -- For the descent phase we have to go back, so we start from the runways threshold and we climb up
    
    -- This function implements the Continuous Descent Approach (CDA)

    -- Steps (reversed):
    -- 1st step: from runway to 1000ft AGL. Speed stabilized to Vapp, we assume the ° provided by the approach phase or 3° if not available
    -- 2nd step: from 1000ft to selection of flaps full: VLS    (if landing in conf 3 selected, ignore)
    -- 3rd step: from flaps full to flaps3: to VLS
    -- 4th step: from flaps3 to FDP intercept
    -- 5th step: from FDP intercept to flaps2: to VLS
    -- 6th step: from flaps2 to flaps1: to VLS
    -- 7th step: from flaps1 to decel point: green dot speed
    -- 8th step: from decel point to speed limit (FL100): transition to 250 kts
    -- 9th step: from speed limit (FL100) to CRZ FL: ECON DES MACH / ECON DES SPD

    -- First of all, I need the approx weight at runway level, so let's take the one
    -- at TOD and then use the tabular data to obtain an approximation
    local curr_weight = approx_weight_at_TOD - FMGS_sys.data.init.crz_fl / 50

    -- Search for the FDP, which is defined as the first point in the CIFP having a 
    -- constant angle
    find_FDP()

    -- We compute all the steps ignoring the horizontal position
    -- we will update it later

    curr_weight = curr_weight + vertical_profile_descent_update_step1(curr_weight)
    curr_weight = curr_weight + vertical_profile_descent_update_step234(curr_weight, 2)
    curr_weight = curr_weight + vertical_profile_descent_update_step234(curr_weight, 3)
    curr_weight = curr_weight + vertical_profile_descent_update_step234(curr_weight, 4)
    curr_weight = curr_weight + vertical_profile_descent_update_step567(curr_weight, 5)
    curr_weight = curr_weight + vertical_profile_descent_update_step567(curr_weight, 6)
    curr_weight = curr_weight + vertical_profile_descent_update_step567(curr_weight, 7)
    curr_weight = vertical_profile_descent_update_step89(curr_weight, 8)    -- Non increment version
    curr_weight = vertical_profile_descent_update_step89(curr_weight, 9)    -- Non increment version

end

function vertical_profile_cruise_descent_ft_update()
    -- From the first descent point (computed_des_idx, this time for real)
    -- we have to update fuel and time from that point on. The data on each
    -- waypoint is relative to each leg (and we need to transform it to global)
    -- HOWEVER: it's possible that the last point is still partial (see vertical_profile_descent_update_step89)
    -- therefore we need to complete the last point time and fuel.

    local start_leg = the_big_array[computed_des_idx]
    local fuel_cumulative = start_leg.pred.fuel
    local time_cumulative = start_leg.pred.time
    local i = computed_des_idx + 1
    local end_i = #the_big_array

    while i <= end_i do
        fuel_cumulative = fuel_cumulative + the_big_array[i].pred.fuel
        time_cumulative = time_cumulative + the_big_array[i].pred.time

        the_big_array[i].pred.fuel = fuel_cumulative
        the_big_array[i].pred.time = time_cumulative

        i = i + 1
    end

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

    if not FMGS_sys.data.init.crz_fl then
        -- We need also the Cruise FL...
        return
    end

    if not FMGS_sys.fpln.active.apts.arr or not FMGS_sys.fpln.active.apts.arr_appr then
        -- No approach / arr airtport?
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

    local approx_weight_at_TOD = vertical_profile_cruise_update(idx_next_wpt)

    vertical_profile_descent_update(approx_weight_at_TOD)

    local exact_weight_at_TOD = vertical_profile_cruise_update(idx_next_wpt)

    vertical_profile_cruise_descent_ft_update()


end


FMGS_sys.pred_debug = { -- Just for debugging

    get_big_array = function()
        return the_big_array
    end
}