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
-- File: FMGS/route.lua 
-- Short description: Compute the route
-------------------------------------------------------------------------------

include('FMGS/nav_helpers.lua')
include('libs/geo-helpers.lua')

local ROUTE_FREQ_UPDATE_SEC = 0.5

local route_last_update = 0


local function update_active_fpln()
    local fpln_active = FMGS_sys.fpln.active
    
    local nr_points = #fpln_active
    if nr_points <= 1 then
        return  -- We need at least 2 waypoints to build a route...
    end
    
    local roll_limit = FMGS_get_roll_limit()
    local NM_ARC = math.max(0, math.floor(adirs_get_avg_tas())^2 / (math.tan(math.rad(roll_limit)) * 11.294) * 0.000164579)
    
    for k,r in ipairs(fpln_active) do
        if k > 1 and k < nr_points then
        
            lat_start, lon_start = point_from_a_segment_lat_lon(r.lat, r.lon, fpln_active[k-1].lat, fpln_active[k-1].lon, NM_ARC)
            lat_end,   lon_end   = point_from_a_segment_lat_lon(r.lat, r.lon, fpln_active[k+1].lat, fpln_active[k+1].lon, NM_ARC)
            
            fpln_active[k].beizer = {
                start_lat =  lat_start,
                start_lon =  lon_start,
                end_lat   =  lat_end,
                end_lon   =  lon_end,
            }

        end
    end
    
end


function update_route()

--[[    -- Disable for testing
    if get(TIME) - route_last_update < ROUTE_FREQ_UPDATE_SEC then
        return
    end
    
    route_last_update = get(TIME)
]]--

    update_active_fpln()

end

