local BUTTON_PRESS_TIME = 0.5
local WAITING_SCREEN_TIME = 1.6

-----------------------------------------------

local refresh_button_begin = 0
local send_data_button_begin = 0
local waiting_screen_begin = 0

--column 1 displayed data
local displayed_zfw = 0
local displayed_zfwcg = 0
local displayed_block_fuel = 0

--column 2 displayed data
local displayed_v1 = 0
local displayed_vr = 0
local displayed_v2 = 0
local displayed_flaps = 0
local displayed_trim = 0
local displayed_flex = 0
local displayed_wind = 0
local displayed_tow = 0
local displayed_flex_corr = 0
local displayed_mtow_corr = 0
local displayed_rwy_length = 0

local dropdown_1 = {"FLAPS 1+F", "FLAPS 2", "FLAPS 3"}
local dropdown_2 = {"TOGA", "FLEX"}
local dropdown_3 = {"DRY", "WET"}
local dropdown_4 = {"ON", "OFF"}
local dropdown_5 = {"ON", "OFF"}
local dropdown_6 = {"ON", "OFF"}
local dropdown_expanded = {false,false,false,false,false,false}
local dropdown_selected = {1,1,1,1,#dropdown_5,#dropdown_6}

include("EFB/efb_topcat.lua")

local flaps_table = {"1+F", 2, 3}
---------------------------------------------------------------------------------------------------------------------------------


local function draw_no_dep_data()
    if deparr_apts[1] == "" then
        sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, EFB_BACKGROUND_COLOUR)
        drawTextCentered(Font_Airbus_panel,  572, 360, "NO DEPARTURE DATA", 30, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
        drawTextCentered(Font_Airbus_panel,  572, 333, "RETURN TO PAGE 3 SUBPAGE 1", 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
end

local function fetch_wind_data()
    displayed_wind = Round(get(Wind_HDG), 0).."°/"..Round(get(Wind_SPD)).."kt"
end

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s2_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

local function draw_standby()
    if get(TIME) - waiting_screen_begin < WAITING_SCREEN_TIME then
        draw_standby_screen("CALCULATING....")
    end
end

local function draw_buttons()
    if get(TIME) -  refresh_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 343,115,544,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 343,115,544,32,2,2)
    end
    if get(TIME) -  send_data_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 800,115,544,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 800,115,544,32,2,2)
    end

    drawTextCentered( Font_Airbus_panel , 343 , 130, "REFRESH"    , 22 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel , 800 , 130, "FORWARD TO MCDU"    , 22 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )

end

local function draw_qnh_oat()
    drawTextCentered( Font_Airbus_panel , 909 , 518, Round(constant_conversions() ,0) , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_FULL_GREEN )
    drawTextCentered( Font_Airbus_panel , 909 , 491, Round(get(OTA),0) , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_FULL_GREEN  )
end



