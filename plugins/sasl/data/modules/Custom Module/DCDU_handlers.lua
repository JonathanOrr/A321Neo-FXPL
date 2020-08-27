----------------------------------------------------------------------------------------------------
-- DCDU Button handlers
----------------------------------------------------------------------------------------------------

-- Register commands
sasl.registerCommandHandler (DCDU_cmd_msg_plus,  0, function(phase) dcdu_message_plus(phase)  end )
sasl.registerCommandHandler (DCDU_cmd_msg_minus, 0, function(phase) dcdu_message_minus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_page_plus, 0, function(phase) dcdu_page_plus(phase)     end )
sasl.registerCommandHandler (DCDU_cmd_page_minus,0, function(phase) dcdu_page_minus(phase)    end )
sasl.registerCommandHandler (DCDU_cmd_left_btm,  0, function(phase) dcdu_left_btm(phase)      end )
sasl.registerCommandHandler (DCDU_cmd_left_top,  0, function(phase) dcdu_left_top(phase)      end )
sasl.registerCommandHandler (DCDU_cmd_right_btm, 0, function(phase) dcdu_right_btm(phase)     end )
sasl.registerCommandHandler (DCDU_cmd_right_top, 0, function(phase) dcdu_right_top(phase)     end )

function dcdu_message_plus(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if get(DCDU_recall_mode) == 0 and #current_messages == 0 then
        return
    end 
    if get(DCDU_recall_mode) == 1 and #past_messages == 0 then
        return
    end 

    if get(DCDU_recall_mode) == 0 then
        msg = current_messages[get(DCDU_msg_no)+1]

        if msg.msg_status == MESSAGE_STATUS_SENDING then
            return
        end
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

    if get(DCDU_recall_mode) == 0 and #current_messages == 0 then
        return
    end 
    if get(DCDU_recall_mode) == 1 and #past_messages == 0 then
        return
    end 

    
    if get(DCDU_recall_mode) == 0 then
        msg = current_messages[get(DCDU_msg_no)+1]

        if msg.msg_status == MESSAGE_STATUS_SENDING then
            return
        end
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
    
    if get(DCDU_recall_mode) == 0 and #current_messages == 0 then
        return
    end 
    if get(DCDU_recall_mode) == 1 and #past_messages == 0 then
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

    if get(DCDU_recall_mode) == 0 and #current_messages == 0 then
        return
    end 
    if get(DCDU_recall_mode) == 1 and #past_messages == 0 then
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
    
    if #current_messages == 0 or get(DCDU_recall_mode) == 1 then
        return -- Well, nothing to do if not messages are present or in recall mode
    end
    
    msg = current_messages[get(DCDU_msg_no)+1]
    if msg.msg_type == MESSAGE_TYPE_AFFNEG then
        msg.msg_type   = MESSAGE_TYPE_NEGATIVE
        msg.msg_status = MESSAGE_STATUS_CONFIRM
    end
    
    change_occured = true
end

function dcdu_left_top(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 or get(DCDU_recall_mode) == 1 then
        return -- Well, nothing to do if not messages are present
    end
    
    msg = current_messages[get(DCDU_msg_no)+1]
    
    if msg.msg_status == MESSAGE_STATUS_NEW then
        if msg.msg_type == MESSAGE_TYPE_WILCO or msg.msg_type == MESSAGE_TYPE_ROGER then
            -- Switch to "CONFIRM WILCO/ROGER" status
            msg.msg_type = MESSAGE_TYPE_UNABLE
            msg.msg_status = MESSAGE_STATUS_CONFIRM
        end
    elseif msg.msg_status == MESSAGE_STATUS_CONFIRM then
            msg.msg_status = MESSAGE_STATUS_NEW
            msg.msg_type = msg.msg_type_orig
    end
    
    change_occured = true
    
end

local function remove_curr_message()
    i = get(DCDU_msg_no)+1
    msg = current_messages[i]
    msg.msg_status = MESSAGE_STATUS_DONE
    table.insert(past_messages, msg)
    table.remove(current_messages,i)
    set(DCDU_msgs_total, #current_messages)
    set(DCDU_msg_no, math.max(0, i-1-1))
    set(DCDU_page_no, 0)
    change_occured = true
end

function dcdu_right_btm(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if get(DCDU_recall_mode) == 1 then
        set(DCDU_recall_mode, 0)
        set(DCDU_msg_no, 0)
        set(DCDU_msgs_total, #current_messages)
        change_occured = true
        return
    end
    
    if #current_messages == 0 then
        set(DCDU_recall_mode, 1)
        set(DCDU_msg_no, 0)
        set(DCDU_msgs_total, #past_messages)
        change_occured = true
        return -- Well, nothing to do if not messages are present
    end
    
    msg = current_messages[get(DCDU_msg_no)+1]
    
    if msg.msg_status == MESSAGE_STATUS_NEW then
        if msg.msg_type == MESSAGE_TYPE_WILCO or msg.msg_type == MESSAGE_TYPE_ROGER then
            -- Switch to "CONFIRM WILCO/ROGER" status
            msg.msg_status = MESSAGE_STATUS_CONFIRM
        elseif msg.msg_type == MESSAGE_TYPE_AFFNEG then
            msg.msg_type   = MESSAGE_TYPE_AFFIRM
            msg.msg_status = MESSAGE_STATUS_CONFIRM
        elseif msg.msg_type == MESSAGE_TYPE_NORESP then
            remove_curr_message()
        end
    elseif msg.msg_status == MESSAGE_STATUS_CONFIRM then
            msg.msg_status = MESSAGE_STATUS_SENDING
            time_to_send = get(TIME)        
    elseif msg.msg_status == MESSAGE_STATUS_SENT or msg.msg_type == MESSAGE_TYPE_NORESP then
        remove_curr_message()
    end
    
    change_occured = true
    
end

function dcdu_right_top(phase)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if #current_messages == 0 then
        return -- Well, nothing to do if not messages are present
    end
    
    msg = current_messages[get(DCDU_msg_no)+1]
    
    if msg.msg_status == MESSAGE_STATUS_NEW then
        if msg.msg_type == MESSAGE_TYPE_WILCO or msg.msg_type == MESSAGE_TYPE_ROGER or
           msg.msg_type == MESSAGE_TYPE_AFFNEG then
            msg.msg_type   = MESSAGE_TYPE_STDBY
            msg.msg_status = MESSAGE_STATUS_CONFIRM
        end
    end    
    
    change_occured = true
end


