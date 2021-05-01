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
-- File: tcas_algorithm.lua
-- Short description: TCAS algorithm according to NASA document
-- Source: https://ntrs.nasa.gov/api/citations/20140002736/downloads/20140002736.pdf
-------------------------------------------------------------------------------

-- TCAS possible results, do not use this for audio and alerts, for internal use only
TCAS_OUTPUT_CLEAR        = 0
TCAS_OUTPUT_CLIMB_LOW    = 1
TCAS_OUTPUT_DESCEND_LOW  = 2
TCAS_OUTPUT_CLIMB_HIGH   = 3
TCAS_OUTPUT_DESCEND_HIGH = 4
TCAS_TRAFFIC             = 5

-- Math functions to improve performance
local mabs  = math.abs
local msqrt = math.sqrt

-- Paramters from tabular data
local parameters_RA = {
    {
        tau = 15,
        dmod = 0.2,
        zthr = 600,
        alim = 300
    },
    {
        tau = 20,
        dmod = 0.35,
        zthr = 600,
        alim = 300
    },
    {
        tau = 25,
        dmod = 0.55,
        zthr = 600,
        alim = 350
    },
    {
        tau = 30,
        dmod = 0.8,
        zthr = 600,
        alim = 400
    },
    {
        tau = 35,
        dmod = 1.1,
        zthr = 700,
        alim = 600
    },
    {
        tau = 35,
        dmod = 1.1,
        zthr = 800,
        alim = 700
    }
}

local parameters_TA = {
    {
        tau = 20,
        dmod = 0.3,
        zthr = 850,
    },
    {
        tau = 25,
        dmod = 0.33,
        zthr = 850,
    },
    {
        tau = 30,
        dmod = 0.48,
        zthr = 850,
    },
    {
        tau = 40,
        dmod = 0.75,
        zthr = 850,
    },
    {
        tau = 45,
        dmod = 1,
        zthr = 850,
    },
    {
        tau = 48,
        dmod = 1.3,
        zthr = 850,
    },
    {
        tau = 48,
        dmod = 1.3,
        zthr = 1200,
    }
}

local function which_ra_params(alt)
    if alt <= 2350 then
        return 1
    elseif alt <= 5000 then
        return 2
    elseif alt <= 10000 then
        return 3
    elseif alt <= 20000 then
        return 4
    elseif alt <= 42000 then
        return 5
    else
        return 6
    end
end

-------------------------------------------------------------------------------
-- Math helpers
-------------------------------------------------------------------------------

local function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end
local function item_mult(a,b)
    return a[1] * b[1] + a[2]*b[2]
end

local function perpendicular(a)
    return { a[2], -a[1] }
end

local function delta(s, v, D)
    local x = D * D * item_mult(v,v)
    v = perpendicular(v)
    local y = item_mult(s,v)
    return x - y*y
end

local function root(a, b, c, eps)   -- Find a 2nd order polynomial solution (if no solution exists returns 0)
    if a == 0 then
        return 0
    end
    if b*b - 4*a*c < 0 then
        return 0
    end
    return (-b + eps*msqrt(b*b - 4*a*c)) / (2 * a)
end

local function theta(s, v, D, eps)
    return root(item_mult(v,v), 2*item_mult(v,v), item_mult(s,s)-D*D, eps)
end

local function tau_mod (s, v, dmod)
	return (dmod*dmod - item_mult(s,s)) / item_mult(s,v);
end

-------------------------------------------------------------------------------
-- Common RA + TA
-------------------------------------------------------------------------------

local function CD2D_inf(diff_pos, diff_spd, D, B)
    local spd_m = item_mult(diff_spd,diff_spd)
    if spd_m == 0 then
        if item_mult(diff_pos,diff_pos) <= D then
            return true
        end
    elseif spd_m > 0 then
        if delta(diff_pos, diff_spd, D) >= 0 then
            if theta(diff_pos, diff_spd, D, 1) >= B then
                return true
            end
        end
    end
    return false
end

local function H(vz, zthr, tau)
	return math.max(zthr, tau*mabs(vz));
end

local function RAZTimeInterval(diff_alt, diff_vs, zthr, tau, B, T)
    if diff_vs == 0 then
        return {B, T}
    end
    return {
        (-sign(diff_vs)*H(diff_vs, zthr, tau)-diff_alt)/diff_vs,
        (sign(diff_vs)*zthr - diff_alt)/diff_vs;
    }

end

local function RA2DTimeInterval(diff_alt, diff_vs, tau, dmod, B, T)
    local a = item_mult(diff_vs, diff_vs)
    local b = 2*item_mult(diff_alt, diff_vs) + tau * item_mult(diff_alt, diff_vs) - dmod*dmod
    local c = item_mult(diff_alt, diff_alt) + tau*item_mult(diff_alt, diff_vs) - dmod*dmod

    local m_alt = item_mult(diff_alt, diff_alt) 

    if a == 0 then
        if m_alt <= dmod then
            return {B,T}
        end
    end

    local o = theta(diff_alt, diff_vs, dmod, 1)
    if m_alt <= dmod then
        return {B, o}
    end

    if item_mult(diff_alt, diff_vs) >= 0 and (b*b-4*a*c < 0) then
        return {T+1, 0}
    end

    if delta(diff_alt, diff_vs, dmod) >= 0 then
        return {root(a,b,c,-1), 0}
    end

    return {root(a,b,c,-1), root(a,b,c,1)}
end


