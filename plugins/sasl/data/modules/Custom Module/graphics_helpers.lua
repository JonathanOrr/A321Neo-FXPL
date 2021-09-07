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
-- File: graphics_helpers.lua
-- Short description: Miscellaneous functions for drawing and knobs handlers, etc.
-------------------------------------------------------------------------------

-- Generic handler for a float knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_up_float(phase, value_dataref, 0, 3) end)
function Knob_handler_up_float(phase, dataref, min, max, step)
    step = step or 0.5  -- Defualt value
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) + step * get(DELTA_TIME_NO_STOP), min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) + step * get(DELTA_TIME_NO_STOP), min, max))
    end
end

-- Generic handler for a float knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_down_float(phase, value_dataref, 0, 3) end)
function Knob_handler_down_float(phase, dataref, min, max, step) 
    step = step or 0.5  -- Defualt value
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) - step * get(DELTA_TIME_NO_STOP), min, max))
    elseif phase == SASL_COMMAND_CONTINUE then
        set(dataref, Math_clamp(get(dataref) - step * get(DELTA_TIME_NO_STOP), min, max))
    end
end

-- Generic handler for a integer knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_up_int(phase, value_dataref, 0, 3) end)
function Knob_handler_up_int(phase, dataref, min, max) 
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) + 1, min, max))
    end
end

-- Generic handler for a integer knob
-- Usage example: sasl.registerCommandHandler(Knob_dataref, 0, function(phase) Knob_handler_down_int(phase, value_dataref, 0, 3) end)
function Knob_handler_down_int(phase, dataref, min, max) 
    if phase == SASL_COMMAND_BEGIN then
        set(dataref, Math_clamp(get(dataref) - 1, min, max))
    end
end


--drawing functions
function Sasl_DrawWideFrame(x, y, width, height, line_width, align_center_in_out, color)
    if align_center_in_out == 0 then--center of line
        sasl.gl.drawWideLine(x - (line_width / 2), y + height,           x + width + (line_width / 2), y + height,                      line_width, color)
        sasl.gl.drawWideLine(x,                    y + (line_width / 2), x,                            y + (height - (line_width / 2)), line_width, color)
        sasl.gl.drawWideLine(x + width,            y + (line_width / 2), x + width,                    y + (height - (line_width / 2)), line_width, color)
        sasl.gl.drawWideLine(x - (line_width / 2), y,                    x + width + (line_width / 2), y,                               line_width, color)
    elseif align_center_in_out == 1 then
        sasl.gl.drawWideLine(x - line_width,               y + height + (line_width / 2), x + width + line_width,       y + height + (line_width / 2), line_width, color)
        sasl.gl.drawWideLine(x - (line_width / 2),         y,                             x - (line_width / 2),         y + height,                    line_width, color)
        sasl.gl.drawWideLine(x + width + (line_width / 2), y,                             x + width + (line_width / 2), y + height,                    line_width, color)
        sasl.gl.drawWideLine(x - line_width,               y - (line_width / 2),          x + width + line_width,       y - (line_width / 2),          line_width, color)
    elseif align_center_in_out == 2 then
        sasl.gl.drawWideLine(x,                            y + height - (line_width / 2), x + width,                    y + height - (line_width / 2), line_width, color)
        sasl.gl.drawWideLine(x + (line_width / 2),         y + line_width,                x + (line_width / 2),         y + (height - line_width),     line_width, color)
        sasl.gl.drawWideLine(x + width - (line_width / 2), y + line_width,                x + width - (line_width / 2), y + (height - line_width),     line_width, color)
        sasl.gl.drawWideLine(x,                            y + (line_width / 2),          x + width,                    y + (line_width / 2),          line_width, color)
    end
end

function SASL_drawRoundedFrames(x, y, width, height, line_width, round_pixels, color)
    sasl.gl.drawWideLine(x - (line_width / 2) + round_pixels, y + height,           x + width + (line_width / 2) - round_pixels, y + height,                      line_width, color)
    sasl.gl.drawWideLine(x,                    y + (line_width / 2) + round_pixels - 2, x,                            y + (height - (line_width / 2)) - round_pixels + 3, line_width, color)
    sasl.gl.drawWideLine(x + width,            y + (line_width / 2) + round_pixels - 2, x + width,                    y + (height - (line_width / 2)) - round_pixels + 1, line_width, color)
    sasl.gl.drawWideLine(x - (line_width / 2) + round_pixels, y,                    x + width + (line_width / 2) - round_pixels, y,                               line_width, color)
    sasl.gl.drawArc ( x + width - round_pixels, y + (height - (line_width / 2)) - round_pixels + 1, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,0 , 90 ,color )
    sasl.gl.drawArc ( x - (line_width / 2) + round_pixels + 2, y + height - round_pixels, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,90 , 90 ,color )
    sasl.gl.drawArc ( x + round_pixels, y + round_pixels, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,180 , 90 ,color )
    sasl.gl.drawArc ( x + width + (line_width / 2) - round_pixels - 3, y + (line_width / 2) + round_pixels - 2, round_pixels - (line_width / 2), round_pixels + (line_width / 2) ,270 , 90 ,color )
