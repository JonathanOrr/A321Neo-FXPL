fbo = true
--for the cursor

----------CONTROLLABLE STUFF---------
local EFB_DELAYED_TRANSIT_FACTOR = 7 --THE SPEED OF THE UNDERLINE MOVING WHEN CHANGINE PAGE, THE LARGER THE FASTER
local TRANSITION_FADE_TIME = 0.7
local EFB_UNDERLINE_THICKNESS = 2
-------------------------------------

include("EFB/efb_common_buttons.lua")
include("EFB/efb_functions.lua")
include("EFB/EFB_pages/1.lua")
include("EFB/EFB_pages/2.lua")
include("EFB/EFB_pages/3.lua")
include("EFB/EFB_pages/4.lua")
include("EFB/EFB_pages/5.lua")
include("EFB/EFB_pages/6.lua")
include("EFB/EFB_pages/7.lua")
include("EFB/EFB_pages/8.lua")
include("EFB/EFB_pages/9.lua")
include("EFB/EFB_pages/10.lua")
include("EFB/efb_topcat.lua")

position = {2943, 1248, 1143, 800}
size = {1143, 800}

EFB_PAGE = 1
EFB_FRAME_AGO_PAGE = 1 --USED FOR CALCULATING DELTA
EFB_DELAYED_PAGE = 1 --FLOAD AND CONTROLLED BY NON-LINEAR CONTROLLER, FOLLOWS EFB PAGE, USED FOR UNDERLINE
EFB_PREV_PAGE = 1
EFB_CURSOR_X = 0
EFB_CURSOR_Y = 0
EFB_CURSOR_on_screen = false
EFB_OFF = false

--UNDERLINE
local EFB_UNDERLINE_POS = 1 --THE POSITION OF THE UNDERLINE
local EFB_selector_transit_start = 0 --THE START TIME OF THE TRANSIT, FOR CONTROLLERS

--CHANGE PAGE FADING
local CHANGE_PAGE_FADING_START_TIME = 0
local CHANGE_PAGE_FADING_TIME_LEFT = 0
Change_alpha_controller = {17/255, 24/255, 39/255}

local line_width_table = {
    {1, 57},
    {2, 42},
    {3, 54},
    {4, 69},
    {5, 58},
    {6, 77},
  }

local change_page_fade_table = {
    {0,0},
    {TRANSITION_FADE_TIME,1},
}

function onKeyDown(component, char, key, shiftDown, ctrlDown, altOptDown)
    if EFB_PAGE == 3 and efb_subpage_number == 1 then
        return EFB_onKeyDown_page3_subpage_1(component, char, key, shiftDown, ctrlDown, altOptDown)
    elseif EFB_PAGE == 3 and efb_subpage_number == 3 then
        return EFB_onKeyDown_page3_subpage_3(component, char, key, shiftDown, ctrlDown, altOptDown)
    elseif EFB_PAGE == 5 and efb_p5_subpage_number == 1 then
        return EFB_onKeyDown_page5(component, char, key, shiftDown, ctrlDown, altOptDown)
    elseif EFB_PAGE == 5 and efb_p5_subpage_number == 2 then
        return EFB_onKeyDown_page5_subpage_2(component, char, key, shiftDown, ctrlDown, altOptDown)
    end
end

function draw_fading_transition()
    Change_alpha_controller[4] = Math_rescale(0,0,TRANSITION_FADE_TIME,1,CHANGE_PAGE_FADING_TIME_LEFT)

    if EFB_PAGE ~= 10 then
        sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, Change_alpha_controller)
    end
end

---------------------------------------------------------------------------------------------------------------
--load in the functions
local EFB_pages_buttons = {
    EFB_execute_page_1_buttons,
    EFB_execute_page_2_buttons,
    EFB_execute_page_3_buttons,
    EFB_execute_page_4_buttons,
    EFB_execute_page_5_buttons,
    EFB_execute_page_6_buttons,
    EFB_execute_page_7_buttons,
    EFB_execute_page_8_buttons,
    EFB_execute_page_9_buttons,
    EFB_execute_page_10_buttons,
}

local EFB_updates_pages = {
    EFB_update_page_1,
    EFB_update_page_2,
    EFB_update_page_3,
    EFB_update_page_4,
    EFB_update_page_5,
    EFB_update_page_6,
    EFB_update_page_7,
    EFB_update_page_8,
    EFB_update_page_9,
    EFB_update_page_10,
}

local EFB_draw_pages = {
    EFB_draw_page_1,
    EFB_draw_page_2,
    EFB_draw_page_3,
    EFB_draw_page_4,
    EFB_draw_page_5,
    EFB_draw_page_6,
    EFB_draw_page_7,
    EFB_draw_page_8,
    EFB_draw_page_9,
    EFB_draw_page_10,
}

EFB.preferences = {
    ["syncqnh"] = false,
    ["nws"] = 1,
    ["tca"] = false,
    ["pausetd"] = false,
    ["copilot"] = false,
    ["flarelaw"] = 0,
}

--load EFB preferences--
local function load_EFB_pref()
    local table_load_buffer = table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_preferences_v2")
    if table_load_buffer ~= nil then

        -- Sanitize check
        for k,x in pairs(EFB.preferences) do
            if table_load_buffer[k] == nil then
                return  -- Saved file is invalid, let's overwrite it
            end
        end

        -- If we are here, the saved file is ok
        EFB.preferences = table_load_buffer

        --init FBW flare law(special case)
        set(FBW_mode_transition_version, EFB.preferences["flarelaw"])
    end
end
load_EFB_pref()

---------------------------------------------------------------------------------------------------------------
--TOP BAR SELECTOR LOGIC--

