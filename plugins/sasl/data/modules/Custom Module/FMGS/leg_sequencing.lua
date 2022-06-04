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

local sequencer_data = {}

local function remove_point_from_fpln(point)
    
    local search_f = function(point, obj)
        if not obj or not obj.legs then
            return false
        end

        for i,x in ipairs(obj.legs) do
            if x == point.orig_ref then
                table.remove(obj.legs, i)
                FMGS_sys.fpln.active.require_recompute = true
                FMGS_refresh_pred()
                return true
            end
        end

        return false
    end

    if search_f(point, FMGS_sys.fpln.active.apts.dep_sid) then
        return true
    elseif search_f(point, FMGS_sys.fpln.active.apts.dep_trans) then
        return true
    elseif search_f(point, FMGS_sys.fpln.active.apts.arr_trans) then
        return true
    elseif search_f(point, FMGS_sys.fpln.active.apts.arr_star) then
        return true
    elseif search_f(point, FMGS_sys.fpln.active.apts.arr_via) then
        return true
    elseif search_f(point, FMGS_sys.fpln.active.apts.arr_appr) then
        return true
    else
        return false
    end
end

function update_sequencing()
    if FMGS_sys.config.phase == FMGS_PHASE_PREFLIGHT or FMGS_sys.config.phase == FMGS_PHASE_DONE then
        FMGS_sys.fpln.active.sequencer.sequenced_after_takeoff = false
        sequencer_data = {}    -- Reset derivatives
        return -- No leg sequencing when on ground
    end

    if not FMGS_sys.fpln.active.segment_curved_list then
        sequencer_data = {}    -- Reset derivatives
        return -- Uhm, no flight plan computed
    end

    if #FMGS_sys.fpln.active.segment_curved_list < 3 then
        return -- Not sufficient number of points to sequencing
    end

    local my_pos = adirs_get_any_fmgs()

    if not my_pos[1] or not my_pos[2] then
        sequencer_data = {}    -- Reset derivatives
        return  -- No valid position, no sequencing
    end

    local my_lat = my_pos[1]
    local my_lon = my_pos[2]

    local offset = FMGS_sys.fpln.active.sequencer.segment_curved_list_curr or 1

    local past_point   = FMGS_sys.fpln.active.segment_curved_list[offset+0]
    local target_point = FMGS_sys.fpln.active.segment_curved_list[offset+1]
    local future_point = FMGS_sys.fpln.active.segment_curved_list[offset+2]
    local target_dist = get_distance_nm(my_lat, my_lon, target_point.end_lat, target_point.end_lon)

    if target_dist > 5 then
        sequencer_data = {}    -- Reset derivatives
        return -- Too far from the target, inhibit sequencing
    end

    local future_dist = get_distance_nm(my_lat, my_lon, future_point.end_lat, future_point.end_lon)

    if not sequencer_data.prev_target or not sequencer_data.prev_future then
        sequencer_data.prev_target = target_dist
        sequencer_data.prev_future = future_dist
        return  -- No previous calculation
    end

    if (target_dist - sequencer_data.prev_target) > 0 and (future_dist - sequencer_data.prev_future)  < 0 
        or (math.abs(target_dist-future_dist) < 1e-5 and future_dist < 0.5) -- This condition is necessary when two point coincides
    then
        -- Time to switch
        FMGS_sys.fpln.active.sequencer.sequenced_after_takeoff = true
        FMGS_sys.fpln.active.sequencer.segment_curved_list_curr = offset+1

        if past_point.orig_ref ~= target_point.orig_ref then
            -- We remove a point only if the previous segment belongs to a different F/PLN
            -- item. So if we are in A -> B -> C and not A -> A -> B (A,B,C means their orig_ref) 
            if remove_point_from_fpln(past_point) then
                FMGS_sys.fpln.active.sequencer.segment_curved_list_curr = 1
            end
        end
        sequencer_data = {}
    else
        sequencer_data.prev_target = target_dist
        sequencer_data.prev_future = future_dist
    end

end