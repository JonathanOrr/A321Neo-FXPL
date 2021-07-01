-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------
-- File: 3.lua 
-- Short description: EFB page 3
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------
include("EFB/EFB_pages/3_subpage2.lua")
include("EFB/EFB_pages/3_subpage3.lua")
include("libs/table.save.lua")
include('libs/geo-helpers.lua')
include("EFB/efb_systems.lua")
include("EFB/efb_topcat.lua")


-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local BUTTON_PRESS_TIME = 0.5
local WEIGHT_PER_PASSENGER = 90 --kg
local DRY_OPERATING_WEIGHT = 47777
local MAX_WEIGHT_VALUES = {8, 80, 100, 5700, 7000, 40000}
local DEFAULT_TAXI_FUEL = 500
local NUMBER_OF_SUBPAGES = 3

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------

New_takeoff_data_available = true

-- LOAD & CG
local load_target = {0,0,0,0,0,Round(get(FOB),0)}
local load_actual = {0,0,0,0,0,Round(get(FOB),0)} -- not a live value! does not change in flight!!!!!!!
local total_load_target = 0

local default_cg = 25
final_cg = 0    -- Need to be noon-local for subpages
local predicted_cg = 0

local percent_cg_to_coordinates = {{-9999,471}, {14, 471}, {22, 676}, {30,882}, {38.2,1092}, {9999,1085}}
local tow_to_coordinates = {{-9999,78}, {45,78}, {102.6,440}, {9999,440}}

local predicted_tow = 0

-- Graphics and others
local dropdown_expanded = {false, false}
local dropdown_selected = {1,1}
local dropdown_1 = {}
local dropdown_2 = {}

local avionics_bay_is_initialising = false

key_p3s1_focus = 0 --0 nothing, 1 oa, 2 ob, 3 oc, 4 cf, 5 ca, 6 fuel
local key_p3s1_buffer = ""

local load_button_begin = 0

efb_subpage_number = 1

deparr_apts = {"", ""}

local tank_index_center = {
    {5000,   -1},
    {10000 , -1},
    {15000 , -2},
    {20000 , -3},
    {25000 , -4},
    {30000 , -4},
    {35000 , -5},
    {40000 , -6},
    {45000 , -7},
    {50000 , -7},
    {55000 , -8},
    {60000 , -9},
    {FUEL_C_MAX , -10},
}

local tank_index_wing = {
    {5000,   -1},
    {10000 , -1},
    {15000 , -2},
    {20000 , -2},
    {25000 , -2},
    {30000 , -3},
    {35000 , -3},
    {40000 , -3},
    {45000 , -3},
    {50000 , -3},
    {55000 , -2},
    {60000 , -2},
    {FUEL_LR_MAX, -1},
}

local tank_index_act = {
    {0,     0},
    {24500 , 0},
}

local tank_index_rct = {
    {0,     0},
    {24500 , 0},
}

local passenger_index_front = {
    {0, 0},
    {10200, -23}
}

local passenger_index_aft = {
    {0, 0},
    {10200, 24}
}

local cargo_index_front = {
    {0, 0},
    {5700, -15.7}
}

local cargo_index_aft = {
    {0, 0},
    {7000, 12.5}
}



-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function set_initial_weights_for_first_few_frames()
    if get(Time_since_last_rest) < 1 then
        load_actual[6] = Round(get(FOB), 0)
        load_target[6] = Round(get(FOB), 0)
    end
end

--MOUSE RESET
function onMouseDown ( component , x , y , button , parentX , parentY )
    if key_p3s1_focus ~= 0 or keyboard_subpage_2_focus ~= 0 then
        if button == MB_LEFT or button == MB_RIGHT then
            key_p3s1_focus = 0
            keyboard_subpage_2_focus = 0
        end
    end
    return true
end

----------------KEYOARD STUFF

local function set_takeoff_runway_data_to_global()
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local apts = AvionicsBay.apts.get_by_name(deparr_apts[1])
        if #apts > 0 then    -- If the airport exists
        local apt = apts[1] 

            local selected1 = Round(dropdown_selected[1]/2, 0)
            if selected1 > 0 and apt ~= nil then
                local bearing = apt.rwys[selected1].bearing
                if Round(dropdown_selected[1]/2, 0) == dropdown_selected[1]/2 then
                    set(TOPCAT_torwy_bearing, apt.rwys[selected1].bearing + 180)
                    set(TOPCAT_torwy_length, apt.rwys[selected1].distance)
                else
                    set(TOPCAT_torwy_bearing, apt.rwys[selected1].bearing)
                    set(TOPCAT_torwy_length, apt.rwys[selected1].distance)
                end
            end
        end 
    end
