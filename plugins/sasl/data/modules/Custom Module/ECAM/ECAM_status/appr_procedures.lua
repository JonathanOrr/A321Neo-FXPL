
function ECAM_status_get_appr_procedures()
    local messages = {}
    if get(FBW_status) < 2 then -- altn or direct law
        table.insert(messages, { text="-FOR LDG.......USE FLAP 3", color=ECAM_BLUE})
        table.insert(messages, { text="-GPWS LDG FLAP 3.......ON", color=ECAM_BLUE})
    end

    if get(FAILURE_gear) == 2 then
        table.insert(messages, { text="-L/G...........GRVTY EXTN", color=ECAM_BLUE})
    end

    return messages
end
