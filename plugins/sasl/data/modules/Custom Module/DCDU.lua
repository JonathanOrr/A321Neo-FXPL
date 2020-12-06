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
-- File: DCDU.lua 
-- Short description: Main file for DCDU
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- DCDU Graphics & Logic
--
-- The DCDU logic works as follows:
-- - The Acars_status dataref is updated according to VHF and SATCOM communications (see function `update_satcom_vhf_connection` for details) 
-- - If Acars_status == 0 the disconnession message is showed
-- - If Acars_status > 0 we have a connection. The selection of the ATC to show depends on the current status of the flight (see function `update_connected_atc`)
-- - If Acars_status > 0 and at least a message exists in the array `current_messages`, the message in the position `get(DCDU_msg_no)` is shown
-- Each message has the following format: {msg_text="Text", msg_type=MESSAGE_TYPE_WILCO, msg_type_orig=MESSAGE_TYPE_WILCO, msg_status=MESSAGE_STATUS_NEW, msg_time="1200", msg_source="LIML"}
-- The message type initially refers to the type of the message, i.e. WILCO or ROGER. Then it moves to the CONFIRM, SENDING and SEND stage, depending on user inputs
-- Please check the following constants
----------------------------------------------------------------------------------------------------

-- Messages to be implemented:
-- ROGER 7500 (ACK)

-- Auto-metar (ACK)
-- ALTIMETER [altimeter] (ROGER)
-- [facility designation] ALTIMETER [altimeter] (ROGER)
-- RADAR CONTACT [position] (ROGER)

position= {1990,1866,463,325}
size = {463, 325}

include('DCDU_handlers.lua')    -- DCDU handlers contains the button handlers
include('constants.lua')

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------

include('constants.lua')

-- Message types
MESSAGE_TYPE_WILCO    = 1
MESSAGE_TYPE_ROGER    = 2
MESSAGE_TYPE_AFFNEG   = 3
MESSAGE_TYPE_AFFIRM   = 4
MESSAGE_TYPE_NEGATIVE = 5
MESSAGE_TYPE_NORESP   = 6
MESSAGE_TYPE_UNABLE   = 10
MESSAGE_TYPE_STDBY    = 11

-- Message status
MESSAGE_STATUS_NEW     = 1
MESSAGE_STATUS_CONFIRM = 2
MESSAGE_STATUS_SENDING = 3
MESSAGE_STATUS_SENT    = 4
MESSAGE_STATUS_DONE    = 5

-- 10 seconds after power on
FIRST_CONNECTION_TIME = 10

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------

-- Text status in each region of the DCDU display
local display_btm_left  = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_btm_right = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_title = {text="", color=ECAM_BLACK}
local display_r = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_l = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}
local display_running_text = {text="", color=ECAM_GREEN}
local display_ack = {text="", color="", background=false}
local display_top = {{text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}, {text="", color=ECAM_BLACK}}

-- A couple of boolean to manage the status
local was_connected  = true
local updated_connection = false

-- Current ATC information
local curr_atc_id   = ""
local curr_atc_name = ""
local curr_atc_lat = 0
local curr_atc_lon = 0
local array_ctr = {}
local nearest_ctr = nil

-- Power on time
local powered_on_at = 0

-- The time when a message switch from the status CONFIRM to the status SENDING. After 3 seconds from this time,
-- the status switch to SENT
time_to_send = 0    -- It must stay at zero unless a message is in the status SENDING

-- The most important array: the list of currenctly active messages
current_messages   = {}
-- The past messages (no actions possible, just view)
past_messages   = {}

-- A boolean to avoid to re-draw everything every update call.
change_occured = true

-- Used to keep track of the last time we updated the CTR list
local last_CTR_update = 0

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

-- Inizialization of the array of ATC CTR messages. This is an intensive operation because it
-- requires to parse the whole text file and should be performed only once at startup
local function init_array_ctr()
    array_ctr = Read_CSV(moduleDirectory .. "/Custom Module/data/ctr.csv")
end
init_array_ctr()    -- This funciton is immediately called at startup

-- Function to search the nearest ATC CTR. Avoid to call this function too frequently.
-- The nearest CTR is put into the `nearest_ctr` variable
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

-- Clears all the text. The DCDU screen becomes black (with except of the fixed lines)
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