end

local function set_landing_runway_data_to_global()
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local apts = AvionicsBay.apts.get_by_name(deparr_apts[2])
        if #apts > 0 then    -- If the airport exists
        local apt = apts[1] 

            local selected2 = Round(dropdown_selected[2]/2, 0)
            if selected2 > 0 and apt ~= nil then
                local bearing = apt.rwys[selected2].bearing
                if Round(dropdown_selected[2]/2, 0) == dropdown_selected[2]/2 then
                    set(TOPCAT_ldgrwy_bearing, apt.rwys[selected2].bearing + 180)
                    set(TOPCAT_ldgrwy_length, apt.rwys[selected2].distance)
                else
                    set(TOPCAT_ldgrwy_bearing, apt.rwys[selected2].bearing)
                    set(TOPCAT_ldgrwy_length, apt.rwys[selected2].distance)
                end
                set(TOPCAT_ldgrwy_elev, apt.alt)
            end
        end 
    end
end

local airport_reset_flags = {true,true} -- 1 is dep 2 is arr
local function request_departure_runway_data()
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() and not airport_reset_flags[1] then
        local apts = AvionicsBay.apts.get_by_name(deparr_apts[1])
        if #apts > 0 then    -- If the airport exists
            local apt = apts[1]    -- Take the airport
            dropdown_1 = {} -- CLEAR IT FIRST
            for i=1, #apt.rwys do
                table.insert(dropdown_1, apt.rwys[i].name) 
                table.insert(dropdown_1, apt.rwys[i].sibl_name) 
                set_takeoff_runway_data_to_global() -- SET THE RUNWAY DATA AFTER PLUGGING IN THE TABLE, SO THAT THE NUMBERS DO NOT REMAIN IN 0,0 IN CASE THE USER DOESN'T TOUCH THE DROPDOWN AT ALL
            end
        end
        airport_reset_flags[1] = true
        avionics_bay_is_initialising = false
    elseif not airport_reset_flags[1] then
        avionics_bay_is_initialising = true
    end
end

local function request_arrival_runway_data()
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() and not airport_reset_flags[2] then
        local apts = AvionicsBay.apts.get_by_name(deparr_apts[2])
        if #apts > 0 then    -- If the airport exists
            local apt = apts[1]    -- Take the airport
            dropdown_2 = {} -- CLEAR IT FIRST
            for i=1, #apt.rwys do

                table.insert(dropdown_2, apt.rwys[i].name) 
                table.insert(dropdown_2, apt.rwys[i].sibl_name) 
                set_landing_runway_data_to_global() -- SET THE RUNWAY DATA AFTER PLUGGING IN THE TABLE, SO THAT THE NUMBERS DO NOT REMAIN IN 0,0 IN CASE THE USER DOESN'T TOUCH THE DROPDOWN AT ALL
            end
        end
        airport_reset_flags[2] = true
        avionics_bay_is_initialising = false
    elseif not airport_reset_flags[2] then
        avionics_bay_is_initialising = true
    end
end

local function p3s1_dropdown_buttons( x,y,w,h, table, identifier)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        dropdown_expanded[identifier] = not dropdown_expanded[identifier]
    end)
    for i=1, #table do
        if dropdown_expanded[identifier] then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2 + 5, y - h*i - 14, w-10 + ( x - w/2 + 5), h-2 + ( y - h*i - 14),function ()
                dropdown_selected[identifier] = i
                dropdown_expanded[identifier] = false
                set_takeoff_runway_data_to_global()--EVERYTIME THE USER CLICKS THE RUNWAY DROPDOWN MENU, IT REQUESTS THE RUNWAY DATA ONCE. THAT IS THE ONLY WAY I CAN THINK OF TO REFRESH RUNWAY DATA WITHOUT USING UPDATE LOOP.
                set_landing_runway_data_to_global()
            end)
        end
    end
    if dropdown_expanded[identifier] then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
            dropdown_expanded[identifier] = false
        end)
    end
end

