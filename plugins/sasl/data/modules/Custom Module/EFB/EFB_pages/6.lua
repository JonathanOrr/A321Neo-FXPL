-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2021
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
-- File: 6.lua
-- Short description: EFB page 6 ENG MRO related parameters beyond engine type
-- currently PW1100 related stuff like EGT drop, cooling
-------------------------------------------------------------------------------
include("libs/table.save.lua")
include("EFB/efb_systems.lua")
include("EFB/efb_topcat.lua")

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

-- arrays to hold dropdown states
local dropdown_expanded = {false,false}
local dropdown_selected = {1,1}

local dropdown_cooling_time = {"0", "30"}
local dropdown_egt_drop = {"OFF", "ON"}


local function set_cooling_time_config(val_idx)
    local cooling_time = dropdown_cooling_time[val_idx]
    if val_idx == 1 then
        set(ENG_config_cooling_time,0) -- standard behavior starting without cooling on first startup
    else
        set(ENG_config_cooling_time,30) -- maintenance training config, start with 30 sec cooling also on first start
    end
end

local function set_egt_drop_config(val_idx)
    -- EGT drop on startup as of SIL 013 for PW1100 engines
    if val_idx == 1 then
        set(ENG_config_egt_drop,0)
    else
        set(ENG_config_egt_drop,1)
    end

end

local function p_eng_dropdown_buttons(x, y, w, h, values, identifier)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        dropdown_expanded[identifier] = not dropdown_expanded[identifier]
    end)
    for i=1, #values do
        if dropdown_expanded[identifier] then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2 + 5, y - h*i - 14, w-10 + ( x - w/2 + 5), h-2 + ( y - h*i - 14),function ()
                dropdown_selected[identifier] = i
                dropdown_expanded[identifier] = false  -- click on value closes drop down 
                if identifier == 1 then
                    set_cooling_time_config(i)
                else
                    set_egt_drop_config(i)
                end
            end)
        end
    end
    if dropdown_expanded[identifier] then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
            dropdown_expanded[identifier] = false
        end)
    end
end


local function draw_dropdowns()
    draw_dropdown_menu(104, 597, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_cooling_time, dropdown_expanded[1], dropdown_selected[1])
    draw_dropdown_menu(293, 597, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_egt_drop, dropdown_expanded[2], dropdown_selected[2])

end


local function draw_focus_frame()
    -- TODO just example code copied from PERF PAGE to highlight text box
    if focussed_textfield == 7 then
        efb_draw_focus_frames(71, 565, 93, 27)
    elseif focussed_textfield == 8 then
        efb_draw_focus_frames(357, 565, 93, 27)
    end
end


--MOUSE & BUTTONS--
function EFB_execute_page_6_buttons()

    p_eng_dropdown_buttons(104, 599, 90, 28, dropdown_cooling_time, 1)
    p_eng_dropdown_buttons(293, 597, 90, 28, dropdown_egt_drop, 2)
end
--UPDATE LOOPS--
function EFB_update_page_6()
end

--DRAW LOOPS--
function EFB_draw_page_6()
    sasl.gl.drawTexture (EFB_ENG_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
    draw_dropdowns()
end
