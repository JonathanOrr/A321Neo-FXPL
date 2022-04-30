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


local function draw_poi_special(data, functions, lat, lon, offset_x, texture, color)
    local range_in_nm = get_range_in_nm(data)
    local px_per_nm = functions.get_px_per_nm(data) / range_in_nm

    local x, y = functions.get_x_y_heading(data, lat,lon, data.inputs.heading)

    if x > 0 and x < size[1] and y > 0 and y < size[2] then
        sasl.gl.drawTexture(texture, x-25-offset_x, y-25, 50,50, color)
    end

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

    local LINE_SIZE = 2

    local already_drawn = {}
    local first_point_drawn = false

    local prev_orig_ref = nil

    for i,x in ipairs(curved_route) do
        if x.segment_type == FMGS_COMP_SEGMENT_LINE or x.segment_type == FMGS_COMP_SEGMENT_ENROUTE or x.segment_type == FMGS_COMP_SEGMENT_RWY_LINE then
            local x_start,y_start = functions.get_x_y_heading(data, x.start_lat, x.start_lon, data.inputs.heading)
            local x_end,y_end     = functions.get_x_y_heading(data, x.end_lat, x.end_lon, data.inputs.heading)
            sasl.gl.drawWideLine(x_start, y_start, x_end, y_end, LINE_SIZE, ECAM_GREEN)
        elseif x.segment_type == FMGS_COMP_SEGMENT_ARC then
            local x_ctr,y_ctr = functions.get_x_y_heading(data, x.ctr_lat, x.ctr_lon, data.inputs.heading)
            local x_lat,y_lon = functions.get_x_y_heading(data, x.end_lat, x.end_lon, data.inputs.heading)
            local xy_radius = functions.get_px_per_nm(data) * x.radius
            local heading_offset = data.config.mode == ND_MODE_PLAN and 0 or data.inputs.heading-Local_magnetic_deviation()
            sasl.gl.drawArc(x_ctr, y_ctr, xy_radius-LINE_SIZE/2, xy_radius+LINE_SIZE/2, x.start_angle+heading_offset, x.arc_length_deg, ECAM_GREEN)
        end

        local color = first_point_drawn and ECAM_GREEN or ECAM_WHITE

        if x.orig_ref and x.orig_ref.leg_name_poi and not already_drawn[x.orig_ref.leg_name] then
            already_drawn[x.orig_ref.leg_name] = true
            first_point_drawn = true

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

        if x.orig_ref then
            local toc = FMGS_pred_get_toc()

            if prev_orig_ref and prev_orig_ref ~= x.orig_ref and toc and x.orig_ref == toc.prev_wpt then
                local lat, lon = point_from_a_segment_lat_lon(prev_orig_ref.lat, prev_orig_ref.lon, x.orig_ref.lat, x.orig_ref.lon, toc.dist_prev_wpt)
                draw_poi_special(data, functions, lat, lon, 25, image_point_toc, ECAM_WHITE)
            end

            local tod = FMGS_pred_get_tod()
            if prev_orig_ref and prev_orig_ref ~= x.orig_ref and tod and x.orig_ref == tod.prev_wpt then
                local lat, lon = point_from_a_segment_lat_lon(prev_orig_ref.lat, prev_orig_ref.lon, x.orig_ref.lat, x.orig_ref.lon, tod.dist_prev_wpt)
                draw_poi_special(data, functions, lat, lon, 25, image_point_tod, ECAM_WHITE)
            end

            local spdlim = FMGS_pred_get_climb_lim()
            if prev_orig_ref and prev_orig_ref ~= x.orig_ref and spdlim and x.orig_ref == spdlim.prev_wpt then
                local lat, lon = point_from_a_segment_lat_lon(prev_orig_ref.lat, prev_orig_ref.lon, x.orig_ref.lat, x.orig_ref.lon, spdlim.dist_prev_wpt)
                draw_poi_special(data, functions, lat, lon, 0, image_point_spdchange, ECAM_MAGENTA)
            end

            local spdlim = FMGS_pred_get_descent_lim()
            if prev_orig_ref and prev_orig_ref ~= x.orig_ref and spdlim and x.orig_ref == spdlim.prev_wpt then
                local lat, lon = point_from_a_segment_lat_lon(prev_orig_ref.lat, prev_orig_ref.lon, x.orig_ref.lat, x.orig_ref.lon, spdlim.dist_prev_wpt)
                draw_poi_special(data, functions, lat, lon, 0, image_point_spdchange, ECAM_MAGENTA)
            end


            prev_orig_ref = x.orig_ref
        end

    end   

end