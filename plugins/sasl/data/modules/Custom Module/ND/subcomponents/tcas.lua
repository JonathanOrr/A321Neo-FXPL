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
-- File: tcas.lua
-- Short description: TCAS drawings on ND
-------------------------------------------------------------------------------


local image_tcas_far  = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-far.png")
local image_tcas_prox = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-prox.png")
local image_tcas_ta   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-ta.png")
local image_tcas_ra   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/tcas-ra.png")

local function draw_tcas_altitude(data, acf, poi)
    if poi.x == nil then
        return
    end

    local alt_diff = math.abs(acf.alt - data.inputs.altitude)
    local alt_diff_text = Fwd_string_fill(""..math.floor(alt_diff/100), "0", 2)
    if acf.alt >= data.inputs.altitude then
        alt_diff_text = "+" .. alt_diff_text
    else
        alt_diff_text = "-" .. alt_diff_text
    end
    local color = acf.alert == TCAS_ALERT_TA and COLOR_YELLOW or (acf.alert == TCAS_ALERT_RA and ECAM_RED or ECAM_WHITE)

    sasl.gl.drawText(Font_ECAMfont, poi.x-25, poi.y-40, alt_diff_text, 26, false, false, TEXT_ALIGN_LEFT, color)

    -- DEBUG INFOs
    if debug_tcas_system then
        local labels = { [0] = "-", "TA", "RA"}
        local labels_act = { [0] = "-", "CL L", "DS L", "CL H", "DS H", "T"}
    
        sasl.gl.drawText(Font_ECAMfont, poi.x-25, poi.y-70, "STATUS: " .. (labels[acf.alert] .. " (" .. acf.alert .. ")") , 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_ECAMfont, poi.x-25, poi.y-100, "ACTION: " .. (labels_act[acf.action] .. " (" .. acf.action .. ")") , 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        sasl.gl.drawText(Font_ECAMfont, poi.x-25, poi.y-130, "REASON: " .. (acf.debug_reason or "NIL"), 26, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
        if acf.debug_inhib > 0 then
            sasl.gl.drawText(Font_ECAMfont, poi.x+25, poi.y-40, "INHIBIT: " .. acf.debug_inhib, 26, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
        end
    end
end

local function draw_tcas_vs(data, acf, poi)
    if poi.x == nil then
        return
    end
    
    if math.abs(acf.vs * 60) < 500 then
        return -- Show the arrow only if V/S > 500
    end

    local color = acf.alert == TCAS_ALERT_TA and COLOR_YELLOW or (acf.alert == TCAS_ALERT_RA and ECAM_RED or ECAM_WHITE)

    sasl.gl.drawWideLine(poi.x+20, poi.y-14, poi.x+20, poi.y+14, 2, color)

    if acf.vs > 0 then
        sasl.gl.drawWideLine(poi.x+20, poi.y+14, poi.x+27, poi.y+3, 2, color)
        sasl.gl.drawWideLine(poi.x+20, poi.y+14, poi.x+13, poi.y+3, 2, color)
    else
        sasl.gl.drawWideLine(poi.x+20, poi.y-14, poi.x+27, poi.y-3, 2, color)
        sasl.gl.drawWideLine(poi.x+20, poi.y-14, poi.x+13, poi.y-3, 2, color)
    end
end

function draw_tcas_acf(data, acf, poi, draw_poi_array)
    if poi.distance > 80 then
        return -- Too far
    end

    local alt_diff = acf.alt - data.inputs.altitude

    -- ABV or THRT
    if (get(TCAS_disp_mode) == 1 or get(TCAS_disp_mode) == 3) and alt_diff < -2700 then
        return false, nil
    end

    -- BLW or THRT
    if (get(TCAS_disp_mode) == 2 or get(TCAS_disp_mode) == 3) and alt_diff > 2700 then
        return false, nil
    end

    local texture = image_tcas_far
    if acf.alert == TCAS_ALERT_TA then
        texture = image_tcas_ta
    elseif acf.alert == TCAS_ALERT_RA then
        texture = image_tcas_ra
    elseif poi.distance <= 6 and math.abs(alt_diff) <= 1200 then
        texture = image_tcas_prox
    end
    local modified, poi = draw_poi_array(data, poi, texture, ECAM_WHITE)

    draw_tcas_altitude(data, acf, poi)
    draw_tcas_vs(data, acf, poi)
    
    return modified, poi
end

