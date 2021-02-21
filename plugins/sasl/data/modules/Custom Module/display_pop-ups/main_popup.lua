sasl.registerCommandHandler(Pop_out_CAPT_PFD, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = CAPT_PFD_window:getPosition()
        CAPT_PFD_window:setPosition ( window_x , window_y , 500, 500)
        CAPT_PFD_window:setIsVisible(not CAPT_PFD_window:isVisible())
    end
end)

sasl.registerCommandHandler(Pop_out_FO_PFD, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = FO_PFD_window:getPosition()
        FO_PFD_window:setPosition ( window_x , window_y , 500, 500)
        FO_PFD_window:setIsVisible(not FO_PFD_window:isVisible())
    end
end)

sasl.registerCommandHandler(Pop_out_CAPT_ND, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = CAPT_ND_window:getPosition()
        CAPT_ND_window:setPosition ( window_x , window_y , 500, 500)
        CAPT_ND_window:setIsVisible(not CAPT_ND_window:isVisible())
    end
end)

sasl.registerCommandHandler(Pop_out_FO_ND, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = FO_ND_window:getPosition()
        FO_ND_window:setPosition ( window_x , window_y , 500, 500)
        FO_ND_window:setIsVisible(not FO_ND_window:isVisible())
    end
end)

sasl.registerCommandHandler(Pop_out_EWD, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = EWD_window:getPosition()
        EWD_window:setPosition ( window_x , window_y , 500, 500)
        EWD_window:setIsVisible(not EWD_window:isVisible())
    end
end)

sasl.registerCommandHandler(Pop_out_ECAM, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        local window_x, window_y, window_width, window_height = ECAM_window:getPosition()
        ECAM_window:setPosition ( window_x , window_y , 500, 500)
        ECAM_window:setIsVisible(not ECAM_window:isVisible())
    end
end)