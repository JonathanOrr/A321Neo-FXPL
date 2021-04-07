local BUTTON_PRESS_TIME = 0.5
local dropdown_expanded = {false, false, false, false, false, false, false, false}
local dropdown_names = {EFB_LOAD_s3_dropdown1, EFB_LOAD_s3_dropdown2, EFB_LOAD_s3_dropdown3, EFB_LOAD_s3_dropdown4, EFB_LOAD_s3_dropdown5, EFB_LOAD_s3_dropdown6, EFB_LOAD_s3_dropdown7, EFB_LOAD_s3_dropdown8}

---------------------------------------------------------------------------------------------------------------------------------

include("EFB/efb_functions.lua")

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s3_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

local function draw_dropdowns()
    for i, v in ipairs(dropdown_expanded) do
        if dropdown_expanded[i] then
            sasl.gl.drawTexture (dropdown_names[i] , 0 , 0 , 1143 , 800 , EFB_WHITE )
        end
    end
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

local test_table = {"Hello", "Rico", "This", "Is", "A", "Dropdown", "Drawn"}

--DRAW LOOPS--
function p3s3_draw()
    draw_background()
    draw_dropdown_menu(800, 500, 260, 29, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, test_table, true, 1)

end

--DO AT THE BEGINNING
