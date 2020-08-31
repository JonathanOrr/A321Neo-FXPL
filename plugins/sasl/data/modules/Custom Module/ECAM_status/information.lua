include('constants.lua')

function ECAM_status_get_information()
    local messages = {}

    -- ELEC
    if get(Battery_1) == 0 or get(Battery_2) == 0 then
        table.insert(messages, "APU BAT START NOT AVAIL")
    end

    -- FBW
    if get(FBW_status) == 0 then
        table.insert(messages, "DIRECT LAW")
        table.insert(messages, "MANEUVER WITH CARE")
        table.insert(messages, "USE SPD BRK WITH CARE")
    end
    if get(FBW_status) == 1 then
        table.insert(messages, "WHEN L/G DN : DIRECT LAW")
        table.insert(messages, "ALTN LAW : PROT LOST")
    end

    if get(FAILURE_gear) == 1 then
        table.insert(messages, "INCREASED FUEL CONSUMP")        
    end


    if get(Nosewheel_Steering_and_AS) == 0 or get(FAILURE_gear) == 2 or MessageGroup_ADR_FAULT_SINGLE:is_active() or MessageGroup_IR_FAULT_SINGLE:is_active() then
        table.insert(messages, "CAT 3 SINGLE ONLY")
    elseif MessageGroup_ADR_FAULT_DOUBLE:is_active() or MessageGroup_ADR_FAULT_TRIPLE:is_active() or MessageGroup_IR_FAULT_DOUBLE:is_active() or MessageGroup_IR_FAULT_TRIPLE:is_active() then
        table.insert(messages, "CAT 1 ONLY")
    end

    return messages

end