local function draw_column_1_values()
    drawTextCentered( Font_Airbus_panel , 225 , 361, displayed_zfw      , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 225 , 335, displayed_zfwcg    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 225 , 309, displayed_block_fuel     , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
end

local function draw_column_2_values()
    drawTextCentered( Font_Airbus_panel , 549 , 361, displayed_v1    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 335, displayed_vr    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 309, displayed_v2    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 283, displayed_flaps , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 257, displayed_trim , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 231, displayed_flex , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
end

local function draw_column_3_values()
    drawTextCentered( Font_Airbus_panel , 885 , 361, displayed_wind  , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 885 , 335, displayed_tow  , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 885 , 309, displayed_flex_corr, 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 885 , 283, displayed_mtow_corr, 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 885 , 257, displayed_rwy_length, 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
end

local function refresh_data_reminder()
    if New_takeoff_data_available then
        drawTextCentered( Font_Airbus_panel , 370 , 45, "NEW PERFORMANCE DATA AVAILABLE, PLEASE REFRESH"  , 22 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_RED )
    end
end

local function refresh_data()

    --request data from the topcat
    local flex_temp, flex_temp_corr = flex_calculation(dropdown_selected[4],dropdown_selected[5],dropdown_selected[6])
    local mtwo_decrease = mtow_decrease_calculation(dropdown_selected[4],dropdown_selected[5],dropdown_selected[6])
    local v1, vr, v2 = vspeeds_calculation(dropdown_selected[1], dropdown_selected[3])

    displayed_zfw =Round(get(Gross_weight) - get(FOB), 0)
    displayed_zfwcg = Round_fill(WEIGHTS.get_current_cg_perc(),1).."%"
    displayed_block_fuel = Round(get(FOB), 0) --see variables created inside draw lop in page 3 subpage 1
    displayed_v1 = v1
    displayed_vr = vr
    displayed_v2 = v2
    displayed_flaps = flaps_table[dropdown_selected[1]]
    displayed_flex = dropdown_selected[2] == 1 and "NO FLEX" or flex_temp
    displayed_tow = Round(get(Gross_weight),0)
    displayed_flex_corr = dropdown_selected[2] == 1 and "N/A" or flex_temp_corr
    displayed_mtow_corr = Round(math.abs(mtwo_decrease), -2)
    if get(TOPCAT_torwy_length) ~= 0 then
        displayed_rwy_length = Round(get(TOPCAT_torwy_length),-1)
    else
        displayed_rwy_length = "NO DATA"
    end

    trim_raw = Round(Table_extrapolate(pitch_trim_table, 25),1)
    set(TOPCAT_trim, Round(trim_raw,1))
    if trim_raw > 0 then
        displayed_trim = "UP"..math.abs(trim_raw)
    else
        displayed_trim = "DN"..math.abs(trim_raw)
    end

    New_takeoff_data_available = false
end

local dropdown_location = {
    {402,501,158,80},
    {645,529,158,52},
    {877,529,158,52},
    {115,422,158,52},
    {349,422,158,52},
    {609,422,158,52},
}


local function p3s2_dropdown_buttons( x,y,w,h, table, identifier)
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

local function draw_dropdowns()
    draw_dropdown_menu(688, 487, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_4, dropdown_expanded[6], dropdown_selected[6])
    draw_dropdown_menu(432, 487, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_4, dropdown_expanded[5], dropdown_selected[5])
    draw_dropdown_menu(194, 487, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_4, dropdown_expanded[4], dropdown_selected[4])
    draw_dropdown_menu(960, 594, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_3, dropdown_expanded[3], dropdown_selected[3])
    draw_dropdown_menu(720, 594, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_2, dropdown_expanded[2], dropdown_selected[2])
    draw_dropdown_menu(480, 594, 155, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_1, dropdown_expanded[1], dropdown_selected[1])
end


local function close_menu(number)
    dropdown_expanded[number] = false
end

local function close_menu_1()
    dropdown_expanded[1] = false
end
local function close_menu_2()
    dropdown_expanded[2] = false
end
local function close_menu_3()
    dropdown_expanded[3] = false
end
local function close_menu_4()
    dropdown_expanded[4] = false
end
local function close_menu_5()
    dropdown_expanded[5] = false
end
local function close_menu_6()
    dropdown_expanded[6] = false
end

--MOUSE & BUTTONS--
function p3s2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 206, 115, 480, 147,function () --refresh
        waiting_screen_begin = get(TIME)
        refresh_button_begin = get(TIME)
        execute_takeoff_performance() --see bottom of topcat script
        fetch_wind_data()
        -----------------------------------put this at the bottom
        refresh_data()
    end)

    p3s2_dropdown_buttons(480, 594, 155, 28, dropdown_1, 1)
    p3s2_dropdown_buttons(720, 594, 155, 28, dropdown_2, 2)
    p3s2_dropdown_buttons(960, 594, 155, 28, dropdown_3, 3)
    p3s2_dropdown_buttons(194, 487, 155, 28, dropdown_4, 4)
    p3s2_dropdown_buttons(432, 487, 155, 28, dropdown_5, 5)
    p3s2_dropdown_buttons(688, 487, 155, 28, dropdown_6, 6)
end

--UPDATE LOOPS--
function p3s2_update()
end

--DRAW LOOPS--
function p3s2_draw()
    draw_background()
    draw_buttons()
    draw_column_1_values()
    draw_column_2_values()
    draw_column_3_values()
    refresh_data_reminder()
    draw_qnh_oat()
    draw_dropdowns()
    draw_standby()
    draw_no_dep_data()
end

--DO AT THE BEGINNING
