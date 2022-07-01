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

-------------------------------------------------------------------------------
-- Descent
-------------------------------------------------------------------------------
function get_target_speed_descent()
    -- This function does not consider  the initial climb part or
    -- restrictions

    -- Otherwise it depends on the cost index
    local cost_index = FMGS_init_get_cost_idx()
    if not cost_index then
        cost_index = 0 -- Cost index default to zero
    end

    -- Interpolated data from here: https://ansperformance.eu/library/airbus-cost-index.pdf
    local optimal_speed = -0.0003333333333 * cost_index^3 + 0.0308928571429* cost_index^2 +0.7869047619048 * cost_index + 252.1142857142856
    local optimal_mach  = -0.000003392857143 * cost_index * cost_index + 0.000716428571429 * cost_index + 0.764485714285714
    return optimal_speed, math.min(0.80, optimal_mach)
end


function find_FDP()
    -- Reset data
    FMGS_sys.data.pred.appr.fdp_idx = nil
    FMGS_sys.data.pred.appr.fdp_dist_to_rwy = nil
    FMGS_sys.data.pred.appr.final_angle = 3

    -- And then recompute
    local cifp_appr = FMGS_arr_get_appr(false)
    for i,x in ipairs(cifp_appr.legs) do
        if not FMGS_sys.data.pred.appr.fdp_idx then
            if x.vpath_angle and x.vpath_angle > 0 then
                FMGS_sys.data.pred.appr.fdp_idx = i
                FMGS_sys.data.pred.appr.final_angle = math.abs(x.vpath_angle / 100)
                FMGS_sys.data.pred.appr.fdp_dist_to_rwy = 0 
            end
        else
            -- Ok let's compute the distance with the runway (we need this later)
            FMGS_sys.data.pred.appr.fdp_dist_to_rwy = FMGS_sys.data.pred.appr.fdp_dist_to_rwy + (x.computed_distance or 0)
        end
    end

end


function compute_vapp(weight_at_rwy)
    -- Then we need the Vapp speed
    local flaps = FMGS_get_landing_config() + 1
    local VLS = 1.28 * FBW.FMGEC.Extract_vs1g(weight_at_rwy, flaps, true)
    FMGS_set_landing_vls(VLS)
    local APPR_CORR = 5 -- TODO:
    -- - 5kt if A/THR is ON
    -- - 5kt if ice accretion (10kt instead of 5kt on A320 family when in CONF 3)
    -- - 1/3 Headwind excluding gust
    -- Cannot be < 5 or > 15
    FMGS_set_landing_vapp_internal(VLS+APPR_CORR)

    local vapp_our, vapp_user = FMGS_get_landing_vapp()

    return vapp_user or vapp_our
end

function get_arrival_apt_temp() 
    if FMGS_sys.perf.landing.temp then
        return FMGS_sys.perf.landing.temp
    else
        return get(OTA)
    end
end
