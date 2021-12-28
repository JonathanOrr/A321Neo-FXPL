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

local image_h_deviation_sym     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vorils-dev.png")
local image_v_deviation_sym     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-gs-dev.png")
local image_deviation_ind       = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-outer-ring.png")
local image_deviation_arrow     = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-vor-arrow-ring.png")
local image_deviation_ind_ils   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-outer-ring.png")
local image_deviation_arrow_ils = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-ils-arrow-ring.png")
local image_deviation_diamond_ils = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/sym-gs-diamond.png")
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
        sasl.gl.drawText(Font_AirbusDUL, size[1]-15, size[2]-90, crs .. "°", 34, false, false, TEXT_ALIGN_RIGHT, color == ECAM_WHITE and ECAM_BLUE or color)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]-15, size[2]-90, "---°", 34, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
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
    local curr_nav = data.id == ND_CAPT and 2 or 1
    
    local is_valid = radio_ils_is_valid()
    data.misc.loc_failure = not is_valid

    sasl.gl.drawText(Font_AirbusDUL, size[1]-250, size[2]-50, "ILS" .. curr_nav, 34, false, false, TEXT_ALIGN_LEFT, is_valid and ECAM_WHITE or ECAM_RED)

    if not is_valid then
        if data.misc.loc_failure_time == nil then
            data.misc.loc_failure_time = get(TIME)
        elseif get(TIME) - data.misc.loc_failure_time < 9 then
            data.misc.loc_failure = get(TIME) % 1 < 0.5
        end
    else
        data.misc.loc_failure_time = nil
    end

    draw_upper_info_freq(data,
                         radio_ils_get_freq(),
                         radio_ils_get_crs(),
                         DRAIMS_common.radio.ils == nil and "" or DRAIMS_common.radio.ils.id,
                         radio_ils_get_tuning_source(),
                         ECAM_MAGENTA)
end


local function draw_rose_vor_indication(data)
    local curr_nav = data.id

    local crs_angle = 0

    if adirs_is_hdg_ok(data.id) then
        crs_angle = radio_vor_get_crs(curr_nav)
    else
        crs_angle = data.inputs.heading -- Stay at zero
    end
    
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
        sasl.gl.drawRotatedTexture(image_h_deviation_sym, -data.inputs.heading+crs_angle, (size[1]-500)/2,(size[2]-176)/2,500,176, {1,1,1})
        sasl.gl.drawRotatedTextureCenter(image_deviation_arrow, -data.inputs.heading+crs_angle, size[1]/2, size[2]/2, (size[1]-28)/2+degrees_px,(size[2]-176)/2, 28,176, {1,1,1})
    end

end

local function draw_rose_loc_indication(data)
    local crs_angle = 0

    if adirs_is_hdg_ok(data.id) then
        crs_angle = radio_ils_get_crs()
    else
        crs_angle = data.inputs.heading -- Stay at zero
    end
    
    sasl.gl.drawRotatedTexture(image_deviation_ind_ils, -data.inputs.heading+crs_angle, (size[1]-75)/2,(size[2]-590)/2,75,590, {1,1,1})

    
    local is_valid = radio_ils_is_valid() and radio_loc_is_valid()
    if not is_valid then
        return -- No active ils
    end

    -- image_deviation_arrow
        
    local degrees = radio_get_ils_deviation_h()
    if radio_get_ils_is_backcourse() then
        degrees = - degrees
    end
    local degrees_clamp = Math_clamp(degrees, -1.7, 1.7)
    local ralt = data.id == ND_CAPT and get(Capt_ra_alt_ft) or get(Fo_ra_alt_ft)
    if degrees_clamp ~= degrees and get(TIME) % 1 < 0.5 and ralt > 15 then
        return  -- Pulsing if excessive
    end

    local degrees_px = degrees_clamp / 5 * 569

    local angle = -data.inputs.heading+crs_angle
    sasl.gl.drawRotatedTexture(image_h_deviation_sym, angle, (size[1]-500)/2,(size[2]-176)/2,500,176, {1,1,1})
    sasl.gl.drawRotatedTextureCenter(image_deviation_arrow_ils, angle, size[1]/2, size[2]/2, (size[1]-28)/2+degrees_px,(size[2]-176)/2, 28,176, {1,1,1})
    if math.abs(angle) > 90 then
        angle = angle - 180
    end
    local text = radio_get_ils_is_backcourse() and "B/C" or "LOC"
    sasl.gl.drawRotatedText(Font_AirbusDUL, size[1]/2-180, size[1]/2+20, size[1]/2, size[1]/2, angle, text, 30, false , false , TEXT_ALIGN_CENTER , ECAM_MAGENTA )
end

local function draw_rose_gs_indication(data)



    local is_valid = radio_ils_is_valid()
    data.misc.gs_failure = not is_valid

    if not is_valid then
        -- Flash G/S for 9 seconds
        if data.misc.gs_failure_time == nil then
            data.misc.gs_failure_time = get(TIME)
        elseif get(TIME) - data.misc.gs_failure_time < 9 then
            data.misc.gs_failure = get(TIME) % 1 < 0.5
        end

        return -- No active GS
    end
    data.misc.gs_failure_time = nil
    
    -- image_deviation_arrow

    if radio_gs_is_valid() then
        local degrees = -radio_get_ils_deviation_v()
        local degrees_clamp = Math_clamp(degrees, -0.9, 0.9)
        local ralt = data.id == ND_CAPT and get(Capt_ra_alt_ft) or get(Fo_ra_alt_ft)
        
        if degrees_clamp ~= degrees and get(TIME) % 1 < 0.5 and ralt then
            return  -- Pulsing if excessive
        end

        sasl.gl.drawTexture(image_v_deviation_sym, size[1]-75, 201, 29, 500, {1,1,1})
        local degrees_px = Math_rescale_no_lim(0, 0, 0.9, 240, degrees_clamp)
        sasl.gl.drawTexture(image_deviation_diamond_ils, size[1]-77, 428 + degrees_px, 32, 45, {1,1,1})
    else
        sasl.gl.drawTexture(image_v_deviation_sym, size[1]-75, 201, 29, 500, {1,1,1})
    end
end

function draw_rose_vor(data)
    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- Not drawn
    end

    draw_rose_vor_indication(data)
end

function draw_rose_ils(data)
    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- Not drawn
    end

    draw_rose_loc_indication(data)
    draw_rose_gs_indication(data)
end

function draw_rose_vorils_unmasked(data)
    if data.config.range <= ND_RANGE_ZOOM_2 then
        return  -- Not drawn
    end
    if data.config.mode == ND_MODE_VOR then
        draw_upper_right_info_vor(data)
    elseif data.config.mode == ND_MODE_ILS then
        draw_upper_right_info_ils(data)
    end
end
