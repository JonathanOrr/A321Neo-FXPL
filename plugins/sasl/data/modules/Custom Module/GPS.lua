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
-- File: GPS.lua 
-- Short description: The code for GPS
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

local HOT_START_GPS  = 1    -- nr. of seconds required to get GPS fix if last time active < 1 hour
local WARM_START_GPS = 20   -- nr. of seconds required to get GPS fix if last time active > 1 hour (we don't simulate cold start)

local MAX_GPS_ERROR = 4 * 1e-5

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------

local gps_last_time_on =  {0,0}
local gps_start_time_point = {0,0}
local gps_1_offset = math.random() * 200 - 100
local gps_2_offset = math.random() * 200 - 100


----------------------------------------------------------------------------------------------------
-- GPS
----------------------------------------------------------------------------------------------------
local function update_gps_single(nr, power_status, not_failure_status)
    if power_status and not_failure_status then
        -- GPS is online
        if nr == 1 then
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.1, 0.1)
        else
            ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.1, 0.1)        
        end

        if gps_start_time_point[nr] == 0 then
            gps_start_time_point[nr] = get(TIME)
        end
        
        if get(TIME) - gps_last_time_on[nr] > 3600 or gps_last_time_on[nr] == 0 then
            -- We need a cold start
            if get(TIME) - gps_start_time_point[nr] > WARM_START_GPS then
                gps_last_time_on[nr] = get(TIME)
                return 1
            end
        else
            if get(TIME) - gps_start_time_point[nr] > HOT_START_GPS then
                gps_last_time_on[nr] = get(TIME)
                return 1
            end        
        end
    else
        gps_start_time_point[nr] = 0
    end
    return 0
end

local function update_gps()

    local roll_is_ok = math.abs(get(Flightmodel_roll)) <= 90

    if debug_override_ADIRS_ok then
        set(GPS_1_is_available, 1)
        set(GPS_2_is_available, 1)
    else
        set(GPS_1_is_available, update_gps_single(1, get(AC_ess_bus_pwrd) == 1, get(FAILURE_GPS_1) == 0 and roll_is_ok))
        set(GPS_2_is_available, update_gps_single(2, get(AC_bus_2_pwrd) == 1,   get(FAILURE_GPS_2) == 0 and roll_is_ok))
    end

    if get(GPS_1_is_available) == 1 then
        set(GPS_1_altitude, gps_1_offset + get(Elevation_m) * 3.28084)
        set(GPS_1_lat, get(Aircraft_lat)  + gps_1_offset * MAX_GPS_ERROR)
        set(GPS_1_lon, get(Aircraft_long) + gps_1_offset * MAX_GPS_ERROR)
    end
    
    if get(GPS_2_is_available) == 1 then
        set(GPS_2_altitude, gps_2_offset + get(Elevation_m) * 3.28084)
        set(GPS_2_lat, get(Aircraft_lat)  + gps_2_offset * MAX_GPS_ERROR)
        set(GPS_2_lon, get(Aircraft_long) + gps_2_offset * MAX_GPS_ERROR)
    end
    
end

function update()
    update_gps()
end