position= {1990,1866,463,325}
size = {463, 325}

include('DCDU_handlers.lua')

local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

local ECAM_BLACK = {0, 0, 0}
local ECAM_WHITE = {1.0, 1.0, 1.0}
local ECAM_BLUE = {0.004, 1.0, 1.0}
local ECAM_GREEN = {0.184, 0.733, 0.219}
local ECAM_ORANGE = {0.725, 0.521, 0.18}

local MESSAGE_TYPE_WILCO = 1
local MESSAGE_TYPE_ROGER = 2
local MESSAGE_TYPE_CONFIRM_WILCO = 11
local MESSAGE_TYPE_CONFIRM_ROGER = 12

local display_btm_left  = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_btm_right = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_title = {text="", color=ECAM_BLACK}
local display_r = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_l = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_running_text = {text="", color=ECAM_GREEN}
local display_ack = {text="", color="", background=false}
local display_top = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}

local was_connected  = true
local change_occured = true
local updated_connection = false

local curr_atc_id   = ""
local curr_atc_name = ""
local curr_atc_lat = 0
local curr_atc_lon = 0
local array_ctr = {}
local nearest_ctr = nil

local current_messages = {}
-- {msg_text="ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMNOPQRSTUVWXYZ", msg_type=MESSAGE_TYPE_CONFIRM_WILCO, msg_time="1200", msg_source="LIML"}
local function init_array_ctr()
    array_ctr = Read_CSV(moduleDirectory .. "/Custom Module/data/ctr.csv")
end

init_array_ctr()

local function update_nearest_ctr()
    min_distance = 99999;
    min_i = 0;

    aircraft_lat = get(Aircraft_lat)
    aircraft_lon = get(Aircraft_long)

    for i, x in ipairs(array_ctr) do
        dist = GC_distance_km(aircraft_lat, aircraft_lon, x[4], x[3])
        if dist < min_distance then
            min_distance = dist
            min_i = i
        end
    end

    nearest_ctr = array_ctr[min_i]
    
end


local function reset_display() 
    display_ack = {text="", color="", background=false}
    
    display_top[1].text = ""
    display_top[2].text = ""
    display_top[3].text = ""
    display_top[4].text = ""
    display_top[5].text = ""
    
    display_r[1].text = ""
    display_r[2].text = ""
    display_l[1].text = ""
    display_l[2].text = ""
    
    display_title.text = ""

    display_btm_left[1].text = ""
    display_btm_left[2].text = ""
    display_btm_left[3].text = ""
    display_btm_right[1].text = ""
    display_btm_right[2].text = ""
    display_btm_right[3].text = ""
    

end

local function display_message(message_text, message_type, msg_time, msg_source)

    reset_display()

    display_running_text.text = msg_time .. "Z FROM " .. msg_source
 
    local MAX_LINE_LENGTH = 28

    local message_length = string.len(message_text)
    
    local total_num_pages = math.ceil(message_length/(MAX_LINE_LENGTH*5))
    set(DCDU_pages_total, total_num_pages)
    local start_page = get(DCDU_page_no)*MAX_LINE_LENGTH*5
   
    for i=1,5 do
        display_top[i].text  = string.sub(message_text,start_page + (i-1) * MAX_LINE_LENGTH + 1, start_page + i * MAX_LINE_LENGTH)
        display_top[i].color = ECAM_WHITE
        if i*MAX_LINE_LENGTH > message_length then            
            break
        end
    end
    
    if total_num_pages > 1 then
        display_r[1].text  = "PGE"
        display_r[1].color = ECAM_WHITE
        display_r[2].text  = (get(DCDU_page_no) + 1 ) .. "/" .. total_num_pages
        display_r[2].color = ECAM_WHITE
    end
    
    if get(DCDU_msgs_total) > 1 then
        display_l[1].text  = "MSG"
        display_l[1].color = ECAM_WHITE
        display_l[2].text  = (get(DCDU_msg_no) + 1 ) .. "/" .. get(DCDU_msgs_total) 
        display_l[2].color = ECAM_WHITE
    end

    display_ack.text = "OPEN"
    display_ack.color = ECAM_BLUE
    display_ack.background = false
    
    if message_type == MESSAGE_TYPE_WILCO then
        display_btm_right[3].text = "WILCO *"
        display_btm_right[1].text = "STBY *"
        display_btm_left[1].text = "* UNABLE"
    end
    
    if message_type == MESSAGE_TYPE_ROGER then
        display_btm_right[3].text = "ROGER *"
        display_btm_right[1].text = "STBY *"
    end
    
    if message_type == MESSAGE_TYPE_CONFIRM_WILCO or message_type == MESSAGE_TYPE_CONFIRM_ROGER then
        display_btm_right[3].text = "SEND *"
        display_btm_left[1].text  = "* CANCEL"
        display_title.text = "CONFIRM"
        display_title.color = ECAM_BLUE
        display_ack.color = ECAM_BLUE
        display_ack.background = true
    end

    if message_type == MESSAGE_TYPE_CONFIRM_WILCO then
        display_ack.text = "WILCO"    
    end
    if message_type == MESSAGE_TYPE_CONFIRM_ROGER then
        display_ack.text = "ROGER"
    end


    display_btm_right[1].color = ECAM_BLUE 
    display_btm_right[3].color = ECAM_BLUE 
    display_btm_left[1].color = ECAM_BLUE 
    display_btm_left[3].color = ECAM_BLUE 

