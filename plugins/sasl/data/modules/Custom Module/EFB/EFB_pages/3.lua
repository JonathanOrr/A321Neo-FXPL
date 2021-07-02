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

--------OK SO WORKFLOW OF THE SCRIPT!!!!!!! ~ Henrick 2 Jul 2021

--EFB_p3s1_onmousedown(x,y,i) this kind of function consisting of x y and i, are always run in a for loop.
--The for loop has to be looped from 1 to 6, because there are 6 sliders.
--when you click a slider, a variable "selected_slider" will be changed to the corresponding slider.
--This value is used to link the mouse cursor and the slider.
--EFB_p3s1_onmouseup() or not EFB_CURSOR_on_screen will make the selected slider become 0.
--
--Now comes the fun part.
--slider_to_weights_translator() is run every frame as it ensures that the actual values (in kg, ppl, etc) are always corresponding to the slider.
--draw_slider_corresponding_values() is drawn on top of the slider as a graphical display of the slider corresponding value.
--When the load button is called, set_values() is called. The slider corresponding value from slider_to_weights_translator() is set to the weights function.
--Weights function are created by Rico, in weights.lua.

-- To whoever is reading this, this is the ceiling of my coding ability. Please improve this if you can!
-- It is the second attempt of me writing this page, I abandoned the first page as the workflow was a mess and I lost track.

--11pm now, got to shower. Cheers!

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
local WEIGHT_PER_PASSENGER = 80 --kg
local DRY_OPERATING_WEIGHT = 47777
local MAX_WEIGHT_VALUES = {8, 80, 100, 5700, 7000, 40000}
local DEFAULT_TAXI_FUEL = 500
local NUMBER_OF_SUBPAGES = 3

-------------------------------------------------------------------------------
-- Global variables
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-----------------------------------------------------------DO NOT TOUCH!!!!!!
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
local reset_button_begin = 0

efb_subpage_number = 1

deparr_apts = {"", ""}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-----------------------------------------------------------DO NOT TOUCH!!!!!!
-------------------------------------------------------------------------------

local slider_pos = {0,0.5,0,0,0,5000/40000}
local slider_actual_values = {0,0.5,0,0,0,0}
local focused_slider = 0

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function within(what,min,max)
    if what <= max and what >= min then 
        return true 
    else 
        return false 
    end
end

local function draw_slider_corresponding_values()
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 0, tostring(Round(slider_actual_values[1]/WEIGHT_PER_PASSENGER,0).." PPL") , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 1, slider_actual_values[2] <= 0.5 and "FWD" or "AFT" , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 2, tostring(slider_actual_values[3]).." KG" , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 3, tostring(slider_actual_values[4]).." KG" , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 4, tostring(slider_actual_values[5]).." KG" , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
    drawTextCentered(Font_Airbus_panel,  630 ,426 - 52 * 5, tostring(slider_actual_values[6]).." KG" , 17, true, false, TEXT_ALIGN_RIGHT, EFB_WHITE)
end

local function draw_sliders(x,y,i)

    if i ~= 2 then
        sasl.gl.drawRectangle( 52 ,399 - (i-1)*52,  560 * slider_pos[i],     15, EFB_DARKGREY)
    elseif slider_pos[2] > 0.5 then
        sasl.gl.drawRectangle( 52+560/2 ,399 - (i-1)*52,  560 * (slider_pos[i]-0.5),     15, EFB_DARKGREY)
    elseif slider_pos[2] < 0.5 then
        sasl.gl.drawRectangle( 52+560/2+ 560 * (slider_pos[i]-0.5) ,399 - (i-1)*52,  -560 * (slider_pos[i]-0.5),     15, EFB_DARKGREY)
    end

    local cursor_is_near_slider = within(EFB_CURSOR_X,(x-2)+ 560 * slider_pos[i],(x-2)+30+ 560 * slider_pos[i]) and within(EFB_CURSOR_Y,y-2,y-2+19) 
    if cursor_is_near_slider or focused_slider == i then
        sasl.gl.drawRectangle( (x-2)+ 560 * slider_pos[i] + (1-slider_pos[i]) - 1,   y-2,      29 + 1,     18 + 1, focused_slider == i and EFB_WHITE or EFB_LIGHTBLUE)
    end
    sasl.gl.drawRectangle(      x + 559 * slider_pos[i],        y,      26,     15,  {248/255,165/255,27/255})
end

local function EFB_p3s1_onmousedown(x,y,i) --the mose down function is put inside the button loop
    if within(EFB_CURSOR_X,(x-2)+ 560 * slider_pos[i],(x-2)+30+ 560 * slider_pos[i]) and within(EFB_CURSOR_Y,y-2,y-2+19) then
        focused_slider = i
    end
end

function EFB_p3s1_onmouseup()
    focused_slider = 0
end

local function EFB_p3s1_move_slider()
    if focused_slider ~= 0 then
        slider_pos[focused_slider] = Math_rescale(52 + 13, 0, 52+560 + 13, 1, EFB_CURSOR_X)
    end