local function draw_avionics_bay_standby()
    if avionics_bay_is_initialising then
        sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, EFB_BACKGROUND_COLOUR)
        drawTextCentered(Font_Airbus_panel,  572, 355, "INITIALISING AVIONICS BAY", 30, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
end

local function p3s1_plug_in_the_buffer()
    if key_p3s1_focus < 7 then
        if string.len(key_p3s1_buffer) <= 0 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
        else
            load_target[key_p3s1_focus] = math.min(MAX_WEIGHT_VALUES[key_p3s1_focus], key_p3s1_buffer) --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET ARRAY
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
        end
    elseif key_p3s1_focus == 7 then
        if string.len(key_p3s1_buffer) <= 3 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
        else
            deparr_apts[1] = key_p3s1_buffer --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
            airport_reset_flags[1] = false
        end
    elseif key_p3s1_focus == 8 then
        if string.len(key_p3s1_buffer) <= 3 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
        else
            deparr_apts[2] = key_p3s1_buffer --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
            key_p3s1_focus = 0
            key_p3s1_buffer = ""
            airport_reset_flags[2] = false
        end
    else
        assert(key_p3s1_focus > 8, "P3S1 KEYBOARD OUT OF FOCUS, CONTACT HENRICK KU")
    end
end

function p3s1_revert_to_previous_and_delete_buffer()
    key_p3s1_focus = 0
    key_p3s1_buffer = ""
end

local function p3s1_construct_the_buffer(char)
    if key_p3s1_focus < 7 then
        local read_n = tonumber(string.char(char)) --JUST TO MAKE SURE WHAT YOU TYPE IS A NUMBER
        if read_n ~= nil and string.len(key_p3s1_buffer) < 7 then -- "tonumber()" RETURNS nil IF NOT A NUMBER, ALSO MAKES SURE STRING LENGTH IS <7
            key_p3s1_buffer = key_p3s1_buffer..string.char(char)
        end
    elseif key_p3s1_focus >= 7 then
        local read_n = tonumber(string.char(char)) --JUST TO MAKE SURE WHAT YOU TYPE IS AN ALPHABET
        if read_n == nil and string.len(key_p3s1_buffer) < 7 then -- "tonumber()" RETURNS nil IF NOT A NUMBER, ALSO MAKES SURE STRING LENGTH IS <7
            key_p3s1_buffer = string.upper(key_p3s1_buffer..string.char(char))
        end
    end
end

function EFB_onKeyDown_page3_subpage_1(component, char, key, shiftDown, ctrlDown, altOptDown)
    if efb_subpage_number == 1 then
        if key_p3s1_focus == 0 then
            return false
        end
            if char == SASL_KEY_DELETE then --BACKSPACE
                key_p3s1_buffer = string.sub(key_p3s1_buffer, 1, -2)
            elseif char == SASL_VK_RETURN then --ENTER
                p3s1_plug_in_the_buffer()
            elseif char == SASL_VK_ESCAPE then --REVERT TO THE PREVIOUS VALUE.
                p3s1_revert_to_previous_and_delete_buffer()
            else
                p3s1_construct_the_buffer(char)
            end
        return true
    end
end


--------------------------------------------------------------------------------------------------------------------------------SUBPAGE 1

local function load_weights_from_file()
end

local function save_weights_to_file()
    table.save(load_target, moduleDirectory .. "/Custom Module/saved_configs/previous_load_target")
end

local function draw_focus_frame()
    if key_p3s1_focus == 7 then
        efb_draw_focus_frames(71, 565, 93, 27)
    elseif key_p3s1_focus == 8 then
        efb_draw_focus_frames(357, 565, 93, 27)
    end
end

local function runway_related_buttons()
    --------------------------------BELOW ARE FOR RUNWAY SELECTION FOR PERF!!!!!!!!!!!!!!!!!!!!!!!!
    --------------------------------BELOW ARE FOR RUNWAY SELECTION FOR PERF!!!!!!!!!!!!!!!!!!!!!!!!

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 71 , 565, 163, 591,function ()
        p3s1_plug_in_the_buffer()
        key_p3s1_focus = key_p3s1_focus == 7 and 0 or 7
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 357 , 565, 449, 591,function ()
        p3s1_plug_in_the_buffer()
        key_p3s1_focus = key_p3s1_focus == 8 and 0 or 8
    end)

    if key_p3s1_focus == 7 then
        click_anywhere_except_that_area( 71 , 565, 163, 591, p3s1_plug_in_the_buffer)
    elseif key_p3s1_focus == 8 then
        click_anywhere_except_that_area( 357, 565, 449, 591, p3s1_plug_in_the_buffer)
    end

    p3s1_dropdown_buttons(230, 578, 90, 28,    dropdown_1, 1)
    p3s1_dropdown_buttons(511, 578, 90, 28,    dropdown_2, 2)

    --------------------------------ABOVE ARE FOR RUNWAY SELECTION FOR PERF!!!!!!!!!!!!!!!!!!!!!!!!
    --------------------------------ABOVE ARE FOR RUNWAY SELECTION FOR PERF!!!!!!!!!!!!!!!!!!!!!!!!
