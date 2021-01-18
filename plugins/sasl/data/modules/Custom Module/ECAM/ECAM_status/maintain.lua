
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

    return messages
end


function ecam_update_status_page_maintain()

end
