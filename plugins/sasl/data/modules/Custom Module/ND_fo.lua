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
-- File: ND_fo.lua
-- Short description: F/O ND display (logic is in ND.lua)
-------------------------------------------------------------------------------

position = {2030, 3166, 900, 900}
size = {900, 900}

include('constants.lua')

function draw()

    Draw_LCD_backlight(0, 0, 900, 900, 0.5, 1, get(Fo_ND_brightness_act))

    sasl.gl.drawText(Font_AirbusDUL, size[1]/2, size[2]/2, "F/O ND", 40, false, false, TEXT_ALIGN_CENTER, ECAM_RED)
    
    
    sasl.gl.drawRectangle(0, 0, 900, 900, {0, 0, 0, 1 - get(Fo_ND_brightness_act)})
end