local function display_message_new(message_text, message_type)
    display_ack.text = "OPEN"
    display_ack.color = ECAM_BLUE
    display_ack.background = false
    
    if message_type == MESSAGE_TYPE_WILCO then
        display_btm_right[3].text = "WILCO *"
        display_btm_right[1].text = "STBY *"
        display_btm_left[1].text = "* UNABLE"
    elseif message_type == MESSAGE_TYPE_ROGER then
        display_btm_right[3].text = "ROGER *"
        display_btm_right[1].text = "STBY *"
        display_btm_left[1].text = "* UNABLE"
    elseif message_type == MESSAGE_TYPE_AFFNEG then
        display_btm_right[3].text = "AFFIRM *"
        display_btm_right[1].text = "STBY *"
        display_btm_left[3].text = "* NEGAT."
    elseif message_type == MESSAGE_TYPE_NORESP then
        display_ack.text = "ACK"
        display_ack.color = ECAM_GREEN
        display_ack.background = true
        display_btm_right[3].text = "CLOSE *"
    end    
    
end

local function display_message_confirm(message_text, message_type)
    
    display_btm_right[3].text = "SEND *"
    display_btm_left[1].text  = "* CANCEL"
    display_title.text = "CONFIRM"
    display_title.color = ECAM_BLUE
    display_ack.color = ECAM_BLUE
    display_ack.background = true
    
    if message_type == MESSAGE_TYPE_WILCO then
        display_ack.text = "WILCO"
    elseif message_type == MESSAGE_TYPE_ROGER then
        display_ack.text = "ROGER"
    elseif message_type == MESSAGE_TYPE_AFFIRM then
        display_ack.text = "AFFIRM"
    elseif message_type == MESSAGE_TYPE_NEGATIVE then
        display_ack.text = "NEGATIVE"
    elseif message_type == MESSAGE_TYPE_UNABLE then
        display_ack.text = "UNABLE"
    elseif message_type == MESSAGE_TYPE_STDBY then
        display_ack.text = "STBY"
    end
    
end

local function display_message_sending(message_text, message_type)
    display_title.text = "SENDING"
    display_title.color = ECAM_WHITE
    display_ack.color = ECAM_BLUE
    display_ack.background = true
    
    if message_type == MESSAGE_TYPE_WILCO then
        display_ack.text = "WILCO"
    elseif message_type == MESSAGE_TYPE_ROGER then
        display_ack.text = "ROGER"
    elseif message_type == MESSAGE_TYPE_AFFIRM then
        display_ack.text = "AFFIRM"
    elseif message_type == MESSAGE_TYPE_NEGATIVE then
        display_ack.text = "NEGATIVE"
    elseif message_type == MESSAGE_TYPE_UNABLE then
        display_ack.text = "UNABLE"
    elseif message_type == MESSAGE_TYPE_STDBY then
        display_ack.text = "STBY"
    end
    

end

local function display_message_sent(message_text, message_type)
    display_title.text = "SENT"
    display_title.color = ECAM_GREEN
    display_ack.color = ECAM_GREEN
    display_ack.background = true
    display_btm_right[3].text = "CLOSE *"
        
    if message_type == MESSAGE_TYPE_WILCO then
        display_ack.text = "WILCO"
    elseif message_type == MESSAGE_TYPE_ROGER then
        display_ack.text = "ROGER"
    elseif message_type == MESSAGE_TYPE_AFFIRM then
        display_ack.text = "AFFIRM"
    elseif message_type == MESSAGE_TYPE_NEGATIVE then
        display_ack.text = "NEGATIVE"
    elseif message_type == MESSAGE_TYPE_UNABLE then
        display_ack.text = "UNABLE"
    elseif message_type == MESSAGE_TYPE_STDBY then
        display_ack.text = "STBY"
    end
        
end

local function display_message_done(message_text, message_type)
    display_title.text = "RECALL MODE"
    display_title.color = ECAM_WHITE
    display_ack.color = ECAM_GREEN
    display_ack.background = true
    display_btm_right[3].text = "CLOSE *"
        
    if message_type == MESSAGE_TYPE_WILCO then
        display_ack.text = "WILCO"
    elseif message_type == MESSAGE_TYPE_ROGER then
        display_ack.text = "ROGER"
    elseif message_type == MESSAGE_TYPE_AFFIRM then
        display_ack.text = "AFFIRM"
    elseif message_type == MESSAGE_TYPE_NEGATIVE then
        display_ack.text = "NEGATIVE"
    elseif message_type == MESSAGE_TYPE_NORESP then
        display_ack.text = "ACK"
    elseif message_type == MESSAGE_TYPE_UNABLE then
        display_ack.text = "UNABLE"
    elseif message_type == MESSAGE_TYPE_STDBY then
        display_ack.text = "STBY"
    end
        
