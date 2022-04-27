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

-- Adapted from: https://aviation.stackexchange.com/a/77300/12643

local feet_per_metre = 3.28
local T_0C = 273.15   -- 0 degrees C in Kelvin


local g=9.81          -- Acceleration due to gravity
local R=287           -- Specific gas constant for air
local L=0.0065        -- Lapse rate in K/m
local T0 = 288.15     -- ISA sea level temp in K
local p0 = 101325     -- ISA sea level pressure in Pa
local k = 1.4         -- k is a shorthand for Gamma, the ratio of specific heats for air
local lss0 = math.sqrt(k*R*T0) -- ISA sea level speed sound
local rho0 = 1.225    -- ISA sea level density in Kg/m3


-- Return pressure ratio given a Mach number and static pressure,
-- assuming compressible flow
local function compressible_pitot(M)
    return (M*M*(k-1)/2 + 1) ^ (k/(k-1)) - 1
end

local function compressible_pitot_inverse(p)
    return math.sqrt(((p + 1) ^ (1/(k/(k-1))) - 1) * 2 / (k-1))
end

-- Return Mach number, given a pressure ratio d=p_d/p_s
local function pitot_to_mach(d)
    return math.sqrt(((d+1)^((k-1)/k) - 1)*2/(k-1))
end

local function mach_to_pitot(M)
    return (M^2 * (k-1) / 2 + 1)^(1/((k-1)/k)) - 1
end

-- Given an altitude h, return the temperature, assuming we're
-- using the International Standard Atmosphere and are flying
-- in the troposphere.
local function temperature(h)
    return T0 - h*L
end

-- Given an altitude h, return the local spead of sound, assuming
-- we're using the International Standard Atmosphere and are flying
-- in the troposphere.
local function lss(h)
    return math.sqrt(k*R*temperature(h))
end

-- Given an altitude h, return the pressure, assuming we're
-- using the International Standard Atmosphere and are flying
-- in the troposphere.
local function pressure(h)
    return p0 * (temperature(h) / T0) ^ (g / L / R)
end

-- Given an altitude h, return the density, assuming we're
-- using the International Standard Atmosphere and are flying
-- in the troposphere.
local function density(h)
    return pressure(h) / (R * temperature(h))
end


function m_to_nm(m)
    return m * 0.000539957;
end

function nm_to_m(nm)
    return nm * 1852;
end

function kts_to_ms(kts)
    return kts * 0.514444
end

function ms_to_kts(ms)
    return ms * 1.94384
end


function fpm_to_kts(fpm)
    return fpm * 0.00987473
end

function fpm_to_ms(fpm)
    return 0.00508 * fpm
end

function ms_to_fpm(ms)
    return 196.85 * ms
end

function convert_to_eas_tas_mach(cas, alt)
    cas = kts_to_ms(cas)
    alt = alt / feet_per_metre

    local ps = pressure(alt)
    local lss = lss(alt)
    local oat = temperature(alt)
    local rho = density(alt)
    local pd = compressible_pitot(cas/lss0) * p0

    local M = pitot_to_mach(pd / ps)
    local eas = lss0 * M * math.sqrt(ps/p0)
    local tas = lss * M

    return ms_to_kts(eas), ms_to_kts(tas), M
end

function mach_to_cas(M, alt)
    alt = alt / feet_per_metre

    local ps = pressure(alt)
    local pd = mach_to_pitot(M) * ps
    local caslss = compressible_pitot_inverse(pd / p0)

    return ms_to_kts(caslss * lss0)
end

function convert_to_tas(M, alt)
    alt = alt / feet_per_metre

    local lss = lss(alt)
    local tas = M * lss

    return ms_to_kts(tas)
end


-- return in [kts]
-- inputs: tas [kts], vs [fpm], v_wind [kts], d_wind [deg, relative]
function tas_to_gs(tas, vs, v_wind, d_wind)
    vs = fpm_to_kts(vs)
    return math.sqrt(tas*tas - vs*vs) + v_wind * math.cos(math.rad(d_wind))
end

function wind_to_relative(wind_dir, acf_dir)
    return (acf_dir - wind_dir + 360) % 360
end