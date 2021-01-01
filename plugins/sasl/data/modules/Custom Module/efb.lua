fbo = true
--for the cursor

include('constants.lua')

position = {2943, 1248, 1143, 800}
size = {1143, 800}

local cursor_x = 0
local cursor_y = 0

local efb_page = 0

Door1R_C = sasl.findCommand("a321neo/cockpit/door/toggle_door_1_r")







---------------------------------------------------------------------------------------------------------------

local function draw_efb_bgd()
    SASL_drawRoundedFrames(27 ,27 ,1012 ,660 , 5, 30, EFB_RED)
    sasl.gl.drawTexture ( EFB_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end

local function cursor_texture_to_local_pos(x, y, component_width, component_height, panel_width, panel_height)
    local tex_x, tex_y = sasl.getCSPanelMousePos()
    
    --mouse not on the screen
    if tex_x == nil or tex_y == nil then
        return
    end

    --0 --> 1 to px
    local px_x = Math_rescale(0, 0, 1, panel_width,  tex_x)
    local px_y = Math_rescale(0, 0, 1, panel_height, tex_y)

    --px --> component
    local component_x = Math_rescale(x, 0, x + component_width,  component_width,  px_x)
    local component_y = Math_rescale(y, 0, y + component_height, component_height, px_y)

    --output converted coordinates
    return component_x, component_y
end

function onMouseDown(component, x, y, button, parentX, parentY)
    local tex_x, tex_y = sasl.getCSPanelMousePos()
    
    --mouse not on the screen
    if tex_x == nil or tex_y == nil then
        return
    end

    if button == MB_LEFT then
        if cursor_x >= 63 and cursor_x <= 143 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 1 Signal")
            efb_page = 1
        elseif cursor_x >= 167 and cursor_x <= 247 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 2 Signal")
            efb_page = 2
        elseif cursor_x >= 271 and cursor_x <= 351 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 3 Signal")
            efb_page = 3
        elseif cursor_x >= 375 and cursor_x <= 455 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 4 Signal")
            efb_page = 4
--        elseif cursor_x >= 480 and cursor_x <= 560 and cursor_y >= 705 and cursor_y <= 785 then
--            print("Page 5 Signal")
--            efb_page = 5
--        elseif cursor_x >= 583 and cursor_x <= 663 and cursor_y >= 705 and cursor_y <= 785 then
--            print("Page 6 Signal")
--            efb_page = 6
--        elseif cursor_x >= 687 and cursor_x <= 767 and cursor_y >= 705 and cursor_y <= 785 then
--            print("Page 7 Signal")
--            efb_page = 7
--        elseif cursor_x >= 791 and cursor_x <= 871 and cursor_y >= 705 and cursor_y <= 785 then
--            print("Page 8 Signal")
--            efb_page = 8
        elseif cursor_x >= 895 and cursor_x <= 975 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 9 Signal")
            efb_page = 9
        elseif cursor_x >= 989 and cursor_x <= 1079 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 0 Signal")
            efb_page = 0
        end
    end
end


local function draw_efb_page_1()
    sasl.gl.drawTexture ( EFB_HOME, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end

local function draw_efb_page_2()
    sasl.gl.drawTexture ( EFB_DOOR, 0 , 0 , 1143 , 800 , ECAM_WHITE )
    if cursor_x >= 175 and cursor_x <= 210 and cursor_y >= 415 and cursor_y <= 437 then
        sasl.commandOnce(Door1R_C)
        print("Door1R Pressed")
    end
end

local function draw_efb_page_3()
    sasl.gl.drawTexture ( EFB_LOADING, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end

local function draw_efb_page_4()
end

local function draw_efb_page_5()
end

local function draw_efb_page_6()
end

local function draw_efb_page_7()
end

local function draw_efb_page_8()
end

local function draw_efb_page_9()
    sasl.gl.drawTexture ( EFB_CREDITS, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end

local function draw_efb_page_0()
end

local function draw_cursor()------------------------------DONT U DARE REMOVE THIS LINE, IT KEEPS THE CURSOR ON TOP
    if sasl.getCSPanelMousePos() == nil then
  else
  SASL_draw_img_center_aligned ( EFB_cursor,cursor_x, cursor_y, 50, 50, ECAM_WHITE )
  end
end


function draw()  ------KEEP THE draw_cursor() AT THE BOTTOM YOU DUMBASS!!!!!
    draw_efb_bgd()
    if efb_page == 1 then
        draw_efb_page_1()
    elseif efb_page == 2 then
        draw_efb_page_2()
    elseif efb_page == 3 then
        draw_efb_page_3()
    elseif efb_page == 4 then
        draw_efb_page_4()
    elseif efb_page == 5 then
        draw_efb_page_5()
    elseif efb_page == 6 then
        draw_efb_page_6()
    elseif efb_page == 7 then
        draw_efb_page_7()
    elseif efb_page == 8 then
        draw_efb_page_8()
    elseif efb_page == 9 then
        draw_efb_page_9()
    elseif efb_page == 0 then
        draw_efb_page_0()
    end
    draw_cursor()
end

function update()
    cursor_x, cursor_y = cursor_texture_to_local_pos(position[1], position[2], position[3], position[4], 4096, 4096)
end