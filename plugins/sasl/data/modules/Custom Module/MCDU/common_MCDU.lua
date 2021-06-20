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
include('MCDU/inputs.lua')
include('MCDU/handlers.lua')
include('MCDU/format.lua')
include('MCDU/rendering.lua')
include('FMGS/functions.lua')

include('MCDU/pages/include_all.lua')   -- This must be the last

--line spacing
local MCDU_DRAW_OFFSET  = {x = 25, y = 420}   -- starting offset for line drawing
local MCDU_DRAW_SPACING = {x = 520, y = -37} -- change in offset per line drawn


function draw_get_x(align)
    return MCDU_DRAW_OFFSET.x + (MCDU_DRAW_SPACING.x * (align - 1))
end

function draw_get_y(line)
    return MCDU_DRAW_OFFSET.y + (MCDU_DRAW_SPACING.y * (line - 1))
end

function init_data(mcdu_data, id)
    mcdu_data.id = id
    mcdu_data.draw_lines = {}
    mcdu_data.entry = {text="", color=nil}
    mcdu_data.entry_cache = {text="", color=nil}
    mcdu_data.dat = {}
    mcdu_data.title = {}
    mcdu_data.messages = {}
    mcdu_data.message_showing = false
    mcdu_data.curr_page = 0
    mcdu_data.v = {}    -- Various values used in MCDU
    mcdu_data.last_update = get(TIME)
    mcdu_data.page_data = {}    -- Custom data for each page

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
        if line.font == MCDU_LARGE then
            font = Font_MCDU
        else
            font = Font_MCDUSmall
        end

        sasl.gl.drawText(font, line.disp_x, line.disp_y, line.disp_text, line.disp_text_size, false, false, line.disp_text_align, line.disp_color)
    end

    --draw scratchpad
    if mcdu_data.entry.text ~= "" then
        mcdu_data.entry.color = mcdu_data.entry.color or ECAM_WHITE
        sasl.gl.drawText(Font_MCDU, draw_get_x(1), draw_get_y(12), mcdu_data.entry.text, MCDU_DISP_TEXT_SIZE[MCDU_LARGE], false, false, TEXT_ALIGN_LEFT, mcdu_data.entry.color)
    end

    if mcdu_data.lr_arrows then
        sasl.gl.drawTexture(MCDU_lr_arrows, 505, 495, 40, 16, 1, 1, 1)
    end
    if mcdu_data.ud_arrows_btm then
        sasl.gl.drawTexture(MCDU_ud_arrows, 500, 20, 38, 26, 1, 1, 1)
    end
end

function mcdu_clearall(mcdu_data)
    mcdu_data.title = {txt = "", col = ECAM_WHITE, size = nil}
    mcdu_data.lr_arrows = false
    mcdu_data.ud_arrows_btm = false
    mcdu_data.num_pages = nil
    for i,size in ipairs(MCDU_DIV_SIZE) do
        for j,align in ipairs(MCDU_DIV_ALIGN) do
            for k,row in ipairs(MCDU_DIV_ROW) do
                mcdu_data.dat[size][align][row] = {txt = nil, col = ECAM_WHITE, size = nil}
            end
        end
    end
end

function mcdu_open_page(mcdu_data, id)
    mcdu_clearall(mcdu_data)
    mcdu_data.curr_page = id
    assert(mcdu_pages[id] ~= nil, "Non existent page: " .. id)
    mcdu_pages[id]:exec_render(mcdu_data)
end

function mcdu_force_update(mcdu_data)
    mcdu_clearall(mcdu_data)
    mcdu_pages[mcdu_data.curr_page]:exec_render(mcdu_data)
end

function mcdu_reset_fpln(mcdu_data)
    mcdu_pages[603].curr_page = 1
    mcdu_pages[604].curr_page = 1
end

--define custom functionalities
function mcdu_send_message(mcdu_data, message, color)

    color = color or ECAM_WHITE

    if #mcdu_data.messages > 0 and mcdu_data.messages[#mcdu_data.messages].text == message.text then
        return
    end
    table.insert(mcdu_data.messages, {text=message, color=color})
end

function common_update(mcdu_data)
    
    if mcdu_data.curr_page == 0 then
        mcdu_open_page(mcdu_data, debug_mcdu_startup_page)
    end
    
    if #mcdu_data.messages > 0 then
        if not mcdu_data.message_showing then
            mcdu_data.entry_cache = mcdu_data.entry
        end
        mcdu_data.entry = mcdu_data.messages[#mcdu_data.messages]
        mcdu_data.message_showing = true
    end
    
    if get(TIME) - mcdu_data.last_update > 1 then
        mcdu_force_update(mcdu_data)
    end

end

MCDU.send_message = function(message, color)
    mcdu_send_message(MCDU.captain_side_data, message, color)
    --mcdu_send_message(MCDU.fo_side_data, message) TODO
end
MCDU.force_update = function()
    mcdu_force_update(MCDU.captain_side_data)
    --mcdu_force_update(MCDU.fo_side_data, message) TODO
end
MCDU.reset_fpln = function()
    mcdu_reset_fpln(MCDU.captain_side_data)
    --mcdu_reset_fpln(MCDU.fo_side_data, message) TODO
end