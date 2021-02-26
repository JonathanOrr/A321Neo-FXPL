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
-- File: engines_computations.lua
-- Short description: Functions to compute the MAX N1 value for each mode
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Helper functions
-------------------------------------------------------------------------------

local function interpolate_2d(x,y,z,value_x, value_y)

    local i = 1
    while i <= #x do
        if x[i] >= value_x then
            break
        end
        i = i + 1
    end

    local j = 1
    while j <= #y do
        if y[j] >= value_y then
            break
        end
        j = j +1
    end


    local temp_j = j
    if temp_j > #y then
        temp_j = #y
    end
    
    local x_comp = 0
    if i == 1 then
        x_comp = z[i][temp_j]
    elseif i > #x then
        x_comp = z[#x][temp_j]
        i = #x
    else

        x_comp = Math_rescale(x[i-1], z[i-1][temp_j], x[i], z[i][temp_j], value_x) 
    end

    local y_comp = 0
    if j == 1 then
        y_comp = z[i][j]
    elseif j > #y then
        y_comp = z[i][#y]
    else
        y_comp = Math_rescale(y[j-1], z[i][j-1], y[j], z[i][j], value_y) 
    end

    return (x_comp + y_comp) / 2
end

local function poly_2nd_order(coeff, x, y)
    return coeff[1][1] + coeff[2][1] * x + coeff[3][1] * x^2 + coeff[1][2] * y + coeff[1][3] * y^2 +
           coeff[2][2] * x * y + coeff[2][3] * x * y^2 +  coeff[3][2] * x^2 * y +  coeff[3][3] * x^2 * y^2
end

local function compute_penalties(penalty_table, OAT_condition_triggered, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    local EXTRA = 0
    
    if OAT_condition_triggered then
        if is_packs_on then
            EXTRA = EXTRA + penalty_table.packs_up_temp;
        end
        if is_eng_ai_on then
            EXTRA = EXTRA + penalty_table.nai_up_temp;
        end
        if is_wing_ai_on then
            EXTRA = EXTRA + penalty_table.wai_dn_temp;
        end
    else
        if is_packs_on then
            EXTRA = EXTRA + penalty_table.packs_dn_temp;
        end
        if is_eng_ai_on then
            EXTRA = EXTRA + penalty_table.nai_dn_temp;
        end
        if is_wing_ai_on then
            EXTRA = EXTRA + penalty_table.wai_up_temp;
        end
    end
    return EXTRA
end

-------------------------------------------------------------------------------
-- TOGA mode
-------------------------------------------------------------------------------

function eng_N1_limit_takeoff(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    local comp  = poly_2nd_order(ENG.data.modes.toga, OAT, altitude)

    local temp_corner_point = ENG.data.modes.toga_penalties.temp_function(altitude)

    local EXTRA = compute_penalties(ENG.data.modes.toga_penalties, OAT >= temp_corner_point, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    return Math_clamp(comp + EXTRA, 50, ENG.data.max_n1)
end

-------------------------------------------------------------------------------
-- SOFT GA mode
-------------------------------------------------------------------------------

function eng_N1_limit_ga_soft(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    return eng_N1_limit_takeoff(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on) - Math_clamp(4 * (altitude+2000)/9000, 0, 4)
end

-------------------------------------------------------------------------------
-- MCT mode
-------------------------------------------------------------------------------

function eng_N1_limit_mct(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    local comp  = poly_2nd_order(ENG.data.modes.mct, OAT, altitude)

    local temp_corner_point = ENG.data.modes.mct_penalties.temp_function(altitude)

    local EXTRA = compute_penalties(ENG.data.modes.mct_penalties, OAT >= temp_corner_point, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    return Math_clamp(comp + EXTRA, 50, ENG.data.max_n1)
end

-------------------------------------------------------------------------------
-- CLIMB mode
-------------------------------------------------------------------------------


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

-------------------------------------------------------------------------------
-- FLEX mode
-------------------------------------------------------------------------------

function eng_N1_limit_flex(FLEX_temp, OAT, altitude, is_packs_on)

    local y_lim  = -0.2769231*FLEX_temp + 20.76923
    
    local x = altitude
    local y_base = 6.921356 + 0.0008471222*x + 8.470689e-8 * x^2 + 4.83583e-11 * x^3 - 9.577161e-15 * x^4 + 4.0369989999999994e-19 * x^5

    local y = math.min(y_lim, y_base)
    
    local n1 = 80 + y + OAT/7.5 - (is_packs_on and 0.7 or 0)

    return n1
end


