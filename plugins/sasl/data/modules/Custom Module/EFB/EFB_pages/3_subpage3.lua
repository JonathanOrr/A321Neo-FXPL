local BUTTON_PRESS_TIME = 0.5
local dropdown_1 = {"DRY", "WET", "COMPACT SNOW", "DRY/WET SNOW", "SLUSH", "STAND WATER"}
local dropdown_2 = {"SINGLE FAULT", "DUAL FAULT", "NONE"}
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

local failure_buffer_array = {0, 0, 0, 0, 0, 0}

local generate_button_begin = 0
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

local function general_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 903, 384, 1086, 415,function () --DROPDOWN 3 EXPAND
        generate_button_begin = get(TIME)
    end)
end

local function p3s3_dropdown_buttons( x,y,w,h, table, identifier)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2, y-h/2,x + w/2, y + h/2,function ()
        dropdown_expanded[identifier] = not dropdown_expanded[identifier]
    end)
    for i=1, #table do
        if dropdown_expanded[identifier] then
            Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, x - w/2 + 5, y - h*i - 14, w-10 + ( x - w/2 + 5), h-2 + ( y - h*i - 14),function ()
                print(i)
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
end

--UPDATE LOOPS--
function p3s3_update()
    print(EFB_CURSOR_X, EFB_CURSOR_Y)
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
end

--DO AT THE BEGINNING
