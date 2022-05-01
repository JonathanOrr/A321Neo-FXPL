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
-- File: FMGS.lua 
-- Short description: The Flight Management Systems main file
-------------------------------------------------------------------------------

include('FMGS/route.lua')
include('FMGS/limits.lua')
include('FMGS/vertical_profile.lua')
include('FMGS/constraints_checker.lua')

local TIME_TO_GET_WIND = 5 -- in seconds

local loading_cifp = 0

local config = {
    status = FMGS_MODE_OFF,
    phase  = FMGS_PHASE_PREFLIGHT,
    takeoff_time = nil,     -- In simulator time, from get(TIME)
    master = 0,
    backup_req = false,
    gps_primary = false,
}

FMGS_sys.config = config

FMGS_sys.data = {
    init = {
        flt_nbr = nil,
        cost_index = 10,
        crz_fl = 27000,
        crz_temp = 0,
        tropo = 36090,
        weights = {
            taxi_fuel = 0.2,
            zfw   = 68.0, -- zero fuel weight
            zfwcg = nil, -- zero fuel weight center of gravity
            block_fuel = 12.0, -- Existing known fuel load
            rsv_fuel_perc = 5.0,
            rsv_fuel      = nil,
            min_dest_fob  = nil,
        },
        alt_speed_limit_climb   = {250, 10000},
        alt_speed_limit_descent = {250, 10000}
    },

    limits = {
        max_alt = nil,
        opt_alt = nil
    },

    pred = {    -- Various predictions
                ----------------------------------------------------------------------
                -- NOTE! ADD the default value also to vertical_profile_reset() !
                ----------------------------------------------------------------------
        invalid = false,
        trip_fuel = nil,
        trip_time = nil,
        trip_dist = nil,
        efob = nil,         -- At destination
        require_update = false,

        takeoff = {
            gdot = nil,
            ROC_init = nil,
            total_fuel_kgs = nil,
            time_to_400ft = 0,  -- In secs  -- From RWY to 400ft
            dist_to_400ft = 0,  -- In nm    -- From RWY to 400ft
            time_to_sec_climb = 0,  -- In secs -- Accelerate at 400ft
            dist_to_sec_climb = 0,  -- In nm   -- Accelerate at 400ft
            time_to_vacc = 0,  -- In secs   -- Climb from 400 to acc alt
            dist_to_vacc = 0,  -- In nm     -- Climb from 400 to acc alt
        },

        climb = {
            total_fuel_kgs = nil,
            lim_wpt = nil, -- The 10000ft/250kts point
            toc_wpt = nil
        },

        descent = {
            tod_wpt = nil,
            lim_wpt = nil, -- The 10000ft/250kts point
        },

        appr = {
            fdp_idx = nil,
            fdp_dist_to_rwy = nil,
            final_angle = 3,    -- Default to 3, always positive (descent angle)
            steps = {
                {},     -- 1000ft
                {},     -- FLAP FULL (may have skip=true if FLAP 3 config)
                {},     -- FLAP 3
                {},     -- FDP
                {},     -- FLAP 2
                {},     -- FLAP 1
                {}      -- DECEL
            }
        }
    },

    nav_accuracy = 0.0,

    -- Winds (cruise winds are in each WPT)
    winds_climb = {},
    winds_descent = {},
    winds_req_in_progress_time = -1  -- <0 if not in progress, get(TIME) if yes
}

FMGS_sys.fpln = {

    active = {
        apts = {
            dep=nil,        -- As returned by AvionicsBay, runways included
            dep_cifp=nil,   -- All the loaded CIFP
            dep_rwy=nil,
            dep_sid=nil,    -- Selected SID for departure
            dep_trans=nil,  -- Selected Transition for departure
            
            arr=nil,        -- As returned by AvionicsBay, runways included
            arr_cifp=nil,   -- All the loaded CIFP
            arr_rwy=nil,
            arr_trans =  nil,
            arr_star = nil,
            arr_via = nil,
            arr_appr = nil,
            arr_map  = nil, -- Missed approach procedure
            
            alt=nil,    -- As returned by AvionicsBay, runways included
            alt_cifp=nil,
        },

        -- Format:
        -- {ptr_type = FMGS_PTR_*, id="AAA", lat=10.2, lon=10.3, obj={}}
        -- or
        -- {discontinuity = true}

        legs = {
            {ptr_type = FMGS_PTR_WPT, id="LAGEN", lat=44.394166667, lon=8.498055556, flt_phase = { is_climb=false, is_descent=false }},
            {ptr_type = FMGS_PTR_WPT, id="ANAKI", lat=44.201111111, lon=8.725555556, flt_phase = { is_climb=false, is_descent=false }},
            {ptr_type = FMGS_PTR_WPT, id="IXITO", lat=44.134722222, lon=8.803611111, flt_phase = { is_climb=false, is_descent=false }},
            {ptr_type = FMGS_PTR_WPT, id="UNITA", lat=43.944444444, lon=9.025000000, flt_phase = { is_climb=false, is_descent=false }},
            {ptr_type = FMGS_PTR_WPT, id="TIDKA", lat=43.800000000, lon=9.191944444, flt_phase = { is_climb=false, is_descent=false }},
        },
        
        
        next_leg = 1,
        curr_segment  = FMGS_SEGMENT_NONE,

        segment_curved_list = nil,  -- List of segments and arcs generated by turn_computer
    },
    
    temp = nil,
    sec = nil
}

