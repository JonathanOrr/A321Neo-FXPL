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
-- File: graphics_vorils.lua
-- Short description: ROSE VOR and ROSE ILS page
-------------------------------------------------------------------------------

include('DRAIMS/radio_logic.lua')

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
size = {900, 900}

local image_h_deviation_sym = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vorils-dev.png")
local image_deviation_ind = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-outer-ring.png")
local image_deviation_arrow = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-arrow-ring.png")

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function leading_zeros_int(num, num_total)
    return string.format("%0" .. num_total .. "d", num) 
end

local function draw_upper_info_freq(data, freq, crs, id_text, tuned_id, color)
    -- Frequency
    sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-50, math.floor(freq), 34, false, false, TEXT_ALIGN_LEFT, color)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-70, size[2]-50, "." .. leading_zeros_int(Round((freq*100)%100,0), 2), 28, false, false, TEXT_ALIGN_LEFT, color)
    
    -- CRS
    sasl.gl.drawText(Font_AirbusDUL, size[1]-165, size[2]-90, "CRS", 34, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    if adirs_is_hdg_ok(data.id) then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-90, crs .. "°", 34, false, false, TEXT_ALIGN_RIGHT, color == ECAM_WHITE and ECAM_BLUE or color)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-90, "---°", 34, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end

    -- Identifier
    sasl.gl.drawText(Font_AirbusDUL, size[1]-25, size[2]-130, id_text, 34, false, false, TEXT_ALIGN_RIGHT, color)

    -- Tuned symbol
    local tuned_symbol = ""
    if tuned_id == 2 then
        tuned_symbol = "M"
    elseif tuned_id == 3 then
        tuned_symbol = "R"
    end
    
    if tuned_symbol ~= "" then
        sasl.gl.drawText(Font_AirbusDUL, size[1]-130, size[2]-130, tuned_symbol, 22, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawWideLine(size[1]-130, size[2]-135, size[1]-140, size[2]-135, 2, ECAM_WHITE)
    end
end

local function draw_upper_right_info_vor(data)
    local curr_nav = data.id
    
    local is_valid = radio_vor_is_valid(curr_nav)
    data.misc.vor_failure = not is_valid

    sasl.gl.drawText(Font_AirbusDUL, size[1]-250, size[2]-50, "VOR" .. curr_nav, 34, false, false, TEXT_ALIGN_LEFT, is_valid and ECAM_WHITE or ECAM_RED)

    if not is_valid then
        if data.misc.vor_failure_time == nil then
            data.misc.vor_failure_time = get(TIME)
        elseif get(TIME) - data.misc.vor_failure_time < 9 then
            data.misc.vor_failure = get(TIME) % 1 < 0.5
        end
    else
        data.misc.vor_failure_time = nil
    end

    draw_upper_info_freq(data,
                         radio_vor_get_freq(curr_nav, false),
                         radio_vor_get_crs(curr_nav),
                         DRAIMS_common.radio.vor[curr_nav] == nil and "" or DRAIMS_common.radio.vor[curr_nav].id,
                         radio_vor_get_tuning_source(),
                         ECAM_WHITE)

end

local function draw_upper_right_info_ils(data)

end


local function draw_rose_vor_indication(data)
    local curr_nav = data.id

    local crs_angle = 0
    local is_valid = radio_vor_is_valid(curr_nav)
    if adirs_is_hdg_ok(data.id) then
        crs_angle = radio_vor_get_crs(curr_nav)
    else
        crs_angle = data.inputs.heading -- Stay at zero
    end
    
    sasl.gl.drawRotatedTexture(image_h_deviation_sym, -data.inputs.heading+crs_angle, (size[1]-500)/2,(size[2]-176)/2,500,176, {1,1,1})
    sasl.gl.drawRotatedTexture(image_deviation_ind, -data.inputs.heading+crs_angle, (size[1]-75)/2,(size[2]-590)/2,75,590, {1,1,1})

    
    local is_valid = radio_vor_is_valid(curr_nav)
    if not is_valid then
        return -- No active vor
    end

    -- image_deviation_arrow
    if is_valid then
        
        local degrees = DRAIMS_common.radio.vor[curr_nav].curr_bearing
        degrees = degrees - crs_angle
        
        if degrees > 180 then
            degrees = degrees - 360
        end

        local degrees_clamp = Math_clamp(degrees, -11, 11)
        if degrees_clamp ~= degrees and get(TIME) % 1 < 0.5 then
            return
        end
        local degrees_px = degrees_clamp / 5 * 88
        sasl.gl.drawRotatedTextureCenter(image_deviation_arrow, -data.inputs.heading+crs_angle, size[1]/2, size[2]/2, (size[1]-28)/2+degrees_px,(size[2]-176)/2, 28,176, {1,1,1})
    end


end

function draw_rose_vor(data)
    draw_rose_vor_indication(data)
end

function draw_rose_ils(data)
--    draw_upper_right_info(data, 2)
end

function draw_rose_vorils_unmasked(data)
    draw_upper_right_info_vor(data, 1)
end
