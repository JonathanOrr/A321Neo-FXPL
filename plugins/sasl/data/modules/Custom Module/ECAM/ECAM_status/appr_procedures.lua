
function ECAM_status_get_appr_procedures()
    local messages = {}
    if get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_DIRECT_LAW then -- altn or direct law
        table.insert(messages, { text="-FOR LDG.......USE FLAP 3", color=ECAM_BLUE})
        table.insert(messages, { text="-GPWS LDG FLAP 3.......ON", color=ECAM_BLUE})
    end

    if get(FAILURE_gear) == 2 then
        table.insert(messages, { text="-L/G...........GRVTY EXTN", color=ECAM_BLUE})
    end

    return messages
end
