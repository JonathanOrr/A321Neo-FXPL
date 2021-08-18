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
-- File: ECAM.lua 
-- Short description: Main ECAM file 
-------------------------------------------------------------------------------

position = {get(ECAM_displaying_position, 1), get(ECAM_displaying_position, 2), get(ECAM_displaying_position, 3), get(ECAM_displaying_position, 4)}
size = {900, 900}

include('ECAM/ECAM_automation.lua')
include('ECAM/ECAM_apu.lua')
include('ECAM/ECAM_bleed.lua')
include('ECAM/ECAM_cond.lua')
include('ECAM/ECAM_cruise.lua')
include('ECAM/ECAM_door.lua')
include('ECAM/ECAM_elec.lua')
include('ECAM/ECAM_engines.lua')
include('ECAM/ECAM_fctl.lua')
include('ECAM/ECAM_fuel.lua')
include('ECAM/ECAM_hyd.lua')
include('ECAM/ECAM_press.lua')
include('ECAM/ECAM_status.lua')
include('ECAM/ECAM_wheel.lua')
include('ADIRS_data_source.lua')

--local variables
local apu_avail_timer = -1
local gload = 1
local last_update_gload = 0
local image_camera_1 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/camera-1.png")
local image_camera_2 = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ECAM/camera-2.png")
local current_door_video   = 0 -- 0 not active, 1 main door, 2 side doors
local is_door_video_active = true
local time_g_load_visible = -10
local time_g_load_catch = 0

-- Handlers for the camera
sasl.registerCommandHandler (VIDEO_cmd_toggle,  0, function(phase) if phase == SASL_COMMAND_BEGIN then is_door_video_active = not is_door_video_active end end )
sasl.registerCommandHandler (VIDEO_cmd_require, 0, function(phase) if phase == SASL_COMMAND_BEGIN then current_door_video = (current_door_video + 1) % 3 end end )

local function draw_ecam_lower_section_fixed()
    sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-372, "TAT", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-407, "SAT", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-372, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-407, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]-230, size[2]/2-372, "GW", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-15, size[2]/2-375, "KG", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-407, "H", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)

    local isa_displayed = get(Capt_Baro) > 29.91 and get(Capt_Baro) < 29.93 and adirs_is_adr_working(PFD_CAPT)

    if isa_displayed then
        sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-442, "ISA", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-442, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    end

    if (gload >= 1.4 or gload <= 0.7) then
        if time_g_load_catch == 0 then
            time_g_load_catch = get(TIME)
        end
    else
        time_g_load_catch = 0
    end
    
    local trigger_in_condition  = time_g_load_catch ~= 0 and (get(TIME) - time_g_load_catch > 2) 
    local trigger_out_condition = (get(TIME) - time_g_load_visible < 5) 
    
    if (trigger_in_condition or trigger_out_condition) then
        if trigger_in_condition then
            time_g_load_visible = get(TIME)
        end
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-115, size[2]/2-372, "G LOAD", 32, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+50, size[2]/2-372, Round_fill(gload,1), 32, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    else
    
        if get(AUTOFLT_FCU_M_ALT) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-130, size[2]/2-372, "ALT SEL", 32, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)

            local altitude_m = math.floor(get(AUTOFLT_FCU_ALT) * 0.3048)

            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+110, size[2]/2-372, altitude_m, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)


            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+120, size[2]/2-372, "M", 24, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

        end
    
    end
end

local function get_isa()
    -- Source: http://fisicaatmo.at.fcen.uba.ar/practicas/ISAweb.pdf
    local alt_meter = get(Capt_Baro_Alt) * 0.3048
    return math.max(-56.5, 15 - 6.5 * alt_meter/1000)
end

--custom fucntions
local function draw_ecam_lower_section()

    draw_ecam_lower_section_fixed()

    --left section
    local tat = "XX"
    local ota = "XX"
    if adirs_is_adr_working(PFD_CAPT) then
        ota = Round(get(OTA), 0)
        if ota > 0 then
            ota = "+" .. ota
        end
        tat = Round(get(TAT), 0)
        if tat > 0 then
            tat = "+" .. tat
        end
    end
    sasl.gl.drawText(Font_AirbusDUL, 190, size[2]/2-372, tat, 32, false, false, TEXT_ALIGN_RIGHT, tat == "XX" and ECAM_ORANGE or ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, 190, size[2]/2-407, ota, 32, false, false, TEXT_ALIGN_RIGHT, ota == "XX" and ECAM_ORANGE or ECAM_GREEN)

    local isa_displayed = get(Capt_Baro) > 29.91 and get(Capt_Baro) < 29.93 and adirs_is_adr_working(PFD_CAPT)
    if isa_displayed then
        local delta_isa = Round(get(TAT) - get_isa(), 0)
        if delta_isa > 0 then
            delta_isa = "+" .. delta_isa
        end
        sasl.gl.drawText(Font_AirbusDUL, 190, size[2]/2-442, delta_isa, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
    --center section
    --adding a 0 to the front of the time when single digit
    if GPS_sys[1].status == GPS_STATUS_NAV or GPS_sys[2].status == GPS_STATUS_NAV then
        if get(ZULU_hours) < 10 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-408, "0" .. get(ZULU_hours), 38, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-408, get(ZULU_hours), 38, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end

        if get(ZULU_mins) < 10 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+25, size[2]/2-408, "0" .. get(ZULU_mins), 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+25, size[2]/2-408, get(ZULU_mins), 34, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        end
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-408, "XX", 38, false, false, TEXT_ALIGN_RIGHT, ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+25, size[2]/2-408, "XX", 34, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
    end
    --right section
    if get(FAILURE_FUEL_FQI_1_FAULT) == 1 and get(FAILURE_FUEL_FQI_2_FAULT) == 1 then
        GW = "-----"
        color = ECAM_ORANGE
    else
        GW = math.floor(get(Gross_weight))
        GW = GW - GW%100
        color = ECAM_GREEN
    end
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+370, size[2]/2-375, GW, 36, false, false, TEXT_ALIGN_RIGHT, color)
end

