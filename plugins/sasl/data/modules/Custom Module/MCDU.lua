position = {75,1690,320,285}
size = {320, 285}

--[[
--
--
--      A32NX MCDU
--
--      CONSTS DECLARATION
--      MCDU DATA INITIALIZATION
--      DATA & COMMAND REGISTRATION
--      MCDU PAGE SIMULATION
--
--
--]]

--[[
--
--
--      CONSTS DECLARATION
--
--
--]]

local MCDU_DRAW_SIZE = {w = 320, h = 285} -- idk if size table is required by anything else, this is for internal reference

--define the const size, align and row.
local MCDU_DIV_SIZE = {"s", "l"}
local MCDU_DIV_ALIGN = {"L", "C", "R"}
local MCDU_DIV_ROW = {1,2,3,4,5,6}

--line spacing
local MCDU_DRAW_OFFSET = {x = 7, y = 240} -- starting offset for line drawing
local MCDU_DRAW_SPACING = {x = 156, y = -18.5} -- change in offset per line drawn
local MCDU_DRAW_TEXT_SIZE = {s = 12, l = 20} -- font size

--reference table for drawing
local MCDU_DISP_COLOR = 
{
    ["white"] = {1.0, 1.0, 1.0},
    ["blue"] = {0.004, 1.0, 1.0},
    ["green"] = {0.184, 0.733, 0.219},
    ["orange"] = {0.725, 0.521, 0.18},
    ["black"] = {0,0,0,1},
}
local MCDU_DISP_TEXT_SIZE =
{
    ["s"] = MCDU_DRAW_TEXT_SIZE.s,
    ["l"] = MCDU_DRAW_TEXT_SIZE.l,
}
local MCDU_DISP_TEXT_SPACING =
{
    ["s"] = 1.667,
    ["l"] = 1.0,
}
local MCDU_DISP_TEXT_ALIGN =
{
    ["L"] = TEXT_ALIGN_LEFT,
    ["C"] = TEXT_ALIGN_CENTER,
    ["R"] = TEXT_ALIGN_RIGHT,
}

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

-- alphanumeric & decimal FMC entry keys
local MCDU_ENTRY_KEYS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "Δ", " "}
local MCDU_ENTRY_PAGES = {"DIR", "PROG", "PERF", "INIT", "DATA", "F-PLN", "RAD NAV", "FUEL PRED", "SEC F-PLN", "ATC COMM", "MCDU MENU", "AIRP"}
local MCDU_ENTRY_SIDES = {"L1", "L2", "L3", "L4", "L5", "L6", "R1", "R2", "R3", "R4", "R5", "R6", "slew_up", "slew_down", "slew_left", "slew_right"}

--[[
--
--
--      MCDU DATA INITIALIZATION
--
--
--]]

local mcdu_dat = {}
local mcdu_dat_title = {}

for i,size in ipairs(MCDU_DIV_SIZE) do
	mcdu_dat[size] = {}
	for j,align in ipairs(MCDU_DIV_ALIGN) do
		mcdu_dat[size][align] = {}
	end
end

--entry line
local mcdu_entry = ""
local mcdu_messages = {}

--mcdu page call functions
local mcdu_sim_page = {}

--define custom functionalities
local function mcdu_send_message(message)
    table.insert(mcdu_messages, message)
end

local function mcdu_eval_entry(str, format)
    pass = true
    if #str ~= #format then
        pass = false
    end

    for i = 1,#format do
        if string.sub(format, i, i) == "!" then
            -- digit
            if string.find(string.sub(str, i, i), "%d") == nil then
                pass = false
            end
        elseif string.sub(format, i, i) == "@" then
            -- letter
            if string.find(string.sub(str, i, i), "%a") == nil then
                pass = false
            end
        elseif string.sub(format, i, i) == "#" then
            -- do nothing
        else
            if string.sub(str, i, i) ~= string.upper(string.sub(format, i, i)) then 
                pass = false
            end
        end
    end
    return pass
end

