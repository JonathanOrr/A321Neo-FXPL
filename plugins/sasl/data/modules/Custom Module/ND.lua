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
-- File: ND.lua 
-- Short description: main Logic/Graphic code for ND display
-------------------------------------------------------------------------------

position = {1030, 3166, 900, 900}
size = {900, 900}

include('constants.lua')
include('display_common.lua')


function draw()

    if display_special_mode(size, Capt_nd_valid) then
        return
    end


    --sasl.gl.drawFrame(0, 0, 385, 380, {1,0,1})
    --sasl.gl.drawText(B612MONO_regular, 50, 50, "TEST", 10, false, false, TEXT_ALIGN_LEFT, ECAM_BLUE)

    if get(AC_ess_shed_pwrd) == 0 then   -- TODO This should be fixed when screens move around
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS_SHED, 0.26, 0.26)   -- 30W (just hypothesis)

end

sasl.registerCommandHandler (ND_Capt_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Capt_Terrain, 1 - get(ND_Capt_Terrain)) end end)
sasl.registerCommandHandler (ND_Fo_terrain_toggle, 0, function(phase) if phase == SASL_COMMAND_BEGIN then set(ND_Fo_Terrain, 1 - get(ND_Fo_Terrain)) end end)

local function update_buttons()
    pb_set(PB.mip.terr_nd_capt, get(ND_Capt_Terrain) == 1, false)
    pb_set(PB.mip.terr_nd_fo,   get(ND_Fo_Terrain) == 1, false)
end

function update()

    update_buttons()

end
