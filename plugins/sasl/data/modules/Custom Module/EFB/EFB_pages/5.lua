--STUFF YOU CAN MESS WITH
local BUTTON_PRESS_TIME = 0.5
local metar_wait_time = 3

---STUFF YOU CANNOT MESS WITH
local key_p5s1_focus = 0
local key_p5s1_buffer = ""
local target_airport = ""
local metar_button_begin = 0
local metar_string = ""
local please_wait_cover_begin = 0

local efb_subpage_number = 1

include("EFB/efb_functions.lua")
include("libs/table.save.lua")
include("networking/metar_request.lua")

--METAR REQUEST CALLBACK

function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk and string.len(inString) > 0 then
        --logInfo ( " String downloaded ! " )
        --logInfo ( inUrl )
        --logInfo ( inString )
        set(EFB_metar_string, inString)
    else
        set(EFB_metar_string, "Error: Could not obtain valid METAR report for the entered airport.")
    end
end

--KEYBOARD CAPTURE

local function p5s1_plug_in_the_buffer()
    if string.len(key_p5s1_buffer) <= 0 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
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
    if efb_subpage_number == 1 then
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
        --print(key_p5s1_buffer)
        --print(target_airport)
        --print(char)
        return true --sasl manual, callback has to return true in order to override default keys.
    end
end

--MOUSE & BUTTONS--
function EFB_execute_page_5_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 618,417,713,447, function ()
        key_p5s1_focus = key_p5s1_focus == 1 and 0 or 1
    end)

    click_anywhere_except_that_area( 618, 417, 713, 447, p5s1_plug_in_the_buffer)

    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 436,352,707,382, function ()
        metar_button_begin = get(TIME)
        please_wait_cover_begin = get(TIME)
        if string.len(target_airport) == 4 then
            fetch_atis(target_airport, onContentsDownloaded)
        end
        --print(EFB_metar_string)
    end)
end

--UPDATE LOOPS--
function EFB_update_page_5()

end

--DRAW LOOPS--
function EFB_draw_page_5()
    sasl.gl.drawTexture (Metar_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )

    if key_p5s1_focus == 1 then
        sasl.gl.drawTexture (Metar_highlighter, 0 , 0 , 1143 , 800 , EFB_WHITE )
    end

    if string.len(key_p5s1_buffer) > 0 then
        drawTextCentered( Font_Airbus_panel , 663 , 433, key_p5s1_focus == 1 and key_p5s1_buffer or target_airport , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE )
    else
        drawTextCentered( Font_Airbus_panel , 663 , 433, target_airport , 17 ,false , false , TEXT_ALIGN_CENTER , EFB_LIGHTBLUE )
    end

    if get(TIME) -  metar_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 572,350,544,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (EFB_LOAD_compute_button, 572,350,544,32,2,2)
    end
    drawTextCentered( Font_Airbus_panel , 572 , 365, "REQUEST" , 19 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel , 172 , 235, get(EFB_metar_string) , 20 ,false , false , TEXT_ALIGN_LEFT , EFB_FULL_YELLOW )

    if get(TIME) - please_wait_cover_begin < metar_wait_time then
        sasl.gl.drawTexture (Metar_waiting , 0 , 0 , 1143 , 800 , EFB_WHITE )
        sasl.gl.drawWideLine ( 314 , 337 , 829 , 337 , 5, EFB_DARKGREY )
        sasl.gl.drawWideLine ( 314 , 337 , 515*(get(TIME) - please_wait_cover_begin)/ metar_wait_time + 314 , 337 , 5, EFB_LIGHTBLUE )
    end
end


