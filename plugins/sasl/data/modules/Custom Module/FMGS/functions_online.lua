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

include('ADIRS_data_source.lua')
include('FMGS/vertical_profile_climb.lua')
include('FMGS/vertical_profile_descent.lua')
include('FMGS/functions.lua')
include("libs/speed_helpers.lua")

function FMGS_get_current_target_speed()
    -- This function returns only the FMGS calculated speed, it does not care about the (potential) FCU setting
    -- It returns nil,nil if not available for the current phase. Mach target may be 0 if not available.

    if not adirs_is_alt_ok(1) and not adirs_is_alt_ok(2) then
        return nil,nil
    end

    local altitude = adirs_get_avg_alt()

    local _,_,v2  = FMGS_perf_get_v_speeds()
    local dep_rwy_alt = FMGS_sys.fpln.active.apts.dep and FMGS_sys.fpln.active.apts.dep.alt or 0

    local gear_is_out = get(Front_gear_deployment) + get(Left_gear_deployment) + get(Right_gear_deployment) > 0.
    local VS = FBW.FMGEC.Extract_vs1g(get(Gross_weight), get(Flaps_internal_config), gear_is_out)

    if FMGS_sys.config.phase == FMGS_PHASE_TAKEOFF then
        if not v2 then
            return nil,nil
        end

        if altitude < dep_rwy_alt+400 then
            return v2, 0
        else
            return v2+10, 0
        end
    elseif  FMGS_sys.config.phase == FMGS_PHASE_CLIMB then
        local ias, mach  = get_target_speed_climb(altitude, get(Gross_weight))
        return ias, mach
    elseif  FMGS_sys.config.phase == FMGS_PHASE_CRUISE then
        local mach = get_target_mach_cruise(altitude, get(Gross_weight))
        local ias  = mach_to_cas(mach, altitude)
        return ias, mach
    elseif  FMGS_sys.config.phase == FMGS_PHASE_DESCENT then
        local ias, mach = get_target_speed_descent()
        return ias, mach
    elseif  FMGS_sys.config.phase == FMGS_PHASE_APPROACH then
        return FMGS_sys.data.pred.appr.steps[FMGS_sys.data.pred.appr.next_step].ias, 0
    elseif  FMGS_sys.config.phase == FMGS_PHASE_GOAROUND then
        return 1.23 * VS, 0
    else
        return nil,nil    -- Not displayed
    end

end