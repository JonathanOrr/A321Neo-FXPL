include("libs/table.save.lua")
include("networking/json.lua")

local key_p5s2_focus = 0
local key_p5s2_buffer = ""
local save_button_begin = 0
local fetch_button_begin = 0
local send_button_begin = 0
local save_delay = 0

local characters_per_line = 35
local drawing_table = {}
fetch_fail_warning_1 = false
simbrief_standby = false

local displayed_info = {
    ["departure"] = "",
    ["deprwy_length"] = "",
    ["arrival"] = "",
    ["flightno"] = "",
    ["crz_alt"] = "",
    ["pax"] = "",
    ["cargo"] = "",
    ["fuel"] = "",
    ["ci"] = "",
    ["deprwy"] = "",
    ["arrrwy"] = "",
    ["route"] = "",
    ["alternate_route"] = "",
}


local function load_route_table()
    for i = 1, math.ceil(#displayed_info["route"] / characters_per_line) do --BEGIN ROUTE DRAWING LOGIC
        table.insert(
            drawing_table,
            #drawing_table + 1,
            string.sub(displayed_info["route"], (i - 1) * characters_per_line + 1, i * characters_per_line)
        )
    end
end

local function clear_displayed_data()
    displayed_info = {
        ["departure"] = "",
        ["deprwy_length"] = "",
        ["arrival"] = "",
        ["flightno"] = "",
        ["crz_alt"] = "",
        ["pax"] = "",
        ["cargo"] = "",
        ["fuel"] = "",
        ["ci"] = "",
        ["deprwy"] = "",
        ["arrrwy"] = "",
        ["route"] = "",
        ["alternate_route"] = "",
    }
    drawing_table = {}
end

local function simbrief_to_local()
    displayed_info["departure"] = x["origin"]["icao_code"]
    displayed_info["arrival"] = x["destination"]["icao_code"]
    if istable(x["general"]["icao_airline"]) or istable(x["general"]["flight_number"]) then --SIMBRIEF RETURNS BLANK WHEN THERE IS NO FLIGHT NUMBER, LUA TAKES AN ARRAY CELL CONTAINING NOTHING AS A TABLE VALUE
        displayed_info["flightno"] = "NONE"
    else
        displayed_info["flightno"] = x["general"]["icao_airline"]..x["general"]["flight_number"]
    end
    displayed_info["crz_alt"] = x["general"]["initial_altitude"]
    displayed_info["pax"] = x["weights"]["pax_count"]
    displayed_info["cargo"] = x["weights"]["cargo"]
    displayed_info["fuel"] = x["fuel"]["plan_takeoff"]
    displayed_info["ci"] = x["general"]["costindex"]
    displayed_info["deprwy"] = x["origin"]["plan_rwy"]
    displayed_info["arrrwy"] = x["destination"]["plan_rwy"]
    displayed_info["route"] = x["general"]["route"]
    displayed_info["alternate_route"] = x["alternate"]["route"]

    drawing_table = {}
    load_route_table()
end

local function clear_simbrief_buffer_table()
    x = {}
end
sasl.net.setDownloadTimeout(SASL_TIMEOUT_CONNECTION, 3 )

local function onContentsDownloaded ( inUrl , inString , inIsOk , inError )
    if inIsOk then
        x = json.decode(inString)
        simbrief_to_local()
        clear_simbrief_buffer_table()
        fetch_fail_warning_1 = false
        simbrief_standby = false
    else
        fetch_fail_warning_1 = true
        simbrief_standby = false
        clear_displayed_data()
    end
end

--KEYBOARD CAPTURE

local function p5s2_plug_in_the_buffer()
    if string.len(key_p5s2_buffer) <= 0 then --IF THE LENGTH OF THE STRING IS 0, THEN REVERT TO THE PREVIOUS VALUE. ELSE, PLUG-IN THE NEW VALUE.
        key_p5s2_focus = 0
        key_p5s2_buffer = ""
    else
        EFB.pref_set_simbrief_id(key_p5s2_buffer) --PLUG THE SCRATCHPAD INTO THE ACTUAL TARGET
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
        sasl.net.downloadFileContentsAsync ( "https://www.simbrief.com/api/xml.fetcher.php?userid="..EFB.pref_get_simbrief_id().."&json=1" ,onContentsDownloaded)
        simbrief_standby = true
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
        EFB.pref_save()
    end
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
        efb_draw_focus_frames(117,513,140,29)
    end

    if string.len(key_p5s2_buffer) > 0 then
        drawTextCentered( Font_ECAMfont ,  187, 527 ,key_p5s2_buffer , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    else
        drawTextCentered( Font_ECAMfont ,  187, 527 ,EFB.pref_get_simbrief_id() , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN )
    end


    drawTextCentered( Font_Airbus_panel ,  187, 474 ,"SAVE" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel ,  187, 342 ,"FETCH" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )
    drawTextCentered( Font_Airbus_panel ,  672, 68 ,"APPLY TO ACF" , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_BACKGROUND_COLOUR )

    drawTextCentered( Font_ECAMfont ,  446, 527 ,displayed_info["departure"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 462 ,displayed_info["arrival"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 397 ,displayed_info["flightno"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 332 ,displayed_info["crz_alt"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 267 ,displayed_info["pax"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 202 ,displayed_info["cargo"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 137 ,displayed_info["fuel"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  446, 72 ,displayed_info["ci"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  696, 527 ,displayed_info["deprwy"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )
    drawTextCentered( Font_ECAMfont ,  902, 527 ,displayed_info["arrrwy"] , 20 ,false , false , TEXT_ALIGN_CENTER , EFB_FULL_GREEN  )

    for i = 1, #drawing_table do
        drawTextCentered(Font_ECAMfont,  588, 438 - (28 * (i - 1)), drawing_table[i], 19, false, false, TEXT_ALIGN_LEFT, EFB_FULL_GREEN)
    end

    if fetch_fail_warning_1 then
        drawTextCentered(Font_ECAMfont,  99, 291, "NO DATA", 19, false, false, TEXT_ALIGN_LEFT, EFB_FULL_RED)
    end

    if simbrief_standby then
        draw_standby_screen("REQUESTING DATA FROM SIMBRIEF API....")
    end
end


