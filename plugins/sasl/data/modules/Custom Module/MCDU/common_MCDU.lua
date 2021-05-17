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
-- File: common_MCDU.lua 
-- Short description: Various functions for MCDU
-------------------------------------------------------------------------------
include('MCDU/constants.lua')

--line spacing
local MCDU_DRAW_OFFSET  = {x = 15, y = 420}   -- starting offset for line drawing
local MCDU_DRAW_SPACING = {x = 530, y = -37} -- change in offset per line drawn


function draw_get_x(align)
    return MCDU_DRAW_OFFSET.x + (MCDU_DRAW_SPACING.x * (align - 1))
end

function draw_get_y(line)
    return MCDU_DRAW_OFFSET.y + (MCDU_DRAW_SPACING.y * (line - 1))
end

function init_data(mcdu_data, id)
    mcdu_data.id = id
    mcdu_data.draw_lines = {}
    mcdu_data.entry = ""
    mcdu_data.entry_cache = ""
    mcdu_data.dat = {}
    mcdu_data.title = ""
    mcdu_data.messages = {}
    mcdu_data.message_showing = false

    for i,size in ipairs(MCDU_DIV_SIZE) do
	    mcdu_data.dat[size] = {}
	    for j,align in ipairs(MCDU_DIV_ALIGN) do
		    mcdu_data.dat[size][align] = {}
	    end
    end
end

function common_draw(mcdu_data)
    Draw_LCD_backlight(0, 0, size[1], size[2], 0.5, 1, get(mcdu_data.id == 1 and MCDU_1_brightness_act or MCDU_2_brightness_act))

    --draw all horizontal lines
    for i,line in ipairs(mcdu_data.draw_lines) do
        if line.font == "l" then
            font = Font_AirbusDUL
        else
            font = Font_AirbusDUL_small
        end
        sasl.gl.drawText(font, line.disp_x, line.disp_y, line.disp_text, line.disp_text_size, false, false, line.disp_text_align, line.disp_color)
    end

    --draw scratchpad
    sasl.gl.drawText(Font_AirbusDUL, draw_get_x(1), draw_get_y(12), mcdu_data.entry, MCDU_DISP_TEXT_SIZE[MCDU_L], false, false, TEXT_ALIGN_LEFT, ECAM_WHITE)
end


function common_update(mcdu_data)
    
    if #mcdu_data.messages > 0 and not mcdu_data.message_showing then
        mcdu_data.entry_cache = mcdu_data.entry
        mcdu_data.entry = mcdu_data.messages[#mcdu_data.messages]:upper()
        mcdu_data.message_showing = true
        table.remove(mcdu_data.messages)
    end

end