FMGS_sys.dirto = {
    directing_wpt = "RICOO",
    radial_in = nil,
    radial_out = nil
}

FMGS_sys.perf = {
    takeoff = {
        v1 = nil,
        vr = nil,
        v2 = 160,
        v1_popped = nil,    -- This is for MCDU visualization purposes only
        vr_popped = nil,    -- This is for MCDU visualization purposes only
        v2_popped = nil,    -- This is for MCDU visualization purposes only
        trans_alt = 10000,
        user_trans_alt = nil,
        thr_red = 0 + 1500,
        acc = 0 + 1500,
        eng_out = 0+ 1500,
        user_thr_red = nil,
        user_acc = nil,
        user_eng_out = nil,
        toshift = nil,
        flaps = nil,
        ths = nil, --This is a number not a string (not DNXXX or UPXXX), safe to compare
        flex_temp = nil
    },
    landing = {
        qnh = nil,
        mda = nil,
        dh  = nil,
        temp = nil,
        mag = nil,
        wind = nil,
        trans_alt = 10000,
        user_trans_alt = nil,
        vapp = nil,
        user_vapp = nil,
        landing_config = 4, -- 3 is 3, 4 is full
        vls = nil
    },
    go_around = {
        thr_red = 1500,
        thr_acc = 1500,
        user_thr_red = nil,
        user_thr_acc = nil
    }
}

-------------------------------------------
-- TODO Tips Current segment computation:
-- EN ROUTE defined as: > 15.500 ft or > 50.8 nm from departure or dest airport (and not off route)
-- OFF ROUTE: 2 nm / terminal 1nm / appr gps 0.3 or oth 0.5 nm
-- 

local function update_gps_primary()
    if not FMGS_sys.config.gps_primary then
        if GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV then
            FMGS_sys.config.gps_primary = true
            MCDU.send_message("GPS PRIMARY", ECAM_WHITE)
        end
    else
        if GPS_sys[1].status ~= GPS_STATUS_NAV and GPS_sys[2].status ~= GPS_STATUS_NAV then
            FMGS_sys.config.gps_primary = false
            MCDU.send_message("GPS PRIMARY LOST", ECAM_ORANGE)
        end
    end
end

local function update_nav_accuracy()
    local err = 0
    if FMGS_sys.config.gps_primary then
        if GPS_sys[1].status == GPS_STATUS_NAV then
            err = GPS_sys[1].est_error
        end
        if GPS_sys[2].status == GPS_STATUS_NAV then
            err = err + GPS_sys[2].est_error
        end
        err = math.abs(err * 111.111 * 0.539957);    -- Approx meters per degree (to NM)
    else
        -- TODO DME and VOR improvements
        local n = 0
        for i=1,3 do
            if ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED then
                err = err + ADIRS_sys[i].ir_drift
                n = n + 1
            end
        end
        if n > 0 then
            err = math.abs(err / n)
        end
    end
    FMGS_sys.data.nav_accuracy = err
end

local function update_phase()
    if FMGS_sys.config.phase == FMGS_PHASE_PREFLIGHT then
        -- TODO add in `and` with "SRS takeoff mode engaged"

        if ENG.dyn[1].n1 > 85 or ENG.dyn[2].n1 > 85 or adirs_get_avg_gs() > 90 then
            FMGS_sys.config.phase = FMGS_PHASE_TAKEOFF
            FMGS_sys.config.takeoff_time = get(TIME)
        end
    end
end

local function update_status()
    -- NOTE: As far as I know, INDEPENDENT MODE is activated only when databases of FMCUs is different
    --       This has no sense in our aircraft, so this mode doesn't exist.

    local fmgc_1_works = get(FAILURE_FMGC_1) == 0 and get(DC_shed_ess_pwrd) == 1
    local fmgc_2_works = get(FAILURE_FMGC_2) == 0 and get(DC_bus_2_pwrd) == 1
    
    if fmgc_1_works and fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_DUAL
        FMGS_sys.config.master = 1  -- TODO: It depends on AP and FD selections
    elseif fmgc_1_works and not fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_SINGLE
        FMGS_sys.config.master = 1
    elseif not fmgc_1_works and fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_SINGLE
        FMGS_sys.config.master = 2
    elseif FMGS_sys.config.backup_req then
        FMGS_sys.config.status = FMGS_MODE_BACKUP
        FMGS_sys.config.master = 0  -- In backup mode no FMGC works
    else
        FMGS_sys.config.status = FMGS_MODE_OFF
        FMGS_sys.config.master = 0
    end

    update_phase()
    update_gps_primary()
    update_nav_accuracy()