local function RA3DTimeInterval(my_acf, int_acf, B, T, parameters, use_hmdf)

    local diff_pos = {
        my_acf.x - int_acf.x,
        my_acf.y - int_acf.y
    }

    local diff_spd = {
        my_acf.vx - int_acf.vx,
        my_acf.vy - int_acf.vy
    }

    local diff_alt = my_acf.alt - int_acf.alt
    local diff_vs  = my_acf.vs  - int_acf.vs

    -- RA
    if use_hmdf then
        if not CD2D_inf(diff_pos, diff_spd, parameters.dmod, B) then
            return {T,B}
        end
    end

    if diff_vs == 0 then
        if mabs(diff_alt) > parameters.zthr then
            return {T,B}    -- Same V/S but too far with altitude, CLEAR here
        end
    end

    local res_z = RAZTimeInterval(diff_alt, diff_vs, parameters.zthr, parameters.tau, B, T)
    if res_z[2] < B or res_z[1] < T then
        return {T,B}    -- Too far with altitude even in case of V/S ~= 0, CLEAR here
    end

    local t2 = { math.max(B, res_z[1]), math.min(T, res_z[2]) }

    local res_2d = RA2DTimeInterval(diff_alt, diff_vs, B, T)

    if res_2d[0] > res_2d[1] or res_2d[2] < t2[1] or res_2d[1] > t2[2] then
        return {T,B} -- Too far, CLEAR
    end

    return {
        math.max(t2[1], math.min(t2[2], res_2d[1])),
        math.max(t2[1], math.min(t2[2], res_2d[2])),
    }

end



--tcas_bench(so,             my_alt, vo, my_vs, si, int_alt, vi, int_vs);
--tcas_bench(double *so, double soz, double *vo, double voz, double *si, double siz, double *vi, double viz) 
-------------------------------------------------------------------------------
-- RA
-------------------------------------------------------------------------------

local function stop_accel(voz, v, a, eps, t)
	if (t <= 0) or eps*voz >= v then
		return 0
    end
	return (eps*v - voz) / (eps*a);
end

local function own_alt_at(my_acf, v, a, eps, t)
	local s = stop_accel(my_acf.vs,v,a,eps,t)
	local q = math.min(t,s);
	local l = math.max(0, t-s);
	return eps*q*q*a/2 + q*my_acf.vs + my_acf.alt + eps*l*v;
end

local function RA_sense(my_acf, int_acf, parameters, v, a, t)

    local ou = own_alt_at(my_acf, v, a, 1, t)
    local od = own_alt_at(my_acf, v, a, -1, t)

    local i = int_acf.alt + t * int_acf.vs
    local u = ou - i
    local d = i - od

    if sign(my_acf.alt - int_acf.alt) == 1 then
        if u >= parameters.alim then
            return 1
        end
    end

    if sign(my_acf.alt - int_acf.alt) == -1 then
        if d >= parameters.alim then
            return -1
        end
    end

    if u >= d then
        return 1
    else
        return -1
    end
end


local function corrective(my_acf, int_acf, parameters, v, a)
    local diff_pos = {
        my_acf.x - int_acf.x,
        my_acf.y - int_acf.y
    }

    local diff_spd = {
        my_acf.vx - int_acf.vx,
        my_acf.vy - int_acf.vy
    }

    local diff_alt = my_acf.alt - int_acf.alt
    local diff_vs  = my_acf.vs  - int_acf.vs

    local t = tau_mod(diff_pos, diff_spd, parameters.dmod)
    local eps = RA_sense(my_acf, int_acf, parameters, v, a, t)
    if item_mult(diff_pos, diff_pos) < parameters.dmod then
        return true
    end
    if item_mult(diff_pos, diff_spd) < 0 then
        if eps * (diff_alt + t * diff_vs) < parameters.alim then
            return true
        end
    end
    return false
end

local function compute_RA(my_acf, int_acf)

    local parameters = parameters_RA[which_ra_params()]

    local res = RA3DTimeInterval(my_acf, int_acf, 0, 1, parameters, true)
    return res[1] < res[2]
end

local function get_RA_result(my_acf, int_acf)
    local v = 1500  -- FPM
    local a = 0.25 *  1930.44 -- G

    local parameters = parameters_RA[which_ra_params()]

    local corr_low = corrective(my_acf, int_acf, parameters, v, a)
    if corr_low then
        if RA_sense(my_acf, int_acf, parameters, v, a, 0) == 1 then
            return TCAS_OUTPUT_CLIMB_LOW
        else
            return TCAS_OUTPUT_DESCEND_LOW
        end
    else
        v = 2500
        a = 0.35 * 1930.44
        if RA_sense(my_acf, int_acf, parameters, v, a, 0) == 1 then
            return TCAS_OUTPUT_CLIMB_HIGH
        else
            return TCAS_OUTPUT_DESCEND_HIGH
        end
    end

    return TCAS_OUTPUT_CLEAR -- Should not happen
end

-------------------------------------------------------------------------------
-- TA
-------------------------------------------------------------------------------

local function compute_TA(my_acf, int_acf)

end

-------------------------------------------------------------------------------
-- Main function
-------------------------------------------------------------------------------


function compute_tcas(my_acf, int_acf)
    -- Data format:
    -- my_acf / int_acf = {
    --     alt [feet]
    --     vs [fpm]
    --     x [lat, x-plane ref system]
    --     y [lon, x-plane ref system]
    --     vx [x-plane ref system]
    --     vy [x-plane ref system]
    -- }

    local ra_result = compute_RA(my_acf, int_acf)
    if ra_result ~=0 then
        return get_RA_result(my_acf, int_acf)
    end

    local ta_result = compute_TA(my_acf, int_acf)
    if ta_result ~=0 then
        return TCAS_TRAFFIC
    end

end