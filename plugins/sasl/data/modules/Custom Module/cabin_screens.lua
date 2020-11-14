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
-- File: cabin_screens.lua 
-- Short description: 
-------------------------------------------------------------------------------

--a321neo datarefs
local cabin_screen_page = createGlobalPropertyi("a321neo/cabin/screen_page", 0, false, true, false)
local cabin_screen_unit = createGlobalPropertyi("a321neo/cabin/sreen_unit", 0, false, true, false)

--custom timer
local cabin_unit_timer = sasl.createTimer()

function update()
    set(cabin_screen_page, Math_clamp(get(cabin_screen_page), 0, 2))

    --print(sasl.getFMSEntryInfo(sasl.countFMSEntries()-1))

    --unit timmer
    if sasl.getElapsedSeconds(cabin_unit_timer) == 0 then
        sasl.startTimer(cabin_unit_timer)
    elseif sasl.getElapsedSeconds(cabin_unit_timer) > 12 then
        sasl.resetTimer(cabin_unit_timer)
        --change cabin unit system every 12 seconds
        if get(cabin_screen_unit) == 0 then
            set(cabin_screen_unit, 1)
        elseif get(cabin_screen_unit) == 1 then
            set(cabin_screen_unit, 0)
        end
    end

    --calculating different units for the display
    set(Capt_ra_alt_m, get(Capt_ra_alt_ft) / 3.281)
    set(Capt_baro_alt_m, get(Capt_baro_alt_ft) / 3.281)
    set(Distance_traveled_mi, get(Distance_traveled_m) / 1609)
    set(Distance_traveled_km, get(Distance_traveled_m) / 1000)
    set(Ground_speed_kmh, get(Ground_speed_ms) * 3.6)
    set(Ground_speed_mph, get(Ground_speed_ms) * 2.237)

    if get(Engine_1_avail) == 0 or get(Engine_2_avail) == 0 then
        set(cabin_screen_page, 0)
    elseif get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1 then
        set(cabin_screen_page, 1)
    end
end
