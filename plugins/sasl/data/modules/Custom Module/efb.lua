fbo = true
--for the cursor

include('constants.lua')

position = {3020, 1248, 1066, 800}
size = {1066, 800}

local cursor_x = 0
local cursor_y = 0

local efb_page = 0

local function draw_efb_bgd()
    sasl.gl.drawRectangle (0, 0, 1066, 800, EFB_GREY)
    SASL_drawRoundedFrames(27 ,27 ,1012 ,660 , 5, 30, EFB_RED)
    sasl.gl.drawTexture ( EFB_bgd, 0 , 0 , 1066 , 800 , ECAM_WHITE )

    SASL_draw_img_center_aligned ( EFB_cursor,cursor_x, cursor_y, 35, 34, ECAM_WHITE )
    
    SASL_draw_img_center_aligned(EFB_ICON_home, 107, 745, 64, 58, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_door, 213, 745, 64, 64, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_load, 320, 745, 64, 59, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_fuel, 426, 745, 64, 64, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_topcat, 533, 745, 54, 62, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_info, 853, 745, 61, 61, ECAM_WHITE)
    SASL_draw_img_center_aligned(EFB_ICON_settings, 959, 745, 63, 63, ECAM_WHITE)
end

local function cursor_texture_to_local_pos(x, y, component_width, component_height, panel_width, panel_height)
    local tex_x, tex_y = sasl.getCSPanelMousePos()
    
    --mouse not on the screen
    if tex_x == nil or tex_y == nil then
        return 0, 0
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
        if cursor_x >= 67 and cursor_x <= 147 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 1 Signal")
            efb_page = 1
        elseif cursor_x >= 173 and cursor_x <= 253 and cursor_y >= 705 and cursor_y <= 785 then
            print("Page 2 Signal")
            efb_page = 2
        end
    end
end


local function draw_efb_page_1()
end

local function draw_efb_page_2()
end

function draw()
    draw_efb_bgd()
    if efb_page == 1 then
        draw_efb_page_1()
    elseif efb_page == 2 then
        draw_efb_page_2()
    end
end

function update()
    cursor_x, cursor_y = cursor_texture_to_local_pos(position[1], position[2], position[3], position[4], 4096, 4096)
end