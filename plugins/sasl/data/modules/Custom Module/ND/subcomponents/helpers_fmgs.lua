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
-- File: helpers.lua
-- Short description: Misc functions related to FMGS
-------------------------------------------------------------------------------
include('ND/subcomponents/drawing_functions.lua')
include('ND/subcomponents/helpers.lua')

local image_point_apt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-apt.png")
local image_point_vor_only = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-only.png")
local image_point_vor_dme  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-vor-dme.png")
local image_point_dme_only  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-dme-only.png")
local image_point_ndb = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-ndb.png")
local image_point_wpt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/point-wpt.png")
local image_point_toc = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/toc.png")
local image_point_tod = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/tod.png")
local image_point_spdchange = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/spdchange.png")
local image_point_decel = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/decel.png")
local image_point_flaps_one = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/flaps_one.png")
local image_point_flaps_two = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/constraints/flaps_two.png")


local function draw_poi_special(data, functions, lat, lon, offset_x, texture, color)
    local range_in_nm = get_range_in_nm(data)
    local px_per_nm = functions.get_px_per_nm(data) / range_in_nm

    local x, y = functions.get_x_y_heading(data, lat,lon, data.inputs.heading)

    if x > 0 and x < size[1] and y > 0 and y < size[2] then
        sasl.gl.drawTexture(texture, x-25-offset_x, y-25, 50,50, color)
    end

end

local function ND_draw_active_reset_specials(data)
    data.poi_specials = {
        {poi=FMGS_pred_get_toc(),          img=image_point_toc,       img_off=25, drawing=false, drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_tod(),          img=image_point_tod,       img_off=25, drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_climb_lim(),    img=image_point_spdchange, img_off=0, drawing=false, drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_descent_lim(),  img=image_point_spdchange, img_off=0,  drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_decel_point(),  img=image_point_decel,     img_off=0,  drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_flap_1_point(), img=image_point_flaps_one, img_off=0,  drawn=false, leg_offset=0},
        {poi=FMGS_pred_get_flap_2_point(), img=image_point_flaps_two, img_off=0,  drawn=false, leg_offset=0}
    } 
end

local function ND_draw_active_fpln_specials(data, functions, prev_orig_ref, x)

    -- An helper lambda function...
    local check_and_run = function(special)
        local poi = special.poi

        if prev_orig_ref == poi.prev_wpt or special.drawing then
            local segment_length
            if x.segment_type == FMGS_COMP_SEGMENT_LINE or x.segment_type == FMGS_COMP_SEGMENT_ENROUTE then
                segment_length = get_distance_nm(x.start_lat,x.start_lon,x.end_lat,x.end_lon)
            elseif x.segment_type == FMGS_COMP_SEGMENT_ARC then
                segment_length = x.radius * math.rad(x.arc_length_deg)
            else
                segment_length = 0  
            end
            special.leg_offset = special.leg_offset + segment_length
            special.drawing = true

            -- Time to draw it?
            if special.leg_offset > poi.dist_prev_wpt then
                local lat, lon
                local dist_diff = poi.dist_prev_wpt - (special.leg_offset - segment_length) -- Remaining different of distance
                assert(dist_diff >= 0)
                if x.segment_type == FMGS_COMP_SEGMENT_LINE or x.segment_type == FMGS_COMP_SEGMENT_ENROUTE then
                    lat, lon = point_from_a_segment_lat_lon(x.start_lat,x.start_lon,x.end_lat,x.end_lon, dist_diff)
                elseif x.segment_type == FMGS_COMP_SEGMENT_ARC then
                    lat, lon = point_from_a_arc_lat_lon(x.ctr_lat, x.ctr_lon, x.radius, x.start_angle, x.arc_length_deg, poi.dist_prev_wpt)
                end
                if lat and lon then
                    draw_poi_special(data, functions, lat, lon, special.img_off, special.img, ECAM_WHITE)
                end
                special.drawn = true
            end
        end
    end

    if prev_orig_ref then   -- If there exists a previous point...
        for i,spec in ipairs(data.poi_specials) do
            if spec.poi and not spec.drawn then
                check_and_run(spec)
            end
        end
    end
    if x.orig_ref.lat and x.orig_ref.lon then
        -- Some waypoints don't have lat/lon information, let's skip them
        prev_orig_ref = x.orig_ref
    end

    return prev_orig_ref
end

