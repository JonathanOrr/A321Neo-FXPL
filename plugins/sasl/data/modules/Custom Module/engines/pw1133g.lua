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
-- File: pw1133g.lua
-- Short description: Engine data for PW1133G
-------------------------------------------------------------------------------

function configure_pw1133g()


    ENG.data = {
        has_cooling = true,     -- Does this engine have the (dual) cooling feature?
    
        max_n1     = 105,
        max_n2     = 105,
        max_thrust = 33110.0,   -- [lbs]
        fan_size   = 35.76,     -- [feet^2]
        fan_rpm_max= 3281.0,    -- [RPM] at 100% N1
        bypass_ratio = 12.5,    -- [-]

        n1_to_n2_fun = function(n1)
            return -2.6492 + 22.1036*math.log(n1)
        end,
        
        n1_to_egt_fun = function(n1, oat)
            return 1067.597 + (525.8561 - 1067.597)/(1 + (n1/76.42303)^4.611082) + (oat-6) *2
        end,

        oil = {
            qty_max = 22,               -- [QT] oil qty gauge shows a computed value which is about 1/2 actual just to have similar annunciations regardless engine type
            qty_min = 14,               -- [QT] currently unused?! randomness of initial qty is coded in update_engine_type()
            qty_consumption = 0.23,     -- [QT/hour]
            
            pressure_max_toga =  240,    -- [PSI]
            pressure_max_mct  =  220,    -- [PSI]
            pressure_min_idle =  100,     -- [PSI]
            
            temp_min_start = -40,     -- [°C]
            temp_min_toga  = 51.7,    -- [°C]
            temp_max_toga  = 120,     -- [°C]
            temp_max_mct   = 100,     -- [°C]
        },
        
        vibrations = {
            max_n1_nominal = 6,      -- [-]
            max_n2_nominal = 4.3,    -- [-]
        },

        startup = {
            n2 = {
                -- n2_start: start point after which the element is considered
                -- n2_increase_per_sec: N2 is increasing this value each second
                -- fuel_flow: the fuel flow to use in this phase (static)
                -- egt: the value for EGT at the beginning of this phase (it will increase towards the next value)
                {n2_start = 0,    n2_increase_per_sec = 0.26, fuel_flow = 0,   egt=0}, -- egt 0 lead to OAT in display
                {n2_start = 10,   n2_increase_per_sec = 1.5, fuel_flow = 0,    egt=0},
                {n2_start = 16.2, n2_increase_per_sec = 1.5, fuel_flow = 120,  egt=0}, -- EGT can increase only with fuel
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
            ign_on_n2 = 16,
            ign_off_n2 = 55,
            sav_close_n2 = 56
        },

        display = {
            n1_red_limit = 104,
            egt_scale = 1200,                -- [°C]
            egt_red_limit = 1083,            -- [°C]
            egt_amber_limit = 1043,          -- [°C]
            egt_amber_limit_on_start = nil,  -- [°C] Can be nil if not showed

            oil_qty_scale     = 22,          -- [QT]
            oil_qty_advisory  =  1.45,       -- [QT]

            oil_press_scale    = 450,       -- Scale of the ECAM object [PSI]
            oil_press_low_red  = {-108.62, 2.846},    -- 1st order polynomial terms as function of N2
            oil_press_low_amber= {-98.615, 2.846},   -- 1st order polynomial terms as function of N2 (use {-1, 0} if not used)
            oil_press_low_adv  = -1,         -- No present
            oil_press_high_adv = 259,        -- [PSI]

            oil_temp_high_adv  = 135,        -- [°C]
            oil_temp_high_amber= 152,        -- [°C]

        },

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


