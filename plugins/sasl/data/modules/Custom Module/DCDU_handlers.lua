
-- Register commands
sasl.registerCommandHandler (DCDU_cmd_msg_plus,   0 , function(phase) dcdu_message_plus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_msg_minus,   0 , function(phase) dcdu_message_minus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_page_plus,   0 , function(phase) dcdu_page_plus(phase) end )
sasl.registerCommandHandler (DCDU_cmd_page_minus,   0 , function(phase) dcdu_page_minus(phase) end )

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

--DCDU_cmd_msg_plus = createCommand("a321neo/cockpit/DCDU/msg_plus", "Next Message")
--DCDU_cmd_msg_minus = createCommand("a321neo/cockpit/DCDU/msg_minus", "Previous Message")
--DCDU_cmd_page_plus = createCommand("a321neo/cockpit/DCDU/page_plus", "Next Page")
--DCDU_cmd_page_minus = createCommand("a321neo/cockpit/DCDU/page_minus", "Previous Page")
--DCDU_cmd_left_btm = createCommand("a321neo/cockpit/DCDU/left_btm", "Button Bottom-Left")
--D-CDU_cmd_left_top = createCommand("a321neo/cockpit/DCDU/left_top", "Button Top-Left")
--DCDU_cmd_right_btm = createCommand("a321neo/cockpit/DCDU/right_btm", "Button Bottom-Right")
--DCDU_cmd_right_top = createCommand("a321neo/cockpit/DCDU/right_top", "Button Top-Right")
