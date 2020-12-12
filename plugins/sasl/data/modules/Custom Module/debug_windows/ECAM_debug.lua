-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: ECAM_cond.lua 
-- Short description: A debug window for ECAM 
-------------------------------------------------------------------------------

size = {340,400}

--colors--
local FBW_WHITE = {1.0, 1.0, 1.0}
local FBW_RED   = {1.0, 0.0, 0.0}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function update()
    --change menu item state
    if ECAM_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_debug, ShowHideECAMDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_debug, ShowHideECAMDebug, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawText(B612MONO_regular, 140, 370, "EWD", 30, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)

    sasl.gl.drawText(B612MONO_regular, 20, 340, "CURRENT FLIGHT PHASE: ", 15, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    sasl.gl.drawText(B612MONO_regular, 20, 280, "Please refer to the FCOM manual\nfor details about the flight phases.", 12, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    if get(EWD_flight_phase) == 0 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "UNKNOWN (0)", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    end
    if get(EWD_flight_phase) == 1 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "ELEC_PWR (1)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 2 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "1ST_ENG_ON (2)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 3 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "1ST_ENG_TO_PWR (3)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 4 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "ABOVE_80_KTS (4)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 5 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "LIFTOFF (5)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 6 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "AIRBONE (6)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 7 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "FINAL (7)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 8 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "TOUCHDOWN (8)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 9 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "BELOW_80_KTS (9)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    if get(EWD_flight_phase) == 10 then
        sasl.gl.drawText(B612MONO_regular, 20, 310, "2ND_ENG_OFF (10)", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    end
    
    sasl.gl.drawLine(0, 250, 400, 250)
    
    sasl.gl.drawText(B612MONO_regular, 130, 220, "ECAM", 30, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)


    sasl.gl.drawText(B612MONO_regular, 20, 190, "CURRENT PAGE: ", 15, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    
    local text = "UNKNOWN"
    if get(Ecam_current_page) == 1 then
        text = "ENGINE"
    elseif get(Ecam_current_page) == 2 then
        text = "BLEED"
    elseif get(Ecam_current_page) == 3 then
        text = "PRESS"
    elseif get(Ecam_current_page) == 4 then
        text = "ELEC"
    elseif get(Ecam_current_page) == 5 then
        text = "HYD"
    elseif get(Ecam_current_page) == 6 then
        text = "FUEL"
    elseif get(Ecam_current_page) == 7 then
        text = "APU"
    elseif get(Ecam_current_page) == 8 then
        text = "COND"
    elseif get(Ecam_current_page) == 9 then
        text = "DOOR"
    elseif get(Ecam_current_page) == 10 then
        text = "WHEEL"
    elseif get(Ecam_current_page) == 11 then
        text = "F/CTL"
    elseif get(Ecam_current_page) == 12 then
        text = "STS"
    elseif get(Ecam_current_page) == 13 then
        text = "CRUISE"
    end

    if text == "UNKNOWN" then
        sasl.gl.drawText(B612MONO_regular, 20, 160, text .. " (".. get(Ecam_current_page) ..")", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    else
        sasl.gl.drawText(B612MONO_regular, 20, 160, text .. " (".. get(Ecam_current_page) ..")", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)    
    end
    
    sasl.gl.drawText(B612MONO_regular, 20, 120, "CURRENT STATUS: ", 15, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)

    text = "UNKNOWN"
    local desc = "This should not happen."
    if get(Ecam_current_status) == 0 then
        text = "NORMAL"
        desc = "Page depends on flight phase"
    elseif get(Ecam_current_status) == 1 then
        text = "USER"
        desc = "User pressed a page pushbutton"
    elseif get(Ecam_current_status) == 2 then
        text = "ALL"
        desc = "User pressed the ALL pushbutton"
    elseif get(Ecam_current_status) == 3 then
        text = "EWD Failure"
        desc = "Page depends on EWD warning"
    elseif get(Ecam_current_status) == 4 then
        text = "EWD Final"
        desc = "Page is status due to EWD failure cleared"
    end
    
    if text == "UNKNOWN" then
        sasl.gl.drawText(B612MONO_regular, 20, 90, text .. " (".. get(Ecam_current_status) ..")", 20, false, false, TEXT_ALIGN_LEFT, FBW_RED)
    else
        sasl.gl.drawText(B612MONO_regular, 20, 90, text .. " (".. get(Ecam_current_status) ..")", 20, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)    
    end

    sasl.gl.drawText(B612MONO_regular, 20, 70, desc, 12, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    
end
