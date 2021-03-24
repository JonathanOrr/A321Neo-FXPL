local BUTTON_PRESS_TIME = 0.5
local refresh_button_begin = 0
local send_data_button_begin = 0

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

include("EFB/efb_topcat.lua")

local flaps_table = {"1+F", 2, 3}

---------------------------------------------------------------------------------------------------------------------------------
local function compute_flaps()
    set(LOAD_flapssetting, 1)
end

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s2_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

local function draw_buttons()
    if get(TIME) -  refresh_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 343,215,544,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 343,215,544,32,2,2)
    end
    if get(TIME) -  send_data_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 800,215,544,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 800,215,544,32,2,2)
    end
end

local function draw_column_1_values()
    drawTextCentered( Font_Airbus_panel , 225 , 461, displayed_zfw      , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 225 , 435, displayed_zfwcg    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 225 , 409, displayed_block_fuel     , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
end

local function draw_column_2_values()
    drawTextCentered( Font_Airbus_panel , 549 , 461, displayed_v1    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 435, displayed_vr    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 409, displayed_v2    , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 383, displayed_flaps , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 357, displayed_trim , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
    drawTextCentered( Font_Airbus_panel , 549 , 331, displayed_flex , 22 ,false , false , TEXT_ALIGN_LEFT , EFB_LIGHTBLUE )
end

local function refresh_data()
    displayed_zfw = zfw_actual
    displayed_zfwcg = Round(final_cg,0)
    displayed_block_fuel = fuel_weight_actual --see variables created inside draw lop in page 3 subpage 1
    displayed_v1 = computed_v1
    displayed_vr = computed_vr
    displayed_v2 = computed_v2
    displayed_flaps = flaps_table[get(LOAD_flapssetting)]
    displayed_trim = Round(Table_extrapolate(pitch_trim_table, final_cg),0)
    displayed_flex = flex_temp
end

--MOUSE & BUTTONS--
function p3s2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 206, 215, 480, 247,function () --refresh
        refresh_button_begin = get(TIME)
        constant_conversions()
        v2_calculation()
        flex_calculation()
        other_spd_calculation()
        -----------------------------------put this at the bottom
        refresh_data()
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 663, 215, 936, 247,function () --refresh
        send_data_button_begin = get(TIME)
    end)
end

--UPDATE LOOPS--
function p3s2_update()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
    --print(zfw_actual )
end

--DRAW LOOPS--
function p3s2_draw()
    draw_background()
    draw_buttons()
    draw_column_1_values()
    draw_column_2_values()
end

