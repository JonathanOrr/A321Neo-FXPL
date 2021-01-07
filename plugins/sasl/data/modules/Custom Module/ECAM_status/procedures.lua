include('constants.lua')

function ECAM_status_get_procedures()
    
    local messages = {}
    
    local appr_p_10_landing = false
    
    if get(FBW_status) < 2 then -- altn or direct law
        if get(FBW_status) == 0 then -- direct law
            table.insert(messages, { text="MAN PITCH TRIM...........USE", color=ECAM_BLUE})
        end
        appr_p_10_landing = true
    end
    
    if get(Nosewheel_Steering_working) == 0 then    -- TODO Check
        appr_p_10_landing = true
    end
    
    if appr_p_10_landing then
        table.insert(messages, {text="APPR SPD...........VREF + 10", color=ECAM_BLUE})
        table.insert(messages, {text="LDG DIST PROC..........APPLY", color=ECAM_BLUE})
    end
    
    --if MessageGroup_ADR_FAULT_TRIPLE:is_active() then
    --    table.insert(messages, {text="RUD WITH CARE ABV 160 KT", color=ECAM_BLUE})
    --end
    
    --if MessageGroup_IR_FAULT_SINGLE:is_active() or MessageGroup_IR_FAULT_DOUBLE:is_active() or MessageGroup_IR_FAULT_TRIPLE:is_active() then
    --    table.insert(messages, {text="IR MAY BE AVAIL IN ATT", color=ECAM_WHITE})     
    --end
    
    
    return messages
end
