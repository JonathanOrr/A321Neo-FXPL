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
-- File: base.lua 
-- Short description: Base class
-------------------------------------------------------------------------------

MCDU_Page = {id=0}

function MCDU_Page:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MCDU_Page:exec_render(mcdu_data)
    self:render(mcdu_data)
    mcdu_update_render(mcdu_data)
end

function MCDU_Page:render(mcdu_data)
    assert(false, "Render method is abstract")
end

function MCDU_Page:L1(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:L2(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:L3(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:L4(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:L5(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:L6(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R1(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R2(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R3(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R4(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R5(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:R6(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:Slew_Left(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:Slew_Right(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:Slew_Up(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:Slew_Down(mcdu_data)
    -- Do nothing
    table.insert(mcdu_data.messages, "NOT ALLOWED")
end

function MCDU_Page:press_button(mcdu_data, val)
    if val == "L1" then
        self:L1(mcdu_data)
    elseif val == "L2" then
        self:L2(mcdu_data)
    elseif val == "L3" then
        self:L3(mcdu_data)
    elseif val == "L4" then
        self:L4(mcdu_data)
    elseif val == "L5" then
        self:L5(mcdu_data)
    elseif val == "L6" then
        self:L6(mcdu_data)
    elseif val == "R1" then
        self:R1(mcdu_data)
    elseif val == "R2" then
        self:R2(mcdu_data)
    elseif val == "R3" then
        self:R3(mcdu_data)
    elseif val == "R4" then
        self:R4(mcdu_data)
    elseif val == "R5" then
        self:R5(mcdu_data)
    elseif val == "R6" then
        self:R6(mcdu_data)
    else
        assert(false, "Uknown button")
    end
    self:exec_render(mcdu_data)
end


function MCDU_Page:set_line(mcdu_data, align, idx, text, size, color)
    size  = size  or MCDU_LARGE
    align = align or MCDU_LEFT
    color = color or ECAM_WHITE
    
    mcdu_data.dat[size][align][idx] = {txt = text, col = color}
end

function MCDU_Page:set_title(mcdu_data, text, color)
    color = color or ECAM_WHITE
    mcdu_data.title = {txt = text, col = color}
end

