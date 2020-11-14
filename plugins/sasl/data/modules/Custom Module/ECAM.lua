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
include('ECAM_hyd.lua')
include('ECAM_elec.lua')
include('ECAM_engines.lua')
include('ECAM_fuel.lua')
include('ECAM_status.lua')
include('ECAM_press.lua')

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


    --wheels indications--
    if get(Left_brakes_temp) > 400 then
		left_brake_temp_color = ECAM_ORANGE
	else
		left_brake_temp_color = ECAM_WHITE
	end

	if get(Right_brakes_temp) > 400 then
		right_brake_temp_color = ECAM_ORANGE
	else
		right_brake_temp_color = ECAM_WHITE
	end

	if get(Left_tire_psi) > 280 then
		left_tire_psi_color = ECAM_ORANGE
	else
		left_tire_psi_color = ECAM_WHITE
	end

	if get(Right_tire_psi) > 280 then
		right_tire_psi_color = ECAM_ORANGE
	else
		right_tire_psi_color = ECAM_WHITE
	end
	
	ecam_update_page()
	ecam_update_leds()
	ecam_update_fuel_page()
	ecam_update_eng_page()
	ecam_update_cruise_page()
	
	if get(Ecam_current_page) == 2 then
        ecam_update_bleed_page()
    elseif get(Ecam_current_page) == 3 then
        ecam_update_press_page()
    elseif get(Ecam_current_page) == 7 then
        ecam_update_apu_page()
    elseif get(Ecam_current_page) == 8 then
        ecam_update_cond_page()
    end
    
end 

local function draw_sts_page_left(messages)
    local default_visible_left_offset = size[2]/2+320
    local visible_left_offset = size[2]/2+320 + 630 * get(Ecam_sts_scroll_page)

    for i,msg in ipairs(messages) do
        if visible_left_offset < 130 then
            set(Ecam_arrow_overflow, 1)
            break
        end
        if visible_left_offset <= default_visible_left_offset then
            msg.draw(visible_left_offset)
        end
        visible_left_offset = visible_left_offset - 35 - msg.bottom_extra_padding
    end
end


local function prepare_sts_page_left()
    x_left_pos        = size[1]/2-410

    messages = {}
    
    -- SPEED LIMIT    
    max_knots, max_mach = ecam_sts:get_max_speed()
    if max_knots ~= 0 then
        table.insert(messages, {
            bottom_extra_padding = 0,
            draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MAX SPD............".. max_knots .." / ." .. max_mach, 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end
            }
        )
    end
    
    -- FLIGHT LEVEL LIMIT
    max_fl = ecam_sts:get_max_fl()
    if max_fl ~= 0 then
        table.insert(messages, {
            bottom_extra_padding = 0,
            draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MAX FL.............".. max_fl .." / MEA", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end
            }
        )
    end
    
    -- APPR PROC
    appr_proc = ecam_sts:get_appr_proc()
    if #appr_proc > 0 then
        table.insert(messages, {
            bottom_extra_padding = 5,
            draw = function(top_position)
                drawUnderlineText(Font_AirbusDUL, x_left_pos, top_position, "APPR PROC:", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            end
            }
        )
        
        for i,msg in ipairs(appr_proc) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "   " .. msg.text, 28, false, false, TEXT_ALIGN_LEFT, msg.color)
                end
                }
            )
        end
        
        -- Extra spacing after APPR PROC
        table.insert(messages, {
            bottom_extra_padding = 15,
            draw = function(top_position) end
            }
        )
    end

    -- PROCEDURES
    procedures = ecam_sts:get_procedures()
    if #procedures > 0 then
       
        for i,msg in ipairs(procedures) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg.text, 28, false, false, TEXT_ALIGN_LEFT, msg.color)
                end
                }
            )
        end
        
        -- Extra spacing after PROCEDURES
        table.insert(messages, {
            bottom_extra_padding = 15,
            draw = function(top_position) end
            }
        )
    end
    
    -- INFORMATION
    information = ecam_sts:get_information()
     if #information > 0 then
       
        for i,msg in ipairs(information) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg, 28, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
                end
                }
            )
        end
        
        -- Extra spacing after INFORMATION
        table.insert(messages, {
            bottom_extra_padding = 15,
            draw = function(top_position) end
            }
        )
    end
    
    -- CANCELLED CAUTION
    cancelled_cautions = ecam_sts:get_cancelled_cautions()
    if #cancelled_cautions > 0 then
       
        table.insert(messages, {
            bottom_extra_padding = 5,
            draw = function(top_position)
                drawUnderlineText(Font_AirbusDUL, x_left_pos+85, top_position, "CANCELLED CAUTION", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            end
            }
        )
        
        for i,msg in ipairs(cancelled_cautions) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    drawUnderlineText(Font_AirbusDUL, x_left_pos, top_position, msg.title, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg.text, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
                end
                }
            )
        end
    end
    
    return messages
