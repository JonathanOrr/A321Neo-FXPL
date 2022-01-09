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

local function poly_3rd_order(coeff, x, y)
    return coeff[1][1] + coeff[2][1] * x + coeff[3][1] * x^2  + coeff[4][1] * x^3 +
                         coeff[1][2] * y + coeff[1][3] * y^2  + coeff[1][4] * y^3 +
                         coeff[2][2] * x * y + coeff[3][2] * x^2 * y   + coeff[4][2] * x^3 * y +
                                               coeff[2][3] * x   * y^2 + coeff[2][4] * x * y^3 +
                         coeff[3][3] * x^2 * y^2 + coeff[4][3] * x^3 * y^2 + coeff[3][4] * x^2 * y^3 +
                         coeff[4][4] * x^3 * y^3
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

function eng_N1_limit_takeoff_clean(OAT, TAT, altitude)
    if altitude > 16000 then
        return 1 + eng_N1_limit_mct(OAT, TAT, altitude, false, false, false)
    end

    local comp  = poly_3rd_order(ENG.data.modes.toga, TAT, altitude)
    return Math_clamp(comp, 50, ENG.data.max_n1)
end

function eng_N1_limit_takeoff(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    if altitude > 16000 then
        return 1 + eng_N1_limit_mct(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    end

    local comp  = poly_3rd_order(ENG.data.modes.toga, TAT, altitude)


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
    local comp  = poly_2nd_order(ENG.data.modes.mct, TAT, altitude)

    local temp_corner_point = ENG.data.modes.mct_penalties.temp_function(altitude)

    local EXTRA = compute_penalties(ENG.data.modes.mct_penalties, OAT >= temp_corner_point, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    return Math_clamp(comp + EXTRA, 50, ENG.data.max_n1)
end

-------------------------------------------------------------------------------
-- CLIMB mode
-------------------------------------------------------------------------------

function eng_N1_limit_clb(OAT, TAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)
    local comp  = poly_2nd_order(ENG.data.modes.clb, TAT, altitude)
    local temp_corner_point = ENG.data.modes.clb_penalties.temp_function(altitude)

    local EXTRA = compute_penalties(ENG.data.modes.clb_penalties, OAT >= temp_corner_point, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    return Math_clamp(comp + EXTRA, 50, ENG.data.max_n1)
end

-------------------------------------------------------------------------------
-- FLEX mode
-------------------------------------------------------------------------------

function eng_N1_limit_flex(FLEX_temp, OAT, altitude, is_packs_on, is_eng_ai_on, is_wing_ai_on)

    local y_lim = poly_2nd_order(ENG.data.modes.flex.right, FLEX_temp, altitude)
    
    local uncorrected_N1 = ENG.data.modes.flex.left.m * y_lim + ENG.data.modes.flex.left.q

    uncorrected_N1 = uncorrected_N1 + OAT * ENG.data.modes.flex.left.oat_off
    
    local n1 = uncorrected_N1 + (is_packs_on and -1.5 or 0) + (is_eng_ai_on and -0.3 or 0) - (is_wing_ai_on and -1.4 or 0)

    return n1
end