end


-- The core function: this function shows the message according to its type
local function display_message(message_text, message_type, message_status, msg_time, msg_source)

    reset_display()

    display_running_text.text = msg_time .. "Z FROM " .. msg_source
 
    local MAX_LINE_LENGTH = 28

    local message_length = string.len(message_text)
    
    local total_num_pages = math.ceil(message_length/(MAX_LINE_LENGTH*5))
    set(DCDU_pages_total, total_num_pages)
    local start_page = get(DCDU_page_no)*MAX_LINE_LENGTH*5
   
    for i=1,5 do
        display_top[i].text  = string.sub(message_text,start_page + (i-1) * MAX_LINE_LENGTH + 1, start_page + i * MAX_LINE_LENGTH)
        if message_status == MESSAGE_STATUS_SENT or message_status == MESSAGE_STATUS_DONE then
            display_top[i].color = ECAM_GREEN        
        else
            display_top[i].color = ECAM_WHITE
        end
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


    display_btm_right[1].color = ECAM_BLUE 
    display_btm_right[3].color = ECAM_BLUE 
    display_btm_left[1].color = ECAM_BLUE 
    display_btm_left[3].color = ECAM_BLUE 

    if message_status == MESSAGE_STATUS_NEW then
        display_message_new(message_text, message_type)
    elseif message_status == MESSAGE_STATUS_CONFIRM then
        display_message_confirm(message_text, message_type)
    elseif message_status == MESSAGE_STATUS_SENDING then
        display_message_sending(message_text, message_type)
    elseif message_status == MESSAGE_STATUS_SENT then
        display_message_sent(message_text, message_type)
    elseif message_status == MESSAGE_STATUS_DONE then
        display_message_done(message_text, message_type)
    end

end

-- Function called when no connection is active
local function update_no_connection()

    reset_display()

    display_top[2].text = "ATC DISCONNECTED"
    display_top[2].color = ECAM_ORANGE

    display_title.text = "LINK LOST"
    display_title.color = ECAM_ORANGE

    display_btm_right[3].text = "RECALL *"
    display_btm_right[3].color = ECAM_BLUE
    
    display_running_text.text = get(ZULU_hours) .. get(ZULU_mins) .. "Z"
    
end

-- Function called when connection is ok but no messages are present
local function update_no_messages(double_conn)

    reset_display()

    display_top[2].text = "ACTIVE ATC: " .. curr_atc_id
    display_top[2].color = ECAM_GREEN
    display_top[3].text = string.sub(string.upper(curr_atc_name), 0, 28)
    display_top[3].color = ECAM_GREEN

    display_top[5].color = ECAM_GREEN
    
    if get(Acars_status) == 1 then
        display_top[5].text = "                       SATCOM"
    elseif get(Acars_status) == 2 then
        display_top[5].text = "                          VHF"
    elseif get(Acars_status) == 3 then
        display_top[5].text = "                 SATCOM + VHF"
    end
    display_btm_right[3].text = "RECALL *"
    display_btm_right[3].color = ECAM_BLUE
    
    display_running_text.text = get(ZULU_hours) .. get(ZULU_mins) .. "Z"
    
end

-- RECALL is called but no messages are present
local function update_no_recall_messages()
    reset_display()
    
    display_btm_right[3].text = "CLOSE *"
    display_btm_right[3].color = ECAM_BLUE    
    
    display_top[3].text  = "         NO MESSAGES"
    display_top[3].color = ECAM_GREEN
    
    display_title.text = "RECALL MODE"
    display_title.color = ECAM_WHITE
    
    display_running_text.text = get(ZULU_hours) .. get(ZULU_mins) .. "Z"
    
end

