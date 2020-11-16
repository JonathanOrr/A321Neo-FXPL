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

position= {3187,539,900,900}
size = {900, 900}

include('ECAM_automation.lua')
include('ECAM_apu.lua')
include('ECAM_bleed.lua')
include('ECAM_cond.lua')
include('ECAM_cruise.lua')
include('ECAM_door.lua')
include('ECAM_elec.lua')
include('ECAM_engines.lua')
include('ECAM_fctl.lua')
include('ECAM_fuel.lua')
include('ECAM_hyd.lua')
include('ECAM_press.lua')
include('ECAM_status.lua')
include('ECAM_wheel.lua')

include('constants.lua')

--local variables
local apu_avail_timer = -1

--sim datarefs

--colors
local left_brake_temp_color = {1.0, 1.0, 1.0}
local right_brake_temp_color = {1.0, 1.0, 1.0}
local left_tire_psi_color = {1.0, 1.0, 1.0}
local right_tire_psi_color = {1.0, 1.0, 1.0}

local left_bleed_color = ECAM_ORANGE
local right_bleed_color = ECAM_ORANGE
local left_eng_avail_cl = ECAM_ORANGE
local right_eng_avail_cl = ECAM_ORANGE

-- misc

local function drawUnderlineText(font, x, y, text, size, bold, italic, align, color)
    sasl.gl.drawText(font, x, y, text, size, bold, italic, align, color)
    width, height = sasl.gl.measureText(Font_AirbusDUL, text, size, false, false)
    sasl.gl.drawWideLine(x + 3, y - 5, x + width + 3, y - 5, 4, color)
end

local function draw_ecam_lower_section_fixed()
    sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-372, "TAT", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-407, "SAT", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-372, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-407, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)

    sasl.gl.drawText(Font_AirbusDUL, size[1]-230, size[2]/2-372, "GW", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]-15, size[2]/2-375, "KG", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2-407, "H", 30, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
    
    local isa_displayed = get(Capt_Baro) > 29.91 and get(Capt_Baro) < 29.93 and get(Adirs_capt_has_ADR) == 1
    
    if isa_displayed then
        sasl.gl.drawText(Font_AirbusDUL, 100, size[2]/2-442, "ISA", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, 260, size[2]/2-442, "°C", 32, false, false, TEXT_ALIGN_RIGHT, ECAM_BLUE)
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
    if get(Adirs_capt_has_ADR) == 1 then
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
    
    local isa_displayed = get(Capt_Baro) > 29.91 and get(Capt_Baro) < 29.93 and get(Adirs_capt_has_ADR) == 1
    if isa_displayed then
        local delta_isa = Round(get(TAT) - get_isa(), 0)
        if delta_isa > 0 then
            delta_isa = "+" .. delta_isa
        end
        sasl.gl.drawText(Font_AirbusDUL, 190, size[2]/2-442, delta_isa, 32, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end
    --center section
    --adding a 0 to the front of the time when single digit
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

    --right section
    if get(FAILURE_FUEL_FQI_1_FAULT) == 1 and get(FAILURE_FUEL_FQI_2_FAULT) == 1 then
        GW = "-----"
        color = ECAM_ORANGE
    else
        GW = math.floor(get(Gross_weight))
        color = ECAM_GREEN
    end
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+370, size[2]/2-375, GW, 36, false, false, TEXT_ALIGN_RIGHT, color)
end

function update()
    perf_measure_start("ECAM:update()")

    -- APU  -- This is needed for both apu and bleed
    if get(Apu_master_button_state) % 2 == 0 and get(FAILURE_BLEED_APU_VALVE_STUCK) == 0 then
        set(Ecam_bleed_apu_valve, -1)
    else
        set(Ecam_bleed_apu_valve, get(Apu_bleed_switch) * 2 + get(FAILURE_BLEED_APU_VALVE_STUCK))
    end
	
	ecam_update_page()
	ecam_update_leds()
	ecam_update_fuel_page()
	ecam_update_eng_page()  -- This must be called even if the page is not showed to update some stuffs for EWD
	ecam_update_cruise_page()
	
	if get(Ecam_current_page) == 2 then
        ecam_update_bleed_page()
    elseif get(Ecam_current_page) == 3 then
        ecam_update_press_page()
    elseif get(Ecam_current_page) == 7 then
        ecam_update_apu_page()
    elseif get(Ecam_current_page) == 8 then
        ecam_update_cond_page()
    elseif get(Ecam_current_page) == 10 then
        ecam_update_wheel_page()
    end

    perf_measure_stop("ECAM:update()")

end 

--drawing the ECAM
function draw()

    perf_measure_start("ECAM:draw()")

    if get(AC_bus_2_pwrd) == 0 and get(EWD_displaying_status) ~= 4 then
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.43, 0.43)   -- 50W (just hypothesis)


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

    draw_ecam_lower_section()

    -- Update STS box
    set(EWD_box_sts, 0)
    set(Ecam_status_is_normal, ecam_sts:is_normal() and 1 or 0) -- Used in ECAM_automation.lua
    if (not ecam_sts:is_normal()) or (not ecam_sts:is_normal_maintenance() and get(EWD_flight_phase) == 10 ) then
        if get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD_STS and get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD then
            set(EWD_box_sts, 1)
        end
    end
    
    perf_measure_stop("ECAM:draw()")

end
