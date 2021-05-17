MCDU_Page = {id=0}

function MCDU_Page:new (o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
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