local function jon_told_me_not_to_create_super_long_names_for_functions_but_this_function_draw_horizontal_line_with_certain_width_centered(x,y,thickness, width,color)
    sasl.gl.drawWideLine ( x-width/2 , y , x+width/2 , y , thickness, color )
end

---------------------------------------------------------------------------------------------------------------
--MOUSE CLICK LOGIC--
function onMouseDown(component, x, y, button, parentX, parentY)
    --mouse not on the screen
    if EFB_CURSOR_on_screen == false or button ~= MB_LEFT then
        return
    end

    if button == MB_LEFT then
        EFB_common_buttons()
        EFB_pages_buttons[EFB_PAGE]()
    end
    return true
end


function onMouseUp(component , x , y , button , parentX , parentY)
    --mouse not on the screen
    if EFB_CURSOR_on_screen == false or button ~= MB_LEFT then
        return
    end
    if EFB_PAGE == 3 and efb_subpage_number == 1 then
        EFB_p3s1_onmouseup()
    end

    return true
end

--common draw logic
local function draw_efb_bgd()
    sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, EFB_BACKGROUND_COLOUR)
    sasl.gl.drawRectangle ( 0 , 710 , 1143, 90, EFB_BACKGROUND_TOP)
    local efb_titles = {"HOME", "GND", "PERF", "CONFIG", "TOOLS", "MANUAL"}
    for i=1, #efb_titles do
        drawTextCentered(Font_Airbus_panel, (1143/10)*i - 56  ,  750 , efb_titles[i] , 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
        drawTextCentered(Font_Airbus_panel, (1143/10)*i - 56  ,  750 , efb_titles[i] , 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
end

local function compute_page_change_fade_transparency()

    local delta = EFB_PAGE - EFB_FRAME_AGO_PAGE
    EFB_FRAME_AGO_PAGE = EFB_PAGE

    if math.abs(delta) > 0 then
        CHANGE_PAGE_FADING_TIME_LEFT = TRANSITION_FADE_TIME
    end
    if CHANGE_PAGE_FADING_TIME_LEFT > -1 then
        CHANGE_PAGE_FADING_TIME_LEFT = CHANGE_PAGE_FADING_TIME_LEFT - get(DELTA_TIME)
    end
end

local function draw_cursor()------------------------------DONT U DARE REMOVE THIS LINE, IT KEEPS THE CURSOR ON TOP
    if EFB_CURSOR_on_screen == true then
        SASL_draw_img_center_aligned ( EFB_cursor,EFB_CURSOR_X, EFB_CURSOR_Y, 50, 50, ECAM_WHITE )
    end
end

local function Cursor_texture_to_local_pos(x, y, component_width, component_height, panel_width, panel_height)
    local tex_x, tex_y = sasl.getCSPanelMousePos()

    --mouse not on the screen
    if tex_x == nil or tex_y == nil then
        return 0, 0, false
    end

    --0 --> 1 to px
    local px_x = Math_rescale(0, 0, 1, panel_width,  tex_x)
    local px_y = Math_rescale(0, 0, 1, panel_height, tex_y)

    --px --> component
    local component_x = Math_rescale(x, 0, x + component_width,  component_width,  px_x)
    local component_y = Math_rescale(y, 0, y + component_height, component_height, px_y)

    if px_x < x or px_x > x + component_width or px_y < y or px_y > y + component_height then
        return 0, 0, false
    end

    --output converted coordinates
    return component_x, component_y, true
end

--SASL callbacks-------------------------------------------------------------------------------------------------
function update()
    perf_measure_start("EFB:update()")
  
    EFB_CURSOR_X, EFB_CURSOR_Y, EFB_CURSOR_on_screen = Cursor_texture_to_local_pos(position[1], position[2], position[3], position[4], 4096, 4096)
    EFB_updates_pages[EFB_PAGE]()

    if not EFB_CURSOR_on_screen then
        p3s1_revert_to_previous_and_delete_buffer()
        p5s1_revert_to_previous_and_delete_buffer()
        p5s2_revert_to_previous_and_delete_buffer()
    end

    compute_page_change_fade_transparency()

    perf_measure_stop("EFB:update()")
end


function draw()  ------KEEP THE draw_cursor() AT THE BOTTOM YOU DUMBASS!!!!!
  
    perf_measure_start("EFB:draw()")
  
    EFB_DELAYED_PAGE = Set_anim_value(EFB_DELAYED_PAGE, EFB_PAGE, 0, 10, EFB_DELAYED_TRANSIT_FACTOR)
  
    local EFB_UNDERLINE_POS =   (27548.06 + (-53.64934 - 27548.06)/(1 +((EFB_DELAYED_PAGE/215.6605)^1.026289))  )
    local EFB_UNDERLINE_WIDTH = Table_interpolate(line_width_table, EFB_DELAYED_PAGE)

  ----------------------------------------------------------------------------------------------------
  

    draw_efb_bgd()
    EFB_draw_pages[EFB_PAGE]()

    draw_fading_transition()

    
    if EFB_PAGE ~= 10 then
        jon_told_me_not_to_create_super_long_names_for_functions_but_this_function_draw_horizontal_line_with_certain_width_centered(EFB_UNDERLINE_POS, 738,EFB_UNDERLINE_THICKNESS ,EFB_UNDERLINE_WIDTH ,EFB_WHITE) --DRAWS THE UNDERLINE OF THE PAGE TITLE
    end

    if EFB_OFF == false then
        draw_cursor()
    end

    if get(AC_ess_bus_pwrd) == 1 and EFB_OFF == false then
        sasl.gl.drawTexture(EFB_Charging_Overlay, 1058 , 780 , 75 , 14 , EFB_WHITE )
    end

    perf_measure_stop("EFB:draw()")

end
