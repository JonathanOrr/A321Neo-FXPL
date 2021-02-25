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
        max_thrust = 33110.0,   -- [lbs]
        fan_size   = 35.76,     -- [feet^2]
        fan_rpm_max= 3281.0,    -- [RPM] at 100% N1
        bypass_ratio = 12.5,    -- [-]

        oil = {
            qty_max = 35,               -- [QT]
            qty_min = 14,               -- [QT]
            qty_consumption = 0.45,     -- [QT/hour]
            
            pressure_max_toga =  200,    -- [PSI]
            pressure_max_mct  =  190,    -- [PSI]
            pressure_min_idle =  65,    -- [PSI]
            
            temp_min_start = -40,   -- [°C]
            temp_min_toga  = 51.7,    -- [°C]
            temp_max_toga  = 120,   -- [°C]
            temp_max_mct   = 100,   -- [°C]
        },
        
        vibrations = {
            max_n1_nominal = 6,     -- [-]
            max_n2_nominal = 4.3,    -- [-]
        },
        
        display = {
            egt_scale = 1200,                -- [°C]
            egt_red_limit = 1083,            -- [°C]
            egt_amber_limit = 1043,          -- [°C]
            egt_amber_limit_on_start = nil,  -- [°C] Can be nil if not showed

            oil_qty_scale     = 35,
            oil_qty_advisory  =  1.45,

            oil_press_scale    = 450,       -- Scale of the ECAM object [PSI]
            oil_press_low_red  = {-108.62, 2.846},    -- 1st order polynomial terms as function of N2
            oil_press_low_amber= {-98.615, 2.846},   -- 1st order polynomial terms as function of N2 (use {-1, 0} if not used)
            oil_press_low_adv  = -1,         -- No present
            oil_press_high_adv = 259,

            oil_temp_high_adv  = 135,
            oil_temp_high_amber= 152,

        },

        modes = {
            toga = { { 9.09537996e+01,  8.24769700e-04, -1.96960266e-08},
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
            }

        }

    }


end


