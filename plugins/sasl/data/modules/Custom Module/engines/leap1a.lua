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

    ENG.data = {
        has_cooling = false,     -- Does this engine have the (dual) cooling feature?
    
        max_n1     = 101,
        max_thrust = 31689.0,   -- [lbs]
        fan_size   = 33.12,     -- [feet^2]
        fan_rpm_max= 3855.0,    -- [RPM] at 100% N1
        bypass_ratio = 11.0,    -- [-]

        oil = {
            qty_max = 17,               -- [QT]
            qty_min = 2,                -- [QT]
            qty_consumption = 0.45,     -- [QT/hour]
            
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
        },
        
        display = {
            egt_scale = 1200,               -- [°C]
            egt_red_limit = 1050,           -- [°C]
            egt_amber_limit = 950,          -- [°C]
            egt_amber_limit_on_start = 725, -- [°C] Can be nil if not showed

            oil_qty_scale     = 17,
            oil_qty_advisory  =  2,

            oil_press_scale    = 100,       -- Scale of the ECAM object [PSI]
            oil_press_low_red  = {7, 0},    -- 1st order polynomial terms as function of N2
            oil_press_low_amber= {-1, 0},   -- 1st order polynomial terms as function of N2 (use {-1, 0} if not used)
            oil_press_low_adv  = 13,
            oil_press_high_adv = 90,

            oil_temp_high_adv  = 140,
            oil_temp_high_amber= 155,

        }

    }

end

--[[

TOGA:

local TOGA_t = {-54, -38, -22, -6, 10, 26, 42}
local TOGA_a = {-1000, 3000, 11000, 14500, 35000}
local TOGA_N = { {76.2,  82.3, 88.2, 88.5, 92},
                 {78.8,  85.1, 91.1, 91.5, 93},
                 {81.4,  87.7, 93.9, 94.3, 95.5},
                 {83.8,  90.3, 96.6, 97.0, 94},
                 {86.2,  92.8, 99.2, 98.8, 91.2},
                 {89.5, 95.3, 94.9, 94.8, 88.1},
                 {90.8,  95.6, 94.8, 93.2, 87.1}
              }
function eng_N1_limit_takeoff(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    local comp  = interpolate_2d(TOGA_t, TOGA_a, TOGA_N, TAT, altitude)
    
    local EXTRA = (is_packs_on and -0.7 or 0)
    
    local temp_corner_point = -2*altitude/825 + 1358/33
    
    if OAT >= temp_corner_point then
        EXTRA = EXTRA + ((is_eng_ai_on and -1.6 or 0) + (is_wing_ai_on and -0.8 or 0)) * Math_clamp(OAT - temp_corner_point, 0, 1)
    end
    
    return Math_clamp(comp + EXTRA + 1, 73.8, 101)
end


]]--


