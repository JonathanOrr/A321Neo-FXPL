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

include('FMGS/functions_online.lua')

local UPDATE_DATA_SEC = 1

function Get_FMGS_data(data)

    local time =  get(TIME)
    if (time - data.FMGS_timer) < UPDATE_DATA_SEC then
        return
    end

    data.FMGS_timer = time

    local ias, mach = FMGS_get_current_target_speed()
    data.target_speed = ias -- Potentially nil
end