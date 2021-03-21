local hud_colour = "light"
local efb_up_button_begin = 0
local efb_down_button_begin = 0
local efb_save_buttn_begin = 0
--------------------------------------------------------------


include("libs/table.save.lua")
include("EFB/efb_functions.lua")



local function draw_throttle_value()
    if Round(get(Cockpit_throttle_lever_L),2) == 0 then
        drawTextCentered( Font_Airbus_panel , 331 , 357, "L:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 331 , 357, Round(get(Cockpit_throttle_lever_L),2) == 1 and "L:1.00" or "L:"..Round(get(Cockpit_throttle_lever_L),2) , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end

    if Round(get(Cockpit_throttle_lever_R),2) == 0 then
        drawTextCentered( Font_Airbus_panel , 389 , 357, "R:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 389 , 357, Round(get(Cockpit_throttle_lever_L),2) == 1 and "R:1.00" or "R:"..Round(get(Cockpit_throttle_lever_L),2) , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end
end

local function draw_hud_buttons()
    if hud_colour == "light" then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 102,580,192,58,2,1)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 188,580,192,58,2,2)
        sasl.gl.drawTexture ( EFB_CONFIG_hud, 0 , 0 , 1143 , 800 , 0,255/255,0 )
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 102,580,192,58,2,2)
        SASL_drawSegmentedImg_xcenter_aligned (EFB_highlighter, 188,580,192,58,2,1)
        sasl.gl.drawTexture ( EFB_CONFIG_hud, 0 , 0 , 1143 , 800 , 0,170/255,0 )
    end


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

local function draw_save_config_button()
    if get(TIME) - efb_save_buttn_begin < 0.5 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,1)
    end
end

local function draw_toggle_switches()
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 364, 78, 18, 2, EFB_preferences["syncqnh"] == 1 and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 330, 78, 18, 2, EFB_preferences["rolltonws"] == 1 and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 296, 78, 18, 2, EFB_preferences["tca"] == 1 and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 262, 78, 18, 2, EFB_preferences["pausetd"] == 1 and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 228, 78, 18, 2, EFB_preferences["copilot"] == 1 and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 194, 78, 18, 2, EFB_preferences["flarelaw"] == 1 and 2 or 1)
end

local function draw_volume_sliders()
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_ext)*333+680 , 619 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_int)*333+680 , 559 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_wind)*333+680 , 499 , 22 , 22 , ECAM_WHITE )
    sasl.gl.drawTexture ( EFB_CONFIG_slider, get(VOLUME_cabin)*333+680 , 439 , 22 , 22 , ECAM_WHITE )
end


--MOUSE & BUTTONS--
function EFB_execute_page_4_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,618,673,745, function ()
        set(VOLUME_ext, math.max(get(VOLUME_ext)-0.1, 0))
        --print("ext_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,618,1073,745, function ()
        set(VOLUME_ext, math.min(get(VOLUME_ext)+0.1, 1))
        --print("ext_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,557,673,584, function ()
        set(VOLUME_int, math.max(get(VOLUME_int)-0.1, 0))
        --print("int_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,557,1073,584, function ()
        set(VOLUME_int, math.min(get(VOLUME_int)+0.1, 1))
        --print("int_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,497,673,525, function ()
        set(VOLUME_wind, math.max(get(VOLUME_wind)-0.1, 0))
        --print("wind_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,497,1073,525, function ()
        set(VOLUME_wind, math.min(get(VOLUME_wind)+0.1, 1))
        --print("wind_up")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 642,437,673,466, function ()
        set(VOLUME_cabin, math.max(get(VOLUME_cabin)-0.1, 0))
        --print("cabin_down")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1042,437,1073,466, function ()
        set(VOLUME_cabin, math.min(get(VOLUME_cabin)+0.1, 1))
        --print("cabin_up")
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

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 414,46,738,90, function ()
        efb_save_buttn_begin = get(TIME)
    end)

    --Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 751,150,972,174, function ()
    --    table.save(EFB_preferences, moduleDirectory .. "/Custom Module/saved_configs/EFB_preferences")
    --end)
    
----------------------------------------------TOGGLE OPTIONS
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,363,659,381, function ()
        EFB_preferences["syncqnh"] = 1 - EFB_preferences["syncqnh"]
        --print("toggle_options_sync")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,329,659,347, function ()
        EFB_preferences["rolltonws"] = 1 - EFB_preferences["rolltonws"]
        --print("toggle_options_roll")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,295,659,313, function ()
        EFB_preferences["tca"] = 1 - EFB_preferences["tca"]
        --print("toggle_options_tca")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,261,659,279, function ()
        EFB_preferences["pausetd"] = 1 - EFB_preferences["pausetd"]
        --print("toggle_options_pausetd")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,227,659,245, function ()
        EFB_preferences["copilot"] = 1 - EFB_preferences["copilot"]
        --print("toggle_options_callout")
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,193,659,211, function ()
        set(FBW_mode_transition_version, 1 - get(FBW_mode_transition_version))
        EFB_preferences["flarelaw"] = get(FBW_mode_transition_version)
        --print("toggle_flarelaw_mode")
    end)
end

--UPDATE LOOPS--
function EFB_update_page_4() -- update loop
end

--DRAW LOOPS--
function EFB_draw_page_4()



    draw_throttle_value()
    draw_hud_buttons()
    draw_save_config_button()
    sasl.gl.drawTexture ( EFB_CONFIG_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE ) --place the bgd in the middle or it'll cover up the highlighter buttons.
    draw_toggle_switches()
    draw_volume_sliders()

    print(EFB_CURSOR_X, EFB_CURSOR_Y)
    --print(get(Cockpit_throttle_lever_L))
end