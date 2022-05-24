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
    local first_point_drawn = false

    local prev_orig_ref = nil

    for i,x in ipairs(curved_route) do
        if x.segment_type == FMGS_COMP_SEGMENT_LINE or x.segment_type == FMGS_COMP_SEGMENT_ENROUTE or x.segment_type == FMGS_COMP_SEGMENT_RWY_LINE then
            local x_start,y_start = functions.get_x_y_heading(data, x.start_lat, x.start_lon, data.inputs.heading)
            local x_end,y_end     = functions.get_x_y_heading(data, x.end_lat, x.end_lon, data.inputs.heading)
            sasl.gl.drawWideLine(x_start, y_start, x_end, y_end, LINE_SIZE, ECAM_GREEN)
            if debug_ND_debug_paths then
                sasl.gl.drawWideLine(x_start-10, y_start-10, x_start+10, y_start+10, 2, ECAM_BLUE)
                sasl.gl.drawWideLine(x_start-10, y_start+10, x_start+10, y_start-10, 2, ECAM_BLUE)
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
            end
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

        --
        -- Drawing the "special POIs" which are the pseudo waypoints generated by the
        -- FMGS vertical profile: T/C, T/D, SPD LIM (x2), FLAP1, FLAP2, DECEL
        --
        if x.orig_ref then

            -- An helper lambda function...
            local check_and_run = function(poi_special, texture, offset)
                if prev_orig_ref and prev_orig_ref ~= x.orig_ref and poi_special and x.orig_ref == poi_special.prev_wpt then
                    assert(prev_orig_ref.lat and prev_orig_ref.lon, "Previous point (" .. (prev_orig_ref.id or "[UNKN]") .. ") doesn't have lat or lon!")
                    assert(x.orig_ref.lat and x.orig_ref.lon, "Current point (" .. (x.orig_ref.id or "[UNKN]") .. ") doesn't have lat or lon!")
                    local lat, lon = point_from_a_segment_lat_lon(prev_orig_ref.lat, prev_orig_ref.lon, x.orig_ref.lat, x.orig_ref.lon, poi_special.dist_prev_wpt)
                    draw_poi_special(data, functions, lat, lon, offset, texture, ECAM_WHITE)
                end
    
            end

            check_and_run(FMGS_pred_get_toc(), image_point_toc, 25)
            check_and_run(FMGS_pred_get_tod(), image_point_tod, 25)
            check_and_run(FMGS_pred_get_climb_lim(), image_point_spdchange, 0)
            check_and_run(FMGS_pred_get_descent_lim(), image_point_spdchange, 0)
            check_and_run(FMGS_pred_get_decel_point(), image_point_decel, 0)
            check_and_run(FMGS_pred_get_flap_1_point(), image_point_flaps_one, 0)
            check_and_run(FMGS_pred_get_flap_2_point(), image_point_flaps_two, 0)

            if x.orig_ref.lat and x.orig_ref.lon then
                -- Some waypoints don't have lat/lon information, let's skip them
                prev_orig_ref = x.orig_ref
            end
        end

    end   

end