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

function ECAM_status_get_maintain()
    local messages = {}

    -- ADIRS
    if get(Hydraulic_Y_qty) < 0.8 then
        table.insert(messages, "HYD Y RSRV")
    end
    if get(Hydraulic_B_qty) < 0.76 then
        table.insert(messages, "HYD B RSRV")
    end
    if get(Hydraulic_G_qty) < 0.82 then
        table.insert(messages, "HYD G RSRV")
    end

    if get(Eng_1_OIL_qty) < 5 then
        table.insert(messages, "ENG 1 OIL")
    end
    
    if get(Eng_2_OIL_qty) < 5 then
        table.insert(messages, "ENG 2 OIL")
    end
    
    if get(FAILURE_AIRCOND_FAN_FWD) == 1 then
        table.insert(messages, "CAB FAN FWD")
    end
    
    if get(FAILURE_AIRCOND_FAN_AFT) == 1 then
        table.insert(messages, "CAB FAN AFT")
    end

    if get(FAILURE_ENG_FADEC_CH1, 1) == 1 or get(FAILURE_ENG_FADEC_CH2, 1) == 1 then
        table.insert(messages, "ENG 1 FADEC")
    end

    if get(FAILURE_ENG_FADEC_CH1, 2) == 1 or get(FAILURE_ENG_FADEC_CH2, 2) == 1 then
        table.insert(messages, "ENG 2 FADEC")
    end

    if get(FAILURE_AIRCOND_REG_1) == 1 or get(FAILURE_AIRCOND_REG_2) == 1 then
        table.insert(messages, "COND REGUL")
    end

    return messages
end


function ecam_update_status_page_maintain()

end