local function mcdu_get_entry(expected_formats)
    --[[
    -- expected_format
    --
    -- can accept multiple inputs ! for digits, @ for letters, # for anything
    -- https://www.lua.org/pil/20.2.html
    --]]
    if expected_formats[1] ~= nil then
        local pass = false
        variation = 0
        for i,format in ipairs(expected_formats) do-- expected_formats is a table
            if mcdu_eval_entry(mcdu_entry, format) then
                variation = i
                pass = true
            end
        end
        if pass then
            print("a")
            return mcdu_entry, variation 
        else
            mcdu_send_message("invalid format")
            return nil, nil
        end
    else
        if mcdu_eval_entry(mcdu_entry, expected_formats) then
            return mcdu_entry
        else
            mcdu_send_message("invalid format")
            return nil
        end
    end
    me = mcdu_entry
    mcdu_entry = ""
    return me
end

--clear MCDU
local function mcdu_clearall()
    mcdu_dat_title = {txt = "", col = "white", size = nil}
    for i,size in ipairs(MCDU_DIV_SIZE) do
        for j,align in ipairs(MCDU_DIV_ALIGN) do
            for k,row in ipairs(MCDU_DIV_ROW) do
                --mcdu_dat[size][align][row] = {txt = size .. "" .. align .. " " .. row, col = "white"}
                mcdu_dat[size][align][row] = {txt = nil, col = "white", size = nil}
            end
        end
    end
end

local mcdu_page = createGlobalPropertyi("a321neo/cockpit/mcdu/mcdu_page", 0, false, true, false)

--load MCDU page
local function mcdu_open_page(id)
    mcdu_clearall()
    set(mcdu_page, id)
    mcdu_sim_page[get(mcdu_page)]("render")
end



--[[
--
--
--      DATA & COMMAND REGISTERATION
--
--
--]]

--sim dataref
local TIME = globalProperty("sim/time/total_running_time_sec")
local PLANE_LOADED = false

--a321neo dataref
local mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)
local mcdu_message_index = createGlobalPropertyi("a321neo/debug/mcdu/message_index", 0, false, true, false)

--a321neo commands
local mcdu_debug_message = sasl.createCommand("a321neo/debug/mcdu/debug_message", "send a mcdu debug message")

--mcdu entry inputs
local mcdu_inp = {}

local entry_cooldown = 0

