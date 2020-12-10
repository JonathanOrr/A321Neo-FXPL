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
-- File: GPWS.lua 
-- Short description: GPWS system
-------------------------------------------------------------------------------

function update_mode_1(alt, vs)

    set(GPWS_mode_1_sinkrate, 0)
    set(GPWS_mode_1_pullup,   0)

    if alt < 10 or alt > 2450 then
        set(GPWS_mode_is_active, 0, 1)
        return
    end

    set(GPWS_mode_is_active, 1, 1)

    local max_vs_for_sinkrate = Math_rescale(10,  1000, 2450, 5000, alt)
    if alt > 300 then
        local max_vs_for_pullup   = Math_rescale(300, 1600, 2450, 7000, alt)
        if -vs >= max_vs_for_pullup then
            set(GPWS_mode_1_pullup,   1)
        elseif -vs >= max_vs_for_sinkrate then
            set(GPWS_mode_1_sinkrate, 1)
        end
    else
        local max_vs_for_pullup   = Math_rescale(300, 1600, 10, 1500, alt)
        if -vs >= max_vs_for_pullup then
            set(GPWS_mode_1_pullup,   1)
        elseif -vs >= max_vs_for_sinkrate then
            set(GPWS_mode_1_sinkrate, 1)
        end    
    end

end

function update()

    update_mode_1(get(Capt_ra_alt_ft), get(Capt_VVI))


end
