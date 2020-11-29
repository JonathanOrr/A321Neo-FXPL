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
-- File: ECAM_door.lua 
-- Short description: ECAM DOOR page 
-------------------------------------------------------------------------------

include('constants.lua')

PARAM_DELAY    = 0.15 -- Time to filter out the parameters (they are updated every PARAM_DELAY seconds)

local params = {
    cabin_vs       = 0,
    oxygen_psi     = 0,
    last_update    = 0
}

local function get_color_green_blinking()
    if math.floor(get(TIME)) % 2 == 0 then
        return ECAM_GREEN
    else
        return ECAM_HIGH_GREEN
    end
end

local function draw_cabin_vs()
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+327, size[2]-184, math.floor(params.cabin_vs), 36, false, false, TEXT_ALIGN_RIGHT, oxy_color)
end

local function update_param()
    if get(TIME) - params.last_update > PARAM_DELAY then
        params.cabin_vs       = get(Cabin_vs)
        params.oxygen_psi     = get(Oxygen_ckpt_psi)
        params.last_update    = get(TIME)
    end
end

local function draw_oxygen()

    -- TODO fix color
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+250, size[2]-50, "CKPT OXY", 32, false, false, TEXT_ALIGN_CENTER, ECAM_WHITE)

    oxy_color = ECAM_GREEN
    if get(Oxygen_ckpt_psi) < 300 then
        oxy_color = ECAM_ORANGE
    elseif get(Oxygen_ckpt_psi) < 600 then
        oxy_color = get_color_green_blinking()
    end
    sasl.gl.drawText(Font_AirbusDUL, size[1]/2+300, size[2]-85, math.floor(params.oxygen_psi), 36, false, false, TEXT_ALIGN_RIGHT, oxy_color)

    if params.oxygen_psi < 1000 and get(All_on_ground) == 1 then
        sasl.gl.drawWideLine(size[1]/2+210, size[2]-90, size[1]/2+305, size[2]-90, 3, ECAM_ORANGE)
        sasl.gl.drawWideLine(size[1]/2+305, size[2]-60, size[1]/2+305, size[2]-90, 3, ECAM_ORANGE)
    end

    if get(FAILURE_OXY_REGUL_FAIL) == 1 then
        sasl.gl.drawText(Font_AirbusDUL, size[1]/2+270, size[2]-130, "REGUL LO PR", 36, false, false, TEXT_ALIGN_CENTER, ECAM_ORANGE)
    end
end

function draw_door_page()
    update_param()
    draw_oxygen()
    draw_cabin_vs()
end

