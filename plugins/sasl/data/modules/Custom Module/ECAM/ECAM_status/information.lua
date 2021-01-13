
function ECAM_status_get_information()
    local messages = {}

    -- ELEC
    if get(XP_Battery_1) == 0 or get(XP_Battery_2) == 0 then
        table.insert(messages, "APU BAT START NOT AVAIL")
    end

    -- FBW
    if get(FBW_total_control_law) == FBW_DIRECT_LAW then
        table.insert(messages, "DIRECT LAW")
        table.insert(messages, "MANEUVER WITH CARE")
        table.insert(messages, "USE SPD BRK WITH CARE")
    end
    if get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW then
        table.insert(messages, "WHEN L/G DN : DIRECT LAW")
        table.insert(messages, "ALTN LAW : PROT LOST")
    end

    if get(FAILURE_gear) == 1 then
        table.insert(messages, "INCREASED FUEL CONSUMP")
    end
    return messages

end
