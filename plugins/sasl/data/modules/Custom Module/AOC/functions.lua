include("libs/string-slice.lua")

local function insert_received_messages(from_who, title, message)
    local time = (get(ZULU_hours) < 10 and "0"..get(ZULU_hours) or get(ZULU_hours)) ..":".. (get(ZULU_mins) < 10 and "0"..get(ZULU_mins) or get(ZULU_mins))
    local table_buffer = {
        from_who = from_who,
        time = time, 
        opened = false,
        title = title,
        message = string_slice(message, 24)
    }
    local existing_messages = #AOC_sys.msgs
    for i = 1, existing_messages do
        i = existing_messages - i + 1 -- invert the i loop, so the last ones gets shifted first
        AOC_sys.msgs[i+1] = AOC_sys.msgs[i] -- shift everything down a slot

        ---------------------------
        --  1  -  2  -  3  -  4  --
        ---------------------------
             ---BECOME
        ---------------------------------
        -- NEW -  1  -  2  -  3  -  4  --
        ---------------------------------

    end
    AOC_sys.msgs[1] = table_buffer
end

function AOC_atis_req_callback(  url ,  contents ,  isOk ,  error , airport)
    if string.find(contents, "server info") == nil then return end
    local i, j = string.find(contents, "server info")
    local starting_point = j + 3
    local ending_point = #contents - 2

    contents = string.sub(contents, starting_point, ending_point)
    insert_received_messages(airport.." ATIS", airport.." ATIS", contents)
end

function AOC_paragraph_split(string) -- this splits the message into displayable content in an mcdu, which has width 24 characters
end