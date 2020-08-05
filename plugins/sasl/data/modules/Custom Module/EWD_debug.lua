size = {340,200}

--colors--
local FBW_WHITE = {1.0, 1.0, 1.0}
local FBW_RED   = {1.0, 1.0, 1.0}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function update()
    --change menu item state
    if EWD_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideEWDDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideEWDDebug, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawText(B612MONO_regular, 20, 180, "CURRENT FLIGHT PHASE: ", 15, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    sasl.gl.drawText(B612MONO_regular, 20, 50, "Please refer to the FCOM manual\nfor details about the flight phases.", 12, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    if get(EWD_flight_phase) == 0 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "UNKNOWN (0)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 1 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "ELEC_PWR (1)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 2 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "1ST_ENG_ON (2)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 3 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "1ST_ENG_TO_PWR (3)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 4 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "ABOVE_80_KTS (4)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 5 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "LIFTOFF (5)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 6 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "AIRBONE (6)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 7 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "FINAL (7)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 8 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "TOUCHDOWN (8)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 9 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "BELOW_80_KTS (9)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 10 then
        sasl.gl.drawText(B612MONO_regular, 20, 130, "2ND_ENG_OFF (10)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    
end