end

local function update_no_connection()

    reset_display()

    display_top[2].text = "ATC DISCONNECTED"
    display_top[2].color = ECAM_ORANGE

    display_title.text = "LINK LOST"
    display_title.color = ECAM_ORANGE

    display_btm_right[3].text = "CLOSE *"
    display_btm_right[3].color = ECAM_BLUE
    
    display_running_text.text = get(ZULU_hours) .. get(ZULU_mins) .. "Z"
    
end

local function update_no_messages(double_conn)

    reset_display()

    display_top[2].text = "ACTIVE ATC: " .. curr_atc_id
    display_top[2].color = ECAM_GREEN
    display_top[3].text = string.sub(string.upper(curr_atc_name), 0, 28)
    display_top[3].color = ECAM_GREEN

    display_top[5].color = ECAM_GREEN
    
    if get(Acars_status) == 1 then
        display_top[5].text = "                     SATCOM"
    elseif get(Acars_status) == 2 then
        display_top[5].text = "                        VHF"
    elseif get(Acars_status) == 3 then
        display_top[5].text = "               SATCOM + VHF"
    end
    display_btm_right[3].text = "RECALL *"
    display_btm_right[3].color = ECAM_BLUE
    
    display_running_text.text = get(ZULU_hours) .. get(ZULU_mins) .. "Z"
    
end

local function update_satcom_vhf_connection()

    local is_satcom_connected = 1
    if math.abs(get(Aircraft_lat)) > 75 then
        is_satcom_connected = 0 -- SATCOM is not available over 75 degrees
    end
    if math.abs(get(Flightmodel_roll)) > 45 then
        is_satcom_connected = 0 -- The antenna of the SATCOM is no more towards the sky
    end
    
    math.randomseed(get(TIME))
    if math.random (1, 10000) == 5000 then  -- Random satellite disconnection
        is_satcom_connected = 0
    end

    local is_vhf_connected = 2
    local distance_vhf = 999

    if curr_atc_id ~= "" then
        distance_vhf = GC_distance_km(curr_atc_lat, curr_atc_lon, get(Aircraft_lat), get(Aircraft_long))
    end
    if distance_vhf > 300 then  -- Max 300 km
        is_vhf_connected = 0
    end
    
    if math.random (1, 10000) == 5000 then -- Random VHF disconnection
        is_vhf_connected = 0    
    end

    set(Acars_status, is_satcom_connected + is_vhf_connected) 
end

local function update_connected_atc()

    local temp_atc_id = ""
    local temp_atc_name = ""

    testID = sasl.findNavAid (nil, nil, get(Aircraft_lat), get(Aircraft_long), nil, NAV_AIRPORT)
    if testID ~= -1 then
        types, arptLat, arptLon, height, freg, heading, temp_atc_id, temp_atc_name, inCurDSF = sasl.getNavAidInfo(testID)
    else
        temp_atc_id = ""
        temp_atc_name = ""
    end

    if get(EWD_flight_phase) == 6 and nearest_ctr ~= nil then
        temp_atc_id   = nearest_ctr[1]
        temp_atc_name = nearest_ctr[2] .. " ACC"
    end

    if temp_atc_id ~= curr_atc_id then
        curr_atc_id = temp_atc_id
        curr_atc_name = temp_atc_name
        curr_atc_lat = arptLat
        curr_atc_lon = arptLon
        change_occured = false
    end
end

