size = {877, 1365}

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")
local MCDU_OVERLAY = sasl.gl.loadImage("textures/MCDU.png", 0, 0, 877, 1365)

function update()
    --change menu item state
    if MCDU_window:isVisible() == true then
        sasl.setMenuItemState(Menu_main, ShowHideMCDU, MENU_CHECKED)
    else
        sasl.setMenuItemState(Menu_main, ShowHideMCDU, MENU_UNCHECKED)
    end
end

function draw()
    sasl.gl.drawTexture(MCDU_OVERLAY, 0, 0, 877, 1365)
    if get(Mcdu_enabled) == 1 then
        --does enabled exist?
        if MCDU_get_popup("enabled") ~= nil then
            --is enabled true?
            if MCDU_get_popup("enabled") then
                for i,line in ipairs(MCDU_get_popup("draw lines")) do
                    sasl.gl.setFontGlyphSpacingFactor(B612MONO_regular, line.disp_spacing)
                    --sasl.gl.drawText(B612MONO_regular, (line.disp_x * 2) + 98, (line.disp_y * 2) + 345, line.disp_text, line.disp_text_size * 1.2, false, false, line.disp_text_align, line.disp_color)
                    sasl.gl.drawText(B612MONO_regular, (line.disp_x * 1.83) + 140, (line.disp_y * 2.03) + 700, line.disp_text, line.disp_text_size * 1.7, false, false, line.disp_text_align, line.disp_color)
                end
            end
            --drawing scratchpad
            sasl.gl.drawText(B612MONO_regular, 150, 730, MCDU_get_popup("mcdu entry"), 35, false, false, TEXT_ALIGN_LEFT, {1,1,1})
            
        end
    end
end

function onKeyDown ( component , char , key , shDown , ctrlDown , altOptDown )
print ( " Char : " ..string.char ( char ) )
end

