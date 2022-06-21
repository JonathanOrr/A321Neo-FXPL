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

local function remove_point_from_fpln(tgt_point)
    
    local total_deleted = 0

    local search_f = function(deleting, tgt_point, obj)

        if not obj or not obj.legs then
            return false
        end

        if deleting then
            obj.legs = {}
            return true
        end

        for i = #obj.legs, 1, -1 do
            local x = obj.legs[i]

            if deleting then
                table.remove(obj.legs, i)
                total_deleted = total_deleted + 1
            elseif x == tgt_point.orig_ref then
                deleting = true
            end
        end

        return deleting
    end

    local deleting = false

    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.arr_appr)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.arr_via)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.arr_star)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.arr_trans)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.dep_trans)
    deleting = search_f(deleting, tgt_point, FMGS_sys.fpln.active.apts.dep_sid)

    while (#FMGS_sys.fpln.active.segment_curved_list > 0 and FMGS_sys.fpln.active.segment_curved_list[1].orig_ref ~= tgt_point.orig_ref) do
        table.remove(FMGS_sys.fpln.active.segment_curved_list, 1)
    end

    return total_deleted

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

    local target_point = FMGS_sys.fpln.active.sequencer.segment_curved_list_target

    if not target_point then
        local prev = nil
        for i,x in ipairs(FMGS_sys.fpln.active.segment_curved_list) do
            if prev and prev.orig_ref ~= x.orig_ref then
                target_point = x
                break
            end
            prev = x
        end
        FMGS_sys.fpln.active.sequencer.segment_curved_list_target = target_point
    end

    local offset = nil

    for i,x in ipairs(FMGS_sys.fpln.active.segment_curved_list) do
        if x == target_point then
            offset = i
            break
        end
    end

    if not offset or offset <= 1 then
        return -- This shouldn't be possible
    end

    -- For deug only
    FMGS_sys.fpln.active.sequencer.segment_curved_list_curr = offset

    local past_point   = FMGS_sys.fpln.active.segment_curved_list[offset-1] -- -1 not a problem, offset > 1
    local future_point = FMGS_sys.fpln.active.segment_curved_list[offset+1]
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
        FMGS_sys.fpln.active.sequencer.segment_curved_list_target = future_point

        if FMGS_sys.fpln.active.sequencer.sequenced_after_takeoff and future_point.orig_ref ~= target_point.orig_ref then
            -- I delete the old point only if we have a switch between origin points
            remove_point_from_fpln(target_point)
        end


        FMGS_sys.fpln.active.sequencer.sequenced_after_takeoff = true

        FMGS_refresh_pred()
        sequencer_data = {}
    else
        sequencer_data.prev_target = target_dist
        sequencer_data.prev_future = future_dist
    end

end