function ND_draw_active_fpln(data, functions)

    local active_legs = FMGS_get_enroute_legs()


    -- For each point in the FPLN...
    for k,x in ipairs(active_legs) do

        if not x.discontinuity then

            local c_x,c_y = functions.get_x_y_heading(data, x.lat, x.lon, data.inputs.heading)
            x.x = c_x
            x.y = c_y
            
            local color = ECAM_GREEN

            if x.ptr_type == FMGS_PTR_WPT then
                functions.draw_poi_array(data, x, image_point_wpt, color)
            elseif x.ptr_type == FMGS_PTR_NDB then
                functions.draw_poi_array(data, x, image_point_ndb, color)
            elseif x.ptr_type == FMGS_PTR_VOR then
                functions.draw_poi_array(data, x, x.is_coupled_dme and image_point_vor_dme or image_point_vor_only, color)
            elseif x.ptr_type == FMGS_PTR_APT then
                functions.draw_poi_array(data, x, image_point_apt, color)
            elseif x.ptr_type == FMGS_PTR_COORDS then
            
            end
        end
    end

    -- Now let's draw the flight path
    local curved_route =  FMGS_get_active_curved_route() 
    if not curved_route then
        return
    end

    local LINE_SIZE = 3

    local already_drawn = {}
    local prev_orig_ref = nil
    local prev_orig_ref_done_white = false

    ND_draw_active_reset_specials(data)

    for i,x in ipairs(curved_route) do
        if x.segment_type == FMGS_COMP_SEGMENT_LINE or x.segment_type == FMGS_COMP_SEGMENT_ENROUTE or x.segment_type == FMGS_COMP_SEGMENT_RWY_LINE then
            local x_start,y_start = functions.get_x_y_heading(data, x.start_lat, x.start_lon, data.inputs.heading)
            local x_end,y_end     = functions.get_x_y_heading(data, x.end_lat, x.end_lon, data.inputs.heading)
            sasl.gl.drawWideLine(x_start, y_start, x_end, y_end, LINE_SIZE, ECAM_GREEN)
            if debug_ND_debug_paths then
                sasl.gl.drawText(Font_ECAMfont, x_start+10, y_start, x.orig_ref.id or "UKNWN", 11, true, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
                sasl.gl.drawWideLine(x_start-10, y_start-10, x_start+10, y_start+10, 2, ECAM_BLUE)
                sasl.gl.drawWideLine(x_start-10, y_start+10, x_start+10, y_start-10, 2, ECAM_BLUE)
                sasl.gl.drawText(Font_ECAMfont, x_end-10, y_end, x.orig_ref.id or "UKNWN", 11, true, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
                sasl.gl.drawWideLine(x_end-5, y_end-5, x_end+5, y_end+5, 2, ECAM_RED)
                sasl.gl.drawWideLine(x_end-5, y_end+5, x_end+5, y_end-5, 2, ECAM_RED)
            end
        elseif x.segment_type == FMGS_COMP_SEGMENT_ARC then
            local x_ctr,y_ctr = functions.get_x_y_heading(data, x.ctr_lat, x.ctr_lon, data.inputs.heading)
            local xy_radius = functions.get_px_per_nm(data) * x.radius
            local heading_offset = data.config.mode == ND_MODE_PLAN and 0 or data.inputs.heading-Local_magnetic_deviation()
            sasl.gl.drawArc(x_ctr, y_ctr, xy_radius-LINE_SIZE/2, xy_radius+LINE_SIZE/2, x.start_angle+heading_offset, x.arc_length_deg, ECAM_GREEN)
            if debug_ND_debug_paths then
                if x.start_lat then
                    local x_start,y_start = functions.get_x_y_heading(data, x.start_lat, x.start_lon, data.inputs.heading)
                    sasl.gl.drawWideLine(x_start-10, y_start-10, x_start+10, y_start+10, 2, ECAM_BLUE)
                    sasl.gl.drawWideLine(x_start-10, y_start+10, x_start+10, y_start-10, 2, ECAM_BLUE)
                end
                if x.end_lat then
                    local x_end,y_end     = functions.get_x_y_heading(data, x.end_lat, x.end_lon, data.inputs.heading)
                    sasl.gl.drawWideLine(x_end-5, y_end-5, x_end+5, y_end+5, 2, ECAM_RED)
                    sasl.gl.drawWideLine(x_end-5, y_end+5, x_end+5, y_end-5, 2, ECAM_RED)
                end

                sasl.gl.drawArc(x_ctr, y_ctr, 4, 5, 0, 360, ECAM_MAGENTA)
                local text = "ARC " .. (x.id and x.id or "/") .. " r=" .. Round(x.radius, 1) .. " sa=" .. math.floor(x.start_angle) .. " al=" .. math.floor(x.arc_length_deg)
                sasl.gl.drawText(Font_ECAMfont, x_ctr+6, y_ctr, text, 11, true, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
                sasl.gl.drawText(Font_ECAMfont, x_ctr+6, y_ctr+11, x.orig_ref.id or "UKNWN", 11, true, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
            end
        end

        local color = ECAM_GREEN

        if not prev_orig_ref then
            prev_orig_ref = x.orig_ref
        elseif not prev_orig_ref_done_white then
            if prev_orig_ref ~= x.orig_ref then
                color = ECAM_WHITE
                prev_orig_ref_done_white = true
            end
        end


        if x.orig_ref and x.orig_ref.leg_name_poi and not already_drawn[x.orig_ref.leg_name] then
            already_drawn[x.orig_ref.leg_name] = true

            local poi = x.orig_ref.leg_name_poi

            if poi.ptr_type == FMGS_PTR_WPT then
                functions.draw_poi_array(data, poi, image_point_wpt, color)
            elseif poi.ptr_type == FMGS_PTR_NDB then
                functions.draw_poi_array(data, poi, image_point_ndb, color)
            elseif poi.ptr_type == FMGS_PTR_VOR then
                functions.draw_poi_array(data, poi, poi.is_coupled_dme and image_point_vor_dme or image_point_vor_only, color)
            end

            poi.x = nil
            poi.y = nil
        end

        --
        -- Drawing the "special POIs" which are the pseudo waypoints generated by the
        -- FMGS vertical profile: T/C, T/D, SPD LIM (x2), FLAP1, FLAP2, DECEL
        --
        if x.orig_ref then
            prev_orig_ref = ND_draw_active_fpln_specials(data, functions, prev_orig_ref, x)
        end

    end   

end