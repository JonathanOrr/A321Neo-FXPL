position = {75,1690,320,285}
size = {320, 285}

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
    ["green"] = {0.004, 1, 0.004},
    ["orange"] = {0.843, 0.49, 0},
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
local MCDU_ENTRY_KEYS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."}
local MCDU_ENTRY_PAGES = {"DIR", "PROG", "PERF", "INIT", "DATA", "F-PLN", "RAD NAV", "FUEL PRED", "SEC F-PLN", "ATC COMM", "MCDU MENU", "AIRP"}


--[[
--
--
--      DATA & COMMAND REGISTERATION
--
--
--]]

--sim dataref

--a321neo dataref
local mcdu_page = createGlobalPropertyi("a321neo/cockpit/mcdu/mcdu_page", 0, false, true, false)
local mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)
local mcdu_message_index = createGlobalPropertyi("a321neo/debug/mcdu/message_index", 0, false, true, false)

--sim commands

--a321neo commands
local mcdu_debug_message = sasl.createCommand("a321neo/debug/mcdu/debug_message", "send a mcdu debug message")

--mcdu keyboard
--mcdu menu buttons
local mcdu_DIR_key = createCommand("a321neo/cockpit/mcdu/dir", "MCDU DIR Key")
local mcdu_PROG_key = createCommand("a321neo/cockpit/mcdu/prog", "MCDU PROG Key")
local mcdu_PERF_key = createCommand("a321neo/cockpit/mcdu/perf", "MCDU PERF Key")
local mcdu_INIT_key = createCommand("a321neo/cockpit/mcdu/init", "MCDU INIT Key")
local mcdu_DATA_key = createCommand("a321neo/cockpit/mcdu/data", "MCDU DATA Key")
local mcdu_FPLN_key = createCommand("a321neo/cockpit/mcdu/fpln", "MCDU F-PLN Key")
local mcdu_RADNAV_key = createCommand("a321neo/cockpit/mcdu/radnav", "MCDU RAD NAV Key")
local mcdu_FUELPRED_key = createCommand("a321neo/cockpit/mcdu/fuelpred", "MCDU FUEL PRED Key")
local mcdu_SECFPLN_key = createCommand("a321neo/cockpit/mcdu/secfpln", "MCDU SEC F-PLN Key")
local mcdu_ATCCOMM_key = createCommand("a321neo/cockpit/mcdu/atccomm", "MCDU ATC COMM Key")
local mcdu_MCDUMENU_key = createCommand("a321neo/cockpit/mcdu/mcdumenu", "MCDU MCDU MENU Key")
local mcdu_AIRPORT_key = createCommand("a321neo/cockpit/mcdu/airport", "MCDU AIRPORT Key")

local mcdu_positive_negative_key = createCommand("a321neo/cockpit/mcdu/positive_negative", "MCDU Positive Negative Key")

local mcdu_clr_key = createCommand("a321neo/cockpit/mcdu/clr", "MCDU CLR Key")

local mcdu_page_up = sasl.createCommand("a321neo/cockpit/mcdu/page_up", "MCDU page up Key")
local mcdu_page_dn = sasl.createCommand("a321neo/cockpit/mcdu/page_dn", "MCDU page down Key")
--mcdu entry inputs

--alphanumeric and decimal
local mcdu_inp_key = {}
local mcdu_inp_page = {}

for i,key in ipairs(MCDU_ENTRY_KEYS) do
	-- create the command
	mcdu_inp_key[key] = createCommand("a321neo/cockpit/mcdu/" .. key, "MCDU Character " .. key .. " Key")
	-- register the command
	sasl.registerCommandHandler(mcdu_inp_key[key], 0, function (phase)
		if phase == SASL_COMMAND_BEGIN then
			if #mcdu_entry < 22 then
				mcdu_entry = mcdu_entry .. key
			end
		end
	end)
end

for i,page in ipairs(MCDU_ENTRY_PAGES) do
	-- create the command
	mcdu_inp_page[page] = createCommand("a321neo/cockpit/mcdu/" .. page, "MCDU Character " .. page .. " page")
	-- register the command
	sasl.registerCommandHandler(mcdu_inp_page[page], 0, function (phase)
		if phase == SASL_COMMAND_BEGIN then
            mcdu_clear_all()
            set(mcdu_page, i * 100)
            mcdu_sim_page[get(mcdu_page)]("render")
		end
	end)
end

--sim command handlers

--a321neo command handlers
--debuggin
sasl.registerCommandHandler(mcdu_debug_message, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        send_mcdu_message("MCDU DEBUG MESSAGE", 1)
    end
end)
--mcdu menu keys


sasl.registerCommandHandler(mcdu_positive_negative_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
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
end)

sasl.registerCommandHandler(mcdu_clr_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if mcdu_message_active > 0 then
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
end)

sasl.registerCommandHandler(mcdu_page_up, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        mcdu_fpln_page = mcdu_fpln_page + 1
    end
end)

sasl.registerCommandHandler(mcdu_page_dn, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        mcdu_fpln_page = mcdu_fpln_page - 1
    end
end)

--[[
--
--
--      MCDU DATA INITIALIZATION
--
--
--]]

-- init all rows to format as color "white"
local mcdu_dat = {}
for i,size in ipairs(MCDU_DIV_SIZE) do
	mcdu_dat[size] = {}
	for j,align in ipairs(MCDU_DIV_ALIGN) do
		mcdu_dat[size][align] = {}
	end
end

local mcdu_dat_title_L = {txt = "TITLE", col = "white"}
local mcdu_dat_title_C = {txt = "TITLE", col = "white"}
local mcdu_dat_title_R = {txt = "TITLE", col = "white"}

