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
-- File: tcas.lua
-- Short description: TCAS
-------------------------------------------------------------------------------

local MAX_H_RANGE = 100  -- NM radius
local MAX_V_RANGE = 9900 -- Feet +/-

local function update_status()

    set(TCAS_xplane_mode, 0)


    if get(TCAS_master) == 0 or get(TCAS_mode) == 0 then
        set(TCAS_actual_mode, TCAS_MODE_OFF)
        return
    end

    local failure_cond = get(FAILURE_TCAS) == 1
          or (get(FAILURE_ATC_1) == 1 and get(TCAS_atc_sel) == 1)
          or (get(FAILURE_ATC_2) == 1 and get(TCAS_atc_sel) == 2)
          or get(AC_bus_1_pwrd) == 0

    if failure_cond then
        set(TCAS_actual_mode, TCAS_MODE_FAULT)
        return
    end
    
    set(TCAS_xplane_mode, 2)
    
    if get(TCAS_mode) == 2 then
        local radio_altitude = get(TCAS_atc_sel) == 1 and get(Capt_ra_alt_ft) or get(Fo_ra_alt_ft)
        local ta_only_cond = get(GPWS_mode_stall) == 1              -- TODO Add WINDSHEAR
                          or get(GPWS_mode_1_pullup) == 1
                          or get(GPWS_mode_2_pullup) == 1
                          or get(GPWS_pred_terr_pull) == 1
                          or get(GPWS_pred_obst_pull) == 1

       if not ta_only_cond and radio_altitude > 1000 then
            set(TCAS_actual_mode, TCAS_MODE_TARA)
            return
       end
    end

    set(TCAS_actual_mode, TCAS_MODE_TA)
end

function update()
    update_status()
end
