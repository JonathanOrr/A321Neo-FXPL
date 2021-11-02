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
-- File: checklist.lua
-- Short description: Checklist widget
-------------------------------------------------------------------------------

size = { 480 , 550 }
position = { 0 , 0 , 480 , 550 }


local UI_BGD_GREY = {0.1568, 0.1803, 0.2039}
local UI_FGD_GREY = {0.1568 * 1.1, 0.1803 * 1.1, 0.2039 * 1.1}

addSearchPath(moduleDirectory .. "/Custom Module/Cinetracker/sub_functions")

components = {
    constants {},
    camera_status {},
    camera_functions {},
    input_functions {},
}


local NAME_ENTRY = createGlobalPropertys("a321neo/cinetracker/name", "new", false, true, false)
local TIME_ENTRY = createGlobalPropertyf("a321neo/cinetracker/time", 0, false, true, false)

--image textures
local camera_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/white_camera.png")
local zigzag_arrow_img = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/checklist/zigzag_arrow.png")

--checklist items
local cinetracks = {
    test_track
}

--[[
local current_view = {
    get(Head_x
table.save(current_view, moduleDirectory .. "/Custom Module/saved_configs/saved_view")

local function load_save_view()
    local saved_view = table.load(moduleDirectory .. "/Custom Module/saved_configs/saved_view")
    if saved_view == nil then
        saved_view = {
            -0.54000002145767,
            2.0099999904633,
            -17.85000038147,
            5.8500003814697,
        }
        table.save(saved_view, moduleDirectory .. "/Custom Module/saved_configs/saved_view")
    end

    set(Head_x,   saved_view[1])
    set(Head_y,   saved_view[2])
    set(Head_z,   saved_view[3])
    set(Head_the, saved_view[4])
end
]]

--checklist function
local function resize_checklist(checklist_array)
    local pos_x
    local pos_y
    local pos_width
    local pos_height

    pos_x, pos_y, pos_width, pos_height = Checklist_window:getPosition()

    local window_height = 20 + 20 + 30 --20px for upper boarder and 20px for lower boarder 30px for the title box

    --resize to fit the checklist
    size[1] = 480
    size[2] = window_height
    Checklist_window:setSizeLimits ( 480 / 2, window_height / 2, 480, window_height)
    Checklist_window:setPosition ( pos_x , pos_y + (pos_height - window_height), 480, window_height)
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    Cinetracker.inputs.mouse.wheel.down(component, x, y, button, parentX, parentY, value)
end

function onMouseDown(component, x, y, button, parentX, parentY)

end

function onKeyDown(component, char, key, shDown, ctrlDown, altOptDown)
    Cinetracker.inputs.keyboard.down(component, char, key, shDown, ctrlDown, altOptDown)
end

function update()
    --change menu item state
    if Cinetracker_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideCinetracker, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideCinetracker, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawRectangle(0, 0, size[1], size[2], UI_BGD_GREY)
    sasl.gl.drawRectangle(10, 10, size[1] - 20, size[2] - 20, UI_FGD_GREY)
end
