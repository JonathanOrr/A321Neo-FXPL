----------------------------------------------------------------------------------------------------
-- Electrical Logic file

include('electrical_batteries.lua')

local function update_buttons_datarefs()

end

function update()
    update_batteries()
    update_buttons_datarefs()
end
