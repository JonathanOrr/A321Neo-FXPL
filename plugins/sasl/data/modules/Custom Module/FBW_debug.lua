size = {340,500}

--colors--
local FBW_BLACK = {0,0,0}
local FBW_WHITE = {1.0, 1.0, 1.0}
local FBW_BLUE = {0.004, 1.0, 1.0}
local FBW_GREEN = {0.184, 0.733, 0.219}
local FBW_ORANGE = {0.725, 0.521, 0.18}
local FBW_RED = {1, 0.0, 0.0}

--fonts
local B612regular = sasl.gl.loadFont("fonts/B612-Regular.ttf")
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function onMouseDown ( component , x , y , button , parentX , parentY )
    if button == MB_LEFT then
        if x >= 236 and x <= 292 and y >= 476 and y <= 496 then
            if get(FBW_pitch_mode) == 3 then
                set(FBW_pitch_mode, 2)
            elseif get(FBW_pitch_mode) == 2 then
                set(FBW_pitch_mode, 1)
            elseif get(FBW_pitch_mode) == 1 then
                set(FBW_pitch_mode, 0)
            else
                set(FBW_pitch_mode, 3)
            end
        end
    end
end

function update()
    --change menu item state
    if FBW_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideFBWDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideFBWDebug, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawRectangle(0,0,size[1],size[2], FBW_BLACK)
    sasl.gl.drawFrame (20, 180, 140, 140, FBW_WHITE)
    sasl.gl.drawFrame (180, 180, 140, 140, FBW_WHITE)
    sasl.gl.drawFrame (180, 20, 140, 140, FBW_WHITE)
    sasl.gl.drawFrame (20, 127, 140, 33, FBW_WHITE)
    sasl.gl.drawFrame (20, 20, 60, 87, FBW_WHITE)
    sasl.gl.drawFrame (100, 20, 60, 87, FBW_WHITE)

    sasl.gl.drawText(B612MONO_regular, 20, 455, "YOU ARE IN:", 25, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    if get(FBW_status) == 2 then
        if get(FBW_flaring) == 0 then
            sasl.gl.drawText(B612MONO_regular, 20, 425, "NORMAL LAW", 28, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
        else
            sasl.gl.drawText(B612MONO_regular, 20, 425, "FLARE NOW", 28, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
        end

        if get(FBW_ground_mode) == 1 then
            sasl.gl.drawText(B612regular, 78, 480, "GROUND MODE", 15, false, false, TEXT_ALIGN_CENTER, FBW_BLUE)
            sasl.gl.drawText(B612MONO_regular, 310, 483, "CWS", 15, false, false, TEXT_ALIGN_CENTER, FBW_RED)
            sasl.gl.drawText(B612MONO_regular, 20, 405, "AIRCRAFT ON GROUND", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
            sasl.gl.drawText(B612MONO_regular, 20, 385, "UNTIL AIRBORNE", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
            sasl.gl.drawText(B612MONO_regular, 20, 365, "ALL CONTROLS ARE LINEAR", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
        else
            if get(FBW_flare_mode) == 1 then
                sasl.gl.drawText(B612regular, 185, 480, "FLARE MODE", 15, false, false, TEXT_ALIGN_CENTER, FBW_BLUE)
                sasl.gl.drawText(B612MONO_regular, 310, 483, "CWS", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
                sasl.gl.drawText(B612MONO_regular, 20, 405, "AIRCRAFT IN FLARE MODE", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
                sasl.gl.drawText(B612MONO_regular, 20, 385, "APPLYING DOWNWARDS TRIM", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
                sasl.gl.drawText(B612MONO_regular, 20, 365, "PITCH UP INPUT REQUIRED", 15, false, false, TEXT_ALIGN_LEFT, FBW_BLUE)
            else
                sasl.gl.drawText(B612MONO_regular, 310, 483, "CWS", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
                sasl.gl.drawText(B612MONO_regular, 20, 405, "YOU ARE COMMANDING: " .. Round(get(G_load_command), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
                sasl.gl.drawText(B612MONO_regular, 20, 385, "PULLING: " .. Round(get(Total_vertical_g_load), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
                sasl.gl.drawText(B612MONO_regular, 20, 365, "COMMANDING: " .. Round(get(Roll_rate_command), 1) .. " DEG/S", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
                sasl.gl.drawText(B612MONO_regular, 20, 345, "ROLLING: " .. Round(get(Roll_rate), 1) .. " DEG/S", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
            end
        end

        --pitch mode indication
        if get(FBW_pitch_mode) == 3 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 480, "G+YAW", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(FBW_pitch_mode) == 2 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 480, "VPATH", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(FBW_pitch_mode) == 1 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 480, "VPATH", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        else
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 480, "PITCH", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        end

        --yaw limits indication
        if get(Yaw_lim) >= 25 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(Yaw_lim) < 30 and get(Yaw_lim) >= 3.45 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        elseif get(Yaw_lim) < 3.45 and get(Yaw_lim) >= 3.4 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_RED)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_RED)
        end

        --artificial stability sum
        sasl.gl.drawRectangle(245 + 70 * get(Roll_artstab), 85 - 70 * get(Pitch_artstab), 10, 10, FBW_ORANGE)

        --flight envelops
        sasl.gl.drawCircle(90, 250 - 70 * get(Pitch_d_lim), 5, true, FBW_RED)
        sasl.gl.drawCircle(90, 250 - 70 * get(Pitch_u_lim), 5, true, FBW_RED)
        sasl.gl.drawCircle(90 + 70 * get(Roll_l_lim), 250, 5, true, FBW_RED)
        sasl.gl.drawCircle(90 + 70 * get(Roll_r_lim), 250, 5, true, FBW_RED)

        --max speed and AOA protections
        sasl.gl.drawArc(130, 63.5 - 43.5 * get(AOA_lim), 3, 5, 0, 360, FBW_ORANGE)
        sasl.gl.drawArc(130, 63.5 - 43.5 * get(MAX_spd_lim), 3, 5, 0, 360, FBW_BLUE)

        --roll rate and G load command
        sasl.gl.drawCircle(90 + 70 * get(Roll_rate_output), 143.5, 5, true, FBW_BLUE)
        sasl.gl.drawCircle(50, 63.5 - 43.5 * get(G_output), 5, true, FBW_BLUE)

        --elevator trim
        sasl.gl.drawRectangle(300, 405, 20, 75 * get(Elev_trim_ratio), FBW_GREEN)
        sasl.gl.drawFrame (300, 330, 20, 150, FBW_WHITE)
    elseif get(FBW_status) == 1 then
        sasl.gl.drawText(B612MONO_regular, 20, 425, "ALT LAW", 28, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 405, "YOU ARE COMMANDING: " .. Round(get(G_load_command), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 385, "PULLING: " .. Round(get(Total_vertical_g_load), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 365, "ROLL CONTROL IS LINEAR", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)

        --pitch mode indication
        if get(FBW_pitch_mode) == 3 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 480, "G+YAW", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(FBW_pitch_mode) == 2 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 480, "VPATH", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(FBW_pitch_mode) == 1 then
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 480, "VPATH", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        else
            sasl.gl.drawFrame (236, 476, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 480, "PITCH", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        end

        --yaw limits indication
        if get(Yaw_lim) == 30 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_GREEN)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        elseif get(Yaw_lim) < 30 and get(Yaw_lim) >= 3.45 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_ORANGE)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        elseif get(Yaw_lim) < 3.45 and get(Yaw_lim) >= 3.4 then
            sasl.gl.drawFrame (236, 450, 56, 20, FBW_RED)
            sasl.gl.drawText(B612regular, 263, 454, Round(get(Yaw_lim), 1) .. "°", 15, false, false, TEXT_ALIGN_CENTER, FBW_RED)
        end

        --artificial stability sum
        sasl.gl.drawRectangle(245 + 70 * get(Roll_artstab), 85 - 70 * get(Pitch_artstab), 10, 10, FBW_ORANGE)

        --G command
        sasl.gl.drawCircle(50, 63.5 - 43.5 * get(G_output), 5, true, FBW_BLUE)

        --elevator trim
        sasl.gl.drawText(B612MONO_regular, 310, 483, "CWS", 15, false, false, TEXT_ALIGN_CENTER, FBW_GREEN)
        sasl.gl.drawRectangle(300, 405, 20, 75 * get(Elev_trim_ratio), FBW_GREEN)
        sasl.gl.drawFrame (300, 330, 20, 150, FBW_WHITE)
    else
        sasl.gl.drawText(B612MONO_regular, 20, 425, "DIRECT LAW", 28, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 405, "INPUTS ARE LINEAR", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 385, "NO LIMITATIONS", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
        sasl.gl.drawText(B612MONO_regular, 20, 365, "USE MANUAL TRIM", 15, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)

        --elevator trim
        sasl.gl.drawText(B612regular, 310, 485, "MAN TRIM", 12, false, false, TEXT_ALIGN_CENTER, FBW_ORANGE)
        sasl.gl.drawRectangle(300, 405, 20, 75 * get(Elev_trim_ratio), FBW_ORANGE)
        sasl.gl.drawFrame (300, 330, 20, 150, FBW_WHITE)
    end

    --player input
    sasl.gl.drawCircle(250 + 70 * get(Roll), 250 - 70 * get(Pitch), 5, true, FBW_GREEN)

    
end