-- Update the SATCOM and VHF status
local function update_satcom_vhf_connection()

    if get(AC_bus_1_pwrd) == 0 then
        -- No power? No connection
        set(Acars_status, 0)
        powered_on_at = 0
        return
    elseif powered_on_at == 0 then
        powered_on_at = get(TIME)
    end
    
    if get(TIME) - powered_on_at < FIRST_CONNECTION_TIME then
        set(Acars_status, 0)
        return
    end

    -- SATCOM
    local is_satcom_connected = 1
    if math.abs(get(Aircraft_lat)) > 75 then
        is_satcom_connected = 0 -- SATCOM is not available over 75 degrees
    end
    if math.abs(get(Flightmodel_roll)) > 30 then
        is_satcom_connected = 0 -- The antenna of the SATCOM is no more towards the sky
    end
    
    math.randomseed(get(TIME))
    if math.random (1, 10000) == 5000 then  -- Random satellite disconnection
        is_satcom_connected = 0
    end

    -- VHF
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

    if get(VHF_3_monitor_selected) == 1 then
        is_vhf_connected = 0
    end

    set(Acars_status, is_satcom_connected + is_vhf_connected) -- 0 not connected, 1 only satcom, 2 only vhf, 3 both
end

-- Update the current ATC name
local function update_connected_atc()

    -- Two cases:
    -- - Not airbone: nearest airport
    -- - Airbone: nearest CTR (it does not use the real CTR boundaries)

    local temp_atc_id = ""
    local temp_atc_name = ""

    -- Search the nearest airport (this is needed even if we are airbone for VHF check!)
    testID = sasl.findNavAid (nil, nil, get(Aircraft_lat), get(Aircraft_long), nil, NAV_AIRPORT)
    if testID ~= -1 then
        types, arptLat, arptLon, height, freg, heading, temp_atc_id, temp_atc_name, inCurDSF = sasl.getNavAidInfo(testID)
    else
        temp_atc_id = ""
        temp_atc_name = ""
    end

    -- But if we are airbone, let's switch to ACC
    if get(EWD_flight_phase) == 6 and nearest_ctr ~= nil then
        temp_atc_id   = nearest_ctr[1]
        temp_atc_name = nearest_ctr[2] .. " ACC"
    end

    -- If changes, let's update everything
    if temp_atc_id ~= curr_atc_id then
        curr_atc_id = temp_atc_id
        curr_atc_name = temp_atc_name
        curr_atc_lat = arptLat
        curr_atc_lon = arptLon
        change_occured = false
    end
end

