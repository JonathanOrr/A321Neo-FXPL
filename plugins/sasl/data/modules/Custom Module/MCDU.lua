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
local MCDU_DISP_ALIGN =
{
    ["L"] = TEXT_ALIGN_LEFT,
    ["C"] = TEXT_ALIGN_CENTER,
    ["R"] = TEXT_ALIGN_RIGHT,
}

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")


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
local MCDU_ENTRY_KEYS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "."}

local mcdu_inp_key = {}
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

--[[
--
--
--      FMC DATA INITIALIZATION
--
--
--]]

-- init all rows to format as color "white"
local mcdu_dat = {}
local mcdu_dat_title = {txt = "TITLE", col = "white"}
for i,size in ipairs(MCDU_DIV_SIZE) do
	mcdu_dat[size] = {}
	for j,align in ipairs(MCDU_DIV_ALIGN) do
		mcdu_dat[size][align] = {}
		for k,row in ipairs(MCDU_DIV_ROW) do
			-- print(size .. ", " .. align .. ", " .. row)
			-- init in here
			--mcdu_dat[size][align][row] = {txt = size .. "" .. align .. " " .. row, col = "white"}
			mcdu_dat[size][align][row] = {txt = "dot", col = "white"}
		end
	end
end

--sasl variables
--mcdu lines(max munber of character is 22)
local mcdu_title_L = "TITLE"
local mcdu_title_M = "TITLE"
local mcdu_title_R = "TITLE"
--MCDU left section
--entry line
local mcdu_entry = ""
local mcdu_messages = {}

--mcdu status
local mcdu_message_active = 0
local mcdu_init_status = 0

--define custom functionalities
local function send_mcdu_message(message, status)
    table.insert(mcdu_messages, message)
    mcdu_message_active = status
end

--registering command handlers last as putting in variables coming after the handler will crash the plugin
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


function update()
    if get(mcdu_page) == 0 then
    end
end

--drawing the MCDU display
function draw()
    if get(mcdu_enabled) == 1 then
        sasl.gl.drawRectangle(0, 0, 320 , 285, MCDU_DISP_COLOR["black"])
        disp_size = {MCDU_DRAW_SIZE.w, MCDU_DRAW_SIZE.h} -- for debugging
        --[[
        --draw title line
        sasl.gl.drawText(B612MONO_regular, disp_size[1]/2-140, disp_size[2]/2+108,                      mcdu_title_L ,        20, false, false,TEXT_ALIGN_LEFT,     mcdu_title_L_cl)
        sasl.gl.drawText(B612MONO_regular, disp_size[1]/2,     disp_size[2]/2+108,                      mcdu_title_M ,        20, false, false,TEXT_ALIGN_CENTER,   mcdu_title_M_cl)
        sasl.gl.drawText(B612MONO_regular, disp_size[1]/2+140, disp_size[2]/2+108,                      mcdu_title_R ,        20, false, false,TEXT_ALIGN_RIGHT,    mcdu_title_R_cl)
        --]]
        --draw all horizontal lines
        for i,draw_row in ipairs(MCDU_DIV_ROW) do
            for j,draw_size in ipairs(MCDU_DIV_SIZE) do
                draw_act_row = ((i - 1) * 2) + (j - 1) -- draw actual row

                for k,draw_align in ipairs(MCDU_DIV_ALIGN) do

                    -- spacings
                    disp_x = MCDU_DRAW_OFFSET.x
                    disp_x = disp_x + (MCDU_DRAW_SPACING.x * (k - 1)) -- so -140, 0, 140

                    disp_y = MCDU_DRAW_OFFSET.y
                    disp_y = disp_y + (MCDU_DRAW_SPACING.y * draw_act_row) -- so 108, 90, 72

                    -- text size 
                    disp_text_size = MCDU_DISP_TEXT_SIZE[draw_size]
                    -- text alignment
                    disp_align = MCDU_DISP_ALIGN[draw_align]

                    -- text data
                    --print(draw_size .. " " .. draw_align .. " " .. draw_row)
                    dat = mcdu_dat[draw_size][draw_align][draw_row]
                    disp_text = dat.txt
                    disp_color = MCDU_DISP_COLOR[dat.col]

                    -- now draw it!
                    sasl.gl.drawText(B612MONO_regular, disp_x, disp_y, disp_text, disp_text_size, false, false, disp_align, disp_color)
                end
            end
        end

        --drawing entry line
        if mcdu_message_active == 0 then
            sasl.gl.drawText(B612MONO_regular, disp_size[1]/2-140, disp_size[2]/2-132, mcdu_entry, 20, false, false, TEXT_ALIGN_LEFT, MCDU_DISP_COLOR["white"])
        end

        if mcdu_message_active == 1 then
            if #mcdu_messages > 0 then
                sasl.gl.drawText(B612MONO_regular, disp_size[1]/2-140, disp_size[2]/2-132, mcdu_messages[#mcdu_messages], 20, false, false, TEXT_ALIGN_LEFT, MCDU_DISP_COLOR["white"])
            end
        end
    end
end
