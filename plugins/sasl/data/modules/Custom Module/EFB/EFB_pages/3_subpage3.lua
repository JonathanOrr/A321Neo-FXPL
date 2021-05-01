local BUTTON_PRESS_TIME = 0.5
local dropdown_1 = {"DRY", "WET", "COMPACT SNOW", "DRY/WET SNOW", "SLUSH", "STAND WATER"}
local dropdown_2 = {"DUAL FAULT", "SINGLE FAULT", "NONE"}
local dropdown_3 = {"MANUAL", "AUTOMATIC"}
local dropdown_4 = {"CONFIG FULL", "CONFIG 3"}
local dropdown_5 = {"EMER ELEC CFG", "DC EMER CONFIG", "DC BUS 1+2", "DC BUS 2", "DC ESS BUS", "AC BUS 1", "NONE"}
local dropdown_6 = {"ALT/DIR LAW", "1 SPLR FAULT", "2 SPLR FAULT", ">2 SPLR FAULT", "SEC1 OR SEC3", "SEC2", "SEC 1+2 OR 2+3", "SEC 1+3", "ALL SEC FAULT", "NONE"}
local dropdown_7 = {"F: S: AT 0", "F: 0-1 S: <1", "F: 0-1 S: >1", "F: 1-2 S: <1 ", "F: 1-2 S: >1", "F: 2-3 S: <1", "F: 2-3 S: >1", "F: 3 S: <1", "F: 3 S: 1-3", "F: 3 S: >3","F: >3 S: <1","F: 3 S: 1-3", "F: >3 S: >3", "NONE"}
local dropdown_8 = {"SYS G+Y", "SYS B", "SYS G+B", "SYS G+Y", "SYS Y+B", "NONE"}
local dropdown_9 = {"ANTI SKID", "AUTO BRK FAULT", "NONE"}
local dropdown_10 = {"DUAL IR", "DUAL ADR", "TRIPLE ADR", "TRIPLE IR", "NONE"}
local dropdown_11 = {"REV UNLK CFG1", "REV UNLK CFG3", "NONE"}
local dropdown_expanded = {false, false, false, false, false, false, false, false, false, false, false}
local dropdown_selected = {1, #dropdown_2, 1, 1,#dropdown_5, #dropdown_6, #dropdown_7, #dropdown_8, #dropdown_9, #dropdown_10, #dropdown_11} ---CHANGE THE DEFAULT VALUE OF THE DROPDOWN HERE

local failure_code = {0,0,0,0,0,0,0}
local final_min_landing_distance = 0
local final_min_landing_distance_med_ab = 0
local final_min_landing_distance_low_ab = 0

local generate_button_begin = 0

selected_box = 0
key_p3s3_buffer = ""

local selected_box = 0
local landing_aircraft_data = {47777,0,0}



include("EFB/efb_ldgcat.lua")
---------------------------------------------------------------------------------------------------------------------------------

local function draw_no_arr_data()
    if deparr_apts[2] == "" then
        sasl.gl.drawRectangle ( 0 , 0 , 1143, 710, EFB_BACKGROUND_COLOUR)
        drawTextCentered(Font_Airbus_panel,  572, 360, "NO ARRIVAL DATA", 30, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
        drawTextCentered(Font_Airbus_panel,  572, 333, "RETURN TO PAGE 3 SUBPAGE 1", 20, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
end

local function p3s3_plug_in_the_buffer()
    if string.len(key_p3s3_buffer) <= 0 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
        selected_box = 0
        key_p3s3_buffer = ""
    elseif selected_box == 1 then
        landing_aircraft_data[selected_box] = Math_clamp(tonumber(key_p3s3_buffer), 47777, 101000) --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
        selected_box = 0
        key_p3s3_buffer = ""
    elseif selected_box == 2 then
        landing_aircraft_data[selected_box] = Math_clamp(tonumber(key_p3s3_buffer), 0, 359) --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
        selected_box = 0
        key_p3s3_buffer = ""
    elseif selected_box == 3 then
        landing_aircraft_data[selected_box] = Math_clamp(tonumber(key_p3s3_buffer), 0, 50) --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
        selected_box = 0
        key_p3s3_buffer = ""
    end
end

function p3s3_revert_to_previous_and_delete_buffer()
    selected_box = 0
    key_p3s3_buffer = ""
end

local function p3s3_backspace()
    key_p3s3_buffer = string.sub(key_p3s3_buffer, 1, -2)
end

local function p3s3_construct_the_buffer(char)
    local read_n = tonumber(string.char(char)) --JUST TO MAKE SURE WHAT YOU TYPE IS A NUMBER
            
    if read_n ~= nil and string.len(key_p3s3_buffer) < 6 then -- "tonumber()" RETURNS nil IF NOT A NUMBER, ALSO MAKES SURE STRING LENGTH IS <7
        key_p3s3_buffer = string.upper(key_p3s3_buffer..string.char(char))
    end
end

function EFB_onKeyDown_page3_subpage_3(component, char, key, shiftDown, ctrlDown, altOptDown)
    if selected_box == 0 then
        return false
    end
        if char == SASL_KEY_DELETE then --BACKSPACE
            p3s3_backspace()
        elseif char == SASL_VK_RETURN then --ENTER
            p3s3_plug_in_the_buffer()
        elseif char == SASL_VK_ESCAPE then --REVERT TO THE PREVIOUS VALUE.
            p3s3_revert_to_previous_and_delete_buffer()
        else
            p3s3_construct_the_buffer(char)
        end
    --print(key_p3s3_buffer)
    --print(target_airport)
    --print(char)
    return true --sasl manual, callback has to return true in order to override default keys.
end

---------------------------------------------------------------------------------------------------------------------------------

local function draw_background()
    sasl.gl.drawTexture (EFB_LOAD_s3_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
end

local function close_menu(number)
    dropdown_expanded[number] = false
end

local function draw_buttons()
    if get(TIME) -  generate_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 995, 383,368,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_s3_generate_button, 995, 383,368,32,2,2)
    end
    drawTextCentered(Font_Airbus_panel, 996, 398, "GENERATE", 18, false, false, TEXT_ALIGN_CENTER, EFB_BACKGROUND_COLOUR)
end

local function compute_landing_distance()
    if dropdown_selected[5] ~= #dropdown_5 then
        failure_code[1] = dropdown_selected[5]
    else
        failure_code[1] = 0
    end
    if dropdown_selected[6] ~= #dropdown_6 then
        failure_code[2] = dropdown_selected[6] + 6
    else
        failure_code[2] = 0
    end
    if dropdown_selected[7] ~= #dropdown_7 then
        failure_code[3] = dropdown_selected[7] + 15
    else
        failure_code[3] = 0
    end
    if dropdown_selected[8] ~= #dropdown_8 then
        failure_code[4] = dropdown_selected[8] + 28
    else
        failure_code[4] = 0
    end
    if dropdown_selected[9] ~= #dropdown_9 then
        failure_code[5] = dropdown_selected[9] + 33
    else
        failure_code[5] = 0
    end
    if dropdown_selected[10] ~= #dropdown_10 then
        failure_code[6] = dropdown_selected[10] + 35
    else
        failure_code[6] = 0
    end
    if dropdown_selected[11] ~= #dropdown_11 then
        failure_code[7] = dropdown_selected[11] + 39
    else
        failure_code[7] = 0
    end

    local a, b, c = failure_correction(failure_code)
    --print(c)

    local headwind_component = math.cos(math.rad((landing_aircraft_data[2] - get(TOPCAT_ldgrwy_bearing))%360)) * landing_aircraft_data[3]
    final_min_landing_distance, final_min_landing_distance_med_ab, final_min_landing_distance_low_ab = 
                                    landing_distance(
                                    dropdown_selected[1], 
                                    landing_aircraft_data[1], 
                                    Math_clamp(headwind_component/3, 5, 15),
                                    -math.min(headwind_component, 0), 
                                    dropdown_selected[2] - 1, 
                                    dropdown_selected[3]-1, 
                                    dropdown_selected[4]-1
                                )
                                --   local a, b, c  at a few lines above, c is the rwy distance factor in failure.
    final_min_landing_distance = final_min_landing_distance * c
    final_min_landing_distance_med_ab = final_min_landing_distance_med_ab * c
    final_min_landing_distance_low_ab = final_min_landing_distance_low_ab * c
    --print(final_min_landing_distance, final_min_landing_distance_med_ab, final_min_landing_distance_low_ab)
end

local function general_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 903, 384, 1086, 415,function () --DROPDOWN 3 EXPAND
        generate_button_begin = get(TIME)
        compute_landing_distance()
    end)
end

local function p3s3_dropdown_buttons( x,y,w,h, table, identifier)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        dropdown_expanded[identifier] = not dropdown_expanded[identifier]
    end)
    for i=1, #table do
        if dropdown_expanded[identifier] then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2 + 5, y - h*i - 14, w-10 + ( x - w/2 + 5), h-2 + ( y - h*i - 14),function ()
                --print(i)
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

local function draw_hightlighted_boxes()
    if selected_box == 1 then
        sasl.gl.drawTexture (EFB_LOAD_s3_ldgweight_highlighter, 0 , 0 , 1143 , 800 , EFB_WHITE )
    elseif selected_box == 2 then
        sasl.gl.drawTexture (EFB_LOAD_s3_wind_dir_highlighter, 0 , 0 , 1143 , 800 , EFB_WHITE )
    elseif selected_box == 3 then
        sasl.gl.drawTexture (EFB_LOAD_s3_wind_int_highlighter, 0 , 0 , 1143 , 800 , EFB_WHITE )
    end
end

--MOUSE & BUTTONS--
function p3s3_buttons()
    p3s3_dropdown_buttons(194, 273, 157, 28,    dropdown_1, 1)
    p3s3_dropdown_buttons(434, 273, 157, 28,    dropdown_2, 2)
    p3s3_dropdown_buttons(709-20, 273, 157, 28, dropdown_3, 3)
    p3s3_dropdown_buttons(949-20, 273, 157, 28, dropdown_4, 4)
    p3s3_dropdown_buttons(194, 488, 157, 28,     dropdown_5, 5)
    p3s3_dropdown_buttons(434, 488, 157, 28,     dropdown_6, 6)
    p3s3_dropdown_buttons(709-20, 488, 157, 28,  dropdown_7, 7)
    p3s3_dropdown_buttons(949-20, 488, 157, 28,  dropdown_8, 8)
    p3s3_dropdown_buttons(194, 380, 157, 28,      dropdown_9, 9)
    p3s3_dropdown_buttons(434, 380, 157, 28,      dropdown_10, 10)
    p3s3_dropdown_buttons(709-20, 380, 157, 28,   dropdown_11, 11)
    general_buttons()

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 408, 581, 570, 609,function () 
        selected_box = 1
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 629, 581, 749, 609,function ()
        selected_box = 2
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 769, 581, 878, 609,function ()
        selected_box = 3
    end)
    if selected_box == 1 then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 408, 581, 570, 609,function ()
            p3s3_plug_in_the_buffer()
            selected_box = 0
        end)
    elseif selected_box == 2 then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 629, 581, 749, 609,function ()
            p3s3_plug_in_the_buffer()
            selected_box = 0
        end)
    elseif selected_box == 3 then
        I_hate_button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 769, 581, 878, 609,function ()
            p3s3_plug_in_the_buffer()
            selected_box = 0
        end)
    end