-- To add a new message, a new message text is put in dataref Acars_incoming_message, the type in
-- Acars_incoming_message_type and the string length in Acars_incoming_message_length. This function
-- automatically reset the type
local function check_new_messages()
    if get(Acars_incoming_message_type) == 0 then
        return  -- No new message
    end
    
    -- The following sub is needed to remove any text after the termination character
    msg_text = get(Acars_incoming_message)
    msg_text = string.sub(msg_text, 0, get(Acars_incoming_message_length))

    -- Create the new message and add it to the table    
    new_message = {msg_text=msg_text, msg_type=get(Acars_incoming_message_type), msg_type_orig=get(Acars_incoming_message_type), msg_status=MESSAGE_STATUS_NEW, msg_time=get(ZULU_hours) .. get(ZULU_mins), msg_source="USER"}
    table.insert(current_messages, new_message)

    -- Reset & Update the datarefs    
    set(Acars_incoming_message_type, 0)
    set(Acars_incoming_message, "")
    if get(DCDU_recall_mode) == 0 then
        set(DCDU_msgs_total, #current_messages)
    end
end

-- This function switches the status SENDING to SENT when needed (after 3 seconds).
local function update_sending_message()
    if time_to_send > 0 and get(TIME) - time_to_send > 3  then
        if get(Acars_status) ~= 0 then
            current_messages[get(DCDU_msg_no)+1].msg_status = MESSAGE_STATUS_SENT
        end
        time_to_send = 0
        change_occurred = true
    end
end

function update_new_message_light()

    set(DCDU_new_msgs, 0)
    
    if #current_messages > 0 then
        for i,m in ipairs(current_messages) do
            if m.msg_status < MESSAGE_STATUS_SENDING then
                set(DCDU_new_msgs, 1)
            end 
        end
    end

    pb_set(PB.glare.atc_msg, (get(TIME)%1) < 0.5 and get(DCDU_new_msgs) > 0, (get(TIME)%1) < 0.5 and get(DCDU_new_msgs) > 0 )

end

function update()
    perf_measure_start("DCDU:update()")
    check_new_messages()
    update_new_message_light()


    -- Update connection status and CTR every 5 seconds and 60 seconds
    if get(TIME) - last_CTR_update > 5 then  -- Update connection status every 5 sec
        last_CTR_update = get(TIME)
        if not updated_connection then     -- This is to avoid multiple calls
           updated_connection = true
           update_satcom_vhf_connection()
           -- Update the connected ATC (CTR has been already computed)
           update_connected_atc()

           if math.ceil(get(TIME)) % 60 == 0 then  -- Update the ATC CTR every minute (quite computational intensive)
                update_nearest_ctr()
           end
            change_occured = true
        end

    else
        updated_connection = false
    end

    if get(Acars_status) == 0 then
        -- No connection, nothing to do
        was_connected = false
        update_no_connection()
    end

    if get(DCDU_recall_mode) == 1 then
        if #past_messages == 0 then
            update_no_recall_messages()
        else
            display_message(past_messages[get(DCDU_msg_no)+1].msg_text, past_messages[get(DCDU_msg_no)+1].msg_type, past_messages[get(DCDU_msg_no)+1].msg_status, past_messages[get(DCDU_msg_no)+1].msg_time, past_messages[get(DCDU_msg_no)+1].msg_source)
        end
        
        return
    end
        
    if get(Acars_status) > 0 then
    
        if #current_messages > 0 then
            display_message(current_messages[get(DCDU_msg_no)+1].msg_text, current_messages[get(DCDU_msg_no)+1].msg_type, current_messages[get(DCDU_msg_no)+1].msg_status, current_messages[get(DCDU_msg_no)+1].msg_time, current_messages[get(DCDU_msg_no)+1].msg_source)
            update_sending_message()
        else
            if change_occured or not was_connected then
                change_occured = false
                update_no_messages()
                return
            end
        end
        was_connected = true
    end

    perf_measure_stop("DCDU:update()")
end

-- The draw fuction. No logic here, just graphic
function draw()
    perf_measure_start("DCDU:draw()")

    if get(AC_bus_1_pwrd) == 0 then
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.5, 0.5)   -- ~60W (just hypothesis, includes acars)

    sasl.gl.drawText (Font_AirbusDUL, 10, 20, display_btm_left[3].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[3].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, 50, display_btm_left[2].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[2].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, 80, display_btm_left[1].text, 20, false, false, TEXT_ALIGN_LEFT, display_btm_left[1].color )


    sasl.gl.drawText (Font_AirbusDUL, size[1]-10, 20, display_btm_right[3].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[3].color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]-10, 50, display_btm_right[2].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[2].color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]-10, 80, display_btm_right[1].text , 20, false, false, TEXT_ALIGN_RIGHT, display_btm_right[1].color )

    sasl.gl.drawText (Font_AirbusDUL, size[1]/2, 80, display_title.text, 20, false, false, TEXT_ALIGN_CENTER, display_title.color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]/2+100, 50, display_r[1].text , 20, false, false, TEXT_ALIGN_RIGHT, display_r[1].color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]/2+100, 20, display_r[2].text , 20, false, false, TEXT_ALIGN_RIGHT, display_r[2].color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]/2-95, 50,  display_l[1].text , 20, false, false, TEXT_ALIGN_LEFT, display_l[1].color )
    sasl.gl.drawText (Font_AirbusDUL, size[1]/2-95, 20,  display_l[2].text , 20, false, false, TEXT_ALIGN_LEFT, display_l[2].color )

    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-20, display_running_text.text , 17, false, false, TEXT_ALIGN_LEFT, display_running_text.color )

    if display_ack.text ~= "" then
    
        if display_ack.background then
            width, height = sasl.gl.measureText(Font_AirbusDUL, display_ack.text, 25, false, false)
            sasl.gl.drawRectangle ( size[1]-width-10, size[2]-33, width+10 , 32 , display_ack.color )
            sasl.gl.drawText (Font_AirbusDUL, size[1]-8, size[2]-25, display_ack.text , 25, false, false, TEXT_ALIGN_RIGHT, ECAM_BLACK )
        else
            sasl.gl.drawText (Font_AirbusDUL, size[1]-8, size[2]-25, display_ack.text , 25, false, false, TEXT_ALIGN_RIGHT, display_ack.color )
        end
    end
    
    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-56,  display_top[1].text , 25, false, false, TEXT_ALIGN_LEFT, display_top[1].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-92,  display_top[2].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[2].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-128, display_top[3].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[3].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-164, display_top[4].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[4].color )
    sasl.gl.drawText (Font_AirbusDUL, 10, size[2]-200, display_top[5].text, 25, false, false, TEXT_ALIGN_LEFT, display_top[5].color )

    perf_measure_stop("DCDU:draw()")   
end
