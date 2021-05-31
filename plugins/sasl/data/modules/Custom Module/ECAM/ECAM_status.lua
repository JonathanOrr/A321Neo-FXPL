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
-- File: ECAM_status.lua 
-- Short description: ECAM file for the STATUS page 
-------------------------------------------------------------------------------

include('ECAM/ECAM_status/max_speed_fl.lua')
include('ECAM/ECAM_status/appr_procedures.lua')
include('ECAM/ECAM_status/procedures.lua')
include('ECAM/ECAM_status/information.lua')
include('ECAM/ECAM_status/inop_sys.lua')
include('ECAM/ECAM_status/maintain.lua')

ecam_sts = {
    
    -- LEFT PART --
    
    get_max_speed = ECAM_status_get_max_speed,
    get_max_fl = ECAM_status_get_max_fl,
    
    get_appr_proc = ECAM_status_get_appr_procedures,
    
    get_procedures = ECAM_status_get_procedures,
    
    get_information = ECAM_status_get_information,
    
    get_cancelled_cautions = function()
        local messages = {}
        
        for i, m in ipairs(_G.ewd_left_messages_list_cancelled) do
            table.insert(messages, {title = m.text(), text = m.messages[1].text() })
        end
    
        return messages
    end,

    -- RIGHT PART --
  
    get_inop_sys = ECAM_status_get_inop_sys,
    
    get_maintenance = ECAM_status_get_maintain,
    
    -- MISC --
  
    is_normal = function()
        local spd_1, spd_2 = ecam_sts:get_max_speed()
        local max_fl = ecam_sts:get_max_fl()

        return spd_1 == 0 and (max_fl == 0 or max_fl == 999) and #ecam_sts:get_appr_proc() == 0 and
               #ecam_sts:get_information() == 0 and #ecam_sts:get_cancelled_cautions() == 0 and
               #ecam_sts:get_inop_sys() == 0 and #ecam_sts:get_procedures() == 0 and get(is_RAT_out) == 0 
    end,
    
    is_normal_maintenance = function()
        return #ecam_sts:get_maintenance() == 0
    end
    
}

local function drawUnderlineText(font, x, y, text, size, bold, italic, align, color)
    sasl.gl.drawText(font, x, y, text, size, bold, italic, align, color)
    width, height = sasl.gl.measureText(Font_AirbusDUL, text, size, false, false)
    sasl.gl.drawWideLine(x + 3, y - 5, x + width + 3, y - 5, 4, color)
end

function draw_sts_page_left(messages)
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
        if not msg.bottom_extra_padding then
            msg.bottom_extra_padding = 0
        end
        visible_left_offset = visible_left_offset - 35 - msg.bottom_extra_padding
    end
end


function prepare_sts_page_left()
    x_left_pos        = size[1]/2-410

    local messages = {}
    


    -- SPEED LIMIT    
    if get(is_RAT_out) == 1 then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MIN RAT SPEED.........140 KT", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end }
        )
    end

    max_knots, max_mach = ecam_sts:get_max_speed()
    if max_knots ~= 0 then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MAX SPD............".. max_knots .." / ." .. max_mach, 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end }
        )
    end

    -- FLIGHT LEVEL LIMIT
    max_fl = ecam_sts:get_max_fl()
    if max_fl ~= 0 and max_fl ~= 999 then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MAX FL.............".. max_fl .." / MEA", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end }
        )
    end

    if get(Brakes_mode) ~= 1 and get(Brakes_mode) ~= 4 then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MAX BRK PR.........1 000 PSI", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end }
        )
    end

    if get(All_on_ground) == 0 and 
            (get(FBW_total_control_law) == FBW_DIRECT_LAW 
            or get(FAILURE_FCTL_LELEV) == 1 
            or get(FAILURE_FCTL_RELEV) == 1 
            or get(Engine_1_avail) == 0 
            or get(Engine_2_avail) == 0)
            or get(FAILURE_FCTL_THS_MECH) == 1
            or get(FAILURE_FCTL_THS) == 1
            or (get(Hydraulic_Y_press) < 1450 and get(Hydraulic_G_press) < 1450)
            or (get(Hydraulic_Y_press) < 1450 and get(Hydraulic_B_press) < 1450)
            or (get(Hydraulic_B_press) < 1450 and get(Hydraulic_G_press) < 1450)
             then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "MANEUVER WITH CARE", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end }
        )
    end

    if get(Fuel_engine_gravity) == 1 then
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "FUEL GRVTY FEED", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end })
        table.insert(messages, { draw = function(top_position)
                sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, "AVOID NEGATIVE G FACTOR", 28, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)
            end })
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
            table.insert(messages, { draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg.text, 28, false, false, TEXT_ALIGN_LEFT, msg.color)
                end }
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
            table.insert(messages, { draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg.text, 28, false, false, TEXT_ALIGN_LEFT, msg.color)
                end }
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
            table.insert(messages, { draw = function(top_position)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg, 28, false, false, TEXT_ALIGN_LEFT, ECAM_GREEN)
                end }
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
            table.insert(messages, { draw = function(top_position)
                    drawUnderlineText(Font_AirbusDUL, x_left_pos, top_position, msg.title, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
                    sasl.gl.drawText(Font_AirbusDUL, x_left_pos, top_position, msg.text, 28, false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
                end }
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
        if visible_right_offset < default_visible_right_offset or (get(Ecam_sts_scroll_page) == 0 and visible_right_offset == default_visible_right_offset) then
            msg.draw(visible_right_offset)
        end
        visible_right_offset = visible_right_offset - 35 - msg.bottom_extra_padding
    end

    
end

function prepare_sts_page_right()
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

function draw_sts_page()

    sasl.gl.drawTexture(ECAM_STS_bgd_img, 0, 0, 900, 900, {1,1,1})

    if get(FAILURE_DISPLAY_FWC_1) == 1 and get(FAILURE_DISPLAY_FWC_2) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, 50, 450, "STATUS UNAVAIL", 28, false, false, TEXT_ALIGN_LEFT, ECAM_ORANGE)
        return
    end

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

function ecam_update_status_page()
    ecam_update_status_page_maintain()
end
