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

-- All times in seconds
local INIT_START_GPS = 5
local HOT_START_GPS  = 1    -- nr. of seconds required to get GPS fix if last time active < 1 hour
local WARM_START_GPS = 20   -- nr. of seconds required to get GPS fix if last time active > 1 hour (we don't simulate cold start)

local MAX_GPS_ERROR = 1e-5

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local gps_offset = {math.random() * 2 - 0.5, math.random() * 2 - 0.5}

local function create_gps()
    return  {
                status = GPS_STATUS_OFF,
                nr_satellites = 0,
                lat = 0,
                lon = 0,
                alt = 0,
                true_track = 0,
                gs = 0,

                private = {
                    start_time   = 0,
                    last_time_on = 999999, -- Arbitrarily large
                    nr_satellites = 0,  -- Floating point value for animation
                }
            }
end

GPS_sys[1] = create_gps()
GPS_sys[2] = create_gps()

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local function gps_state_machine(i)

    if debug_override_ADIRS_ok then
        GPS_sys[i].status = GPS_STATUS_NAV
        GPS_sys[i].nr_satellites = 14
        return
    end

    local elec_status = (i == 1 and get(AC_ess_bus_pwrd) or get(AC_bus_2_pwrd)) == 1

    if not elec_status then
        GPS_sys[i].status = GPS_STATUS_OFF
        return
    end

    local failure_status = (i == 1 and get(FAILURE_GPS_1) or get(FAILURE_GPS_2)) == 1
    if failure_status then
        GPS_sys[i].status = GPS_STATUS_FAULT
        return
    end

    if GPS_sys[i].private.start_time == 0 then
        GPS_sys[i].private.start_time = get(TIME) + math.random()*2 -- Just create some randomness with the other GPS
    end

    local time_since_start = get(TIME) - GPS_sys[i].private.start_time

    if  time_since_start < INIT_START_GPS then
        GPS_sys[i].status = GPS_STATUS_INIT
        return
    end

    local time_since_init = time_since_start - INIT_START_GPS

    GPS_sys[i].status = GPS_STATUS_NAV

    if GPS_sys[i].private.last_time_on < 3600 then
        -- HOT START
        if  time_since_init < HOT_START_GPS then
            GPS_sys[i].status = GPS_STATUS_ACQ
            GPS_sys[i].private.nr_satellites = 4 - (HOT_START_GPS - time_since_init) / HOT_START_GPS * 4
        end
    else
        -- WARM START
        if  time_since_init < WARM_START_GPS then
            GPS_sys[i].status = GPS_STATUS_ACQ
            GPS_sys[i].private.nr_satellites = 4 - (WARM_START_GPS - time_since_init) / WARM_START_GPS * 4
        end
    end

    if GPS_sys[i].status == GPS_STATUS_NAV then

        -- Roll check
        local roll_is_ok = math.abs(get(Flightmodel_roll)) <= 90
        if not roll_is_ok then
            GPS_sys[i].status = GPS_STATUS_ACQ -- Go back to acquisition
            GPS_sys[i].nr_satellites = 0
            GPS_sys[i].private.nr_satellites = 0
        end

        -- NR. satellites simulation
        GPS_sys[i].private.last_time_on = get(TIME)
        local total_sat = math.ceil(8 + 6 * get(ZULU_hours) / 24) -- A random way to randomize visible satellites
        GPS_sys[i].private.nr_satellites = Set_linear_anim_value(GPS_sys[i].private.nr_satellites, total_sat, 4, 14, 0.05)
    end

    GPS_sys[i].nr_satellites = math.floor(GPS_sys[i].private.nr_satellites)


end

local function update_gps_values(i)
    if GPS_sys[i].status ~= GPS_STATUS_NAV then
        return
    end

    GPS_sys[i].lat = get(Aircraft_lat)  + gps_offset[i] * MAX_GPS_ERROR
    GPS_sys[i].lon = get(Aircraft_long)  + gps_offset[i]  * MAX_GPS_ERROR
    GPS_sys[i].alt = get(Elevation_m) * 3.28084 + gps_offset[i] * 50

    GPS_sys[i].true_track = get(Flightmodel_true_track) - gps_offset[i] / 2
    GPS_sys[i].gs = math.floor(get(Ground_speed_kts) + gps_offset[i] / 2)
end

function update()
    gps_state_machine(1)
    gps_state_machine(2)

    update_gps_values(1)
    update_gps_values(2)

end