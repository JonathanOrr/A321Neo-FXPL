size = {600, 600}

include('constants.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local master_caution_image = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/master_caution.png", 0, 0, 128, 128)
local master_warning_image = sasl.gl.loadImage(moduleDirectory .. "/Custom Module/textures/master_warning.png", 0, 0, 128, 128)

function update()
    if failures_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideFailures, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideFailures, MENU_UNCHECKED)
    end
end


function draw()
    sasl.gl.drawText(B612MONO_regular, 10, size[2]-30, "Failures Manager", 30, false, false, TEXT_ALIGN_LEFT, {1.0, 1.0, 1.0})
    
    if get(MasterCaution) == 1 then
        sasl.gl.drawTexture(master_caution_image, 10, size[2]-110, 64, 64)
    else
        sasl.gl.drawRectangle (10, size[2]-110, 64, 64, {0,0,0})    
    end
    
    if get(MasterWarningBlinking) == 1 then
        sasl.gl.drawTexture(master_warning_image, 80, size[2]-110, 64, 64)
    else
        sasl.gl.drawRectangle (80, size[2]-110, 64, 64, {0,0,0})
    end
end
