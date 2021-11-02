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
position= {0,0,900,900}
size = { 900 , 900 }
fbo = true

include('PFD/PFD_drawing_assets.lua')
include('PFD/PFD_sub_functions/PFD_spd_tape.lua')

function update()
    Cinetracker_HUD:setPosition (0, 0, 408*0.6, 561*0.6)
end

function draw()
    if sasl.getCurrentCameraStatus () == CAMERA_NOT_CONTROLLED then
        return
    end

    PFD_draw_spd_tape(10, -132, PFD.Capt_PFD_table)
    PFD_draw_spd_tape(209, -132, PFD.Fo_PFD_table)
end