local MCDU_ENTRY = 
{
    {
        ref_name = "key",               --the group of the command
        ref_desc = "Key",               --the description of the command
        ref_entries = MCDU_ENTRY_KEYS,  --the group of keys
        ref_callback =                  --what they should do
        function (count, val)
            if get(TIME) - entry_cooldown > get(DELTA_TIME) then
                entry_cooldown = get(TIME)
                if #mcdu_entry < 22 then
                    mcdu_entry = mcdu_entry .. val
                end
            end
        end
    },
    {
        ref_name = "page",
        ref_desc = "Page",
        ref_entries = MCDU_ENTRY_PAGES,
        ref_callback = 
        function (count, val)
            mcdu_open_page(count * 100)
        end
    },
    {
        ref_name = "side",
        ref_desc = "Side key",
        ref_entries = MCDU_ENTRY_SIDES,
        ref_callback = 
        function (count, val)
            mcdu_sim_page[get(mcdu_page)](val)
        end
    },
    {
        ref_name = "misc",
        ref_desc = "Clear key",
        ref_entries = {"clr"},
        ref_callback = 
        function (count, val)
            if #mcdu_messages > 0 then
                table.remove(mcdu_messages)
            else
                if #mcdu_entry > 0 then
                    mcdu_entry = ""
                else
                    if #mcdu_entry == 0 then
                        mcdu_entry = "CLR"
                    end
                end
            end
        end
    },
    {
        ref_name = "misc",
        ref_desc = "positive_negative",
        ref_entries = {"postive_negative"},
        ref_callback = 
        function (count, val)
            if #mcdu_entry < 22 then
                if string.sub(mcdu_entry, #mcdu_entry, #mcdu_entry) == "-" then
                    mcdu_entry = string.sub(mcdu_entry, 0, #mcdu_entry - 1) .. "+"
                elseif string.sub(mcdu_entry, #mcdu_entry, #mcdu_entry) == "+" then
                    mcdu_entry = string.sub(mcdu_entry, 0, #mcdu_entry - 1) .. "-"
                elseif string.sub(mcdu_entry, #mcdu_entry, #mcdu_entry) ~= "+" and string.sub(mcdu_entry, #mcdu_entry, #mcdu_entry) ~= "-" then
                    mcdu_entry = mcdu_entry .. "-"
                end
            end
        end
    }
}

--register all entry keys
for i,entry_category in ipairs(MCDU_ENTRY) do
    for count,entry in ipairs(entry_category.ref_entries) do
        mcdu_inp[entry] = createCommand("a321neo/cockpit/mcdu/" .. entry_category.ref_name .. "/" .. entry, "MCDU " .. entry .. " " .. entry_category.ref_desc)
        sasl.registerCommandHandler(mcdu_inp[entry], 0, function (phase)
            if phase == SASL_COMMAND_BEGIN then
                entry_category.ref_callback(count, entry)
            end
        end)
    end
end

--a321neo command handlers
--debuggin
local hokey_pokey = false --wonder what this does
sasl.registerCommandHandler(mcdu_debug_message, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        hokey_pokey = true
        for i,f in ipairs({"white", "blue", "orange", "green"}) do
            MCDU_DISP_COLOR[f] = {1, 0, 0} 
        end
    end
end)


--[[
--
--
--      MCDU DRAWING
--
--
--]]

local draw_lines = {}
local draw_lines_itr = 0

local function draw_dat(dat, draw_size, disp_x, disp_y, disp_text_align)
    if dat.txt == nil then
        return
    end
    disp_text = dat.txt:upper()
    disp_color = MCDU_DISP_COLOR[dat.col]

    -- is there a custom size
    if dat.size == nil then
        disp_size = draw_size
    else
        disp_size = dat.size
    end

    -- text size 
    disp_text_size = MCDU_DISP_TEXT_SIZE[disp_size]
    -- text spacing
    disp_spacing = MCDU_DISP_TEXT_SPACING[disp_size]

    -- now draw it!
    table.insert(draw_lines, {disp_x = disp_x, disp_y = disp_y, disp_text = disp_text, disp_text_size = disp_text_size, disp_text_align = disp_text_align, disp_color = disp_color, disp_spacing = disp_spacing})
end

local function draw_update()
    -- clear all line which need to be drawn
    draw_lines = {}
    draw_lines_itr = 0

    for i,draw_row in ipairs(MCDU_DIV_ROW) do
        for j,draw_size in ipairs(MCDU_DIV_SIZE) do
            draw_act_row = ((i - 1) * 2) + (j - 1) -- draw actual row

            for k,draw_align in ipairs(MCDU_DIV_ALIGN) do

                -- spacings
                disp_x = MCDU_DRAW_OFFSET.x
                disp_x = disp_x + (MCDU_DRAW_SPACING.x * (k - 1)) -- so -140, 0, 140

                disp_y = MCDU_DRAW_OFFSET.y
                disp_y = disp_y + (MCDU_DRAW_SPACING.y * draw_act_row) -- so 108, 90, 72

                -- text alignment
                disp_text_align = MCDU_DISP_TEXT_ALIGN[draw_align]

                -- text data
                dat_full = mcdu_dat[draw_size][draw_align][draw_row]
                if dat_full[1] == nil then
                    draw_dat(dat_full, draw_size, disp_x, disp_y, disp_text_align)
                else
                    for l,dat in pairs(dat_full) do
                        draw_dat(dat, draw_size, disp_x, disp_y, disp_text_align)
                    end
                end
            end
        end
    end

    --draw title line
    if mcdu_dat_title[1] == nil then
        draw_dat(mcdu_dat_title, "l", MCDU_DRAW_OFFSET.x, MCDU_DRAW_OFFSET.y + 20, MCDU_DISP_TEXT_ALIGN["L"])
    else
        for l,dat in pairs(mcdu_dat_title) do
            draw_dat(dat, "l", MCDU_DRAW_OFFSET.x, MCDU_DRAW_OFFSET.y + 20, MCDU_DISP_TEXT_ALIGN["L"])
        end
    end
end

local function colorize()
    for i,f in ipairs({"white", "blue", "orange", "green"}) do
        c = {}
        c[0] = MCDU_DISP_COLOR[f][1];c[1] = MCDU_DISP_COLOR[f][2];c[2] = MCDU_DISP_COLOR[f][3]
        print(c[0] .. " " .. c[1] .. " " .. c[2])
        inc = 0.1
        if c[0] < 1 and c[1] == 0 and c[2] == 0 then
            c[0] = c[0] + inc
        elseif c[0] == 1 and c[1] < 1 and c[2] == 0 then
            c[1] = c[1] + inc
        elseif c[0] <= 1 and c[0] > 0 and c[1] == 1 and c[2] == 0 then
            c[0] = c[0] - inc
        elseif c[0] == 0 and c[1] == 1 and c[2] < 1 then
            c[2] = c[2] + inc
        elseif c[0] == 0 and c[1] <= 1 and c[1] > 0 and c[2] == 1 then
            c[1] = c[1] - inc
        elseif c[0] < 1 and c[1] == 0 and c[2] == 1 then
            c[0] = c[0] + inc
        elseif c[0] == 1 and c[1] == 0 and c[2] <= 1 and c[2] > 0 then
            c[2] = c[2] - inc
        end
        MCDU_DISP_COLOR[f][1] = math.min(math.max(c[0], 0), 1); MCDU_DISP_COLOR[f][2] = math.min(math.max(c[1], 0), 1); MCDU_DISP_COLOR[f][3] = math.min(math.max(c[2], 0), 1)
    end
    draw_update()
end

--drawing the MCDU display
function draw()
    if hokey_pokey then
        colorize()
    end
    if get(mcdu_enabled) == 1 then
        sasl.gl.drawRectangle(0, 0, 320 , 285, MCDU_DISP_COLOR["black"])
        local draw_size = {MCDU_DRAW_SIZE.w, MCDU_DRAW_SIZE.h} -- for debugging
        --sasl.gl.drawText(B612MONO_regular, draw_size[1]/2-140, draw_size[2]/2+108, mcdu_dat_title.txt, 20, false, false,TEXT_ALIGN_LEFT, MCDU_DISP_COLOR[mcdu_dat_title_L.col])

        --draw all horizontal lines
        for i,line in ipairs(draw_lines) do
            sasl.gl.setFontGlyphSpacingFactor(B612MONO_regular, line.disp_spacing)
            sasl.gl.drawText(B612MONO_regular, line.disp_x, line.disp_y, line.disp_text, line.disp_text_size, false, false, line.disp_text_align, line.disp_color)
        end

        --drawing scratchpad
        sasl.gl.drawText(B612MONO_regular, draw_size[1]/2-140, draw_size[2]/2-132, mcdu_entry, 20, false, false, TEXT_ALIGN_LEFT, MCDU_DISP_COLOR["white"])
    end
end

--[[
--
--
--      MCDU PAGE SIMULATION
--
--      loosely based on
--      http://www.a320dp.com/A320_DP/nav-flight-management/sys-14.0.0.html
--      
--      WARNING - the website has an outdated MCDU, consult ToLiss for actual data
--      14.7.5 would be (0705 - 200) so 0505 so 505
--
--      0 - nothing
--      100 - dir
--      200 - prog
--      300 - perf
--      400 - init
--      500 - data
--        505 - data A/C status
--      600 - f-pln
--      700 - rad nav
--      800 - fuel pred
--      900 - sec f-pln
--      1000 - atc commm
--      1100 - mcdu menu
--      1200 - airp
--
--
--]]


local mcdu_ctrl_instructions = {}

local function mcdu_ctrl_add_inst(inst)
    table.insert(mcdu_ctrl_instructions, 1, inst)
end

local function mcdu_ctrl_exe_inst()
    if #mcdu_ctrl_instructions == 0 then
		return
	end

	inst = mcdu_ctrl_instructions[#mcdu_ctrl_instructions]
	table.remove(mcdu_ctrl_instructions)
    if inst.type == "CMD" then
        sasl.commandOnce(findCommand(inst.arg))
    end
    if inst.type == "GET_LN" then
        inst.callback(get(globalPropertys("sim/cockpit2/radios/indicators/fms_cdu1_text_line" .. inst.arg)))
    end
    if inst.type == "INPUT" then
        if string.sub(get(globalPropertys("sim/cockpit2/radios/indicators/fms_cdu1_text_line13")), 2, 2) == " " then
        print("inputarg")
            for i = 0,#inst.arg - 1 do
                table.insert(mcdu_ctrl_instructions, {type = "CMD", arg = "sim/FMS/key_" .. string.upper(string.sub(inst.arg, #inst.arg - i, #inst.arg - i))})
            end
        else
        print("inputdel" .. string.sub(get(globalPropertys("sim/cockpit2/radios/indicators/fms_cdu1_text_line13")), 2, 2))
            sasl.commandOnce(findCommand("sim/FMS/key_clear"))
            --delete the entire scratchpad
            table.insert(mcdu_ctrl_instructions, inst)
        end
    end
end

--update
function update()
    if get(mcdu_page) == 0 then --on start
       mcdu_open_page(505) --open 505 A/C status
    end

    if #mcdu_messages > 0 and mcdu_entry == "" then
        mcdu_entry = mcdu_messages[#mcdu_messages]
        table.remove(mcdu_messages)
    end
    mcdu_ctrl_exe_inst()
end

--[[
local function sleep(n)
    local t = sasl.createTimer()
    sasl.startTimer(t)
    local t0 = sasl.getElapsedSeconds(t)
    while sasl.getElapsedSeconds(t) - t0 <= n do end
end
--]]

local function mcdu_ctrl_get_cycle(callback)
    --[[
    sasl.commandOnce(findCommand("sim/FMS/index"))
    sleep(1)
    sasl.commandOnce(findCommand("sim/FMS/ls_1l"))
    sleep(1)
    callback(get(globalPropertys("sim/cockpit2/radios/indicators/fms_cdu1_text_line4")))
    --]]

    mcdu_ctrl_add_inst({type = "CMD", arg = "sim/FMS/index"})
    mcdu_ctrl_add_inst({type = "CMD", arg = "sim/FMS/ls_1l"})
    mcdu_ctrl_add_inst({type = "GET_LN", arg = "4", callback = callback})
end

local function mcdu_ctrl_set_fpln_origin(input)
    mcdu_ctrl_add_inst({type = "CMD", arg = "sim/FMS/fpln"})
    mcdu_ctrl_add_inst({type = "INPUT", arg = input})
    mcdu_ctrl_add_inst({type = "CMD", arg = "sim/FMS/ls_1l"})
end

-- 00 template
mcdu_sim_page[00] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          a321-521nx"

        --[[
        mcdu_dat["s"]["L"][1].txt = "□"
        mcdu_dat["l"]["L"][1][1] = {txt = " a", col = "green"}
        mcdu_dat["l"]["L"][1][1] = {txt = "  a", col = "blue", size = "s"}
        --]]

        draw_update()
    end
end

-- 400 init
mcdu_sim_page[400] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          init"

        mcdu_dat["s"]["L"][1].txt = " co rte"
        mcdu_dat["l"]["L"][1] = {txt = "□□□□□□□", col = "orange"}

        mcdu_dat["s"]["R"][1].txt = " from/to  "
        mcdu_dat["l"]["R"][1] = {txt = "□□□□/□□□□", col = "orange"}

        mcdu_dat["s"]["L"][2].txt = "altn/co route"
        mcdu_dat["l"]["L"][2].txt = "----/---------"

        mcdu_dat["s"]["L"][3].txt = "flt nbr"
        mcdu_dat["l"]["L"][3] = {txt = "□□□□□□□□", col = "orange"}

        mcdu_dat["s"]["L"][4].txt = "lat"
        mcdu_dat["l"]["L"][4].txt = "----.-"

        mcdu_dat["s"]["R"][4].txt = "long"
        mcdu_dat["l"]["R"][4].txt = "-----.--"

        mcdu_dat["s"]["L"][5].txt = "cost index"
        mcdu_dat["l"]["L"][5].txt = "---"

        mcdu_dat["l"]["R"][5].txt = "wind>"

        mcdu_dat["s"]["L"][6].txt = "crz fl/temp"
        mcdu_dat["l"]["L"][6].txt = "-----/---°"

        mcdu_dat["s"]["R"][6].txt = "tropo "
        mcdu_dat["l"]["R"][6] = {txt = "36090", col = "blue", size = "s"}

        draw_update()
    end
    if phase == "R1" then
        input, variation = mcdu_get_entry("####/####")
        if input ~= nil then
            mcdu_ctrl_set_fpln_origin(input[1] .. input[2] .. input[3] .. input[4])
            mcdu_ctrl_set_fpln_dest(input[6] .. input[7] .. input[8] .. input[9])
        end
    end
end
-- 500 data
mcdu_sim_page[500] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "     data index"

        mcdu_dat["s"]["L"][1].txt = " position"
        mcdu_dat["l"]["L"][1].txt = "<monitor"

        mcdu_dat["s"]["L"][2].txt = " irs"
        mcdu_dat["l"]["L"][2].txt = "<monitor"

        mcdu_dat["s"]["L"][3].txt = " gps"
        mcdu_dat["l"]["L"][3].txt = "<monitor"

        mcdu_dat["l"]["L"][4].txt = "<a/c status"

        draw_update()
    end
    if phase == "L4" then
        mcdu_open_page(505) -- open 505 data A/C status
    end
end

-- 505 data A/C status
mcdu_sim_page[505] =
function (phase)
    if phase == "render" then

        mcdu_dat["s"]["L"][1].txt = " eng"

        if get(Engine_option) == 0 then
            mcdu_dat_title.txt = "        a321-521nx"
            mcdu_dat["l"]["L"][1] = {txt = "cfm-leap-1a", col = "green"}
        else
            mcdu_dat_title.txt = "        a321-721nx"
            mcdu_dat["l"]["L"][1] = {txt = "pw-1130g-jm", col = "green"}
        end
        
        mcdu_dat["s"]["L"][2].txt = " active data base"
        mcdu_ctrl_get_cycle(function(val)
            mcdu_dat["l"]["L"][2] = {txt = val, col = "blue"}
            draw_update()
        end)
        mcdu_dat["s"]["L"][3].txt = " second data base"
        mcdu_dat["l"]["L"][3] = {txt = " none", col = "blue", size = "s"}

        mcdu_dat["l"]["L"][4].txt = "WORK IN PROGRESS"


        mcdu_dat["s"]["L"][5].txt = "chg code"
        mcdu_dat["l"]["L"][5] = {txt = "[ ]", col = "blue"}
        mcdu_dat["s"]["L"][6].txt = "idle/perf"
        mcdu_dat["l"]["L"][6] = {txt = "+0.0/+0.0", col = "green"}

       
        draw_update()
    end
end

-- 700 rad nav
mcdu_sim_page[700] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        radio nav"
        mcdu_dat["s"]["L"][1].txt = "vor1/freq"

        mcdu_dat["l"]["L"][1][1] = {txt = " [ ]", col = "blue"}
        mcdu_dat["l"]["L"][1][2] = {txt = "    /111.00", col = "blue", size = "s"}

        mcdu_dat["s"]["R"][1].txt = "freq/vor2"

        mcdu_dat["l"]["R"][1][1] = {txt = "[ ] ", col = "blue"}
        mcdu_dat["l"]["R"][1][2] = {txt = "110.90/    ", col = "blue", size = "s"}

        mcdu_dat["s"]["L"][2].txt = "crs"
        mcdu_dat["l"]["L"][2] = {txt = "315", col = "blue"}
        mcdu_dat["s"]["R"][2].txt = "crs"
        mcdu_dat["l"]["R"][2] = {txt = "315", col = "blue"}

        mcdu_dat["s"]["L"][3].txt = "ils /freq"
        mcdu_dat["l"]["L"][3][1] = {txt = "[  ]", col = "blue"}
        mcdu_dat["l"]["L"][3][2] = {txt = "    /108.10", col = "blue", size = "s"}

        mcdu_dat["s"]["R"][3].txt = "chan/ mls"
        mcdu_dat["l"]["R"][3].txt = "---/--- "

        mcdu_dat["s"]["L"][4].txt = "crs"
        mcdu_dat["l"]["L"][4].txt = "---"

        mcdu_dat["s"]["R"][4].txt = "slope   crs"
        mcdu_dat["l"]["R"][4].txt = " -.-    ---"

        mcdu_dat["s"]["L"][5].txt = "adf1/freq"
        mcdu_dat["l"]["L"][5][1] = {txt = " [ ]", col = "blue"}
        mcdu_dat["l"]["L"][5][2] = {txt = "    / 210.0", col = "blue", size = "s"}

        mcdu_dat["s"]["R"][5].txt = "freq/adf2"
        mcdu_dat["l"]["R"][5][1] = {txt = "[ ] ", col = "blue"}
        mcdu_dat["l"]["R"][5][2] = {txt = "210.0/    ", col = "blue", size = "s"}

        draw_update()
    end
end

-- 1100 mcdu menu
mcdu_sim_page[1100] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        mcdu menu"
        mcdu_dat["l"]["L"][1].txt = "<fmgc"

        mcdu_dat["l"]["R"][6].txt = "debug>"
        draw_update()
    end
    if phase == "L1" then
        mcdu_open_page(505) -- open 505 data a/c status
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu debug
    end
end

-- 1101 mcdu menu debug
mcdu_sim_page[1101] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "    a32nx project"

        mcdu_dat["s"]["L"][1].txt = "mcdu version"
        mcdu_dat["l"]["L"][1].txt = "v1.0"
        mcdu_dat["l"]["L"][2].txt = "<colours"

        mcdu_dat["l"]["R"][6].txt = "return>"
        draw_update()
    end
    if phase == "L2" then
        mcdu_open_page(1102) -- open 1102 mcdu menu debug
    end
    if phase == "R6" then
        mcdu_open_page(1100) -- open 1100 mcdu menu
    end
end

local function mcdu_parse_colour(callback)
    if mcdu_get_entry({"r!.!!", "g!.!!", "b!.!!"}) ~= nil then
        input, variation = mcdu_get_entry({"r!.!!", "g!.!!", "b!.!!"})
        print(input, variation)
        input_col = string.sub(input, 2, 2) .. "." .. string.sub(input, 4,5)
        callback(input, variation)
        mcdu_open_page(1102) -- reload page
    else
        print("fail")
        mcdu_send_message("format e.g. b0.50")
    end
end
-- 1102 mcdu menu debug colours
mcdu_sim_page[1102] =
function (phase)
    if phase == "render" then
        for i,col in ipairs({"white", "blue", "green", "orange"}) do
            mcdu_dat["s"]["L"][i].txt = col .. " colour"
            mcdu_dat["l"]["L"][i] = {txt = "<R" .. MCDU_DISP_COLOR[col][1] .. "G" .. MCDU_DISP_COLOR[col][2] .. "B" .. MCDU_DISP_COLOR[col][3], col = col}
        end
        mcdu_dat["l"]["L"][5].txt = "format e.g. r0.10"
        mcdu_dat["l"]["L"][6].txt = "<disco mode"

        mcdu_dat["l"]["R"][6].txt = "return>"
        draw_update()
    end
    if phase == "L1" then
        mcdu_parse_colour(function (input, variation)
            MCDU_DISP_COLOR["white"][variation] = input_col
        end)
    end
    if phase == "L2" then
        mcdu_parse_colour(function (input, variation)
            MCDU_DISP_COLOR["blue"][variation] = input_col
        end)
    end
    if phase == "L3" then
        mcdu_parse_colour(function (input, variation)
            MCDU_DISP_COLOR["green"][variation] = input_col
        end)
    end
    if phase == "L4" then
        mcdu_parse_colour(function (input, variation)
            MCDU_DISP_COLOR["orange"][variation] = input_col
        end)
    end
    if phase == "L6" then
        hokey_pokey = true
        for i,f in ipairs({"white", "blue", "orange", "green"}) do
            MCDU_DISP_COLOR[f] = {1, 0, 0} 
        end
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu debug
    end
end
