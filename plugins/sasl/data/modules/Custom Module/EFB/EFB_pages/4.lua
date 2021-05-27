local hud_colour = "light"
local efb_up_button_begin = 0
local efb_down_button_begin = 0
local efb_save_buttn_begin = 0
local efb_align_button_begin = 0
--------------------------------------------------------------

local dropdown_expanded = {false}


include("libs/table.save.lua")
include("FBW/FBW_subcomponents/autothrust.lua")

local instant_align_command = findCommand("a321neo/cockpit/ADIRS/instantaneous_align")

local function draw_throttle_value()
    if Round(get(Cockpit_throttle_lever_L),2) == 0 then
        drawTextCentered( Font_Airbus_panel , 331 , 367, "L:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 331 , 367, Round(get(Cockpit_throttle_lever_L),2) == 1 and "L:1.00" or "L:"..Round(get(Cockpit_throttle_lever_L),2) , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end

    if Round(get(Cockpit_throttle_lever_R),2) == 0 then
        drawTextCentered( Font_Airbus_panel , 389 , 367, "R:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 389 , 367, Round(get(Cockpit_throttle_lever_R),2) == 1 and "R:1.00" or "R:"..Round(get(Cockpit_throttle_lever_R),2) , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end

    drawTextCentered( Font_Airbus_panel , 397 , 327, "REGISTERED DETENT:" , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_WHITE )

    if get(Lever_in_CL) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 296, "CLIMB" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
    elseif get(Lever_in_FLEX_MCT) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 296, "FLX/MCT" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
    elseif get(Lever_in_TOGA) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 296, "TOGA" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
    elseif Round(get(Cockpit_throttle_lever_L),2) == 0 and Round(get(Cockpit_throttle_lever_R),2) == 0 then
        drawTextCentered( Font_Airbus_panel , 397 , 296, "IDLE" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE)
    else
        drawTextCentered( Font_Airbus_panel , 397 , 296, "MANUAL" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE)
    end
end

local function draw_hud_buttons()
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 102,580,192,58,2,hud_colour == "light" and 1 or 2)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 188,580,192,58,2,hud_colour == "light" and 2 or 1)
    sasl.gl.drawTexture ( EFB_CONFIG_hud, 280 , 498 , 124 , 93 , 0,hud_colour == "light" and 255/255 or 170/255 ,0 )

    if get(TIME) - efb_up_button_begin < 0.5 then
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 144,524,192,58,2,2)
    else
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 144,524,192,58,2,1)
    end


    if get(TIME) - efb_down_button_begin < 0.5 then
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 144,482,192,58,2,2)
    else
    SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 144,482,192,58,2,1)
    end
end

local function draw_align_button()
    if get(TIME) - efb_align_button_begin < 0.5 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_align_button, 393,184,368,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_align_button, 393,184,368,32,2,1)
    end
end

local function draw_save_config_button()
    if get(TIME) - efb_save_buttn_begin < 0.5 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,1)
    end
end

local function draw_toggle_switches()
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 364, 78, 18, 2, EFB.preferences["syncqnh"] and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 330, 78, 18, 2, EFB.preferences["pausetd"] and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 296, 78, 18, 2, EFB.preferences["copilot"] and 2 or 1)
end

local function draw_volume_sliders()
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_ext)*333+680 , 619 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_int)*333+680 , 559 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_wind)*333+680 , 499 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_cabin)*333+680 , 439 , 22 , 22 , ECAM_WHITE )
end

