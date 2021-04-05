local BUTTON_PRESS_TIME = 0.5
local dropdown_expanded = {false, false, false, false, false, false, false, false}
local dropdown_names = {EFB_LOAD_s3_dropdown1, EFB_LOAD_s3_dropdown2, EFB_LOAD_s3_dropdown3, EFB_LOAD_s3_dropdown4, EFB_LOAD_s3_dropdown5, EFB_LOAD_s3_dropdown6, EFB_LOAD_s3_dropdown7, EFB_LOAD_s3_dropdown8}

---------------------------------------------------------------------------------------------------------------------------------

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s3_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

local function close_menu(number)
    dropdown_expanded[number] = false
end



--MOUSE & BUTTONS--
function p3s3_buttons()

end

--UPDATE LOOPS--
function p3s3_update()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end

--DRAW LOOPS--
function p3s3_draw()
    draw_background()
end

--DO AT THE BEGINNING
