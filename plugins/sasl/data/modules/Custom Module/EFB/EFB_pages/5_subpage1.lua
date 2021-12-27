local key_p5s1_focus = 0
local key_p5s1_buffer = ""
local target_airport = ""
local metar_button_begin = 0
local metar_string = ""
local please_wait_cover_begin = 0
local metar_buffer = "NO METAR REPORT RECEIVED"
local metar_wait_time = 3



--METAR REQUEST CALLBACK

local function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk and string.len(inString) > 0 then
        --logInfo ( " String downloaded ! " )
        --logInfo ( inUrl )
        --logInfo ( inString )
        metar_buffer = inString
    else
        metar_buffer = "NO METAR REPORT RECEIVED"
    end
end

--KEYBOARD CAPTURE

local function p5s1_plug_in_the_buffer()
    if string.len(key_p5s1_buffer) < 4 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
        key_p5s1_focus = 0
        key_p5s1_buffer = ""
    else
        target_airport = key_p5s1_buffer --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET AIRPORT
        key_p5s1_focus = 0
        key_p5s1_buffer = ""
    end
end

function p5s1_revert_to_previous_and_delete_buffer()
    key_p5s1_focus = 0
    key_p5s1_buffer = ""
end

local function p5s1_backspace()
    key_p5s1_buffer = string.sub(key_p5s1_buffer, 1, -2)
end

local function p5s1_construct_the_buffer(char)
    local read_n = tonumber(string.char(char)) --JUST TO MAKE SURE WHAT YOU TYPE IS A NUMBER
            
    if read_n == nil and string.len(key_p5s1_buffer) < 4 then -- "tonumber()" RETURNS nil IF NOT A NUMBER, ALSO MAKES SURE STRING LENGTH IS <7
        key_p5s1_buffer = string.upper(key_p5s1_buffer..string.char(char))
    end
end

function EFB_onKeyDown_page5(component, char, key, shiftDown, ctrlDown, altOptDown)
    if efb_p5_subpage_number == 1 then
        if key_p5s1_focus == 0 then
            return false
        end
            if char == SASL_KEY_DELETE then --BACKSPACE
                p5s1_backspace()
            elseif char == SASL_VK_RETURN then --ENTER
                p5s1_plug_in_the_buffer()
            elseif char == SASL_VK_ESCAPE then --REVERT TO THE PREVIOUS VALUE.
                p5s1_revert_to_previous_and_delete_buffer()
            else
                p5s1_construct_the_buffer(char)
            end
        return true --sasl manual, callback has to return true in order to override default keys.
    end
end


---------------------------------------------------------------------------------------------------ABOVE ARE ALL KEYBOARD HANDLERS


--MOUSE & BUTTONS--
function p5s1_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 400,566,470,592, function ()
        key_p5s1_focus = key_p5s1_focus == 1 and 0 or 1
    end)

    click_anywhere_except_that_area( 400,566,470,592, p5s1_plug_in_the_buffer)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 606,566,755,595, function ()
        metar_buffer = "NO METAR REPORT RECEIVED"
        metar_button_begin = get(TIME)
        please_wait_cover_begin = get(TIME)
        if string.len(target_airport) == 4 then
            fetch_atis(target_airport, onContentsDownloaded)
        end
    end)
end

local function draw_request_button()
    if get(TIME) -  metar_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 680,565,300,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 680,565,300,32,2,2)
    end
    drawTextCentered( Font_ECAMfont , 680,580, "REQUEST" , 19 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
end

local function draw_metar_results()
    local starting_y_coordinates  = 481
    local metar_length = string.len(metar_buffer)
    local char_per_line = 61
    local number_of_lines = math.ceil(metar_length/char_per_line)
    for i=1, number_of_lines do
        drawTextCentered( Font_ECAMfont  , 172 , starting_y_coordinates - (i-1)*30, string.sub(metar_buffer,(i-1)*char_per_line+1, (i)*char_per_line) , 20 ,false , false , TEXT_ALIGN_LEFT , EFB_FULL_YELLOW )
    end
end

local function draw_text_highlighter()
    if key_p5s1_focus == 1 then
        efb_draw_focus_frames(400,566,100,26)
    end

    if string.len(key_p5s1_buffer) > 0 then
        drawTextCentered( Font_ECAMfont , 451 , 579, key_p5s1_focus == 1 and key_p5s1_buffer or target_airport , 20 ,false , false , TEXT_ALIGN_CENTER , ECAM_GREEN )
    else
        drawTextCentered( Font_ECAMfont , 451 , 579, target_airport , 20 ,false , false , TEXT_ALIGN_CENTER , ECAM_GREEN )
    end
end

local function draw_text_window(x,y,w,h)
    sasl.gl.drawRectangle( x-w/2 - 1 , y-h/2 - 1,w + 2, h +2 , EFB_DARKGREY)
    sasl.gl.drawRectangle( x-w/2 , y-h/2 ,w, h , EFB_DROPDOWN_INSIDE)
end

local function draw_background()
    drawTextCentered(Font_ECAMfont,  1143/2, 640, "WEATHER REQUEST" , 30, false, false, TEXT_ALIGN_CENTER, EFB_LIGHTBLUE)
    drawTextCentered(Font_ECAMfont,  330, 579, "ARPT ICAO:" , 21, false, false, TEXT_ALIGN_CENTER, EFB_WHITE)
    draw_text_window(450,579,100,24)
    draw_text_window(572,295,843,430)
end

local function draw_waiting_screen()
    local time_remaining = metar_wait_time - (get(TIME) - please_wait_cover_begin)
    if time_remaining > 0.5 then
        draw_standby_screen("FETCHING DATA FROM SERVER....")
    elseif time_remaining <= 0.5 and time_remaining >= 0 then
        draw_standby_screen("DONE!")
    end
end



--UPDATE LOOPS--
function p5s1_update()
    --print(key_p3s1_focus)
end

--DRAW LOOPS--
function p5s1_draw()
    draw_background()

    draw_request_button()

    draw_text_highlighter()

    draw_metar_results()

    draw_waiting_screen()
end