end

function SASL_draw_needle(x, y, radius, angle, thickness, color)
    sasl.gl.drawWideLine(x, y, x + radius * math.cos(math.rad(angle)), y + radius * math.sin(math.rad(angle)), thickness, color)
end

function SASL_draw_needle_adv(x, y, inner_radius, outter_radius, angle, thickness, color)
    sasl.gl.drawWideLine(x + inner_radius * math.cos(math.rad(angle)), y + inner_radius * math.sin(math.rad(angle)), x + outter_radius * math.cos(math.rad(angle)), y + outter_radius * math.sin(math.rad(angle)), thickness, color)
end

--draw images
function SASL_draw_img_center_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x - width / 2, y - height / 2, width, height, color)
end
function SASL_draw_img_xcenter_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x - width / 2, y, width, height, color)
end
function SASL_draw_img_ycenter_aligned(image, x, y, width, height, color)
    sasl.gl.drawTexture(image, x, y - width / 2, width, height, color)
end

function SASL_rotated_center_img_xcenter_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_ycenter_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_center_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_xcenter_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x - width / 2 + center_x_offset, y + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_ycenter_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_rotated_center_img_center_aligned_helper(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    local center_x = x + center_x_offset
    local center_y = y + center_y_offset
    local radius = math.sqrt((center_x - x)^2 + (center_y - y)^2)

    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)

    sasl.gl.drawCircle(x, y, radius, true, {0, 1, 0, 0.25})
    sasl.gl.drawCircle(x, y, 5, true, {1, 0, 0})
    sasl.gl.drawLine(x, y, x + radius*math.cos(-math.rad(get(TIME) * 40 + 90)), y + radius*math.sin(-math.rad(get(TIME) * 40 + 90)), {1, 0, 0})
    sasl.gl.drawRotatedTextureCenter (image, get(TIME) * 40, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function SASL_drawText_rotated(id, x_offset, y_offset, x, y, angle, text, size, isBold, isItalic, alignment, color)
    sasl.gl.drawRotatedText (id, x + x_offset, y + y_offset, x, y, angle, text, size, isBold, isItalic, alignment , color)
end

function SASL_drawSegmentedImg_xcenter_aligned(image, x, y, img_width, img_height, num_positions, position)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x - img_width / num_positions / 2, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, {1, 1, 1})
end

function SASL_drawSegmentedImg(image, x, y, img_width, img_height, num_positions, position)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, {1, 1, 1})
end

function SASL_drawSegmentedImgColored(image, x, y, img_width, img_height, num_positions, position, color)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, color)
end

function SASL_drawSegmentedImgColored_xcenter_aligned(image, x, y, img_width, img_height, num_positions, position, color)
    local recalculated_position = math.floor(position) - 1
    local clamped_position = Math_clamp(recalculated_position, 0, num_positions)

    --draw part of the image
    sasl.gl.drawTexturePart ( image, x - img_width / num_positions / 2, y, img_width / num_positions, img_height, img_width / num_positions * clamped_position, 0, img_width / num_positions, img_height, color)
end

--drawing LED/LCDs
function Draw_LCD_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LCD_backlight_cl = {10/255, 15/255, 25/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LCD_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_green_LED_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local green_backlight_cl = {5/255, 15/255, 10/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, green_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_blue_LED_backlight(x, y, width, hight, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local blue_backlight_cl = {4/255, 6/255, 10/255}

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, blue_backlight_cl[3], brightness)

    sasl.gl.drawRectangle(x, y, width, hight, {blacklight_R, blacklight_G, blacklight_B})
end

function Draw_green_LED_num_and_letter(x, y, string, max_digits, size, alignment, min_brightness_for_backlight, max_brightness_for_backlight, brightness, LED_cl, LED_backlight_cl)
    local LED_cl = LED_cl or {235/255, 200/255, 135/255, brightness}
    local LED_backlight_cl = LED_backlight_cl or {15/255, 20/255, 15/255}

    local backlight_string = ""

    for i = 1, max_digits do
        backlight_string = backlight_string .. 8
    end

    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[3], brightness)

    sasl.gl.drawText(Font_7_digits, x, y, backlight_string, size, false, false, alignment, {blacklight_R, blacklight_G, blacklight_B})
    sasl.gl.drawText(Font_7_digits, x, y, string, size, false, false, alignment, LED_cl)
end

function Draw_white_LED_num_and_letter(x, y, string, max_digits, size, alignment, min_brightness_for_backlight, max_brightness_for_backlight, brightness)
    local LED_cl = {255/255, 255/255, 255/255, brightness}
    local LED_backlight_cl = {15/255, 16/255, 20/255}

    local backlight_string = ""

    if max_digits == 0 then
        backlight_string = ":"
    else
        for i = 1, max_digits do
            backlight_string = backlight_string .. 8
        end
    end
    
    --calculate backlight
    local blacklight_R = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[1], brightness)
    local blacklight_G = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[2], brightness)
    local blacklight_B = Math_rescale(min_brightness_for_backlight, 0, max_brightness_for_backlight, LED_backlight_cl[3], brightness)

    sasl.gl.drawText(Font_7_digits, x, y, backlight_string, size, false, false, alignment, {blacklight_R, blacklight_G, blacklight_B})
    sasl.gl.drawText(Font_7_digits, x, y, string, size, false, false, alignment, LED_cl)
