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

require "Cinetracker.libs.Vector"
addSearchPath(moduleDirectory .. "/Custom Module/Cinetracker/sub_functions")

size = { 480, 550 }
position = { 0, 0, 480, 550 }

-- player camera rotation
CAMERAZOOM = 1
userRot = Vector3(0, 0, 0)
smoothUserRot = Vector3(0, 0, 0)

components = {
    camera_functions {}
}

local prevCurX, prevCurY = 0, 0
function onMouseDown(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
        prevCurX, prevCurY = x, y -- avoid sudden view change
    end

    return true
end

function onMouseHold(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
        local dX, dY = (x - prevCurX) / CAMERAZOOM, (y - prevCurY) / CAMERAZOOM
        prevCurX, prevCurY = x, y
        userRot.x = Math_clamp_heading_sum(userRot.x, dY, 270, 90)
        userRot.y = (userRot.y + dX) % 360
    end

    return true
end

function onMouseUp(component, x, y, button, parentX, parentY)
    if button == MB_LEFT then
    end

    return true
end

function onMouseWheel(component, x, y, button, parentX, parentY, value)
    CAMERAZOOM = Math_clamp(CAMERAZOOM + value, 1, 3)

    return true
end

function update()
    --change menu item state
    if Cinetracker_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideCinetracker, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideCinetracker, MENU_UNCHECKED)
    end
    if sasl.getCurrentCameraStatus() == CAMERA_CONTROLLED_UNTIL_VIEW_CHANGE then
        Cinetracker_window:setIsVisible(true)
    else
        Cinetracker_window:setIsVisible(false)
    end
    if not Cinetracker_window:isVisible() then return end

    local x, y, width, height = sasl.windows.getScreenBoundsGlobal()
    size = { width, height }
    Cinetracker_window:setSizeLimits(width, height, width, height)
    Cinetracker_window:setPosition(x, y, width, height)
end

function draw()
    Sasl_DrawWideFrame(0, 0, size[1], size[2], 10, 2, ECAM_RED)
end
