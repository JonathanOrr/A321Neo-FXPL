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

local DRY_AIR_CONSTANT=287.058
local EARTH_GRAVITY = 9.80665

local function get_std_pressure(altitude, tropo_alt, sea_level_temp, sea_level_press)
    local h = altitude * 0.3048 -- Feet to meters
    local T0 = sea_level_temp and (sea_level_temp + 273.15) or 288.15
    local p0 = sea_level_press or 101325
    tropo_alt = tropo_alt or 36089

    if altitude <= tropo_alt then
        return p0 * (1-0.0065*h/T0) ^ 5.2561
    else
        return 22632 * math.exp(-EARTH_GRAVITY/(DRY_AIR_CONSTANT*216.65) * (altitude - tropo_alt))
    end
end

function air_get_density(altitude, tropo_alt, sea_level_temp, sea_level_press)
    return get_std_pressure(altitude, tropo_alt, sea_level_temp, sea_level_press) 
        / (DRY_AIR_CONSTANT * (sea_level_temp + 273.15))
end

function air_temperature_get_ISA()
    local alt_meter = get(ACF_elevation)
    return math.max(-56.5, 15 - 6.5 * alt_meter/1000)
end

function air_density_to_ratio(density)
    return density / 1.225
end

function air_compute_vs(T,D,W,tas)
    local gamma = ( T - D ) / W;
    return tas * math.sin(gamma) * 60
end

function air_predict_temperature_at_alt(curr_ota, curr_alt_ft, ref_alt_ft)
    local curr_alt_m= curr_alt_ft*0.3048
    local ref_alt_m = ref_alt_ft*0.3048
    
    local isa_temp = math.max(-56.5, 15 - 6.5 * ref_alt_m/1000)
    local isa_temp_curr = math.max(-56.5, 15 - 6.5 * curr_alt_m/1000)
    return isa_temp+isa_temp_curr-curr_ota
end