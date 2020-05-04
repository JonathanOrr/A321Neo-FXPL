--global dataref for the A32NX project
Capt_ra_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_ra_alt_m", 0, false, true, false)
Capt_baro_alt_m = createGlobalPropertyf("a321neo/cockpit/indicators/capt_baro_alt_m", 0, false, true, false)
Distance_traveled_mi = createGlobalPropertyf("a321neo/dynamics/distance_traveled_mi", 0, false, true, false)
Distance_traveled_km = createGlobalPropertyf("a321neo/dynamics/distance_traveled_km", 0, false, true, false)
Ground_speed_kmh = createGlobalPropertyf("a321neo/dynamics/groundspeed_kmh", 0, false, true, false)
Ground_speed_mph = createGlobalPropertyf("a321neo/dynamics/groundspeed_mph", 0, false, true, true)
Engine_1_master_switch = createGlobalPropertyi("a321neo/engine/master_1", 0, false, true, false)
Engine_2_master_switch = createGlobalPropertyi("a321neo/engine/master_2", 0, false, true, false)

--global dataref variable from the Sim
Capt_ra_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
Capt_baro_alt_ft = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
Distance_traveled_m = globalProperty("sim/flightmodel/controls/dist")
Ground_speed_ms = globalProperty("sim/flightmodel/position/groundspeed")
Engine_1_avail = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
Engine_2_avail = globalProperty("sim/flightmodel/engine/ENGN_running[1]")

function geo_distance(lat1, lon1, lat2, lon2)
    if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil then
      return nil
    end
    local dlat = math.rad(lat2-lat1)
    local dlon = math.rad(lon2-lon1)
    local sin_dlat = math.sin(dlat/2)
    local sin_dlon = math.sin(dlon/2)
    local a = sin_dlat * sin_dlat + math.cos(math.rad(lat1)) * math.cos(math.rad(lat2)) * sin_dlon * sin_dlon
    local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    -- 6378 km is the earth's radius at the equator.
    -- 6357 km would be the radius at the poles (earth isn't a perfect circle).
    -- Thus, high latitude distances will be slightly overestimated
    -- To get miles, use 3963 as the constant (equator again)
    local d = 6378 * c
    return d
end