end

--starts at right goes anti-clockwise
function Get_rotated_point_x_pos(x, radius, angle)
    return x + radius * math.cos(math.rad(angle))
end

function Get_rotated_point_y_pos(y, radius, angle)
    return y + radius * math.sin(math.rad(angle))
end

function Get_rotated_point_x_CC_pos(x, radius, angle)
    return x + radius * math.cos(math.rad(90 - angle))
end

function Get_rotated_point_y_CC_pos(y, radius, angle)
    return y + radius * math.sin(math.rad(90 - angle))
end

--starts at top goes clockwise
function Get_rotated_point_x_pos_offset(x, radius, angle, x_offset)
    local recalculated_r = math.sqrt(radius^2 + x_offset^2) * (radius >= 0 and 1 or -1)
    local offset_a = math.deg(math.atan(x_offset / radius))
    local recalculated_a = 90 - angle - offset_a

    return x + recalculated_r * math.cos(math.rad(recalculated_a))
end

function Get_rotated_point_y_pos_offset(y, radius, angle, x_offset)
    local recalculated_r = math.sqrt(radius^2 + x_offset^2) * (radius >= 0 and 1 or -1)
    local offset_a = math.deg(math.atan(x_offset / radius))
    local recalculated_a = 90 - angle - offset_a

    return y + recalculated_r * math.sin(math.rad(recalculated_a))
end

function drawTextCentered(font, x, y, string, size, isbold, isitalic, alignment, colour)
    sasl.gl.drawText (font, x, y - (size/3),string, size, isbold, isitalic, alignment, colour)
end

function drawEmptyTriangle(x1,y1,x2,y2,x3,y3,width,colour)
    sasl.gl.drawWideLine(x1, y1 , x2, y2, width, colour)
    sasl.gl.drawWideLine(x2, y2 , x3, y3, width, colour)
    sasl.gl.drawWideLine(x3, y3 , x1, y1, width, colour)
end

function Init_local_coor(coor_table)
    coor_table.coor = {}
    coor_table.local_coor = {}
    coor_table.curr_coor_idx = 1

    coor_table.setX = function (global_X)
        coor_table.coor[coor_table.curr_coor_idx] = {}
        coor_table.coor[coor_table.curr_coor_idx].x = global_X

        if coor_table.local_coor[coor_table.curr_coor_idx] == nil then
            return coor_table.coor[coor_table.curr_coor_idx].x
        else
            return coor_table.local_coor[coor_table.curr_coor_idx].x
        end
    end

    coor_table.setY = function (global_Y)
        coor_table.coor[coor_table.curr_coor_idx].y = global_Y

        if coor_table.local_coor[coor_table.curr_coor_idx] == nil then
            local output = coor_table.coor[coor_table.curr_coor_idx].y
            coor_table.curr_coor_idx = coor_table.curr_coor_idx + 1
            return output
        else
            local output = coor_table.local_coor[coor_table.curr_coor_idx].y
            coor_table.curr_coor_idx = coor_table.curr_coor_idx + 1
            return output
        end
    end

    coor_table.size = {}
    coor_table.local_size = {}
    coor_table.curr_size_idx = 1

    coor_table.setSize = function (global_Size)
        coor_table.size[coor_table.curr_size_idx] = global_Size

        if coor_table.local_size[coor_table.curr_size_idx] == nil then
            local output = coor_table.size[coor_table.curr_size_idx]
            coor_table.curr_size_idx = coor_table.curr_size_idx + 1
            return output
        else
            local output = coor_table.local_size[coor_table.curr_size_idx]
            coor_table.curr_size_idx = coor_table.curr_size_idx + 1
            return output
        end
    end

    coor_table.scale = function (new_width, new_height)
        local x_factor = new_width / coor_table.width
        local y_factor = new_height / coor_table.height

        if #coor_table.coor == 0 then
            coor_table.curr_coor_idx = 1
            return
        end

        for i = 1, #coor_table.coor do
            coor_table.local_coor[i] = {}
            coor_table.local_coor[i].x = coor_table.coor[i].x * x_factor
            coor_table.local_coor[i].y = coor_table.coor[i].y * y_factor
        end

        for i = 1, #coor_table.size do
            coor_table.local_size[i] = coor_table.size[i] * x_factor
        end

        coor_table.curr_coor_idx = 1
        coor_table.curr_size_idx = 1
    end
end