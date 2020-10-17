position= {3187,539,900,900}
size = {900, 900}

include('ECAM_status.lua')
include('ECAM_automation.lua')
include('ECAM_hyd.lua')
include('ECAM_elec.lua')
include('ECAM_fuel.lua')
include('constants.lua')

--local variables
local apu_avail_timer = -1

--sim datarefs

--a32NX datarefs
local apu_needle_state = createGlobalPropertyi("a321neo/cockpit/apu/apu_needle_state", 0, false, true, false) --0xx, 1operational


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

--custom fucntions
local function draw_ecam_lower_section()
    --left section
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-215, size[2]/2-373, math.floor(get(TAT)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2-215, size[2]/2-409, math.floor(get(OTA)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)

    --center section
    --adding a 0 to the front of the time when single digit
    if get(ZULU_hours) < 10 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-408, "0" .. get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-408, get(ZULU_hours), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
    end

    if get(ZULU_mins) < 10 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+25, size[2]/2-408, "0" .. get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    else
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+25, size[2]/2-408, get(ZULU_mins), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    end

    --right section
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+375, size[2]/2-374, math.floor(get(Gross_weight)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
end

function update()
    if get(Apu_N1) < 1 then
        set(apu_needle_state, 0)
    elseif get(Apu_N1) > 1 then
        set(apu_needle_state, 1)
    end

    if get(Engine_1_avail) == 1 then
        left_eng_avail_cl = ECAM_GREEN
    else
        left_eng_avail_cl = ECAM_ORANGE
    end

    if get(Engine_2_avail) == 1 then
        right_eng_avail_cl = ECAM_GREEN
    else
        right_eng_avail_cl = ECAM_ORANGE
    end

    if get(Left_bleed_avil) > 0.1 then
        left_bleed_color = ECAM_GREEN
    else
        left_bleed_color = ECAM_ORANGE
    end

    if get(Right_bleed_avil) > 0.1 then
        right_bleed_color = ECAM_GREEN
    else
        right_bleed_color = ECAM_ORANGE
    end

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

    elseif get(Ecam_current_page) == 2 then --bleed
        --engine avail--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-310, size[2]/2-200, "1", 28, false, false, TEXT_ALIGN_CENTER, left_eng_avail_cl)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+310, size[2]/2-200, "2", 28, false, false, TEXT_ALIGN_CENTER, right_eng_avail_cl)

        --bleed temperature & pressure--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-55, math.floor(get(L_bleed_press)), 28, false, false, TEXT_ALIGN_CENTER, left_bleed_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2-90, math.floor(get(L_bleed_temp)), 28, false, false, TEXT_ALIGN_CENTER, left_bleed_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-55, math.floor(get(R_bleed_press)), 28, false, false, TEXT_ALIGN_CENTER, right_bleed_color)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2-90, math.floor(get(R_bleed_temp)), 28, false, false, TEXT_ALIGN_CENTER, right_bleed_color)

        --compressor temperature--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2+193, math.floor(get(L_compressor_temp)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+193, math.floor(get(R_compressor_temp)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

        --pre-cooler temperature--
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-250, size[2]/2+296, math.floor(get(L_pack_temp)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]/2+296, math.floor(get(R_pack_temp)), 28, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(Ecam_current_page) == 3 then --press
        --pressure info
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-225, size[2]/2+150, math.floor(get(Cabin_delta_psi)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+30, size[2]/2+180, math.floor(get(Cabin_vs)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+290, size[2]/2+150, math.floor(get(Cabin_alt_ft)), 30, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
    elseif get(Ecam_current_page) == 4 then --elec
        draw_elec_page()
    elseif get(Ecam_current_page) == 5 then --hyd
        draw_hydraulic_page()
    elseif get(Ecam_current_page) == 6 then --fuel
        draw_fuel_page()
    elseif get(Ecam_current_page) == 7 then --apu
        --apu gen section--
        if get(Apu_gen_state) == 2 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+257, math.floor(get(Apu_gen_load)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+224, math.floor(get(Apu_gen_volts)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-235, size[2]/2+192, math.floor(get(Apu_gen_hz)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end
        --apu bleed--
        if get(Apu_bleed_state) > 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+270, size[2]/2+186, math.floor(get(Apu_bleed_psi)), 23, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        end
        --needles--
        if get(apu_needle_state) == 1 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-60, math.floor(get(Apu_N1)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2-180, size[2]/2-260, math.floor(get(APU_EGT)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
    elseif get(Ecam_current_page) == 8 then --cond
        --cabin--
        --actual temperature
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-212, size[2]/2+210, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-13, size[2]/2+210, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+172, size[2]/2+210, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --requested temperatures
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-212, size[2]/2+170, math.floor(get(Cockpit_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-13, size[2]/2+170, math.floor(get(Front_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+172, size[2]/2+170, math.floor(get(Aft_cab_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)

        --cargo--
        --actual temperature
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+168, size[2]/2-59, math.floor(get(Aft_cargo_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --requested temperatures
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+168, size[2]/2-92, math.floor(get(Aft_cargo_temp_req)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
    elseif get(Ecam_current_page) == 9 then --door

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
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-29, size[2]/2-165, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]/2-165, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+31, size[2]/2-165, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- spdbrk
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-29, size[2]-47, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+2, size[2]-47, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+31, size[2]-47, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- elevators        
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-265, size[2]/2-190, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-234, size[2]/2-190, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2-190, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+268, size[2]/2-190, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- pitch trim
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+98, size[2]/2-10, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+126, size[2]/2-10, "Y", 30, false, false, TEXT_ALIGN_CENTER, is_Y_ok and ECAM_GREEN or ECAM_ORANGE)

        -- ailerons        
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-265, size[2]/2+45, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-234, size[2]/2+45, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)

        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+237, size[2]/2+45, "G", 30, false, false, TEXT_ALIGN_CENTER, is_G_ok and ECAM_GREEN or ECAM_ORANGE)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+268, size[2]/2+45, "B", 30, false, false, TEXT_ALIGN_CENTER, is_B_ok and ECAM_GREEN or ECAM_ORANGE)


        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-25, size[2]/2-50, tostring(math.floor(math.abs(get(Elev_trim_degrees)))) .. "." ..  tostring(math.floor((math.abs(get(Elev_trim_degrees)) - math.floor(math.abs(get(Elev_trim_degrees)))) * 10)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        if get(Elev_trim_degrees) >= 0 then
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "UP", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        else
            sasl.gl.drawText(Font_AirbusDUL, size[1]/2+45, size[2]/2-50, "DN", 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        end
    elseif get(Ecam_current_page) == 12 then --STS
        draw_sts_page()
    elseif get(Ecam_current_page) == 13 then --CRUISE
        --temperatures 
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-330, size[2]/2-250, math.floor(get(Cockpit_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-190, size[2]/2-250, math.floor(get(Front_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2-70, size[2]/2-250, math.floor(get(Aft_cab_temp)), 30, false, false, TEXT_ALIGN_CENTER, ECAM_GREEN)
        --cab press
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+10, size[2]/2-105, Round(get(Cabin_delta_psi),1), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-185, math.floor(get(Cabin_vs)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]/2-290, math.floor(get(Cabin_alt_ft)), 30, false, false, TEXT_ALIGN_RIGHT, ECAM_GREEN)
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
