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
        max_n2     = 120,
        max_thrust = 31689.0,   -- [lbs]
        fan_size   = 33.12,     -- [feet^2]
        fan_rpm_max= 3855.0,    -- [RPM] at 100% N1
        bypass_ratio = 11.0,    -- [-]

        n1_to_n2_fun = function(n1)
            return 50 * math.log10(n1) + (n1+50)^3/220000 + 0.64
        end,

        n1_to_egt_fun = function(n1, oat)
            return 1067.597 + (525.8561 - 1067.597)/(1 + (n1/76.42303)^4.611082) + (oat-6) *2
        end,


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

        startup = { -- TODO: These values are for PW
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
            },
            ign_on_n2 = 16, -- TODO copied from PW, TBC
            ign_off_n2 = 55
        },
        
        display = {
            n1_red_limit = 101,
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

        },
        -- TODO this are just dummy values copied from PW1133g.lua at the moment to avoid crash on engine type switch
        -- LEAP1A will be difficult to model since there seems to be no known FF sim supporting that engine currently
        -- we have to try to get some flight deck videos
        modes = {
            toga = { { 9.09537996e+01,  8.24769700e-04, -1.96960266e-08},       -- + 5
                     { 1.45243960e-01, -6.53689814e-06, -1.70959299e-10},
                     {-4.80580173e-04, -2.17676880e-07,  4.76961949e-12}
            },
            toga_penalties = {
                temp_function = function(altitude) return 34 - (altitude+2000)/500 end,
                packs_dn_temp = -1.2,
                packs_up_temp = -1.5,
                nai_dn_temp = 0,
                nai_up_temp = -0.3,
                wai_dn_temp = 0,
                wai_up_temp = -1.4,
            },
            mct = {  { 8.86876385e+01,  5.00892548e-04, -9.41982308e-09},        -- + 3
                     { 1.43874177e-01, -7.44232815e-06,  5.47076769e-11},
                     {-4.88562399e-04, -1.52254937e-07,  2.74045662e-12}
            },
            mct_penalties = {
                temp_function = function(altitude) return 34 - (altitude+2000)/700 end,
                packs_dn_temp = -1.5,
                packs_up_temp = -1.6,
                nai_dn_temp = 0.2,
                nai_up_temp = -0.3,
                wai_dn_temp = 0.2,
                wai_up_temp = -3.0,
            },
            clb = {  { 8.45891154e+01, 5.99049610e-04, -8.66883834e-09},        -- + 2.5
                     { 1.31937461e-01, -3.22712476e-06, -5.12397002e-11},
                     {-4.90067904e-04, -1.16452281e-07,  1.49889194e-12}
            },
            clb_penalties = {
                temp_function = function(altitude) return 34 - (altitude+2000)/700 end,
                packs_dn_temp = -1.3,
                packs_up_temp = -1.5,
                nai_dn_temp = 0.5,
                nai_up_temp = -0.3,
                wai_dn_temp = 0.5,
                wai_up_temp = -1.2,
            },
            flex = {
                right = {
                    { 2.12393386e+01,  8.92878354e-04, -1.99370130e-08},
                    { 1.31597922e-01,  8.34865809e-06, -2.06686148e-09},
                    {-5.08554113e-03, -5.60800867e-07,  3.78138529e-11}
                },
                left = {
                    m = 2/3,
                    q = 206/3 + 3,      -- + 3
                    oat_off = 0.1
                }
            }


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


local MCT_t = {-54, -38, -22, -6, 10, 26}
local MCT_a = {-1000, 3000, 11000, 23000, 35000, 41000}
local MCT_N = {  {76.5,  78.6, 82.1,  88,  91,  89.0},
                 {79.2,  81.3, 84.9, 91.9, 92.9, 91.9},
                 {81.7,  83.8, 87.6, 94.7, 95.4, 94.5},
                 {84.1,  86.3, 90.1, 97.3, 93.5, 92.4},
                 {86.5,  88.8, 92.6, 94.8, 91.3, 90.3},
                 {88.8,  91.1, 91.5, 92.5, 88.1, 87.5}
              }

function eng_N1_limit_mct(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    local standard =  interpolate_2d(MCT_t, MCT_a, MCT_N, TAT, altitude) - (is_packs_on and 0.9 or 0) 
    
    if OAT > 25 then
        standard = standard - ((is_eng_ai_on and -1.4 or 0) + (is_wing_ai_on and -1.8 or 0)) * Math_clamp(OAT - 25, 0, 1)
    end
    
    return standard
end

local CLB_t = {-54, -38, -22, -6, 10, 26}
local CLB_a = {-1000, 3000, 11000, 23000, 35000, 41000}
local CLB_N = {  {74.5,  76.4, 78.8, 81.7, 89.1, 89.0},
                 {77.1,  79.1, 81.5, 84.5, 92.0, 91.9},
                 {79.6,  81.6, 84.0, 87.1, 94.8, 94.7},
                 {82.0,  84.0, 86.5, 89.7, 93.5, 92.4},
                 {84.3,  86.4, 88.9, 90.8, 91.3, 90.3},
                 {86.5,  88.7, 89.9, 89.5, 88.1, 87.5}
              }

function eng_N1_limit_clb(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    local standard =  interpolate_2d(CLB_t, CLB_a, CLB_N, TAT, altitude) - (is_packs_on and 0.8 or 0) 
    
    if OAT > 25 then
        standard = standard - ((is_eng_ai_on and -1.3 or 0) + (is_wing_ai_on and -1.1 or 0)) * Math_clamp(OAT - 25, 0, 1)
    end
    
    return standard
end



function eng_N1_limit_flex(FLEX_temp, OAT, altitude, is_packs_on)

    local y_lim  = -0.2769231*FLEX_temp + 20.76923
    
    local x = altitude
    local y_base = 6.921356 + 0.0008471222*x + 8.470689e-8 * x^2 + 4.83583e-11 * x^3 - 9.577161e-15 * x^4 + 4.0369989999999994e-19 * x^5

    local y = math.min(y_lim, y_base)
    
    local n1 = 80 + y + OAT/7.5 - (is_packs_on and 0.7 or 0)

    return n1
end


]]--


