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