local function check_new_messages()
    if get(Acars_incoming_message_type) == 0 then
        return
    end
    
    -- The following sub is needed to remove any text after the termination character
    msg_text = get(Acars_incoming_message)
    msg_text = string.sub(msg_text, 0, get(Acars_incoming_message_length))
    
    new_message = {msg_text=msg_text, msg_type=get(Acars_incoming_message_type), msg_time=get(ZULU_hours) .. get(ZULU_mins), msg_source="USER"}
    
    set(Acars_incoming_message_type, 0)
    set(Acars_incoming_message, "")
    
    table.insert(current_messages, new_message)
    
    set(DCDU_msgs_total, #current_messages)
    
end

function update()

    check_new_messages()

    if math.ceil(get(TIME)) % 5 == 0 then  -- Update connection every 5 sec
        if not updated_connection then
           updated_connection = true
           update_satcom_vhf_connection()
           if math.ceil(get(TIME)) % 60 == 0 then  -- Update the ATC CTR every minute (quite computational intensive)
                update_nearest_ctr()
           end
        end
    else
        updated_connection = false
    end

    update_connected_atc()

    if get(Acars_status) == 0 then
        -- No connection, nothing to do
        if was_connected then
            was_connected = false
            update_no_connection()
        end
        return
    end
    

    
    if get(Acars_status) > 0 then   -- TODO and no messages
    
        if #current_messages > 0 then
            display_message(current_messages[get(DCDU_msg_no)+1].msg_text, current_messages[get(DCDU_msg_no)+1].msg_type, current_messages[get(DCDU_msg_no)+1].msg_time, current_messages[get(DCDU_msg_no)+1].msg_source)
        else
            if change_occured or not was_connected then
                change_occured = false
                update_no_messages()
                return
            end
        end
    end

    was_connected = true
end

function draw()

    sasl.gl.drawText (B612MONO_regular, 10, 20, display_btm_left[3].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[3].color )
    sasl.gl.drawText (B612MONO_regular, 10, 50, display_btm_left[2].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[2].color )
    sasl.gl.drawText (B612MONO_regular, 10, 80, display_btm_left[1].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[1].color )


    sasl.gl.drawText (B612MONO_regular, size[1]-10, 20, display_btm_right[3].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[3].color )
    sasl.gl.drawText (B612MONO_regular, size[1]-10, 50, display_btm_right[2].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[2].color )
    sasl.gl.drawText (B612MONO_regular, size[1]-10, 80, display_btm_right[1].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[1].color )

    sasl.gl.drawText (B612MONO_regular, size[1]/2, 80, display_title.text, 20, false, false, TEXT_ALIGN_CENTER, display_title.color )
    sasl.gl.drawText (B612MONO_regular, size[1]/2+100, 50, display_r[1].text , 20, false, false, TEXT_ALIGN_RIGHT, display_r[1].color )
    sasl.gl.drawText (B612MONO_regular, size[1]/2+100, 20, display_r[2].text , 20, false, false, TEXT_ALIGN_RIGHT, display_r[2].color )
    sasl.gl.drawText (B612MONO_regular, size[1]/2-95, 50,  display_l[1].text , 20, false, false, TEXT_ALIGN_LEFT, display_l[1].color )
    sasl.gl.drawText (B612MONO_regular, size[1]/2-95, 20,  display_l[2].text , 20, false, false, TEXT_ALIGN_LEFT, display_l[2].color )

    sasl.gl.drawText (B612MONO_regular, 10, size[2]-20, display_running_text.text , 17, false, false, TEXT_ALIGN_LEFT, display_running_text.color )

    if display_ack.text ~= "" then
    
        if display_ack.background then
            sasl.gl.drawRectangle ( size[1]-100, size[2]-33, 100 , 32 , display_ack.color )
            sasl.gl.drawText (B612MONO_regular, size[1]-8, size[2]-25, display_ack.text , 25, false, false, TEXT_ALIGN_RIGHT, ECAM_BLACK )
        else
            sasl.gl.drawText (B612MONO_regular, size[1]-8, size[2]-25, display_ack.text , 25, false, false, TEXT_ALIGN_RIGHT, display_ack.color )
        end
    end
    
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-56,  display_top[1].text , 25, false, false, TEXT_ALIGN_LEFT, display_top[1].color )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-92,  display_top[2].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[2].color )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-128, display_top[3].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[3].color )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-164, display_top[4].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[4].color )
    sasl.gl.drawText (B612MONO_regular, 10, size[2]-200, display_top[5].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[5].color )

--    testID = sasl.findNavAid (nil, nil, get(Aircraft_lat) , get(Aircraft_long), nil, NAV_AIRPORT)
--    types, arptLat ,arptLon ,height ,freg ,heading ,id ,name ,inCurDSF = sasl.getNavAidInfo(testID)
--    print(types , arptLat , arptLon , height , freg , heading , id , name , inCurDSF)
    
end