end

--UPDATE LOOPS--
function p3s3_update()
    --print(EFB_CURSOR_X, EFB_CURSOR_Y)
end

local function draw_landing_distance_bar()
    local distance_ratio_to_x_coords = {
        {-999999, 39},
        {0, 39},
        {1, 1105},
        {999999, 1105},
    }
    local TRANSLUCENT_RED = {1,0,0,0.7}
    local TRANSLUCENT_YELLOW = {1,1,0,0.7}
    local TRANSLUCENT_GREEN = {0,1,0,0.7}

    local min_landing_runway_distance_ratio = final_min_landing_distance / get(TOPCAT_ldgrwy_length)
    local med_landing_runway_distance_ratio = final_min_landing_distance_med_ab / get(TOPCAT_ldgrwy_length)
    local low_landing_runway_distance_ratio = final_min_landing_distance_low_ab / get(TOPCAT_ldgrwy_length)

    local min_distance_in_pixels = Table_interpolate(distance_ratio_to_x_coords, min_landing_runway_distance_ratio )
    local med_distance_in_pixels = Table_interpolate(distance_ratio_to_x_coords, med_landing_runway_distance_ratio )
    local low_distance_in_pixels = Table_interpolate(distance_ratio_to_x_coords, low_landing_runway_distance_ratio )

    sasl.gl.drawRectangle ( 39 , 130 , min_distance_in_pixels - 39 , 13, TRANSLUCENT_RED)
    if min_distance_in_pixels > 39 then
        drawTextCentered(Font_Airbus_panel, (39 + min_distance_in_pixels) / 2, 136, Round(final_min_landing_distance, 0).." MAX MANUAL BRAKE" , 17, true, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
    sasl.gl.drawWideLine ( min_distance_in_pixels, 127 , min_distance_in_pixels , 151 , 3, EFB_WHITE )


    sasl.gl.drawRectangle ( 39 , 106 , med_distance_in_pixels - 39 , 13, TRANSLUCENT_YELLOW)
    if med_distance_in_pixels > 39 then
        drawTextCentered(Font_Airbus_panel, (39 +med_distance_in_pixels) / 2, 112, Round(final_min_landing_distance_med_ab, 0).." MED BRAKE" , 17, true, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
    sasl.gl.drawWideLine ( med_distance_in_pixels, 103 , med_distance_in_pixels , 151 , 3, EFB_WHITE )


    sasl.gl.drawRectangle ( 39 , 82 , low_distance_in_pixels - 39 , 13, TRANSLUCENT_GREEN)
    if low_distance_in_pixels > 39 then
        drawTextCentered(Font_Airbus_panel, (39 + low_distance_in_pixels) / 2, 88, Round(final_min_landing_distance_low_ab, 0).." LOW BRAKE" , 17, true, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    end
    sasl.gl.drawWideLine ( low_distance_in_pixels, 79 , low_distance_in_pixels , 151 , 3, EFB_WHITE )

    sasl.gl.drawRectangle ( size[1]/2 - 70 , 167 , 140 , 30, EFB_BLACK)
    drawTextCentered(Font_Airbus_panel, size[1]/2, 182, Round(get(TOPCAT_ldgrwy_length), 0).."m" , 24, true, false, TEXT_ALIGN_CENTER, EFB_WHITE)

    
    sasl.gl.drawWideLine ( 39, 78 , 39 , 227 , 3, EFB_WHITE )
end
--DRAW LOOPS--
function p3s3_draw()
    draw_background()
    draw_buttons()
    draw_dropdown_menu(194, 273, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_1, dropdown_expanded[1], dropdown_selected[1])
    draw_dropdown_menu(434, 273, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_2, dropdown_expanded[2], dropdown_selected[2])
    draw_dropdown_menu(709-20, 273, 157, 28,    EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_3, dropdown_expanded[3], dropdown_selected[3])
    draw_dropdown_menu(949-20, 273, 157, 28,    EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_4, dropdown_expanded[4], dropdown_selected[4])
    draw_dropdown_menu(194, 380, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_9, dropdown_expanded[9], dropdown_selected[9])
    draw_dropdown_menu(434, 380, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_10, dropdown_expanded[10], dropdown_selected[10])
    draw_dropdown_menu(709-20, 380, 157, 28,    EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_11, dropdown_expanded[11], dropdown_selected[11])
    draw_dropdown_menu(194, 488, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_5, dropdown_expanded[5], dropdown_selected[5])
    draw_dropdown_menu(434, 488, 157, 28,       EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_6, dropdown_expanded[6], dropdown_selected[6])
    draw_dropdown_menu(709-20, 488, 157, 28,    EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_7, dropdown_expanded[7], dropdown_selected[7])
    draw_dropdown_menu(949-20, 488, 157, 28,    EFB_DROPDOWN_OUTSIDE, EFB_DROPDOWN_INSIDE, dropdown_8, dropdown_expanded[8], dropdown_selected[8])
    draw_hightlighted_boxes()

    if string.len(key_p3s3_buffer) > 0 then --THE PURPOSE OF THIS IFELSE IS TO PREVENT THE CURSOR FROM COVERING UP THE PREVIOUS VALUE, WHEN THE SCRATCHPAD IS EMPTY.
        drawTextCentered( Font_ECAMfont , 487 , 595, selected_box == 1 and key_p3s3_buffer or landing_aircraft_data[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_ECAMfont , 686 , 595, selected_box == 2 and key_p3s3_buffer or landing_aircraft_data[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_ECAMfont , 821 , 595, selected_box == 3 and key_p3s3_buffer or landing_aircraft_data[3] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    else
        drawTextCentered( Font_ECAMfont , 487 , 595, landing_aircraft_data[1] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_ECAMfont , 686 , 595, landing_aircraft_data[2] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
        drawTextCentered( Font_ECAMfont , 821 , 595, landing_aircraft_data[3] , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end
    draw_landing_distance_bar()
    draw_no_arr_data()
end


--DO AT THE BEGINNING
