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
-- File: adirs_debug.lua 
-- Short description: ADIRS debug window
-------------------------------------------------------------------------------

size = {700 , 500}

local TIME_TO_START_ADR       = 2 -- In seconds
local IR_TIME_TO_GET_ATTITUDE = 20 -- In seconds


local function write_common(i)
    local x_shift = i == 1 and 0 or (i == 2 and 470 or 235)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-40, "Is on bat?", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, x_shift+120, size[2]-40, ADIRS_sys[i].is_on_bat and "YES" or "NO", 14, false, false, TEXT_ALIGN_LEFT, ADIRS_sys[i].is_on_bat and ECAM_ORANGE or ECAM_BLUE)

    local mode = ADIRS_sys[i].adirs_switch_status == ADIRS_CONFIG_OFF and "OFF" or (ADIRS_sys[i].adirs_switch_status == ADIRS_CONFIG_NAV and "NAV" or "ATT")
    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-60, "Mode:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, x_shift+120, size[2]-60, mode, 14, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

end

local function write_adr(i)
    local x_shift = i == 1 and 0 or (i == 2 and 470 or 235)
    
    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-130, "Status:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    local state = "OFF"
    local color = ECAM_WHITE
    if ADIRS_sys[i].adr_status == ADR_STATUS_STARTING then
        state = "STARTING"
        color = ECAM_ORANGE
    elseif ADIRS_sys[i].adr_status == ADR_STATUS_ON then
        state = "ON"
        color = ECAM_GREEN
    elseif ADIRS_sys[i].adr_status == ADR_STATUS_FAULT then
        state = "FAULT"    
        color = ECAM_RED
    end
    
    sasl.gl.drawText(Font_AirbusDUL, x_shift+100, size[2]-130, state, 14, false, false, TEXT_ALIGN_LEFT, color)

    local time_to_align = math.max(0, TIME_TO_START_ADR - (get(TIME) - ADIRS_sys[i].adr_align_start_time))

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-150, "Rem. time align:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+160, size[2]-150, Round_fill(time_to_align, 1) .. "s", 14, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

end

local function write_ir(i)
    local x_shift = i == 1 and 0 or (i == 2 and 470 or 235)
    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-220, "Status:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    
    local state = "OFF"
    local color = ECAM_WHITE
    if ADIRS_sys[i].ir_status == IR_STATUS_IN_ALIGN then
        state = "IN ALIGN"
        color = ECAM_ORANGE
    elseif ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED then
        state = "ALIGNED"
        color = ECAM_GREEN
    elseif ADIRS_sys[i].ir_status == IR_STATUS_ATT_ALIGNED then
        state = "ATT ALIGNED"
        color = ECAM_MAGENTA
    elseif ADIRS_sys[i].ir_status == IR_STATUS_FAULT then
        state = "FAULT"    
        color = ECAM_RED
    end
    
    sasl.gl.drawText(Font_AirbusDUL, x_shift+100, size[2]-220, state, 14, false, false, TEXT_ALIGN_LEFT, color)

    local time_to_align = math.max(0, get(Adirs_total_time_to_align) - (get(TIME) - ADIRS_sys[i].ir_align_start_time))
    if ADIRS_sys[i].adirs_switch_status == ADIRS_CONFIG_ATT then
        time_to_align = math.max(0, IR_TIME_TO_GET_ATTITUDE - (get(TIME) - ADIRS_sys[i].ir_align_start_time))
    end

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-240, "Rem. time align:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+160, size[2]-240, Round_fill(time_to_align, 1) .. "s", 14, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-260, "Aligning on:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+160, size[2]-260, ADIRS_sys[i].ir_is_aligning_gps and "GPS" or "MANUAL", 14, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)


end

local function write_values(i)
    local x_shift = i == 1 and 0 or (i == 2 and 470 or 235)

    
    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-330, "IAS:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-330, Round_fill(ADIRS_sys[i].ias,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-330, "TAS:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-330, Round_fill(ADIRS_sys[i].tas,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-350, "ALT:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-350, math.floor(ADIRS_sys[i].alt), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    
    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-350, "VS:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-350, math.floor(ADIRS_sys[i].vs), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-370, "W/SPD:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-370, Round_fill(ADIRS_sys[i].wind_spd,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-370, "W/DIR:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-370, math.floor(ADIRS_sys[i].wind_dir), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    -- PITCH & ROLL

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-390, "Pitch:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-390, Round_fill(ADIRS_sys[i].pitch,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-390, "Roll:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-390, Round_fill(ADIRS_sys[i].roll,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    -- HDG & TRACK

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-410, "HDG:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-410, Round_fill(ADIRS_sys[i].hdg,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-410, "THDG:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-410, Round_fill(ADIRS_sys[i].true_hdg,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    
    -- LAT & LON

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-430, "LAT:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-430, Round_fill(ADIRS_sys[i].lat,2), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-430, "LON:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-430, Round_fill(ADIRS_sys[i].lon,2), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    -- GS & Mach

    sasl.gl.drawText(Font_AirbusDUL, x_shift+20, size[2]-450, "GS:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+110, size[2]-450, Round_fill(ADIRS_sys[i].gs,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-450, "Mach:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-450, Round_fill(ADIRS_sys[i].mach,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)


    -- ?? & Track
    sasl.gl.drawText(Font_AirbusDUL, x_shift+135, size[2]-470, "Track:", 14, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    sasl.gl.drawText(Font_AirbusDUL, x_shift+225, size[2]-470, Round_fill(ADIRS_sys[i].track,1), 14, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

end

function draw()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/6, size[2]-15, "ADIRS 1", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 3*size[1]/6, size[2]-15, "ADIRS 3", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 5*size[1]/6, size[2]-15, "ADIRS 2", 20, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    write_common(1)
    write_common(3)
    write_common(2)

    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-100, "ADR 1", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 255, size[2]-100, "ADR 3", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 490, size[2]-100, "ADR 2", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    write_adr(1)
    write_adr(2)
    write_adr(3)
    
    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-190, "IR 1", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 255, size[2]-190, "IR 3", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 490, size[2]-190, "IR 2", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    write_ir(1)
    write_ir(2)
    write_ir(3)

    sasl.gl.drawText(Font_AirbusDUL, 20, size[2]-300, "Computed values", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 255, size[2]-300, "Computed values", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 490, size[2]-300, "Computed values", 18, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

    write_values(1)
    write_values(2)
    write_values(3)


end