end

local function update_cifp_loading()
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    if not AvionicsBay.c.is_cifp_ready() then
        return -- I'm already loading something related to CIFP
    end
    
    -- DEP CIFP
    if FMGS_sys.fpln.active.apts.dep ~= nil and FMGS_sys.fpln.active.apts.dep_cifp == nil then
        if loading_cifp == 1 then
            FMGS_sys.fpln.active.apts.dep_cifp = AvionicsBay.cifp.get(FMGS_sys.fpln.active.apts.dep.id)
            -- Add the NO SID / NO TRANS cases
            table.insert(FMGS_sys.fpln.active.apts.dep_cifp.sids, {
                type        = CIFP_TYPE_SS_RWY_TRANS_FMS,
                proc_name   = "NO SID",
                trans_name  = "ALL",
                legs = {}
            })
            table.insert(FMGS_sys.fpln.active.apts.dep_cifp.sids, {
                type        = CIFP_TYPE_SS_ENR_TRANS_FMS,
                proc_name   = "ALL",
                trans_name  = "NO TRANS",
                legs = {}
            })
            if FMGS_sys.fpln.temp then
                FMGS_sys.fpln.temp.apts.dep_cifp = FMGS_sys.fpln.active.apts.dep_cifp
            end
            loading_cifp = 0
        else
            AvionicsBay.cifp.load_apt(FMGS_sys.fpln.active.apts.dep.id)
            loading_cifp = 1
            return
        end
    end

    if FMGS_sys.fpln.active.apts.arr ~= nil and FMGS_sys.fpln.active.apts.arr_cifp == nil then
        if loading_cifp == 2 then
            FMGS_sys.fpln.active.apts.arr_cifp = AvionicsBay.cifp.get(FMGS_sys.fpln.active.apts.arr.id)
            if FMGS_sys.fpln.temp then
                FMGS_sys.fpln.temp.apts.arr_cifp = FMGS_sys.fpln.active.apts.arr_cifp
            end
            loading_cifp = 0
        else
            AvionicsBay.cifp.load_apt(FMGS_sys.fpln.active.apts.arr.id)
            loading_cifp = 2
            return
        end
    end

    if FMGS_sys.fpln.active.apts.alt ~= nil and FMGS_sys.fpln.active.apts.alt_cifp == nil then
        if loading_cifp == 3 then
            FMGS_sys.fpln.active.apts.alt_cifp = AvionicsBay.cifp.get(FMGS_sys.fpln.active.apts.alt.id)
            if FMGS_sys.fpln.temp then
                FMGS_sys.fpln.temp.apts.alt_cifp = FMGS_sys.fpln.active.apts.alt_cifp
            end
            loading_cifp = 0
        else
            AvionicsBay.cifp.load_apt(FMGS_sys.fpln.active.apts.alt.id)
            loading_cifp = 3
            return
        end
    end

end



local function update_predictions()
    if FMGS_sys.data.pred.require_update then
        vertical_profile_update()
        decorate_legs_with_constraints()
        FMGS_sys.data.pred.require_update = false
    end
end

local function update_wind_uplink()
    if FMGS_sys.data.winds_req_in_progress_time < 0 then
        return
    end
    if get(TIME) - FMGS_sys.data.winds_req_in_progress_time < TIME_TO_GET_WIND then
        return
    end

    FMGS_sys.data.winds_req_in_progress_time = -1
    FMGS_sys.data.winds_climb = {
        {alt = Round(get(Wind_layer_1_alt)*3.28084, 0), spd = Round(get(Wind_layer_1_speed), 0), dir = Round(get(Wind_layer_1_dir),0) },
        {alt = Round(get(Wind_layer_2_alt)*3.28084, 0), spd = Round(get(Wind_layer_2_speed), 0), dir = Round(get(Wind_layer_2_dir),0) },
        {alt = Round(get(Wind_layer_3_alt)*3.28084, 0), spd = Round(get(Wind_layer_3_speed), 0), dir = Round(get(Wind_layer_3_dir),0) }
    }

    table.sort(FMGS_sys.data.winds_climb, function(a, b) return a.alt < b.alt end)

    FMGS_sys.data.winds_descent = {
        FMGS_sys.data.winds_climb[1],
        FMGS_sys.data.winds_climb[2],
        FMGS_sys.data.winds_climb[3]
    }

    for i,x in ipairs(FMGS_sys.fpln.active.legs) do
        x.winds = {FMGS_sys.data.winds_climb[3]}
    end

    FMGS_refresh_pred()
    MCDU.send_message("WIND DATA UPLINK", ECAM_WHITE)

end

function update()
    perf_measure_start("FMGS:update()")
    update_status()
    update_route()
    update_cifp_loading()

    update_limits()
    update_predictions()

    update_route_turns()


    update_wind_uplink()

    perf_measure_stop("FMGS:update()")
end
