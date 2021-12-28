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
-- File: graphics_mouse.lua
-- Short description: PLAN mode mouse management file
-------------------------------------------------------------------------------

local image_cursor_capt = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/cursor-capt.png") 
local image_cursor_fo   = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/ND/cursor-fo.png") 

function onMouseMove(component, x, y,button, parentX, parentY)

    local diff_x = 0
    local diff_y = 0

    if component.nd_data.plan_mouse_x then
        diff_x = component.nd_data.plan_mouse_x - x
        diff_y = component.nd_data.plan_mouse_y - y
    end

    component.nd_data.plan_mouse_x = x
    component.nd_data.plan_mouse_y = y

    if component.nd_data.plan_holding and component.nd_data.config.mode == ND_MODE_PLAN then
        local speed =  20000 / 2^(component.nd_data.config.range-1)
        component.nd_data.plan_ctr_lat = component.nd_data.plan_ctr_lat + diff_y/speed
        component.nd_data.plan_ctr_lon = component.nd_data.plan_ctr_lon + diff_x/speed
        component.nd_data.plan_holding = false
    end
end

function onMouseDown ( component , x , y , button , parentX , parentY )

    if component.nd_data.config.range > ND_RANGE_ZOOM_2 then
        return false
    end

    if button == MB_RIGHT then
        if not component.nd_data.plan_mouse_menu_visible then
            component.nd_data.plan_mouse_menu_visible = true
            component.nd_data.plan_mouse_menu_x = x
            component.nd_data.plan_mouse_menu_y = y
        else
            component.nd_data.plan_mouse_menu_visible = false
        end
    end
    if button == MB_LEFT then
        if component.nd_data.plan_mouse_menu_visible then
            component.nd_data.plan_mouse_menu_clicked = true
        end
    end
    return true
end
function onMouseUp ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then

    end
    return true
end
function onMouseHold ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT and component.nd_data.config.mode == ND_MODE_PLAN then
        component.nd_data.plan_holding = true
    end
    return true
end

local function draw_trigger_action(data, item)
    if item == 0 and data.config.range < ND_RANGE_ZOOM_2 then
        table.insert(data.poi.cross, {x=data.plan_mouse_menu_x, y=data.plan_mouse_menu_y} )
    elseif item == 1 and data.config.range < ND_RANGE_ZOOM_2 then
        table.insert(data.poi.flag,  {x=data.plan_mouse_menu_x, y=data.plan_mouse_menu_y} )
    elseif item == 2 and data.config.range < ND_RANGE_ZOOM_2 then
        data.poi.cross = {}
    elseif item == 3 and data.config.range < ND_RANGE_ZOOM_2 then
        data.poi.flag  = {}
    elseif item == 4 and nd_data.config.mode == ND_MODE_PLAN then
        data.plan_ctr_lat = data.inputs.plane_coords_lat
        data.plan_ctr_lon = data.inputs.plane_coords_lon
    end
end

local function draw_menu(data)

    if data.plan_mouse_menu_visible and data.plan_mouse_menu_x ~= nil then

        local x = data.plan_mouse_menu_x
        local y = data.plan_mouse_menu_y
        sasl.gl.drawRectangle (x, y-215, 300, 210, UI_DARK_GREY)
        Sasl_DrawWideFrame (x+1, y-214, 298, 208, 2, 1, ECAM_WHITE)
        
        local color = ECAM_WHITE
        if data.config.range >= ND_RANGE_ZOOM_2 then
            color = {0.6,0.6,0.6}
        end
        
        sasl.gl.drawText(Font_AirbusDUL, x+10, y-40, "ADD CROSS", 28, false, false, TEXT_ALIGN_LEFT, color)
        sasl.gl.drawText(Font_AirbusDUL, x+10, y-80, "ADD FLAG", 28, false, false, TEXT_ALIGN_LEFT, color)
        sasl.gl.drawText(Font_AirbusDUL, x+10, y-120, "ERASE ALL CROSSES", 28, false, false, TEXT_ALIGN_LEFT, color)
        sasl.gl.drawText(Font_AirbusDUL, x+10, y-160, "ERASE ALL FLAGS", 28, false, false, TEXT_ALIGN_LEFT, color)
    
        local color = ECAM_WHITE
        if nd_data.config.mode ~= ND_MODE_PLAN then
            color = {0.6,0.6,0.6}
        end
        
        sasl.gl.drawText(Font_AirbusDUL, x+10, y-200, "CENTER ON ACFT", 28, false, false, TEXT_ALIGN_LEFT, color)
        
        if data.plan_mouse_x ~= nil then
            if data.plan_mouse_x > x and data.plan_mouse_x < x + 300 and 
               data.plan_mouse_y < y-5 and data.plan_mouse_y > y-200 then

                local item = math.floor((y-data.plan_mouse_y) / 40)

                Sasl_DrawWideFrame (x+5, y-40-40*item-10, 290, 40, 4, 1, ECAM_BLUE)

                if data.plan_mouse_menu_clicked then
                    draw_trigger_action(data, item)
                end
            end
            if data.plan_mouse_menu_clicked then
                data.plan_mouse_menu_clicked = false
                data.plan_mouse_menu_visible = false
            end
        end

    end

end

function draw_mouse(data)

    if data.config.range > ND_RANGE_ZOOM_2 then
        return
    end

    draw_menu(data)

    if data.plan_mouse_x ~= nil and not data.plan_holding then
        local cursor_size_w = 93
        local cursor_size_h = 115

        if data.id == ND_CAPT then
            sasl.gl.drawTexture(image_cursor_capt, data.plan_mouse_x-cursor_size_w/2, data.plan_mouse_y-cursor_size_h/2, cursor_size_w, cursor_size_h, ECAM_MAGENTA)
        else
            sasl.gl.drawTexture(image_cursor_fo, data.plan_mouse_x-cursor_size_w/2, data.plan_mouse_y-cursor_size_h/2, cursor_size_w, cursor_size_h, ECAM_MAGENTA)
        end
    end


end
