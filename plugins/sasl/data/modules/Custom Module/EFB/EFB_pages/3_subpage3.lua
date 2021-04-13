local BUTTON_PRESS_TIME = 0.5
local dropdown_expanded = {false, false, false, false, false, false, false, false}
local dropdown_selected = {0,0,0,0,0,0,0,0}
local test_dropdown_selected = 1
local test_dropdown_expanded = false
---------------------------------------------------------------------------------------------------------------------------------

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s3_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

--local function draw_dropdowns()
--    for i, v in ipairs(dropdown_expanded) do
--        if dropdown_expanded[i] then
--            sasl.gl.drawTexture (dropdown_names[i] , 0 , 0 , 1143 , 800 , EFB_WHITE )
--        end
--    end
--end


local function close_menu(number)
    dropdown_expanded[number] = false
end


local test_table = {"Hello", "Rico", "This", "Is", "A", "Dropdown", "Drawn"}

local function p3s3_dropdown1_buttons(x,y,w,h)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        test_dropdown_expanded = not test_dropdown_expanded
    end)
    for i=1, #test_table do
        if test_dropdown_expanded then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y,x - w/2,y-1 - h*i - 15 - 15, x + w/2, y-1 - h*i + 14,function ()
                print(i)
                test_dropdown_selected = i
                test_dropdown_expanded = false
            end)
        end
    end
end

--MOUSE & BUTTONS--
function p3s3_buttons()
    p3s3_dropdown1_buttons(800, 500, 260, 29)
end

--UPDATE LOOPS--
function p3s3_update()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end


--DRAW LOOPS--
function p3s3_draw()
    draw_background()
    draw_dropdown_menu(800, 500, 260, 29, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, test_table, test_dropdown_expanded, test_dropdown_selected)

end

--DO AT THE BEGINNING
