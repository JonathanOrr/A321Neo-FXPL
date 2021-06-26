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

local loading_cifp = 0

local config = {
    status = FMGS_MODE_OFF,
    phase  = FMGS_PHASE_PREFLIGHT,
    master = 0,
    backup_req = false,
    gps_primary = false,
}

FMGS_sys.config = config

FMGS_sys.data = {
    init = {
        flt_nbr = nil,
        cost_index = nil,
        crz_fl = nil,
        crz_temp = nil,
        tropo = 36090,
        weights = {
            taxi_fuel = 0.2,
            zfw   = nil, -- zero fuel weight
            zfwcg = nil, -- zero fuel weight center of gravity
            block_fuel = nil, -- Existing known fuel load
            rsv_fuel_perc = 5.0,
            rsv_fuel      = nil,
        }
    },
    
    pred = {    -- Various predictions
        trip_fuel = nil,
        trip_time = nil,
        trip_dist = nil,
        efob = nil,
    },
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
            arr_appr=nil,
            arr_star=nil,
            arr_trans=nil,
            arr_via=nil,
            
            alt=nil,    -- As returned by AvionicsBay, runways included
            alt_cifp=nil,
        },

        legs = {
            {ptr_type = FMGS_PTR_WPT, id="TREVI", lat=45.603333, lon=9.693333, disc_after=false},
            {ptr_type = FMGS_PTR_NAVAID, navaid=NAV_ID_NDB, id="TZO", lat=45.558334, lon=9.509444, disc_after=false},
            {ptr_type = FMGS_PTR_WPT, id="RODRU", lat=45.670834, lon=9.393333, disc_after=true},
            {ptr_type = FMGS_PTR_COORDS, lat=45.53575658841703, lon=9.259678021183182, disc_after=false},
            {ptr_type = FMGS_PTR_NAVAID, navaid=NAV_ID_VOR, id="SRN", lat=45.645962, lon=9.021610, has_dme = true, disc_after=false},
        },
        
        
        next_leg = 2,
        curr_segment  = FMGS_SEGMENT_NONE,
    },
    
    temp = nil,
    sec = nil
}

FMGS_sys.perf = {
    takeoff = {
        v1 = nil,
        vr = nil,
        v2 = nil,
        v1_popped = nil,    -- This is for MCDU visualization purposes only
        vr_popped = nil,    -- This is for MCDU visualization purposes only
        v2_popped = nil,    -- This is for MCDU visualization purposes only
        trans_alt = 10000,
        thr_red = nil,
        acc = nil,
        eng_out = nil,
        toshift = nil,
        flaps = nil,
        ths = nil, --This is a number not a string (not DNXXX or UPXXX), safe to compare
        flex_temp = nil,
    }
}

-------------------------------------------
-- TODO Tips Current segment computation:
-- EN ROUTE defined as: > 15.500 ft or > 50.8 nm from departure or dest airport (and not off route)
-- OFF ROUTE: 2 nm / terminal 1nm / appr gps 0.3 or oth 0.5 nm
-- 

local function update_gps_primary()
    if not FMGS_sys.config.gps_primary then
        if get(GPS_1_is_available) == 1 or get(GPS_2_is_available) == 1 then
            FMGS_sys.config.gps_primary = true
            MCDU.send_message("GPS PRIMARY", ECAM_WHITE)
        end
    else
        if get(GPS_1_is_available) == 0 and get(GPS_2_is_available) == 0 then
            FMGS_sys.config.gps_primary = false
            MCDU.send_message("GPS PRIMARY LOST", ECAM_ORANGE)
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

    update_gps_primary()

end

local function update_cifp()
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

function update()
    perf_measure_start("FMGS:update()")
    update_status()
    update_route()
    update_cifp()
    
    perf_measure_stop("FMGS:update()")
end