end


local function draw_sts_page_right(messages)
    local default_visible_right_offset = size[2]/2+330
    local visible_right_offset = size[2]/2+330 + 650 * get(Ecam_sts_scroll_page)

    for i,msg in ipairs(messages) do
        if visible_right_offset < 130 then
            set(Ecam_arrow_overflow, 1)
            break
        end
        if visible_right_offset <= default_visible_right_offset then
            msg.draw(visible_right_offset)
        end
        visible_right_offset = visible_right_offset - 35 - msg.bottom_extra_padding
    end

    
end

local function prepare_sts_page_right()
    x_right_pos       = size[1]/2 + 140
    x_right_title_pos = size[1]/2 + 200

    messages = {}
    
    -- INOP SYS
    inop_sys = ecam_sts:get_inop_sys()
    if #inop_sys > 0 then
        table.insert(messages, {
            bottom_extra_padding = 5,
            draw = function(top_position)
                drawUnderlineText(Font_AirbusDUL, x_right_title_pos, top_position, "INOP SYS", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            end
            }
        )
        
        for i,msg in ipairs(inop_sys) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_right_pos, top_position, msg, 28, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
                end
                }
            )
        end
        
        -- Extra spacing between INOP SYS and maintenance
        table.insert(messages, {
            bottom_extra_padding = 15,
            draw = function(top_position) end
            }
        )
    end
    
    -- MAINTENANCE
    maintenance = ecam_sts:get_maintenance()
    if #maintenance > 0 then
        table.insert(messages, {
            bottom_extra_padding = 5,
            draw = function(top_position)
                drawUnderlineText(Font_AirbusDUL, x_right_title_pos-20, top_position, "MAINTENANCE", 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
            end
            }
        )
        
        for i,msg in ipairs(maintenance) do
            table.insert(messages, {
                bottom_extra_padding = 0,
                draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_right_pos, top_position, msg, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
                end
                }
            )
        end
    end
    
    return messages
end

local function draw_sts_page()

    set(Ecam_arrow_overflow, 0)

    local left_messages = prepare_sts_page_left()
    draw_sts_page_left(left_messages)
    
    local right_messages = prepare_sts_page_right()
    draw_sts_page_right(right_messages)

    set(EWD_box_sts, 0)

    if ecam_sts:is_normal() then
        sasl.gl.drawText(Font_AirbusDUL, x_left_pos, size[2]/2, "NORMAL", 28, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    if get(Ecam_arrow_overflow) == 1 then
        sasl.gl.drawWideLine ( size[1]/2+121, size[2]/2-270 , size[1]/2+121  , size[2]/2-315 , 8 , ECAM_GREEN )
        sasl.gl.drawTriangle ( size[1]/2+106, size[2]/2-300 , size[1]/2+121 , size[2]/2-330 , size[1]/2+136, size[2]/2-300 , ECAM_GREEN )
    end 
end


--drawing the ECAM
function draw()

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
        --brakes temps--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-75, math.floor(get(Left_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-75, math.floor(get(Right_brakes_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --tire press
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-165, math.floor(get(Left_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-165, math.floor(get(Right_tire_psi)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --brakes indications
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-75, "°C", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-120, "REL", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+280, size[2]/2-165, "PSI", 26, false, false, TEXT_ALIGN_CENTER, ECAM_BLUE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-360, size[2]/2-120, "1", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-200, size[2]/2-120, "2", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+200, size[2]/2-120, "3", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+360, size[2]/2-120, "4", 26, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

        --upper arcs
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 60, 60, left_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 60, 60, right_brake_temp_color)
        --lower arcs
        sasl.gl.drawArc(size[1]/2 - 360, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 - 200, size[2]/2 - 110, 76, 80, 240, 60, left_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 200, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)
        sasl.gl.drawArc(size[1]/2 + 360, size[2]/2 - 110, 76, 80, 240, 60, right_tire_psi_color)

    elseif get(Ecam_current_page) == 11 then    -- F/CTL
        local is_G_ok = get(Hydraulic_G_press) >= 1450
        local is_B_ok = get(Hydraulic_B_press) >= 1450
        local is_Y_ok = get(Hydraulic_Y_press) >= 1450
        set(Ecam_fctl_is_rudder_ok, (is_G_ok or is_Y_ok or is_B_ok) and 1 or 0)
        set(Ecam_fctl_is_aileron_ok, (is_G_ok or is_B_ok) and 1 or 0)
        set(Ecam_fctl_is_elevator_R_ok, (is_Y_ok or is_B_ok) and 1 or 0)
        set(Ecam_fctl_is_elevator_L_ok, (is_G_ok or is_B_ok) and 1 or 0)
        set(Ecam_fctl_is_pitch_trim_ok, (is_G_ok or is_Y_ok) and 1 or 0)

        -- rudder
        Sasl_DrawWideFrame(410, size[2]/2-168, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(438, size[2]/2-168, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(466, size[2]/2-168, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2-164, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-164, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2-164, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- spdbrk
        Sasl_DrawWideFrame(410, size[2]/2+401, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(438, size[2]/2+401, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(466, size[2]/2+401, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-26, size[2]/2+405, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2+405, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+29, size[2]/2+405, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- elevators
        Sasl_DrawWideFrame(174, size[2]/2-193, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(203, size[2]/2-193, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2-189, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

        Sasl_DrawWideFrame(673, size[2]/2-193, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(702, size[2]/2-193, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2-189, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+267, size[2]/2-189, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

        -- pitch trim
        Sasl_DrawWideFrame(535, size[2]/2-12, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(563, size[2]/2-12, 25, 29, 2, 0, is_Y_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+98, size[2]/2-8, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+125, size[2]/2-8, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- ailerons
        Sasl_DrawWideFrame(174, size[2]/2+42, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(203, size[2]/2+42, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-263, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-233, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)

        Sasl_DrawWideFrame(673, size[2]/2+42, 25, 29, 2, 0, is_G_ok and {0,0,0,0} or ECAM_ORANGE)
        Sasl_DrawWideFrame(702, size[2]/2+42, 25, 29, 2, 0, is_B_ok and {0,0,0,0} or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2+46, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+267, size[2]/2+46, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, tostring(math.floor(math.abs(get(Elev_trim_degrees)))) .. "." ..  tostring(math.floor((math.abs(get(Elev_trim_degrees)) - math.floor(math.abs(get(Elev_trim_degrees)))) * 10)), 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
        if get(Elev_trim_degrees) >= 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "UP", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "DN", 30, false, false, TEXT_ALIGN_CENTER, get(THS_avail) == 1 and ECAM_GREEN or ECAM_ORANGE)
        end
    elseif get(Ecam_current_page) == 12 then --STS
        draw_sts_page()
    elseif get(Ecam_current_page) == 13 then --CRUISE
        draw_cruise_page()
    end

    draw_ecam_lower_section()

    -- Update STS box
    set(EWD_box_sts, 0)
    if (not ecam_sts:is_normal()) or (not ecam_sts:is_normal_maintenance() and get(EWD_flight_phase) == 10 ) then
        if get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD_STS and get(Ecam_current_status) ~= ECAM_STATUS_SHOW_EWD then
            set(EWD_box_sts, 1)
        end
    end
end
