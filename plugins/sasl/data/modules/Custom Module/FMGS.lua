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

local config = {
    status = FMGS_MODE_OFF,
    phase  = FMGS_PHASE_PREFLIGHT,
    master = 0,
    backup_req = false
}

FMGS_sys.config = config

FMGS_sys.fpln = {
    init = {
        flt_nbr = nil,
        cost_index = nil,
        crz_fl = nil,
        crz_temp = nil,
        tropo = 36090
    },
    
    apts = {
        dep=nil,    -- As returned by AvionicsBay, runways included
        arr=nil,    -- As returned by AvionicsBay, runways included
        alt=nil     -- As returned by AvionicsBay, runways included
    },

    active = {
        {ptr_type = FMGS_PTR_APT, id="LIML", lat=45.454124, lon=9.272948},
        {ptr_type = FMGS_PTR_WPT, id="TREVI", lat=45.603333, lon=9.693333},
        {ptr_type = FMGS_PTR_NAVAID, navaid=NAV_ID_NDB, id="TZO", lat=45.558334, lon=9.509444},
        {ptr_type = FMGS_PTR_WPT, id="RODRU", lat=45.670834, lon=9.393333},
        {ptr_type = FMGS_PTR_COORDS, lat=45.53575658841703, lon=9.259678021183182},
        {ptr_type = FMGS_PTR_NAVAID, navaid=NAV_ID_VOR, id="SRN", lat=45.645962, lon=9.021610, has_dme = true},
    },
    
    
    next_waypoint = 4,
    curr_segment  = FMGS_SEGMENT_NONE,

}

-------------------------------------------
-- TODO Tips Current segment computation:
-- EN ROUTE defined as: > 15.500 ft or > 50.8 nm from departure or dest airport (and not off route)
-- OFF ROUTE: 2 nm / terminal 1nm / appr gps 0.3 or oth 0.5 nm
-- 

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

end

function update()
    perf_measure_start("FMGS:update()")
    update_status()
    update_route()
    perf_measure_stop("FMGS:update()")
end