end


--------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------BELOW ARE THE LOOPS AND BUTTONS
--------------------------------------------------------------------------------------------------------------------------------

local function Subpage_1_buttons()
    runway_related_buttons()
end

local function EFB_update_page_3_subpage_1() --UPDATE LOOP
    request_departure_runway_data()
    request_arrival_runway_data()
end

local function EFB_draw_page_3_subpage_1() -- DRAW LOOP

    sasl.gl.drawTexture (EFB_LOAD_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )

    if string.len(key_p3s1_buffer) > 0 then --THE PURPOSE OF THIS IFELSE IS TO PREVENT THE CURSOR FROM COVERING UP THE PREVIOUS VALUE, WHEN THE SCRATCHPAD IS EMPTY.
        drawTextCentered( Font_Airbus_panel , 116 , 578, key_p3s1_focus == 7 and key_p3s1_buffer or deparr_apts[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_Airbus_panel , 403 , 578, key_p3s1_focus == 8 and key_p3s1_buffer or deparr_apts[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    else
        drawTextCentered( Font_Airbus_panel , 116 , 578, deparr_apts[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_Airbus_panel , 403 , 578, deparr_apts[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end

    draw_dropdown_menu(230, 578, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_1, dropdown_expanded[1], dropdown_selected[1])
    draw_dropdown_menu(511, 578, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_2, dropdown_expanded[2], dropdown_selected[2])

    draw_focus_frame()
    draw_avionics_bay_standby()

--------------------------------------------------------------------------
end

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
local function initialize()
end

initialize()

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------SUBPAGE 2

local function EFB_draw_page_3_subpage_2() --DRAW LOOP
    p3s2_draw()
end

local function EFB_update_page_3_subpage_2() --UPDATE LOOP
    p3s2_update()
end

local function Subpage_2_buttons()
    p3s2_buttons()
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------SUBPAGE 3

local function EFB_draw_page_3_subpage_3() --DRAW LOOP
    p3s3_draw()
end

local function EFB_update_page_3_subpage_3() --UPDATE LOOP
    p3s3_update()
end

local function Subpage_3_buttons()
    p3s3_buttons()
end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------MUTUAL LOOPS

local function mutual_button_loop()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 1031,18,1099,48, function () --SELECTOR BUTTONS WORK AT ALL TIMES
        efb_subpage_number = math.min(efb_subpage_number + 1, NUMBER_OF_SUBPAGES)
        key_p3s1_focus = 0
        key_p3s1_buffer = ""
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 954,18,1021,48, function ()
        efb_subpage_number = math.max( efb_subpage_number - 1, 1)
    end)
end

local function mutual_update_loop()
end

local function mutual_draw_loop()
    SASL_draw_img_center_aligned (EFB_INFO_selector, 1026,33, 147, 32, EFB_WHITE) -- THIS IS THE SELECTOR, IT DRAWS ON ALL PAGES

        sasl.gl.drawText ( Font_Airbus_panel , 880 , 24 , "Page "..efb_subpage_number.."/"..NUMBER_OF_SUBPAGES.."", 20 , false , false , TEXT_ALIGN_CENTER , EFB_WHITE)

end

-------------------------------------------------------------------------------
-- Main Functions
-------------------------------------------------------------------------------


function EFB_execute_page_3_buttons()

    if  efb_subpage_number == 1 then
        Subpage_1_buttons()
    elseif efb_subpage_number == 2 then
        Subpage_2_buttons()
    elseif efb_subpage_number == 3 then
        Subpage_3_buttons()
    end

    mutual_button_loop()
end

--UPDATE LOOPS--
function EFB_update_page_3()

    if efb_subpage_number == 1 then
        EFB_update_page_3_subpage_1()
    elseif efb_subpage_number == 2 then
        EFB_update_page_3_subpage_2()
    elseif efb_subpage_number == 3 then
        EFB_update_page_3_subpage_3()
    end
    mutual_update_loop()
end

--DRAW LOOPS--
function EFB_draw_page_3()
    if efb_subpage_number == 1 then
        EFB_draw_page_3_subpage_1()
    elseif efb_subpage_number == 2 then
        EFB_draw_page_3_subpage_2()
    elseif efb_subpage_number == 3 then
        EFB_draw_page_3_subpage_3()
    end
    mutual_draw_loop()
end

