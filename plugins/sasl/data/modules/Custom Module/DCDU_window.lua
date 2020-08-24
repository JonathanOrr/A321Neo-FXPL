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
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-33, "(Click to focus)", 10, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawRectangle(20, size[2]-145, 350, 110, {0.5, 0.5, 0.8})

    sasl.gl.drawRectangle(30, size[2]-175, 120, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawRectangle(230, size[2]-175, 120, 22, {0.3, 0.3, 0.3})
    sasl.gl.drawText(B612MONO_regular, 40, size[2]-170, "Req. WILCO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 240, size[2]-170, "Req. ROGER", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})

    local MAX_LENGTH = 35
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-50, string.sub(temp_text,0,MAX_LENGTH), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-70, string.sub(temp_text,MAX_LENGTH+1,MAX_LENGTH*2), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-90, string.sub(temp_text,MAX_LENGTH*2+1,MAX_LENGTH*3), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-110, string.sub(temp_text,MAX_LENGTH*3+1,MAX_LENGTH*4), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})
    sasl.gl.drawText(B612MONO_regular, 20, size[2]-130, string.sub(temp_text,MAX_LENGTH*4+1,MAX_LENGTH*5), 14, false, false, TEXT_ALIGN_LEFT, {0.0, 0.0, 0.0})

    sasl.gl.drawLine(20, size[2]-190, size[1]-20, size[2]-190, {0.0, 0.0, 0.0})
    
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-220, "Debug", 20, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-250, "Current status:", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 180, size[2]-250, "VHF ", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    if get(Acars_status) >= 2 then
        sasl.gl.drawText(B612MONO_regular, 220, size[2]-250, "OK", 15, false, false, TEXT_ALIGN_LEFT, {0.0, 1.0, 0.0})
    else
        sasl.gl.drawText(B612MONO_regular, 220, size[2]-250, "KO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 0.0, 0.0})    
    end
    sasl.gl.drawText(B612MONO_regular, 270, size[2]-250, "SATCOM ", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    if get(Acars_status) == 1 or get(Acars_status) == 3 then
        sasl.gl.drawText(B612MONO_regular, 340, size[2]-250, "OK", 15, false, false, TEXT_ALIGN_LEFT, {0.0, 1.0, 0.0})
    else
        sasl.gl.drawText(B612MONO_regular, 340, size[2]-250, "KO", 15, false, false, TEXT_ALIGN_LEFT, {1.0, 0.0, 0.0})    
    end
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-280, "VHF conditions:",  12, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-295, " - VHF3 tuned to ACARS (TODO)",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-310, " - Nearest airport < 300 km ",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-325, "SATCOM conditions:",  12, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-340, " - Not over 75°/-75° latitude",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-355, " - Bank angle < 45°",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-370, "Random VHF or SATCOM disconnessions sometimes occur.",  11, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0}) 
    
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
    
    if x >= 30 and x <=150 and y>= size[2]-175 and y<= size[2]-175+22 then
        set(Acars_incoming_message, temp_text)
        set(Acars_incoming_message_type, 1)
        temp_text = ""
    end
    
    if x >= 230 and x <=350 and y>= size[2]-175 and y<= size[2]-175+22 then
        set(Acars_incoming_message, temp_text)
        set(Acars_incoming_message_type, 2)
        temp_text = ""
    end

    
    return true
end
