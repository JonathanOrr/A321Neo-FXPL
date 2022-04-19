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
-- File: constraints_checker.lua
-- Short description: Verifies wether constraints will be met or not
-------------------------------------------------------------------------------

local SPD_TOLERANCE = 5 -- +- 5 knots tolerance
local ALT_TOLERANCE = 250 -- +- 250 feet tolerance

local function decorate_leg_with_spd_constraint(leg)
    if leg.cstr_speed_type == CIFP_CSTR_SPD_ABOVE then
        return (leg.pred.ias >= leg.cstr_speed - SPD_TOLERANCE)
    elseif leg.cstr_speed_type == CIFP_CSTR_SPD_BELOW then
        return (leg.pred.ias <= leg.cstr_speed + SPD_TOLERANCE)
    elseif leg.cstr_speed_type == CIFP_CSTR_SPD_AT then
        return (leg.pred.ias <= leg.cstr_speed + SPD_TOLERANCE) and (leg.pred.ias > leg.cstr_speed - SPD_TOLERANCE)
    else
        assert(false, "This should never happen.")
    end
end

local function decorate_leg_with_alt_constraint(leg)
    if leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE then
        local alt_cstr = (leg.cstr_altitude1_fl and leg.cstr_altitude1*100 or leg.cstr_altitude1)
        return (leg.pred.altitude >= alt_cstr - ALT_TOLERANCE)
    elseif leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_2ND then
        local alt_cstr = (leg.cstr_altitude2_fl and leg.cstr_altitude2*100 or leg.cstr_altitude2)
        return (leg.pred.altitude >= alt_cstr - ALT_TOLERANCE)
    elseif leg.cstr_alt_type == CIFP_CSTR_ALT_BELOW then
        local alt_cstr = (leg.cstr_altitude1_fl and leg.cstr_altitude1*100 or leg.cstr_altitude1)
        return (leg.pred.altitude <= alt_cstr + ALT_TOLERANCE)
    elseif leg.cstr_alt_type == CIFP_CSTR_ALT_AT then
        local alt_cstr = (leg.cstr_altitude1_fl and leg.cstr_altitude1*100 or leg.cstr_altitude1)
        return (leg.pred.altitude <= alt_cstr + ALT_TOLERANCE) and (leg.pred.altitude >= alt_cstr - ALT_TOLERANCE)
    elseif leg.cstr_alt_type == CIFP_CSTR_ALT_ABOVE_BELOW then
        local alt_cstr_1 = (leg.cstr_altitude1_fl and leg.cstr_altitude1*100 or leg.cstr_altitude1)
        local alt_cstr_2 = (leg.cstr_altitude2_fl and leg.cstr_altitude2*100 or leg.cstr_altitude2)
        return (leg.pred.altitude <= alt_cstr_2 + ALT_TOLERANCE) and (leg.pred.altitude >= alt_cstr_1 - ALT_TOLERANCE)
    else
        assert(false, "This should never happen.")
    end
end

local function decorate_legs_with_constraints_sub(set)
    for i, leg in ipairs(set) do
        if leg.pred then
            if leg.pred.ias and leg.cstr_speed_type and leg.cstr_speed_type ~= CIFP_CSTR_SPD_NONE then
                leg.pred.cstr_ias_met = decorate_leg_with_spd_constraint(leg)
            end
            if leg.pred.altitude and leg.cstr_alt_type and leg.cstr_alt_type ~= CIFP_CSTR_ALT_NONE then
                leg.pred.cstr_alt_met = decorate_leg_with_alt_constraint(leg)
            end
        end
    end
end

function decorate_legs_with_constraints()
    if FMGS_sys.fpln.active.apts.dep_sid and FMGS_sys.fpln.active.apts.dep_sid.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.dep_sid.legs)
    end
    if FMGS_sys.fpln.active.apts.dep_trans and FMGS_sys.fpln.active.apts.dep_trans.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.dep_trans.legs)
    end
    if FMGS_sys.fpln.active.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.legs)
    end
    if FMGS_sys.fpln.active.apts.arr_trans and FMGS_sys.fpln.active.apts.arr_trans.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.arr_trans.legs)
    end
    if FMGS_sys.fpln.active.apts.arr_star and FMGS_sys.fpln.active.apts.arr_star.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.arr_star.legs)
    end
    if FMGS_sys.fpln.active.apts.arr_via and FMGS_sys.fpln.active.apts.arr_via.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.arr_via.legs)
    end
    if FMGS_sys.fpln.active.apts.arr_appr and FMGS_sys.fpln.active.apts.arr_appr.legs then
        decorate_legs_with_constraints_sub(FMGS_sys.fpln.active.apts.arr_appr.legs)
    end
end