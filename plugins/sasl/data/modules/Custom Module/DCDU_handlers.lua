
-- Register commands
sasl.registerCommandHandler (DCDU_cmd_msg_plus,   0 , function(phase) dcdu_message_plus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_msg_minus,   0 , function(phase) dcdu_message_minus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_page_plus,   0 , function(phase) dcdu_page_plus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_page_minus,   0 , function(phase) dcdu_page_minus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_left_btm,   0 , function(phase) dcdu_left_btm(phase) end )
sasl.registerCommandHandler (DCDU_cmd_left_top,   0 , function(phase) dcdu_left_top(phase) end )
sasl.registerCommandHandler (DCDU_cmd_right_btm,   0 , function(phase) dcdu_right_btm(phase) end )
sasl.registerCommandHandler (DCDU_cmd_right_top,   0 , function(phase) dcdu_right_top(phase) end )

function dcdu_message_plus(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    local msg_no  = get(DCDU_msg_no)
    local msg_tot = get(DCDU_msgs_total)
    
    if msg_no < msg_tot - 1 then
        set(DCDU_msg_no, msg_no+1)
        set(DCDU_page_no, 0)
    end
    
end

function dcdu_message_minus(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    local msg_no = get(DCDU_msg_no)
    
    if msg_no > 0 then
        set(DCDU_msg_no, msg_no-1)
        set(DCDU_page_no, 0)
    end
    
end

function dcdu_page_plus(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    local page_no  = get(DCDU_page_no)
    local page_tot = get(DCDU_pages_total)
    
    if page_no < page_tot - 1 then
        set(DCDU_page_no, page_no+1)
    end
end

function dcdu_page_minus(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end

    local page_no = get(DCDU_page_no)
    
    if page_no > 0 then
        set(DCDU_page_no, page_no-1)
    end
end

function dcdu_left_btm(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 then
        return -- Well, nothing to do if not messages are present
    end
    
    
end

function dcdu_left_top(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 then
        return -- Well, nothing to do if not messages are present
    end
    
end

function dcdu_right_btm(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 then
        return -- Well, nothing to do if not messages are present
               -- TODO Recall
    end
    
    if current_messages[1].msg_type < 20 then
        -- Switch to "CONFIRM WILCO/ROGER" status
        current_messages[1].msg_type = current_messages[1].msg_type + 10
        if current_messages[1].msg_type > 10 then
            time_to_send = get(TIME)        
        end
        return
    end
    
    if current_messages[1].msg_type > 30 then
        table.remove(current_messages,1)
        set(DCDU_msgs_total, #current_messages)
        set(DCDU_msg_no, math.max(0, get(DCDU_msg_no)))
        set(DCDU_page_no, 0)
        change_occured = true
    end
    
end

function dcdu_right_top(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 then
        return -- Well, nothing to do if not messages are present
    end
    
    
    
end


