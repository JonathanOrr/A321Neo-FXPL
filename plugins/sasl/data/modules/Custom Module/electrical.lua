----------------------------------------------------------------------------------------------------
-- Electrical Logic file

include('electrical_batteries.lua')
include('electrical_buses.lua')
include('electrical_generators.lua')
include('electrical_tr_and_inv.lua')
include('electrical_misc.lua')


function update()
    update_generators()
    update_buses()
    update_batteries()
    update_trs_and_inv()
    update_misc()
end
