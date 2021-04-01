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
-- File: navaids.lua 
-- Short description: NAVAIDs debug window
-------------------------------------------------------------------------------

size = {600 , 600}

include('DRAIMS/radio_logic.lua')

local function draw_static()
    sasl.gl.drawFrame(10, 410, 180, 180, ECAM_WHITE)
    sasl.gl.drawFrame(210, 410, 180, 180, ECAM_WHITE)

    sasl.gl.drawFrame(10, 210, 180, 180, ECAM_WHITE)
    sasl.gl.drawFrame(210, 210, 180, 180, ECAM_WHITE)
    sasl.gl.drawFrame(410, 210, 180, 380, ECAM_WHITE)

    sasl.gl.drawFrame(10, 30, 580, 160, ECAM_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 100, 570, "VOR 1", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 300, 570, "VOR 2", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 100, 370, "ADF 1", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 300, 370, "ADF 2", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 500, 570, "GLS", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, 300, 170, "ILS", 15, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

end

local function draw_vor(x, i)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 540, "Freq./CRS:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 520, "Found:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 500, "Name:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 480, "Distance (nm):", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 460, "Bearing:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_B612MONO_regular, x+15, 435, "DME Valid:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 415, "DME Value:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, x+100, 540, Round_fill(radio_vor_get_freq(i,false),2) .. "/" .. radio_vor_get_crs(i), 13, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, x+180, 520, radio_vor_is_valid(i) and "YES" or "NO", 13, false, false, TEXT_ALIGN_RIGHT, radio_vor_is_valid(i) and ECAM_GREEN or ECAM_RED)

    if radio_vor_is_valid(i) then
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 500, DRAIMS_common.radio.vor[i].id, 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 480, Round_fill(DRAIMS_common.radio.vor[i].curr_distance,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 460, Round_fill(DRAIMS_common.radio.vor[i].curr_bearing,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end
    
    sasl.gl.drawText(Font_B612MONO_regular, x+180, 435, radio_vor_is_dme_valid(i) and "YES" or "NO", 13, false, false, TEXT_ALIGN_RIGHT, radio_vor_is_dme_valid(i) and ECAM_GREEN or ECAM_RED)
    if radio_vor_is_dme_valid(i) then
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 415, Round_fill(radio_vor_get_dme_value(i),2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end
end

local function draw_adf(x, i)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 340, "Freq.:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 320, "Found:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 300, "Name:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 280, "Distance (nm):", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, x+15, 260, "Bearing:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, x+100, 340, Round_fill(radio_adf_get_freq(i),2), 13, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, x+180, 320, radio_adf_is_valid(i) and "YES" or "NO", 13, false, false, TEXT_ALIGN_RIGHT, radio_adf_is_valid(i) and ECAM_GREEN or ECAM_RED)

    if radio_adf_is_valid(i) then
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 300, DRAIMS_common.radio.adf[i].id, 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 280, Round_fill(DRAIMS_common.radio.adf[i].curr_distance,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, x+180, 260, Round_fill(DRAIMS_common.radio.adf[i].curr_bearing,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end

end

local function draw_loc()
    if not radio_ils_is_valid() then
        return
    end
    if radio_loc_is_valid() then
        sasl.gl.drawText(Font_B612MONO_regular, 215, 140, "LOC OK", 13, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        if radio_get_ils_is_backcourse() then
            sasl.gl.drawText(Font_B612MONO_regular, 300, 140, "B/C", 13, false, false, TEXT_ALIGN_LEFT, ECAM_MAGENTA)
        end
        sasl.gl.drawText(Font_B612MONO_regular, 215, 120, "Deviation:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        sasl.gl.drawText(Font_B612MONO_regular, 350, 120, Round_fill(radio_get_ils_deviation_h(),2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        
    else
        sasl.gl.drawText(Font_B612MONO_regular, 215, 140, "LOC NOT OK", 13, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        sasl.gl.drawText(Font_B612MONO_regular, 215, 120, "Reason:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        
        local reason = "Unknown"
        if DRAIMS_common.radio.ils.loc.reason == 1 then
            reason = "Altitude: Too High or Too Low"
        elseif DRAIMS_common.radio.ils.loc.reason == 2 then
            reason = "Distance: Too far"
        elseif DRAIMS_common.radio.ils.loc.reason == 3 then
            reason = "Angle: Not in the receive zone"
        end
        sasl.gl.drawText(Font_B612MONO_regular, 215, 100, reason, 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

local function draw_gs()
    if not radio_ils_is_valid() then
        return
    end
    if radio_gs_is_valid() then
        sasl.gl.drawText(Font_B612MONO_regular, 215, 80, "G/S OK", 13, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        sasl.gl.drawText(Font_B612MONO_regular, 215, 60, "Deviation:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        sasl.gl.drawText(Font_B612MONO_regular, 350, 60, Round_fill(radio_get_ils_deviation_v(),2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        
    else
        sasl.gl.drawText(Font_B612MONO_regular, 215, 80, "G/S NOT OK", 13, false, false, TEXT_ALIGN_LEFT, ECAM_RED)
        sasl.gl.drawText(Font_B612MONO_regular, 215, 60, "Reason:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
        
        local reason = "Unknown"
        if DRAIMS_common.radio.ils.gs.reason == 1 then
            reason = "Altitude: Too High or Too Low"
        elseif DRAIMS_common.radio.ils.gs.reason == 2 then
            reason = "Distance: Too far"
        elseif DRAIMS_common.radio.ils.gs.reason == 3 then
            reason = "Angle: Not in the receive zone"
        end
        sasl.gl.drawText(Font_B612MONO_regular, 215, 40, reason, 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    end
end

local function draw_ils()
    sasl.gl.drawText(Font_B612MONO_regular, 15, 160, "Freq.:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 15, 140, "Found:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 15, 120, "Name:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 15, 100, "Distance (nm):", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 15, 80, "Bearing:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 15, 60, "DME Valid:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_B612MONO_regular, 15, 40, "DME Value:", 13, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    sasl.gl.drawText(Font_B612MONO_regular, 100, 160, Round_fill(radio_ils_get_freq(),2) .. "/" .. radio_ils_get_crs(), 13, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_B612MONO_regular, 180, 140, radio_ils_is_valid() and "YES" or "NO", 13, false, false, TEXT_ALIGN_RIGHT, radio_ils_is_valid() and ECAM_GREEN or ECAM_RED)

    if radio_ils_is_valid() then
        sasl.gl.drawText(Font_B612MONO_regular, 180, 120, DRAIMS_common.radio.ils.id, 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        sasl.gl.drawText(Font_B612MONO_regular, 180, 100, Round_fill(DRAIMS_common.radio.ils.curr_distance,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        if DRAIMS_common.radio.ils.loc.bearing then
            sasl.gl.drawText(Font_B612MONO_regular, 180, 80, Round_fill(DRAIMS_common.radio.ils.loc.bearing,2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
        end
    end
    
    sasl.gl.drawText(Font_B612MONO_regular, 180, 60, radio_ils_is_dme_valid() and "YES" or "NO", 13, false, false, TEXT_ALIGN_RIGHT, radio_ils_is_dme_valid() and ECAM_GREEN or ECAM_RED)
    if radio_ils_is_dme_valid() then
        sasl.gl.drawText(Font_B612MONO_regular, 180, 40, Round_fill(radio_ils_get_dme_value(),2), 13, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end
    
    draw_loc()
    draw_gs()
end

local function draw_ab()
    sasl.gl.drawText(Font_B612MONO_regular, 10, 0, "AVIONICSBAY:", 15, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    if AvionicsBay.is_initialized() then
        sasl.gl.drawText(Font_B612MONO_regular, 200, 0, "INIT", 15, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(TIME) % 0.5 < 0.25 then
        sasl.gl.drawText(Font_B612MONO_regular, 200, 0, ">>>> NOT INIT <<<<", 15, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
    
    if AvionicsBay.is_initialized()  and AvionicsBay.is_ready() then
        sasl.gl.drawText(Font_B612MONO_regular, 400, 0, "READY", 15, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(TIME) % 0.5 < 0.25 then
        sasl.gl.drawText(Font_B612MONO_regular, 400, 0, ">>>> NOT READY <<<<<", 15, true, false, TEXT_ALIGN_CENTER, ECAM_RED)
    end
    
end

function draw()

    draw_static()
    draw_ab()
    draw_vor(0, 1)
    draw_vor(200, 2)
    draw_adf(0, 1)
    draw_adf(200, 2)
    draw_ils()
end