function update()
    perf_measure_start("ECAM:update()")

    position = {get(ECAM_displaying_position, 1), get(ECAM_displaying_position, 2), get(ECAM_displaying_position, 3), get(ECAM_displaying_position, 4)}

	ecam_update_page()
	ecam_update_leds()
	ecam_update_fuel_page()
	ecam_update_eng_page()  -- This must be called even if the page is not showed to update some stuffs for EWD
    ecam_update_fctl_page()
	ecam_update_cruise_page()
    ecam_update_status_page() -- This must be called even if the page is not showed

    if get(Ecam_current_page) == 3 then
        ecam_update_press_page()
    elseif get(Ecam_current_page) == 10 then
        ecam_update_wheel_page()
    end

    if get(TIME) - last_update_gload > 0.1 then
        last_update_gload = get(TIME)
        gload = get(Total_vertical_g_load)
    end

    perf_measure_stop("ECAM:update()")

end

local function draw_video()

    pb_set(PB.ovhd.misc_cockpit_video, not is_door_video_active, false)

    if is_door_video_active and current_door_video ~= 0 then
        if current_door_video == 1 then
            sasl.gl.drawTexture(image_camera_1, 0,130,900,770,{1,1,1})
        elseif current_door_video == 2 then
            sasl.gl.drawTexture(image_camera_2, 0,130,900,770,{1,1,1})
        end
    end
end

function draw_ecam_backdrop()
    sasl.gl.drawWideLine(10, 112, 890, 112, 4,ECAM_WHITE)
    sasl.gl.drawWideLine(600, 112, 600, 1, 4, ECAM_WHITE)
    sasl.gl.drawWideLine(300, 112, 300, 1, 4, ECAM_WHITE)
end

local function draw_ecam_pages()
    draw_ecam_backdrop()
    if get(Ecam_current_page) == 1 then --eng
        draw_eng_page()
    elseif get(Ecam_current_page) == 2 then --bleed
        draw_bleed_page()
    elseif get(Ecam_current_page) == 3 then --press
        draw_press_page()
    elseif get(Ecam_current_page) == 4 then --elec
        draw_elec_page()
    elseif get(Ecam_current_page) == 5 then --hyd
        draw_hydraulic_page()
    elseif get(Ecam_current_page) == 6 then --fuel
        draw_fuel_page()
    elseif get(Ecam_current_page) == 7 then --apu
        draw_apu_page()
    elseif get(Ecam_current_page) == 8 then --cond
        draw_cond_page()
    elseif get(Ecam_current_page) == 9 then --door
        draw_door_page()
    elseif get(Ecam_current_page) == 10 then --wheel
        draw_wheel_page()
    elseif get(Ecam_current_page) == 11 then -- F/CTL
        draw_fctl_page()
    elseif get(Ecam_current_page) == 12 then --STS
        draw_sts_page()
    elseif get(Ecam_current_page) == 13 then --CRUISE
        draw_cruise_page()
    end
end

local skip_1st_frame_AA = true

--drawing the ECAM
function draw()

    perf_measure_start("ECAM:draw()")

    if not skip_1st_frame_AA then
        sasl.gl.setRenderTarget(ECAM_popup_texture, true, get(PANEL_AA_LEVEL_1to32))
    else
        sasl.gl.setRenderTarget(ECAM_popup_texture, true)
    end
    skip_1st_frame_AA = false
    
    draw_ecam_pages()
    draw_ecam_lower_section()
    draw_video()
    sasl.gl.restoreRenderTarget()

    sasl.gl.drawTexture(ECAM_popup_texture, 0, 0, 900, 900, {1,1,1})

    -- Update STS box
    set(EWD_box_sts, 0)
    set(Ecam_status_is_normal, ecam_sts:is_normal() and 1 or 0) -- Used in ECAM_automation.lua
    if (not ecam_sts:is_normal()) or (not ecam_sts:is_normal_maintenance() and get(EWD_flight_phase) == PHASE_2ND_ENG_OFF ) then
        if get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD_STS and get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD then
            set(EWD_box_sts, 1)
        end
    end

    perf_measure_stop("ECAM:draw()")

end
