
local hud_colour = "light"
local efb_up_button_begin = 0
local efb_down_button_begin = 0
local efb_save_button_begin = 0
local efb_align_button_begin = 0

local dropdown_1 = {"ROLL", "YAW", "TILLER"}
local dropdown_expanded = {false}
local dropdown_selected = {1}

local function draw_throttle_value()

    local left_throttle = Round(get(Cockpit_throttle_lever_L),2)
    local right_throttle = Round(get(Cockpit_throttle_lever_R),2)

    if left_throttle == 0 then
        drawTextCentered( Font_Airbus_panel , 331 , 367, "L:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 331 , 367, left_throttle == 1 and "L:1.00" or "L:"..left_throttle , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end

    if right_throttle == 0 then
        drawTextCentered( Font_Airbus_panel , 389 , 367, "R:0.00" , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    else
        drawTextCentered( Font_Airbus_panel , 389 , 367, right_throttle == 1 and "R:1.00" or "R:"..right_throttle , 17 ,false , false , TEXT_ALIGN_LEFT , EFB_WHITE )
    end

    drawTextCentered( Font_Airbus_panel , 397 , 327, "REGISTERED DETENT:" , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_WHITE )

    if get(Lever_in_CL) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 294, "CLIMB" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, EFB_FULL_GREEN)
    elseif get(Lever_in_FLEX_MCT) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 294, "FLX/MCT" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, EFB_FULL_GREEN)
    elseif get(Lever_in_TOGA) == 1 then
        drawTextCentered( Font_Airbus_panel , 397 , 294, "TOGA" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, EFB_FULL_GREEN)
    elseif left_throttle == 0 and right_throttle == 0 then
        drawTextCentered( Font_Airbus_panel , 397 , 294, "IDLE" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, EFB_LIGHTGREY)
    elseif left_throttle < 0 and right_throttle < 0 then
        drawTextCentered( Font_Airbus_panel , 397 , 294, "REVR" , 23 ,false , false , TEXT_ALIGN_CENTER , ECAM_ORANGE)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, ECAM_ORANGE)
    else
        drawTextCentered( Font_Airbus_panel , 397 , 294, "MANUAL" , 23 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE)
        Sasl_DrawWideFrame(341, 280, 110, 30, 2, 0, EFB_LIGHTBLUE)
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

local function draw_dropdowns()
    draw_dropdown_menu(143, 294, 219-63, 307-281, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_1, dropdown_expanded[1], dropdown_selected[1])
end

local function p4s1_dropdown_buttons( x,y,w,h, table, identifier)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        dropdown_expanded[identifier] = not dropdown_expanded[identifier]
    end)
    for i=1, #table do
        if dropdown_expanded[identifier] then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2 + 5, y - h*i - 14, w-10 + ( x - w/2 + 5), h-2 + ( y - h*i - 14),function ()
                dropdown_selected[identifier] = i
                dropdown_expanded[identifier] = false
            end)
        end
    end
    if dropdown_expanded[identifier] then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
            dropdown_expanded[identifier] = false
        end)
    end
end

local function draw_save_config_button()
    if get(TIME) - efb_save_button_begin < 0.5 then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,2)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_CONFIG_save, 577,54,634,32,2,1)
    end
end

local function draw_toggle_switches()
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 364, 78, 18, 2, EFB.pref_get_syncqnh() and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 330, 78, 18, 2, EFB.pref_get_pausetd() and 2 or 1)
    SASL_drawSegmentedImg_xcenter_aligned (EFB_toggle, 640, 296, 78, 18, 2, EFB.pref_get_copilot() and 2 or 1)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function p4s1_buttons()
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
        sasl.commandOnce(findCommand("a321neo/cockpit/ADIRS/instantaneous_align"))
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 414,46,738,90, function ()
        efb_save_button_begin = get(TIME)
        EFB.pref_save()
    end)

    -----------------------DROPDOWNS
    
    p4s1_dropdown_buttons(143, 294, 219-63, 307-281, dropdown_1, 1)

----------------------------------------------TOGGLE OPTIONS
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,363,659,381, function ()
        EFB.pref_set_syncqnh( not EFB.pref_get_syncqnh() )
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,329,659,347, function ()
        EFB.pref_set_pausetd( not EFB.pref_get_pausetd() )
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 620,295,659,313, function ()
        EFB.pref_set_copilot( not EFB.pref_get_copilot() )
    end)
end

function p4s1_update()
    EFB.pref_set_nws(dropdown_selected[1]-1)
end

function p4s1_draw()
    draw_throttle_value()
    draw_hud_buttons()
    draw_align_button()
    draw_save_config_button()
    sasl.gl.drawTexture ( EFB_CONFIG_bgd, 0 , 0 , 1143 , 800 , ECAM_WHITE ) --place the bgd in the middle or it'll cover up the highlighter buttons.
    draw_toggle_switches()
    draw_dropdowns()
end