--sasl variables
--MCDU left section
--entry line
local mcdu_entry = ""
local mcdu_messages = {}

--mcdu status
local mcdu_message_active = 0
local mcdu_init_status = 0

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
end

--drawing the MCDU display
function draw()
    if get(mcdu_enabled) == 1 then
        sasl.gl.drawRectangle(0, 0, 320 , 285, MCDU_DISP_COLOR["black"])
        local draw_size = {MCDU_DRAW_SIZE.w, MCDU_DRAW_SIZE.h} -- for debugging
        --draw title line
        sasl.gl.drawText(B612MONO_regular, draw_size[1]/2-140, draw_size[2]/2+108, mcdu_dat_title_L.txt,        20, false, false,TEXT_ALIGN_LEFT, MCDU_DISP_COLOR[mcdu_dat_title_L.col])
        sasl.gl.drawText(B612MONO_regular, draw_size[1]/2,     draw_size[2]/2+108, mcdu_dat_title_C.txt,        20, false, false,TEXT_ALIGN_CENTER, MCDU_DISP_COLOR[mcdu_dat_title_C.col])
        sasl.gl.drawText(B612MONO_regular, draw_size[1]/2+140, draw_size[2]/2+108, mcdu_dat_title_R.txt,        20, false, false,TEXT_ALIGN_RIGHT, MCDU_DISP_COLOR[mcdu_dat_title_R.col])
        --draw all horizontal lines
        for i,line in ipairs(draw_lines) do
            sasl.gl.setFontGlyphSpacingFactor(B612MONO_regular, line.disp_spacing)
            sasl.gl.drawText(B612MONO_regular, line.disp_x, line.disp_y, line.disp_text, line.disp_text_size, false, false, line.disp_text_align, line.disp_color)
        end

        --drawing entry line
        if mcdu_message_active == 0 then
            sasl.gl.drawText(B612MONO_regular, draw_size[1]/2-140, draw_size[2]/2-132, mcdu_entry, 20, false, false, TEXT_ALIGN_LEFT, MCDU_DISP_COLOR["white"])
        end

        if mcdu_message_active == 1 then
            if #mcdu_messages > 0 then
                sasl.gl.drawText(B612MONO_regular, draw_size[1]/2-140, draw_size[2]/2-132, mcdu_messages[#mcdu_messages], 20, false, false, TEXT_ALIGN_LEFT, MCDU_DISP_COLOR["white"])
            end
        end
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
--      505 - A/C Status
--
--
--]]

local mcdu_sim_page = {}

--define custom functionalities
local function send_mcdu_message(message, status)
    table.insert(mcdu_messages, message)
    mcdu_message_active = status
end

local function mcdu_ctrl_get_page()
    sasl.commandOnce(sasl.findCommand("sim/FMS/index"))
    sasl.commandOnce(sasl.findCommand("sim/FMS/ls_1l"))
    return get(globalPropertys("sim/cockpit2/radios/indicators/fms_cdu1_text_line4"))
end

local function mcdu_clearall()
    mcdu_dat_title_L = {txt = "", col = "white", size = nil}
    mcdu_dat_title_C = {txt = "", col = "white", size = nil}
    mcdu_dat_title_R = {txt = "", col = "white", size = nil}
    for i,size in ipairs(MCDU_DIV_SIZE) do
        for j,align in ipairs(MCDU_DIV_ALIGN) do
            for k,row in ipairs(MCDU_DIV_ROW) do
                --mcdu_dat[size][align][row] = {txt = size .. "" .. align .. " " .. row, col = "white"}
                mcdu_dat[size][align][row] = {txt = nil, col = "white", size = nil}
            end
        end
    end
end

--registering command handlers last as putting in variables coming after the handler will crash the plugin

function update()
    if get(mcdu_page) == 0 then
        mcdu_clearall()
        set(mcdu_page, 505)
        mcdu_sim_page[get(mcdu_page)]("render")
    end
end

-- 505 A/C Status
mcdu_sim_page[505] =
function (phase)
    if phase == "render" then
        mcdu_dat_title_C.txt = "A321 NEO"

        mcdu_dat["s"]["L"][1].txt = " eng"

        if get(Engine_option) == 0 then
            mcdu_dat["l"]["L"][1] = {txt = "cfm-leap-1a", col = "green"}
        else
            mcdu_dat["l"]["L"][1] = {txt = "pw-1130g-jm", col = "green"}
        end
        
        mcdu_dat["s"]["L"][2].txt = " active data base"
        mcdu_dat["l"]["L"][2] = {txt = mcdu_ctrl_get_page(), col = "blue"}
        mcdu_dat["s"]["L"][3].txt = " second data base"
        mcdu_dat["l"]["L"][3] = {txt = " none", col = "blue", size = "s"}

        --[[
        mcdu_dat["l"]["L"][4][1] = {txt = "a", col = "white"}
        mcdu_dat["l"]["L"][4][2] = {txt = " a", col = "blue", size = "s"}
        mcdu_dat["l"]["L"][4][3] = {txt = "  a", col = "green"}
        mcdu_dat["l"]["L"][4][4] = {txt = "   a", col = "orange", size = "s"}
        --]]

        mcdu_dat["s"]["L"][5].txt = "chg code"
        mcdu_dat["l"]["L"][5] = {txt = "[ ]", col = "blue"}
        mcdu_dat["s"]["L"][6].txt = "idle/perf"
        mcdu_dat["l"]["L"][6] = {txt = "+0.0/+0.0", col = "green"}
       
        draw_update()
    end
end

