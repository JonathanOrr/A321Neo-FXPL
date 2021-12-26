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

local possible_messages = {
    {"PACK 1", "PRESS INSUF"},
    {"PACK 2", "TEMP LOW"},
    {"ZONE CONT", "T35 FAULT"},
    {"CRG HEAT", "TEMP LOW"},
    {"CIDS", "FAP COMM"},
    {"DC BUS TIE", "REL INOP"},
    {"AC GEN", "FREQ IRREG"},
    {"SDCU", "CHAN FAIL"},
    {"SMOKE","REPL SENSOR"},
    {"F/CTL", "ELEV ACT OIL"},
    {"SFCS", "SLATS SLOW"},
    {"FUEL", "VALVE 1.3 INT FAULT"},
    {"QAR", "MEMORY FULL"}, -- Quick Access Recorder
    {"DAR", "UNEXP. REBOOT"}, -- Digital AIDS Recorder
    {"CFDIU", "BACKUP FAIL"},
    {"ACMS", "1225"},
    {"DMC 1/3", ""},
    {"DMC 2/3", ""},
    {"ADR", "RECALIB"},
    {"IR", "DRIFT HIGH"},
    {"AIR BLEED", "PRESS FLUCT"},
    {"APU", "OIL REPL"},
    {"ENG EIU", "CH FAULT"},
    {"ENG EVMU", "SENSOR INACC"}
}

local active_messages = {
}

MCDU.cfds_active_maintain_messages = active_messages

local MTTF = 100 -- Mean time to failure in hour for maintenance

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

    if ENG.dyn[1].oil_qty < 5 then
        table.insert(messages, "ENG 1 OIL")
    end
    
    if ENG.dyn[2].oil_qty < 5 then
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
        table.insert(messages, "TEMP CTL")
    end

    for _,x in ipairs(active_messages) do
        table.insert(messages, x[1])
    end

    return messages
end


function ecam_update_status_page_maintain()
    local delta = get(DELTA_TIME)
    local random = math.random()
    local probability = 1 / (MTTF * 60 * 60) * delta
    if random < probability then
        local el_idx = math.ceil(math.random() * #possible_messages)
        if el_idx == 0 then
            return  -- no more messages
        end
        table.insert(active_messages, {possible_messages[el_idx][1], get(ZULU_hours), get(ZULU_mins), possible_messages[el_idx][2]})
        table.remove(possible_messages, el_idx)
    end
end
