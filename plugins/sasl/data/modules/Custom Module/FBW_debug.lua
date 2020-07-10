size = {340,500}

--colors--
local FBW_BLACK = {0,0,0}
local FBW_WHITE = {1.0, 1.0, 1.0}
local FBW_BLUE = {0.004, 1.0, 1.0}
local FBW_GREEN = {0.184, 0.733, 0.219}
local FBW_ORANGE = {0.725, 0.521, 0.18}
local FBW_RED = {1, 0.0, 0.0}

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

function update()
    --change menu item state
    if Vnav_debug_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHidePacksDebug, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHidePacksDebug, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawRectangle(0,0,size[1],size[2], FBW_BLACK)
    sasl.gl.drawFrame (20, 20, 300, 300, FBW_WHITE)

    sasl.gl.drawText(B612MONO_regular, 20, 460, "YOU ARE IN:", 28, false, false, TEXT_ALIGN_LEFT, FBW_WHITE)
    if get(FBW_on) == 1 then
        sasl.gl.drawText(B612MONO_regular, 20, 410, "NORMAL LAW", 40, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
        sasl.gl.drawText(B612MONO_regular, 20, 380, "YOU ARE COMMANDING: " .. Round(get(G_load_command), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
        sasl.gl.drawText(B612MONO_regular, 20, 360, "PULLING: " .. Round(get(Total_vertical_g_load), 1) .. "G", 15, false, false, TEXT_ALIGN_LEFT, FBW_GREEN)
    else
        sasl.gl.drawText(B612MONO_regular, 20, 400, "DIRECT LAW", 40, false, false, TEXT_ALIGN_LEFT, FBW_ORANGE)
    end

    sasl.gl.drawRectangle(size[1]/2-10 + 150 * get(Roll_artstab), (size[2]/2-90) - 150 * get(Pitch_artstab), 20, 20, FBW_ORANGE)
    sasl.gl.drawCircle(size[1]/2 + 150 * get(Roll), (size[2]/2-80) - 150 * get(Pitch), 10, true, FBW_GREEN)

    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(Pitch_d_lim), 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(Pitch_u_lim), 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * get(Roll_l_lim), (size[2]/2-80) - 150 * 0, 10, true, FBW_RED)
    sasl.gl.drawCircle(size[1]/2 + 150 * get(Roll_r_lim), (size[2]/2-80) - 150 * 0, 10, true, FBW_RED)

    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(Pitch_G_down), 10, true, FBW_BLUE)
    sasl.gl.drawCircle(size[1]/2 + 150 * 0, (size[2]/2-80) - 150 * get(Pitch_G_up), 10, true, FBW_BLUE)

    sasl.gl.drawRectangle(300, 405, 20, 75 * get(Elev_trim_ratio), FBW_GREEN)
    sasl.gl.drawFrame (300, 330, 20, 150, FBW_WHITE)
end