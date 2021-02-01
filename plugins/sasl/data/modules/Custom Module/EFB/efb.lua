fbo = true
--for the cursor

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

position = {2943, 1248, 1143, 800}
size = {1143, 800}

EFB_PAGE = 1
EFB_DELAYED_PAGE = 1
EFB_DELAYED_TRANSIT_FACTOR = 7
EFB_PREV_PAGE = 1
EFB_CURSOR_X = 0
EFB_CURSOR_Y = 0
EFB_CURSOR_on_screen = false

EFB_UNDERLINE_POS = 1

EFB_selector_transit_start = 0

AVITAB_INSTALLED = false

EFB_OFF = false

if findPluginBySignature("org.solhost.folko.avitab") ~= NO_PLUGIN_ID then
    Avitab_Enabled = globalProperty("avitab/panel_enabled")
    AVITAB_INSTALLED = true
    set(Avitab_Enabled, 0)
else
    AVITAB_INSTALLED = false
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

--SASL callbacks-------------------------------------------------------------------------------------------------
function update()
    EFB_CURSOR_X, EFB_CURSOR_Y, EFB_CURSOR_on_screen = Cursor_texture_to_local_pos(position[1], position[2], position[3], position[4], 4096, 4096)
    EFB_updates_pages[EFB_PAGE]()
    EFB_DELAYED_PAGE = Set_anim_value(EFB_DELAYED_PAGE, EFB_PAGE, 0, 10, EFB_DELAYED_TRANSIT_FACTOR)
    EFB_UNDERLINE_POS =   (27548.06 + (-53.64934 - 27548.06)/(1 +((EFB_DELAYED_PAGE/215.6605)^1.026289))  )
end

function draw()  ------KEEP THE draw_cursor() AT THE BOTTOM YOU DUMBASS!!!!!
    perf_measure_start("EFB:draw()")
    draw_efb_bgd()
    EFB_draw_pages[EFB_PAGE]()

    if EFB_PAGE ~= 10 then
        draw_horizontal_line_with_certain_width_centered(EFB_UNDERLINE_POS, 738, 1, (171 - 197.3*EFB_DELAYED_PAGE + 105.9167*EFB_DELAYED_PAGE^2 - 25.54167*EFB_DELAYED_PAGE^3 + 3.083333*EFB_DELAYED_PAGE^4 - 0.1583333*EFB_DELAYED_PAGE^5),EFB_WHITE) --DRAWS THE UNDERLINE OF THE PAGE TITLE
    end

    if EFB_OFF == false then
        draw_cursor()
    end
    perf_measure_stop("EFB:draw()")
end




