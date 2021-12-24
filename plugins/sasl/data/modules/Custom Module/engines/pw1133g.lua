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

        n1_to_nfan  = function(n1)
            return n1 / 3.0625
        end,
        
        n1_to_egt_fun = function(n1, oat)
            return 1067.597 + (525.8561 - 1067.597)/(1 + (n1/76.42303)^4.611082) + (oat-6) *2
        end,

        n2_spoolup_fun = function(t)    -- ONLY for start, do not use once started (use n1_to_n2_fun)
            -- f( x ) = -51.28921087158405 + 26.341569276939737x - 4.888598740355502x2 + 0.4958496916187694x3 - 0.030213494410506178x4 + 0.0011400009575645398x5 - 0.00002614187911145765x6 + 3.3430175965887e-7x7 - 1.83007315404e-9x8
            return  -51.28921087158405 + 26.341569276939737*t - 4.888598740355502*t^2 + 0.4958496916187694*t^3 - 0.030213494410506178*t^4 + 0.0011400009575645398*t^5 - 0.00002614187911145765*t^6 + 3.3430175965887e-7*t^7 - 1.83007315404e-9*t^8
        end,

        n1_to_FF = function(n1, alt_feet, mach, ISA_diff)
            local FF_kgh =  146.727863052605 + 0.0261181684784363 * alt_feet + 11.5349714362869 * n1 -2975.15872221267 * mach
            -0.00118985331744109 * alt_feet * n1 + 0.00789909488873666 * alt_feet * mach + 7.6073360167464e-05 * alt_feet * ISA_diff
            +80.7328342498208 * n1 * mach -0.0747796055618955 * n1 * ISA_diff -7.14050794839843 * mach * ISA_diff
            +3.61693670778034e-07 * alt_feet^2 + 0.0734051071819252 * n1^2 -2515.81613588608 * mach^2
            +0.228108903034049 * ISA_diff^2
            return FF_kgh / 3600
        end,

        oil = {
            qty_max = 22,               -- [QT] oil qty gauge shows a computed value which is about 1/2 actual just to have similar annunciations regardless engine type
            qty_min = 14,               -- [QT] currently unused?! randomness of initial qty is coded in update_engine_type()
            qty_consumption = 0.2,      -- [QT/hour] acc AMM

            pressure_max_limit=  270,    -- [PSI]
            pressure_max_toga =  240,    -- [PSI]
            pressure_max_mct  =  220,    -- [PSI]
            pressure_min_idle =  100,     -- [PSI] TODO acc AMM is linear N2 based from min@IDLE: 65 up to 166 at redline N2
            
            temp_min_start = -40,     -- [°C]
            temp_min_toga  = 51.7,    -- [°C]
            temp_max_toga  = 120,     -- [°C] -- typical target values at thrust level
            temp_max_mct   = 100,     -- [°C]
        },
        
        vibrations = {
            max_n1_nominal = 6,      -- [-] TODO advisory level is 5 for N1 and N2 acc AMM
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
            oil_temp_high_amber= 152,        -- [°C] TODO dynamically adjust acc. thrust level based limits
            oil_temp_limit_toga  = 140.56,  -- [°C] limits at thrust level acc AMM
            oil_temp_limit_mct  = 146.11,   -- [°C]
            oil_temp_limit_idle  = 151.67,  -- [°C]

        },

        modes = {
            toga = { {  86.271, 0.00091623, -3.6944e-08, 8.3468e-13},   -- see eng_N1_limit_takeoff_clean
                     {  0.1937, -3.9445e-06, -5.07e-10,           0},
                     {-0.00133, -1.9656e-07,         0,           0},
                     {-3.6553e-05,        0,         0,           0}
            },
            toga_penalties = {
                temp_function = function(altitude) return 34 - (altitude+2000)/700 end,
                packs_dn_temp = -1.2,
                packs_up_temp = -1.5,
                nai_dn_temp = 0,
                nai_up_temp = -0.3,
                wai_dn_temp = 0,
                wai_up_temp = -1.4,
            },
            mct = {  { 8.56876385e+01,  5.00892548e-04, -9.41982308e-09},        -- + 3
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
            clb = {  { 8.20891154e+01, 5.99049610e-04, -8.66883834e-09},        -- + 2.5
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


        },
        model = {
            zero_thrust_n1            = 10,
            coeff_to_thrust_crit_temp = 0.0075, -- See thrust_takeoff_computation
            perc_penalty_AI_engine    = 0.012,  -- See thrust_penalty_computation
            perc_penalty_AI_wing      = 0.058,  -- See thrust_penalty_computation
            perc_penalty_AI_bleed     = 0.03,   -- See thrust_penalty_computation
            thr_mach_barrier          = 0.4,
            thr_k_coeff = {
                            {    -0.010  ,   -0.0025 },
                            { -0.3, -0.595 },
                            { 0.005, -0.03 },
                            { 0.89,      1 },
                          },
            thr_alt_penalty = {1, 0.7},
            thr_alt_limit   = 11000,
            CG_vert_displacement = 1.0287,  -- in meters
            CG_lat_displacement = 5.75,     -- in meters
        }

    }


end


