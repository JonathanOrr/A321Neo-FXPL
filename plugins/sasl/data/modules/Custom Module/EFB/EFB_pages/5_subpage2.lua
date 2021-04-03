include("libs/table.save.lua")
include("networking/json.lua")

local key_p5s2_focus = 0
local key_p5s2_buffer = ""
local userid = ""
local save_button_begin = 0
local fetch_button_begin = 0
local send_button_begin = 0
local fxxk_the_tablesave = {}
local save_delay = 0

local displayed_info = {
    ["departure"] = "",
    ["arrival"] = "",
    ["flightno"] = "",
    ["acf"] = "",
    ["pax"] = "",
    ["cargo"] = "",
    ["fuel"] = "",
    ["ci"] = "",
    ["deprwy"] = "",
    ["arrrwy"] = "",
}

local function save_id_to_file()
    fxxk_the_tablesave[1] = userid
    table.save(fxxk_the_tablesave, moduleDirectory .. "/Custom Module/saved_configs/simbrief_id")
end

local function load_id_from_file()
    fxxk_the_tablesave = table.load(moduleDirectory .. "/Custom Module/saved_configs/simbrief_id")
    userid = fxxk_the_tablesave[1]
end

local function simbrief_to_local()
    displayed_info["departure"] = x["origin"]["icao_code"]
    displayed_info["arrival"] = x["destination"]["icao_code"]
    displayed_info["flightno"] = x["general"]["flight_number"]
    displayed_info["acf"] = x["aircraft"]["icaocode"]
    displayed_info["pax"] = x["weights"]["pax_count"]
    displayed_info["cargo"] = x["weights"]["cargo"]
    displayed_info["fuel"] = x["fuel"]["plan_takeoff"]
    displayed_info["ci"] = x["general"]["costindex"]
    displayed_info["deprwy"] = x["origin"]["plan_rwy"]
    displayed_info["arrrwy"] = x["destination"]["plan_rwy"]
end

local function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk then
        logInfo ( " String downloaded ! " )
        x = json.decode(inString)
        simbrief_to_local()
    else
        logInfo ( inUrl )
        logWarning ( inError )
    end
end

--KEYBOARD CAPTURE

local function p5s2_plug_in_the_buffer()
    if string.len(key_p5s2_buffer) <= 0 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
        key_p5s2_focus = 0
        key_p5s2_buffer = ""
    else
        userid = key_p5s2_buffer --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET
        key_p5s2_focus = 0
        key_p5s2_buffer = ""
    end
end

function p5s2_revert_to_previous_and_delete_buffer()
    key_p5s2_focus = 0
    key_p5s2_buffer = ""
end

local function p5s2_backspace()
    key_p5s2_buffer = string.sub(key_p5s2_buffer, 1, -2)
end

local function p5s2_construct_the_buffer(char)
    local read_n = tonumber(string.char(char)) --JUST TO MAKE SURE WHAT YOU TYPE IS A NUMBER
            
    if read_n ~= nil and string.len(key_p5s2_buffer) < 6 then -- "tonumber()" RETURNS nil IF NOT A NUMBER, ALSO MAKES SURE STRING LENGTH IS <6
        key_p5s2_buffer = string.upper(key_p5s2_buffer..string.char(char))
    end
end

function EFB_onKeyDown_page5_subpage_2(component, char, key, shiftDown, ctrlDown, altOptDown)
    if key_p5s2_focus == 0 then
        return false
    end
        if char == SASL_KEY_DELETE then --BACKSPACE
            p5s2_backspace()
        elseif char == SASL_VK_RETURN then --ENTER
            p5s2_plug_in_the_buffer()
        elseif char == SASL_VK_ESCAPE then --REVERT TO THE PREVIOUS VALUE.
            p5s2_revert_to_previous_and_delete_buffer()
        else
            p5s2_construct_the_buffer(char)
        end
    --print(key_p5s2_buffer)
    --print(target_airport)
    --print(char)
    return true --sasl manual, callback has to return true in order to override default keys.
end

local function deselect_and_save()
    p5s2_plug_in_the_buffer()
    key_p5s2_focus = 0
end

--MOUSE & BUTTONS--
function p5s2_buttons()
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 116,458,258,489, function ()
        save_button_begin = get(TIME)
        save_delay = 2
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 116,326,258,357, function ()
        fetch_button_begin = get(TIME)
        sasl.net.downloadFileContentsAsync ( "https://www.simbrief.com/api/xml.fetcher.php?userid="..userid.."&json=1" ,onContentsDownloaded)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 579,53,764,84, function ()
        send_button_begin = get(TIME)
    end)
    Button_check_and_action(EFB_CURSOR_X, EFB_CURSOR_Y, 119,513,258,541, function ()
        key_p5s2_focus = key_p5s2_focus == 1 and 0 or 1
    end)
    click_anywhere_except_that_area( 119,513,258,541,  deselect_and_save)
end

--UPDATE LOOPS--
function p5s2_update()

    if save_delay > 0 then
        save_delay = save_delay -1
    end
    if save_delay == 1 then
        save_id_to_file()
    end

    print(EFB_CURSOR_X, EFB_CURSOR_Y)

end

--DRAW LOOPS--
function p5s2_draw()
    sasl.gl.drawTexture (Simbrief_bgd, 0 , 0 , 1143 , 800 , EFB_WHITE )
    if get(TIME) - save_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_apply, 188,458,278,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_apply, 188,458,278,32,2,2)
    end
    if get(TIME) - fetch_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_apply, 188,326,278,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_apply, 188,326,278,32,2,2)
    end
    if get(TIME) - send_button_begin > BUTTON_PRESS_TIME then
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_send, 671,53,368,32,2,1)
    else
        SASL_drawSegmentedImg_xcenter_aligned (Simbrief_send, 671,53,368,32,2,2)
    end

    if key_p5s2_focus == 1 then
        sasl.gl.drawTexture (Simbrief_highlighter, 0 , 0 , 1143 , 800 , EFB_WHITE )
    end

    if string.len(key_p5s2_buffer) > 0 then
        drawTextCentered( Font_Airbus_panel ,  187, 527 ,key_p5s2_buffer , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    else
        drawTextCentered( Font_Airbus_panel ,  187, 527 ,userid , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end


    drawTextCentered( Font_Airbus_panel ,  187, 474 ,"SAVE" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel ,  187, 342 ,"FETCH" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel ,  672, 68 ,"APPLY TO ACF" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )

    drawTextCentered( Font_Airbus_panel ,  446, 528 ,displayed_info["departure"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 463 ,displayed_info["arrival"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 398 ,displayed_info["flightno"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 333 ,displayed_info["acf"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 268 ,displayed_info["pax"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 203 ,displayed_info["cargo"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 138 ,displayed_info["fuel"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  446, 73 ,displayed_info["ci"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  696, 528 ,displayed_info["deprwy"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_Airbus_panel ,  902, 528 ,displayed_info["arrrwy"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )

end



---------DO AT THE BEGINNING

if table.load(moduleDirectory .. "/Custom Module/saved_configs/simbrief_id") ~= nil then
    load_id_from_file()
end

