----------------------------------------------------------------------------------------------------
-- Electrical Logic file

include('electrical_batteries.lua')
include('electrical_buses.lua')
include('electrical_generators.lua')

local function update_buttons_datarefs()

end

function update()
    update_generators()
    update_buses()
    update_batteries()
    update_buttons_datarefs()
end