local function draw_dropdowns()
    if dropdown_expanded[1] then
        sasl.gl.drawTexture (EFB_CONFIG_dropdown1 , 63 , 200 , 158 , 80 , ECAM_WHITE )
    end
    if EFB.preferences["nws"] == 0 then
        drawTextCentered( Font_Airbus_panel , 141 , 294, "ROLL"  , 19 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    elseif EFB.preferences["nws"] == 1 then
        drawTextCentered( Font_Airbus_panel , 141 , 294, "YAW"  , 19 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    elseif EFB.preferences["nws"] == 2 then
        drawTextCentered( Font_Airbus_panel , 141 , 294, "TILLER"  , 19 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end
end

local function close_menu_1()
    dropdown_expanded[1] = false
end

--MOUSE & BUTTONS--
function EFB_execute_page_4_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,618,673,745, function ()
        set(VOLUME_ext, math.max(get(VOLUME_ext)-0.1, 0))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,618,1073,745, function ()
        set(VOLUME_ext, math.min(get(VOLUME_ext)+0.1, 1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,557,673,584, function ()
        set(VOLUME_int, math.max(get(VOLUME_int)-0.1, 0))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,557,1073,584, function ()
        set(VOLUME_int, math.min(get(VOLUME_int)+0.1, 1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,497,673,525, function ()
        set(VOLUME_wind, math.max(get(VOLUME_wind)-0.1, 0))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,497,1073,525, function ()
        set(VOLUME_wind, math.min(get(VOLUME_wind)+0.1, 1))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,437,673,466, function ()
        set(VOLUME_cabin, math.max(get(VOLUME_cabin)-0.1, 0))
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,437,1073,466, function ()
        set(VOLUME_cabin, math.min(get(VOLUME_cabin)+0.1, 1))
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 69,594,136,623, function ()
        hud_colour = "light"
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 154,594,221,623, function ()
        hud_colour = "dark"
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 110,537,179,567, function ()
        efb_up_button_begin = get(TIME)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 110,495,179,526, function ()
        efb_down_button_begin = get(TIME)
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 301,184,485,216, function ()
        efb_align_button_begin = get(TIME)
        sasl.commandOnce(instant_align_command)
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 414,46,738,90, function ()
        efb_save_buttn_begin = get(TIME)
        local volume_buffer_table = {get(VOLUME_ext), get(VOLUME_int), get(VOLUME_wind), get(VOLUME_cabin)}
        table.save(EFB.preferences, moduleDirectory .. "/Custom Module/saved_configs/EFB_preferences_v2")
        table.save(volume_buffer_table, moduleDirectory .. "/Custom Module/saved_configs/EFB_volume_settings")
    end)
    
----------------------------------------------TOGGLE OPTIONS
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,363,659,381, function ()
        EFB.preferences["syncqnh"] = not EFB.preferences["syncqnh"]
        --print("toggle_options_sync")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,329,659,347, function ()
        EFB.preferences["pausetd"] = not EFB.preferences["pausetd"]
        --print("toggle_options_tca")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,295,659,313, function ()
        EFB.preferences["copilot"] = not EFB.preferences["copilot"]
        --print("toggle_options_pausetd")
    end)

    ----------------------------------------------OPEN DROPDOWNS

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 61,280,248,309, function ()
        dropdown_expanded[1] = not dropdown_expanded[1]
    end)
    if dropdown_expanded[1] then
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 61,252,248,280, function ()
            EFB.preferences["nws"] = 0
            close_menu_1()
        end)   
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 61,228,248,252, function ()
            EFB.preferences["nws"] = 1
            close_menu_1()
        end)   
        Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 61,200,248,228, function ()
            EFB.preferences["nws"] = 2
            close_menu_1()
        end)   
        click_anywhere_except_that_area( 61, 200, 220, 309, close_menu_1)
    end
end

local function table_loading_on_start()
    if table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_volume_settings") ~= nil then
        local volume_table_load =  table.load(moduleDirectory .. "/Custom Module/saved_configs/EFB_volume_settings")
        set(VOLUME_ext, volume_table_load[1])
        set(VOLUME_int, volume_table_load[2])
        set(VOLUME_wind, volume_table_load[3])
        set(VOLUME_cabin, volume_table_load[4])
    end
end
table_loading_on_start()


--UPDATE LOOPS--
function EFB_update_page_4() -- update loop
end

--DRAW LOOPS--
function EFB_draw_page_4()
    draw_throttle_value()
    draw_hud_buttons()
    draw_align_button()
    draw_save_config_button()
    sasl.gl.drawTexture ( EFB_CONFIG_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE ) --place the bgd in the middle or it'll cover up the highlighter buttons.
    draw_toggle_switches()
    draw_volume_sliders()
    draw_dropdowns()

    print(EFB_CURSOR_X, EFB_CURSOR_Y)
end
