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
-- File: leap1a.lua
-- Short description: Engine data for LEAP1A
-------------------------------------------------------------------------------

function configure_leap_1a()

    ENG_data = {
        has_cooling = true,     -- Does this engine have the (dual) cooling feature?
    
        max_thrust = 31689.0,   -- [lbs]
        fan_size   = 33.12,     -- [feet^2]
        fan_rpm_max= 3281.0,    -- [RPM] at 100% N1
        bypass_ratio = 11.0,    -- [-]

        oil = {
            qty_max = 17,               -- [L]
            qty_min = 2,                -- [L]
            qty_consumption = 0.45,      -- [L/hour]
            
            pressure_max_toga =  50,    -- [PSI]
            pressure_max_mct  =  40,    -- [PSI]
            pressure_min_idle =  17,    -- [PSI]
            
            temp_min_start = -25,   -- [°C]
            temp_min_toga  = 38,    -- [°C]
            temp_max_toga  = 155,   -- [°C]
            temp_max_mct   = 140,   -- [°C]
        },
        
        vibrations = {
            max_n1_nominal = 6,     -- [-]
            max_n2_nominal = 4.3,    -- [-]
        },

        startup = {
            n2 = {
                -- n2_start: start point after which the element is considered
                -- n2_increase_per_sec: N2 is increasing this value each second
                -- fuel_flow: the fuel flow to use in this phase (static)
                -- egt: the value for EGT at the beginning of this phase (it will increase towards the next value)
                {n2_start = 0,    n2_increase_per_sec = 0.26, fuel_flow = 0,   egt=0},
                {n2_start = 10,   n2_increase_per_sec = 1.5, fuel_flow = 0,    egt=97},
                {n2_start = 16.2, n2_increase_per_sec = 1.5, fuel_flow = 120,  egt=97},
                {n2_start = 16.7, n2_increase_per_sec = 1.8, fuel_flow = 180,  egt=97},
                {n2_start = 24,   n2_increase_per_sec = 1.25, fuel_flow = 100, egt=162},
                {n2_start = 26.8, n2_increase_per_sec = 1.25, fuel_flow = 100, egt=263},
                {n2_start = 31.8, n2_increase_per_sec = 0.44, fuel_flow = 120, egt=173},
                {n2_start = 34.2, n2_increase_per_sec = 0.60, fuel_flow = 140, egt=229}
            },
            n1 = {
                {n1_set = 2,      n1_increase_per_sec = 1, fuel_flow = 140, egt=230},
                {n1_set = 5,      n1_increase_per_sec = 0.60, fuel_flow = 140, egt=290},
                {n1_set = 6.6,    n1_increase_per_sec = 0.60, fuel_flow = 160, egt=303},
                {n1_set = 7.3,    n1_increase_per_sec = 0.20, fuel_flow = 180, egt=357},
                {n1_set = 7.8,    n1_increase_per_sec = 0.20, fuel_flow = 220, egt=393},
                {n1_set = 12.2,   n1_increase_per_sec = 0.60, fuel_flow = 260, egt=573},
                {n1_set = 14.9,   n1_increase_per_sec = 0.60, fuel_flow = 280, egt=574},
                {n1_set = 15.4,   n1_increase_per_sec = 1.16, fuel_flow = 300, egt=580},
                {n1_set = 16.3,   n1_increase_per_sec = 1.08, fuel_flow = 320, egt=592},
                {n1_set = 17.1,   n1_increase_per_sec = 0.83, fuel_flow = 340, egt=602},
                {n1_set = 17.6,   n1_increase_per_sec = 0.79, fuel_flow = 360, egt=623},
                {n1_set = 18.3,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637},
                {n1_set = 18.5,   n1_increase_per_sec = 0.24, fuel_flow = 380, egt=637},
            }
        }

    }

end


