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
-- File: rendering.lua 
-- Short description: Draw & Render helpers
-------------------------------------------------------------------------------

local function draw_dat(mcdu_data, dat, draw_size, disp_x, disp_y, disp_text_align)
    if dat.txt == nil then
        return
    end
    local disp_text = tostring(dat.txt):upper()
    dat.col = dat.col or ECAM_WHITE --default colour
    local disp_color = dat.col

    -- is there a custom size
    local disp_size = dat.size or draw_size

    -- text size 
    local disp_text_size = MCDU_DISP_TEXT_SIZE[disp_size]

    -- replace { with the box
    local text = ""
    for j = 1,#disp_text do
        if disp_text:sub(j,j) == "{" then
            text = text .. "□"
        else
            text = text .. disp_text:sub(j,j)
        end
    end
    disp_text = text

    -- now draw it!
    table.insert(mcdu_data.draw_lines, {font = disp_size, disp_x = disp_x, disp_y = disp_y, disp_text = disp_text, disp_text_size = disp_text_size, disp_text_align = disp_text_align, disp_color = disp_color})
end


function mcdu_update_render(mcdu_data)
    -- clear all line which need to be drawn
    mcdu_data.draw_lines = {}
    mcdu_data.draw_lines_itr = 0

    for i,draw_row in ipairs(MCDU_DIV_ROW) do
        for j,draw_size in ipairs(MCDU_DIV_SIZE) do
            local draw_act_row = ((i - 1) * 2) + (j - 1) -- draw actual row

            for k,draw_align in ipairs(MCDU_DIV_ALIGN) do

                -- spacings
                local disp_x = draw_get_x(k)
                local disp_y = draw_get_y(draw_act_row)

                -- text alignment
                local disp_text_align = MCDU_DISP_TEXT_ALIGN[draw_align]

                -- text data
                local dat_full = mcdu_data.dat[draw_size][draw_align][draw_row]
                if dat_full[1] == nil then
                    draw_dat(mcdu_data, dat_full, draw_size, disp_x, disp_y, disp_text_align)
                else
                    for l,dat in pairs(dat_full) do
                        draw_dat(mcdu_data, dat, draw_size, disp_x, disp_y, disp_text_align)
                    end
                end
            end
        end
    end

    --draw title line
    if mcdu_data.title[1] == nil then
        draw_dat(mcdu_data, mcdu_data.title, MCDU_LARGE, draw_get_x(1.5), draw_get_y(-1), TEXT_ALIGN_CENTER)
    else
        for l,dat in pairs(mcdu_data.title) do
            draw_dat(mcdu_data, dat, MCDU_LARGE, draw_get_x(1.5), draw_get_y(-1), TEXT_ALIGN_CENTER)
        end
    end
end

