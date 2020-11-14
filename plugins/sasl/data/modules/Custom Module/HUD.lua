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
-- File: HUD.lua 
-- Short description: The HUD logic and graphics
-------------------------------------------------------------------------------

local default_head_x = -0.445792
local default_head_y = 2.204
local default_head_z = -17.3736

local actual_alt_ft = 3.281 * get(Elevation_m)

local hud_h_transform = createGlobalPropertyf("a321neo/dynamics/hud/horizontal_transform", 0, false, true, false)
local hud_v_transform = createGlobalPropertyf("a321neo/dynamics/hud/vertical_transform", 0, false, true, false)

function update()
    actual_alt_ft = 3.281 * get(Elevation_m)

    set(hud_h_transform, (get(Head_x)-default_head_x) * 6020)
    set(hud_v_transform, (get(Head_y)-default_head_y - (0.029 * (actual_alt_ft / 50000)) + ((0.007 + 0.018 * (actual_alt_ft / 50000)) * ((get(Head_z) + 17.3736) / -0.3736))) * 6020)
end
