fbo = true
--for the cursor

----------CONTROLLABLE STUFF---------
local EFB_DELAYED_TRANSIT_FACTOR = 7 --THE SPEED OF THE UNDERLINE MOVING WHEN CHANGINE PAGE, THE LARGER THE FASTER
local CHARGE_SCREEN_TIME = 5
local EFB_UNDERLINE_THICKNESS = 2
-------------------------------------

include("EFB/efb_common_buttons.lua")
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
EFB_DELAYED_PAGE = 1 --FLOAD AND CONTROLLED BY NON-LINEAR CONTROLLER, FOLLOWS EFB PAGE, USED FOR UNDERLINE
EFB_PREV_PAGE = 1
EFB_CURSOR_X = 0
EFB_CURSOR_Y = 0
EFB_CURSOR_on_screen = false

EFB_OFF = false

AVITAB_INSTALLED = false

---CHARGING
local CHARGE_START_TIME = 0
local CHARGE_TIME_LEFT = 0
local Ac_ess_past_value = 0
local Ac_ess_delta = 0
local Charging_alpha_controller = {1,1,1,1}

--UNDERLINE
local EFB_UNDERLINE_POS = 1 --THE POSITION OF THE UNDERLINE
local EFB_selector_transit_start = 0 --THE START TIME OF THE TRANSIT, FOR CONTROLLERS

local line_width_table = {
    {1, 57},
    {2, 42},
    {3, 54},
    {4, 69},
    {5, 72},
    {6, 48},
  }

local charge_fade_table = {
    {0, 0},
    {0.1, 1},
    {CHARGE_SCREEN_TIME-0.3, 1},
    {CHARGE_SCREEN_TIME, 0},
  }

if findPluginBySignature("org.solhost.folko.avitab") ~= NO_PLUGIN_ID then
    Avitab_Enabled = globalProperty("avitab/panel_enabled")
    AVITAB_INSTALLED = true
    set(Avitab_Enabled, 0)
else
    AVITAB_INSTALLED = false
end

function onKeyDown(component, char, key, shiftDown, ctrlDown, altOptDown)
    if EFB_PAGE == 3 then
        return EFB_onKeyDown_page3(component, char, key, shiftDown, ctrlDown, altOptDown)
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

EFB_preferences = {
    ["syncqnh"] = 0,
    ["rolltonws"] = 0,
    ["tca"] = 0,
    ["pausetd"] = 0,
    ["copilot"] = 0,
    ["flarelaw"] = 0
}

--load EFB preferences--
local table_load_buffer = table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_preferences")
if table_load_buffer ~= nil then
    EFB_preferences = table_load_buffer

    --init FBW flare law(special case)
    set(FBW_mode_transition_version, EFB_preferences["flarelaw"])
end

---------------------------------------------------------------------------------------------------------------
--TOP BAR SELECTOR LOGIC--

local function jon_told_me_not_to_create_super_long_names_for_functions_but_this_function_draw_horizontal_line_with_certain_width_centered(x,y,thickness, width,color)
    sasl.gl.drawWideLine ( x-width/2 , y , x+width/2 , y , thickness, color )
end

---------------------------------------------------------------------------------------------------------------
--MOUSE CLICK LOGIC--
function onMouseDown(component, x, y, button, parentX, parentY)
    --mouse not on the screen
    if EFB_CURSOR_on_screen == false then
        return
    end

    if button == MB_LEFT then
        EFB_common_buttons()
        EFB_pages_buttons[EFB_PAGE]()
    end
end

--common draw logic
local function draw_efb_bgd()
    sasl.gl.drawTexture ( EFB_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE )
end

local function draw_cursor()------------------------------DONT U DARE REMOVE THIS LINE, IT KEEPS THE CURSOR ON TOP
    if EFB_CURSOR_on_screen == true then
        SASL_draw_img_center_aligned ( EFB_cursor,EFB_CURSOR_X, EFB_CURSOR_Y, 50, 50, ECAM_WHITE )
    end
end

local function update_battery()
    CHARGE_TIME_LEFT = get(TIME) - CHARGE_START_TIME
    Charging_alpha_controller = {1,1,1,Table_interpolate(charge_fade_table, CHARGE_TIME_LEFT)}
    Ac_ess_delta = get(AC_ess_bus_pwrd) - Ac_ess_past_value
    Ac_ess_past_value = get(AC_ess_bus_pwrd)
    if Ac_ess_delta > 0 then
        CHARGE_START_TIME = get(TIME)
    end  
end

--SASL callbacks-------------------------------------------------------------------------------------------------
function update()
    perf_measure_start("EFB:update()")
  
    EFB_CURSOR_X, EFB_CURSOR_Y, EFB_CURSOR_on_screen = Cursor_texture_to_local_pos(position[1], position[2], position[3], position[4], 4096, 4096)
    EFB_updates_pages[EFB_PAGE]()
    update_battery()

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

    if EFB_PAGE ~= 10 then
        jon_told_me_not_to_create_super_long_names_for_functions_but_this_function_draw_horizontal_line_with_certain_width_centered(EFB_UNDERLINE_POS, 738,EFB_UNDERLINE_THICKNESS ,EFB_UNDERLINE_WIDTH ,EFB_WHITE) --DRAWS THE UNDERLINE OF THE PAGE TITLE
    end

    if CHARGE_START_TIME == 0 then
        --do sth
    elseif CHARGE_TIME_LEFT < CHARGE_SCREEN_TIME then	-- Screen is showing charge icon
        sasl.gl.drawTexture (EFB_Charging, 0 , 0 , 1143 , 800 , Charging_alpha_controller )
    else
        CHARGE_START_TIME = 0 -- Let's reset it for the future
    end

    if EFB_OFF == false then
        draw_cursor()
    end

    if get(AC_ess_bus_pwrd) == 1 and EFB_OFF == false then
        sasl.gl.drawTexture (EFB_Charging_Overlay, 0 , 0 , 1143 , 800 , EFB_WHITE )
    end

    perf_measure_stop("EFB:draw()")
end


