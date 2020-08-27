size = {400, 400}

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local WHITELIST = "1234567890qwertyuiopasdfghjklzxcvbnm./ -,?!@#$%^&*()=+"

local temp_text = ""
local clicked = false

function update()
    --change menu item state
    if DCDU_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideDCDU, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideDCDU, MENU_UNCHECKED)
    end
end


function draw()
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-20, "Send message:", 20, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-33, "(Click the textbox to focus and input the message)", 10, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawRectangle(20, size[2]-145, 350, 110, {0.5, 0.5, 0.8})

    sasl.gl.drawRectangle(30, size[2]-175, 140, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(220, size[2]-175, 140, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(30, size[2]-200, 140, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(220, size[2]-200, 140, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawText(B612MONO_regular, 40, size[2]-170, "Req. WILCO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 230, size[2]-170, "Req. ROGER", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 40, size[2]-195, "Req. AFF/NEG", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 230, size[2]-195, "Only Inform", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})

    local MAX_LENGTH = 35
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-50, string.sub(temp_text,0,MAX_LENGTH), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-70, string.sub(temp_text,MAX_LENGTH+1,MAX_LENGTH*2), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-90, string.sub(temp_text,MAX_LENGTH*2+1,MAX_LENGTH*3), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-110, string.sub(temp_text,MAX_LENGTH*3+1,MAX_LENGTH*4), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-130, string.sub(temp_text,MAX_LENGTH*4+1,MAX_LENGTH*5), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})

    sasl.gl.drawLine(20, size[2]-210, size[1]-20, size[2]-210, {0.0, 0.0, 0.0})
    
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-240, "Debug", 20, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-260, "Current status:", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 180, size[2]-260, "VHF ", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    if get(Acars_status) >= 2 then
        sasl.gl.drawText(B612MONO_regular, 220, size[2]-260, "OK", 15, false, false, TEXT_ALIGN_LEFT, {0.0, 1.0, 0.0})
    else
        sasl.gl.drawText(B612MONO_regular, 220, size[2]-260, "KO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 0.0, 0.0})    
    end
    sasl.gl.drawText(B612MONO_regular, 270, size[2]-260, "SATCOM ", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    if get(Acars_status) == 1 or get(Acars_status) == 3 then
        sasl.gl.drawText(B612MONO_regular, 340, size[2]-260, "OK", 15, false, false, TEXT_ALIGN_LEFT, {0.0, 1.0, 0.0})
    else
        sasl.gl.drawText(B612MONO_regular, 340, size[2]-260, "KO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 0.0, 0.0})    
    end
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-290, "VHF conditions:",  12, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-305, " - VHF3 tuned to DATA (TODO)",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-320, " - Nearest airport < 300 km ",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-335, "SATCOM conditions:",  12, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-350, " - Not over 75°/-75° latitude",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-365, " - Bank angle < 45°",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-380, "Random VHF or SATCOM disconnessions sometimes occur.",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0}) 
    
end

function onKeyDown (component, charCode, key, shDown, ctrlDown, altOptDown)

    if charCode == 8 then
        temp_text = string.sub(temp_text,0,-2)
        return true
    end

    local pass = false
    for i = 1, string.len(WHITELIST) do
        if string.char(charCode):lower() == WHITELIST:sub(i,i) then
            pass = true
        end
    end
    if pass then
        temp_text = temp_text .. string.char(charCode)
    end

    return true
end

function onMouseDown (component , x , y , button , parentX , parentY)
    
    if string.len(temp_text) == 0 then
        return true 
    end
    
    if x >= 30 and x <=170 and y>= size[2]-175 and y<= size[2]-175+22 then
        set(Acars_incoming_message, string.upper(temp_text))
        set(Acars_incoming_message_type, 1)
        set(Acars_incoming_message_length, string.len(temp_text))
        temp_text = ""
    end
    
    if x >= 220 and x <=360 and y>= size[2]-175 and y<= size[2]-175+22 then
        set(Acars_incoming_message, string.upper(temp_text))
        set(Acars_incoming_message_type, 2)
        set(Acars_incoming_message_length, string.len(temp_text))
        temp_text = ""
    end
    
    if x >= 30 and x <=170 and y>= size[2]-200 and y<= size[2]-200+22 then
        set(Acars_incoming_message, string.upper(temp_text))
        set(Acars_incoming_message_type, 3)
        set(Acars_incoming_message_length, string.len(temp_text))
        temp_text = ""
    end
    
    if x >= 220 and x <=360 and y>= size[2]-200 and y<= size[2]-200+22 then
        set(Acars_incoming_message, string.upper(temp_text))
        set(Acars_incoming_message_type, 6)
        set(Acars_incoming_message_length, string.len(temp_text))
        temp_text = ""
    end

    
    return true
end