end

local function reset_slider_when_mouse_leave()
    if not EFB_CURSOR_on_screen then
        focused_slider = 0
    end
end

local function slider_to_weights_translator()
    slider_actual_values[1] = Math_rescale(0, 0, 1, 18800, slider_pos[1])
    slider_actual_values[2] = slider_pos[2]
    slider_actual_values[3] = Math_rescale(0, 0, 1, 2400, slider_pos[3])
    slider_actual_values[4] = Math_rescale(0, 0, 1, 2400, slider_pos[4])
    slider_actual_values[5] = Math_rescale(0, 0, 1, 1500, slider_pos[5])
    slider_actual_values[6] = Math_rescale(0, 0, 1, 40000, slider_pos[6])
    for i=1, 6 do
        if i == 1 then
            slider_actual_values[i] = math.floor(slider_actual_values[i])
        elseif i == 2 then
            --do nothing
        else
            slider_actual_values[i] = Round(slider_actual_values[i],-2)
        end
    end
end

local function set_values()
    local CG_effect = (1-slider_actual_values[1]/18800)
    WEIGHTS.set_passengers_weight(slider_actual_values[1] ,(slider_actual_values[2]-0.5) * CG_effect + 0.5)
    WEIGHTS.set_fwd_cargo_weight(slider_actual_values[3])
    WEIGHTS.set_aft_cargo_weight(slider_actual_values[4])
    WEIGHTS.set_bulk_cargo_weight(slider_actual_values[5])
    set_fuel(slider_actual_values[6] + 10 * (slider_actual_values[6]/40000) )
    -- so long story short, there was an issue which set_fuel(40000) will only add 39990 kg of fuel
    --the issue is not in this script, it is rico's set fuel function.
    --therefore, for every 40000 kg of fuel, 10 kg has to be added.
    --that is where 10 * (slider_actual_values[6]/40000)  come from
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

local function draw_dropdowns()
    if string.len(key_p3s1_buffer) > 0 then --THE PURPOSE OF THIS IFELSE IS TO PREVENT THE CURSOR FROM COVERING UP THE PREVIOUS VALUE, WHEN THE SCRATCHPAD IS EMPTY.
        drawTextCentered( Font_Airbus_panel , 116 , 578, key_p3s1_focus == 7 and key_p3s1_buffer or deparr_apts[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_Airbus_panel , 403 , 578, key_p3s1_focus == 8 and key_p3s1_buffer or deparr_apts[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    else
        drawTextCentered( Font_Airbus_panel , 116 , 578, deparr_apts[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_Airbus_panel , 403 , 578, deparr_apts[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end

    draw_dropdown_menu(230, 578, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_1, dropdown_expanded[1], dropdown_selected[1])
    draw_dropdown_menu(511, 578, 90, 28, EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_2, dropdown_expanded[2], dropdown_selected[2])

end

local function draw_buttons()
    if get(TIME) -  load_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 200,70,368,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 200,70,368,32,2,2)
    end

    if get(TIME) -  reset_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 200 + 280,70,368,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 200 + 280,70,368,32,2,2)
    end

    drawTextCentered(Font_Airbus_panel,  197 ,85, "LOAD AIRCRAFT" , 18, true, false, TEXT_ALIGN_CENTER, EFB_BACKGROUND_COLOUR)
    drawTextCentered(Font_Airbus_panel,  479 ,85, "RESET DEFAULTS" , 18, true, false, TEXT_ALIGN_CENTER, EFB_BACKGROUND_COLOUR)
end


--------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------BELOW ARE THE LOOPS AND BUTTONS
--------------------------------------------------------------------------------------------------------------------------------


local function Subpage_1_buttons()
    runway_related_buttons()
    for i=1, 6 do
        EFB_p3s1_onmousedown(52,399 - (i-1)*52,i) 
    end

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 108,70,108+368/2,70+32,function () --refresh
        load_button_begin = get(TIME)
        set_values()
    end)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 108+280,70,108+368/2+280,70+32,function () --refresh
        reset_button_begin = get(TIME)
        slider_pos[1] = 0
        slider_pos[2] = 0.5
        slider_pos[3] = 0
        slider_pos[4] = 0
        slider_pos[5] = 0
        slider_pos[6] = 5000/40000
        slider_to_weights_translator()
        set_values()
    end)

end

local function EFB_update_page_3_subpage_1() --UPDATE LOOP
    EFB_p3s1_move_slider()
    reset_slider_when_mouse_leave()
    slider_to_weights_translator()
    request_departure_runway_data()
    request_arrival_runway_data()
end

local function EFB_draw_page_3_subpage_1() -- DRAW LOOP

    sasl.gl.drawTexture (EFB_LOAD_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )

    for i=1, 6 do
        draw_sliders(52,399 - (i-1)*52, i)
    end

    draw_slider_corresponding_values()

    draw_dropdowns()

    draw_focus_frame()
    draw_buttons()
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

