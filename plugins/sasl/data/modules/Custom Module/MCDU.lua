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
-- File: MCDU.lua 
-- Short description: A32NX MCDU
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Table of contents for the A32NX MCDU
--
--
-- CONSTS DECLARATION
-- FMGS & MCDU DATA INITIALIZATION
-- DATA & COMMAND REGISTRATION
-- MCDU - XP FUNC CONTROLS
-- MCDU PAGE SIMULATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- EMULATOR SHELL CODE (I of II)
--    Simulates SASL running on a lua intrepreter (or https://repl.it)
--    instead of booting up X-Plane everytime you want to run this.
--    
--    Notes
--    - This code is continued also at the bottom of this file.
--    - Uses Linux OS-based system calls
--    - Very smelly code, can fail at any time!

EMULATOR = false -- SET THIS TO ENABLE/DISABLE THE EMULATOR!!!

EMULATOR_PROMPT_BEFORE_RUN = false -- Wait after initialization?

if EMULATOR then
	EMULATOR_HEADER = "\27[101;93mSASL EMULATOR\27[0m: "
	os.execute("clear")
	
	-- MCDU popup
	function MCDU_set_popup(str1, str2)
	end

	-- SASL Class
	EmulatorSasl = {gl = nil}
	commands = {}
	SASL_COMMAND_BEGIN = "begin"

	function EmulatorSasl:new (o)
		o = o or {}   -- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		return o
	end

	function EmulatorSasl:test()
		print(EMULATOR_HEADER .. "Test OK")
	end

	function EmulatorSasl.createCommand(str, str2)
		print(EMULATOR_HEADER .. "Create command " .. str)
	end

	function EmulatorSasl.registerCommandHandler(str, int, ref)
		if not str then
			print(EMULATOR_HEADER .. "passed NIL for sasl.registerCommandHandler")
			return
		end
		print(EMULATOR_HEADER .. "Register command " .. str)
		for i = 1, #commands, 1 do
			if commands[i].name == str then
				commands[i].ref = ref
				print("found.")
			end
		end	
	end

	function EmulatorSasl.commandOnce(str)
		print(EMULATOR_HEADER .. "Command " .. str)
	end

	function EmulatorSasl:findNavAid(name, a, b, c, d, find_type)
		return 1
	end

	function EmulatorSasl:getNavAidInfo(id)
		return NAV_AIRPORT, 121, 141, 300, 110.500, 70, "id", "name", true
	end

	-- SASL OpenGL Class
	EmulatorGL = {}

	function EmulatorGL:new (o)
		o = o or {}   -- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		return o
	end

	function EmulatorGL.loadFont(str)
		print(EMULATOR_HEADER .. "Load font " .. str)
	end

	function EmulatorGL.drawText(font, x, y, str, size, bool1, bool2, align, color)
	end

	-- SASL Global Functions
	function include(str)
		print(EMULATOR_HEADER .. "Include file " .. str)
	end

	function createGlobalPropertyi(str)
		print(EMULATOR_HEADER .. "Create global property (int) " .. str)
	end

	function createGlobalPropertys(str)
		print(EMULATOR_HEADER .. "Create global property (string) " .. str)
	end

	function createCommand(str)
		if not str then
			print(EMULATOR_HEADER .. "passed NIL for createCommand")
			return
		end
		print(EMULATOR_HEADER .. "Create global command " .. str)
		table.insert(commands, {name = str})
		return str
	end

	function globalPropertys(str)
		return str
	end

	function findCommand(str)
		print(EMULATOR_HEADER .. "Find command " .. str)
		return str
	end

	-- profiler
	function perf_measure_start(str)
	end
	function perf_measure_stop(str)
	end

	-- brightness
	function Draw_LCD_backlight(a,b,c,d,e,f)
	end

	-- get set
	variables = {}
	function get(str)
		return variables[str] 
	end

	function set(str, val)
		variables[str] = val
	end

	-- elecs
	EmulatorELEC = {}

	function EmulatorELEC:new (o)
		o = o or {}   -- create object if user does not provide one
		setmetatable(o, self)
		self.__index = self
		return o
	end

	function EmulatorELEC.add_power_consumption(a,b,c)
	end

	ELEC_sys = EmulatorELEC
	sasl = EmulatorSasl:new()
	sasl.gl = EmulatorGL:new()
	sasl.test()

	ECAM_WHITE = {1.0, 1.0, 1.0}
	ECAM_LINE_GREY = {62/255, 74/255, 91/255}
	ECAM_HIGH_GREY = {0.6, 0.6, 0.6}
	ECAM_YELLOW = {1.0, 1.0, 0}
	ECAM_BLUE = {0.004, 1.0, 1.0}
	ECAM_GREEN = {0.20, 0.98, 0.20}
	ECAM_HIGH_GREEN = {0.1, 0.6, 0.1}
	ECAM_ORANGE = {1, 0.66, 0.16}
	ECAM_RED = {1.0, 0.0, 0.0}
	ECAM_MAGENTA = {1.0, 0.0, 1.0}
	ECAM_GREY = {0.3, 0.3, 0.3}
	ECAM_BLACK = {0, 0, 0}

	NAV_UNKNOWN = -1
	NAV_AIRPORT = 0
	NAV_NDB = 1
	NAV_VOR = 2
	NAV_ILS = 3
	NAV_LOCALIZER = 4
	NAV_GLIDESLOPE = 5
	NAV_OUTERMARKER = 6
	NAV_MIDDLEMARKER = 7
	NAV_INNERMARKER = 8
	NAV_FIX = 9
	NAV_DME = 10

end
-- END OF EMULATOR SHELL CODE I OF II (CONTINUED AT END OF SCRIPT)
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------



-- START OF MCDU CODE
-- START OF MCDU CODE
-- START OF MCDU CODE

--[[
--
--
--      CONSTS DECLARATION
--
--
--]]

position = {1020, 1666, 560, 530}
size = {560, 530}

include('constants.lua')

local NIL = 0 -- used for input return and checking

--define the const size, align and row.
local MCDU_DIV_SIZE = {"s", "l"}
local MCDU_DIV_ALIGN = {"L", "R"}
local MCDU_DIV_ROW = {1,2,3,4,5,6}

--line spacing
local MCDU_DRAW_OFFSET = {x = 15, y = 420} -- starting offset for line drawing
local MCDU_DRAW_SPACING = {x = 530, y = -37} -- change in offset per line drawn

--reference table for drawing
local MCDU_DISP_COLOR = 
{
    ["white"] =   ECAM_WHITE,
    ["cyan"] =    ECAM_BLUE,
    ["green"] =   ECAM_GREEN,
    ["amber"] =   ECAM_ORANGE,
    ["yellow"] =  ECAM_YELLOW,
    ["magenta"] = ECAM_MAGENTA,
    ["red"] =     ECAM_RED,

    ["black"] =   ECAM_BLACK,
}

--font size
local MCDU_DISP_TEXT_SIZE =
{
    ["s"] = 25,
    ["l"] = 37
}

--alignment
local MCDU_DISP_TEXT_ALIGN =
{
    ["L"] = TEXT_ALIGN_LEFT,
    ["R"] = TEXT_ALIGN_RIGHT,
}

-- alphanumeric & decimal FMC entry keys
local MCDU_ENTRY_KEYS = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", ".", "overfly", "slash", "space"}
local MCDU_ENTRY_PAGES = {"dir", "prog", "perf", "init", "data", "f-pln", "rad_nav", "fuel_pred", "sec_f-pln", "atc_comm", "mcdu_menu", "air_port"}
local MCDU_ENTRY_SIDES = {"L1", "L2", "L3", "L4", "L5", "L6", "R1", "R2", "R3", "R4", "R5", "R6", "slew_up", "slew_down", "slew_left", "slew_right"}

--[[
--
--
--      FMGS & MCDU DATA INITIALIZATION
--
--
--]]

local fmgs_dat = {}
local fmgs_metadat = {}
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
local mcdu_entry_cache = "" --caches entry for when messages are shown
local mcdu_messages = {}
local mcdu_message_showing = false

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
    me = mcdu_entry
    mcdu_entry = ""
    
    if expected_formats == nil then
        return me
    end

    if expected_formats[1] ~= nil then
        local pass = false
        variation = 0
        for i,format in ipairs(expected_formats) do-- expected_formats is a table
            if mcdu_eval_entry(me, format) then
                variation = i
                pass = true
            end
        end
        if pass then
            return me, variation 
        else
            mcdu_send_message("format error")
            return NIL, NIL
        end
    else
        if mcdu_eval_entry(me, expected_formats) then
            return me
        else
            mcdu_send_message("format error")
            return NIL
        end
    end
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

--pad a number up to a given dp
--e.g. (2.4, 3) -> 2.400
local function mcdu_pad_dp(number, required_dp)
    return(string.format("%." .. required_dp .. "f", number))
end

--pad a number up to a given length
--e.g. (50, 3) -> 050
local function mcdu_pad_num(number, required_length)
    str = tostring(number)
    while #str < required_length do
        str = "0" .. str
    end
    return str
end



--toggle obj between two strings, a and b
--e.g. ("ad", "ba", "ad") -> "ba"
local function mcdu_toggle(obj, str_a, str_b)
    if obj == str_a then
        return str_b
    elseif obj == str_b then
        return str_a
    end
end

--init FMGS data to 2nd argument
local function fmgs_dat_init(dat_name, dat_init)
    --is data uninitialised?
    if fmgs_dat[dat_name] == nil then
        fmgs_dat[dat_name] = dat_init
    end
end

--get FMGS data with initialisation
local function fmgs_dat_get(dat_name, dat_init, dat_init_col, dat_set_col, dat_format_callback)
    --[[
    -- dat_name     name of data from fmgs_dat
    -- dat_init     value the data starts with initially
    -- dat_init_col colour when data hasn't been set
    -- dat_set_col  colour when data has been set
    -- dat_format_callback (optional) format callback when data has been set
    --]]

    if fmgs_dat[dat_name] == nil then
        return {txt = dat_init, col = dat_init_col}
    else
        val = fmgs_dat[dat_name]
        if dat_format_callback == nil then
            dat_format_callback = function (val) return val end
        end

        if type(dat_init) == "string" then
            val = tostring(dat_format_callback(tostring(val)))
        else
            val = dat_format_callback(val)
        end

        return {txt = val, col = dat_set_col}
    end
end

--get FMGS data with initialisation sans colouring. GET PURE TEXT
local function fmgs_dat_get_txt(dat_name, dat_init, dat_format_callback)
    --[[
    -- dat_name     name of data from fmgs_dat
    -- dat_init     value the data starts with initially
    -- dat_format_callback (optional) format callback when data has been set
    --]]

    if fmgs_dat[dat_name] == nil then
        return dat_init
    else
        val = fmgs_dat[dat_name]
        if dat_format_callback == nil then
            dat_format_callback = function (val) return val end
        end

        if type(dat_init) == "string" then
            val = tostring(dat_format_callback(tostring(val)))
        else
            val = dat_format_callback(val)
        end

        return val
    end
end



--[[
--
--
--      DATA & COMMAND REGISTERATION
--
--
--]]
--a321neo commands
local mcdu_debug_get = sasl.createCommand("a321neo/debug/mcdu/get_data", "retrieve FMGS data from pointer a321neo/cockpit/mdu/mcdu_debug_pointer to a321neo/cockpit/mcdu/mcdu_debug_dat")
local mcdu_debug_set = sasl.createCommand("a321neo/debug/mcdu/set_data", "inject FMGS data from pointer a321neo/cockpit/mdu/mcdu_debug_pointer to a321neo/cockpit/mcdu/mcdu_debug_dat")
local mcdu_debug_pointer = createGlobalPropertys("a321neo/debug/mcdu/mcdu_pointer")
local mcdu_debug_dat = createGlobalPropertys("a321neo/debug/mcdu/mcdu_dat")

local mcdu_debug_busy = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_bug_busy")

local mcdu_irs_aligned = createGlobalPropertyi("a321neo/cockpit/mcdu/mcdu_irs_aligned", 1)

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

            if val == "overfly" then
                val = "Δ"
            elseif val == "slash" then
                val = "/"
            elseif val == "space" then
                val = " "
            end

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
            if mcdu_message_showing then
                mcdu_entry = mcdu_entry_cache
                mcdu_message_showing = false
            else
                if #mcdu_entry > 0 then
                    mcdu_entry = mcdu_entry:sub(1,#mcdu_entry - 1) 
                else
                    if #mcdu_entry == 0 then
                        mcdu_entry = "CLR"
                        mcdu_message_showing = true
                    end
                end
            end
        end
    },
    {
        ref_name = "misc",
        ref_desc = "positive_negative",
        ref_entries = {"positive_negative"},
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
                if get(Mcdu_enabled) == 1 then
                    entry_category.ref_callback(count, entry)
                end
            end
        end)
    end
end

--a321neo command handlers
--debugging
local hokey_pokey = false --wonder what this does
sasl.registerCommandHandler(mcdu_debug_get, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        print("MCDU DEBUG get " .. fmgs_dat[get(mcdu_debug_pointer)])
        set(mcdu_debug_dat, fmgs_dat[get(mcdu_debug_pointer)])
        mcdu_open_page(get(mcdu_page))
    end
end)
sasl.registerCommandHandler(mcdu_debug_set, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        print("MCDU DEBUG set " .. fmgs_dat[get(mcdu_debug_pointer)])
        fmgs_dat[get(mcdu_debug_pointer)] = get(mcdu_debug_dat)
        mcdu_open_page(get(mcdu_page))
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
    disp_text = tostring(dat.txt):upper()
    dat.col = dat.col or "white" --default colour
    disp_color = MCDU_DISP_COLOR[dat.col]

    -- is there a custom size
    if dat.size == nil then
        disp_size = draw_size
    else
        disp_size = dat.size
    end

    -- text size 
    disp_text_size = MCDU_DISP_TEXT_SIZE[disp_size]

    -- replace { with the box
    text = ""
    for j = 1,#disp_text do
        if disp_text:sub(j,j) == "{" then
            if EMULATOR then
                text = text .. "b"
            else
                text = text .. "□"
            end
        else
            text = text .. disp_text:sub(j,j)
        end
    end
    disp_text = text

    -- now draw it!
    table.insert(draw_lines, {font = disp_size, disp_x = disp_x, disp_y = disp_y, disp_text = disp_text, disp_text_size = disp_text_size, disp_text_align = disp_text_align, disp_color = disp_color})
end

local function draw_get_x(align)
    return MCDU_DRAW_OFFSET.x + (MCDU_DRAW_SPACING.x * (align - 1))
end

local function draw_get_y(line)
    return MCDU_DRAW_OFFSET.y + (MCDU_DRAW_SPACING.y * (line - 1))
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
                disp_x = draw_get_x(k)
                disp_y = draw_get_y(draw_act_row)

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
        draw_dat(mcdu_dat_title, "l", draw_get_x(1), draw_get_y(-1), MCDU_DISP_TEXT_ALIGN["L"])
    else
        for l,dat in pairs(mcdu_dat_title) do
            draw_dat(dat, "l", draw_get_x(1), draw_get_y(-1), MCDU_DISP_TEXT_ALIGN["L"])
        end
    end
end

local function colorize()
    for i,f in ipairs({"white", "cyan", "amber", "green", "yellow", "magenta", "red"}) do
        c = {}
        c[0] = MCDU_DISP_COLOR[f][1];c[1] = MCDU_DISP_COLOR[f][2];c[2] = MCDU_DISP_COLOR[f][3]
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
	perf_measure_start("MCDU:draw()")
    --DEBUG TODO: commented out four lines because of debugging and the time it takes for it to load.
    --[[
    if get(AC_ess_bus_pwrd) == 0 then   -- TODO MCDU2 is on AC2
        return -- Bus is not powered on, this component cannot work
    end
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, 0.26, 0.26)   -- 30W (just hypothesis)
    --]]

    --sasl.gl.drawRectangle(0, 0, 560, 530, {1,0,0})
    if hokey_pokey then
        colorize()
    end
    if get(Mcdu_enabled) == 1 then
        MCDU_set_popup("draw lines", draw_lines)
        MCDU_set_popup("mcdu entry", mcdu_entry)
        MCDU_set_popup("enabled", true)

        --draw backlight--
        Draw_LCD_backlight(0, 0, size[1], size[2], 0.5, 1, get(MCDU_1_brightness_act))

        --draw all horizontal lines
        for i,line in ipairs(draw_lines) do
            if line.font == "l" then
                font = Font_AirbusDUL
            else
                font = Font_AirbusDUL_small
            end
            sasl.gl.drawText(font, line.disp_x, line.disp_y, line.disp_text, line.disp_text_size, false, false, line.disp_text_align, line.disp_color)
        end

        --draw scratchpad
        sasl.gl.drawText(Font_AirbusDUL, draw_get_x(1), draw_get_y(12), mcdu_entry, MCDU_DISP_TEXT_SIZE["l"], false, false, MCDU_DISP_TEXT_ALIGN["L"], MCDU_DISP_COLOR["white"])

    end
	perf_measure_stop("MCDU:draw()")
end

--[[
--
--
--      MCDU - XP FUNC CONTROLS
--
--
--]]

--sasl get nav aid information
local function mcdu_ctrl_get_nav(find_nameid, find_type)
    --find by name
    id = sasl.findNavAid(find_nameid:upper(), nil, nil, nil, nil, find_type)
    --if name is not found
    if id == -1 then
        --find by id
        id = sasl.findNavAid(nil, find_nameid:upper(), nil, nil, nil, find_type) 
    end
    local nav = {}
    nav.navtype, nav.lat, nav.lon, nav.height, nav.freq, nav.hdg, nav.id, nav.name, nav.loadedDSF = sasl.getNavAidInfo(id)
    print("nav")
    print("type " .. nav.navtype)
    print("lat " .. nav.lat)
    print("lon " .. nav.lon)
    print("height " .. nav.height)
    print("freq " .. nav.freq)
    print("hdg " .. nav.hdg)
    print("id " .. nav.id)
    print("name " .. nav.name)
    return nav
end

-- converts Decimal Degrees and Axis (lat/lon) to Degrees Minute Seconds Direction
local function mcdu_ctrl_dd_to_dmsd(dd, axis)
    if axis == "lat" then
        if dd > 0 then
            p = "N"
        else
            p = "S"
        end
    else
        if dd > 0 then
            p = "E"
        else
            p = "W"
        end
    end

    print(dd)
    dd = math.abs(dd)
    print(dd)
    d = dd
    print(d)
    m = d % 1 * 60
    print(m)
    s = m % 1 * 60
    print(s)
    return math.floor(d), m, s, p
end

-- converts Degrees Minute Seconds Direction to Decimal Degrees
local function mcdu_ctrl_dmsd_to_dd(d,m,s,dir)
    if dir == "E" or dir == "N" then
        p = 1
    else
        p = -1
    end
    dd = (d + m*(1/60) + s*(1/3600)) * p
    return dd
end

mcdu_entry = string.upper("ksea/kbfi")

--update
function update()
	perf_measure_start("MCDU:update()")
    if get(mcdu_page) == 0 then --on start
       mcdu_open_page(505) --open 505 A/C status
       --mcdu_open_page(1106) --open 1106 mcdu menu options debug
	   --mcdu_open_page(400)
    end

    -- display next message
    if #mcdu_messages > 0 and not mcdu_message_showing then
        mcdu_entry_cache = mcdu_entry
        mcdu_entry = mcdu_messages[#mcdu_messages]:upper()
        mcdu_message_showing = true
        table.remove(mcdu_messages)
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
--        601 - f-pln lat rev
--        602 - f-pln lat rev dept airport
--        603 - f-pln lat rev dest airport
--      700 - rad nav
--      800 - fuel pred
--      900 - sec f-pln
--      1000 - atc comm
--      1100 - mcdu menu
--      1200 - air port
--
--
--]]

-- FLIGHT PLAN

fmgs_dat["fpln"] = {}
fmgs_dat["fpln fmt"] = {}

local function fpln_addwpt(navtype, loc, via, name, trk, time, dist, spd, alt, efob, windspd, windhdg, next)
    wpt = {}
    wpt.name = name or ""
    wpt.navtype = navtype or ""
    wpt.time = time or "----"
    wpt.dist = dist or ""
    wpt.spd = spd or "---"
    wpt.alt = alt or "-----"
    wpt.via = via or ""
    wpt.trk = trk or ""
    wpt.next = next
    wpt.efob = efob or 5.5
    wpt.windspd = windspd or 0
    wpt.windhdg = windhdg or 0
    table.insert(fmgs_dat["fpln"], loc, wpt)
end

local function fpln_load()
    --init local variables
    fpln_fmt = {}
    fmgs_dat["fpln"] = {}

    --navtype loc via name trk time dist spd alt efob windspd windhdg next

    --add airports
    for i = 1, sasl.countFMSEntries() do
        navtype, name, id, alt, lat, lon = sasl.getFMSEntryInfo(sasl.countFMSEntries() - i)
        fpln_addwpt(navtype, 1, nil, name:lower(), nil, nil, nil, nil, alt, nil, nil, nil, "")
        print(i .. " " .. name:lower())
    end
end

--formats the fpln
local function fpln_format()
    fpln_fmt = {}
    fpln = fmgs_dat["fpln"]

    for i,wpt in ipairs(fpln) do
        --is waypoint a blank?
        if wpt.name ~= "" then
            --check for flight discontinuities
            if wpt.name == "discon" then
                table.insert(fpln_fmt, "---f-pln discontinuity--")
            else
                --insert waypoint
                table.insert(fpln_fmt, wpt)
                --set previous waypoint
                wpt_prev = wpt
            end
        end
    end
    table.insert(fpln_fmt, "----- end of f-pln -----")
    table.insert(fpln_fmt, "----- no altn fpln -----")

    --output
    fmgs_dat["fpln fmt"] = fpln_fmt
end

--DEMO
--fpln_addwpt(NAV_FIX, 1, "chins3", "humpp", nil, 2341, 14, 297, 15000, nil, nil, nil, "aubrn")

-- MCDU PAGES

-- 00 template
mcdu_sim_page[00] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          a321-521nx"

        --[[
        mcdu_dat["s"]["L"][1].txt = "□"
        mcdu_dat["l"]["L"][1][1] = {txt = " a", col = "green"}
        mcdu_dat["l"]["L"][1][1] = {txt = "  a", col = "cyan", size = "s"}
        --]]

        draw_update()
    end
end

-- 100 dir
mcdu_sim_page[100] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          dir"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 200 prog
mcdu_sim_page[200] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          prog"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 300 perf
mcdu_sim_page[300] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          perf"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 400 init
mcdu_sim_page[400] =
function (phase)
    if phase == "update" then
    end

    if phase == "render" then
        mcdu_dat_title.txt = "          init"

        fmgs_dat_init("fmgs init", false)   -- init has the fmgs been initialised? to false
        fmgs_dat_init("latlon sel", "nil") -- init latlon selection for irs alignment

        fmgs_dat_init("crz temp alt", true) --init has crz temp been changed?

        --[[ CO RTE --]]
        mcdu_dat["s"]["L"][1].txt = " co rte"
        --changes on fmgs airport init
        if fmgs_dat["fmgs init"] then
            mcdu_dat["l"]["L"][1] = fmgs_dat_get("co rte", "NONE", "cyan", "cyan")
        else
            mcdu_dat["l"]["L"][1] = fmgs_dat_get("co rte", "{{{{{{{{{{", "amber", "cyan")
        end

        --[[ FROM / TO --]]
        mcdu_dat["s"]["R"][1].txt = " from/to  "

        mcdu_dat["l"]["R"][1] = fmgs_dat_get("origin", "{{{{", "amber", "cyan")
        mcdu_dat["l"]["R"][1].txt = mcdu_dat["l"]["R"][1].txt .. "/" .. fmgs_dat_get_txt("dest", "{{{{")

        --[[ ALTN / CO RTE --]]
        mcdu_dat["s"]["L"][2].txt = "altn/co rte"
        mcdu_dat["l"]["L"][2] = fmgs_dat_get("co rte", "----/---------", "white", "cyan")

        --[[ FLT NBR --]]
        mcdu_dat["s"]["L"][3].txt = "flt nbr"
        mcdu_dat["l"]["L"][3] = fmgs_dat_get("flt nbr", "{{{{{{{{", "amber", "cyan")

        --[[ IRS INIT --]]
        mcdu_dat["l"]["R"][3].txt = "irs init>"

        --[[ COST INDEX --]]
        mcdu_dat["s"]["L"][5].txt = "cost index"
        --changes on fmgs airport init
        if fmgs_dat["fmgs init"] then
            mcdu_dat["l"]["L"][5] = fmgs_dat_get("cost index", "{{{", "amber", "cyan")
        else
            mcdu_dat["l"]["L"][5] = fmgs_dat_get("cost index", "---", "white", "cyan")
        end

        --[[ WIND --]]
        mcdu_dat["l"]["R"][5].txt = "wind>"

        --[[ CRZ FL/TEMP --]]
        mcdu_dat["s"]["L"][6].txt = "crz fl/temp"
        --changes on fmgs airport init
        if fmgs_dat["fmgs init"] then
            crz_fl_init_txt = "{{{{{"
            crz_fl_init_col = "amber"
        else
            crz_fl_init_txt = "-----"
            crz_fl_init_col = "white"
        end
        mcdu_dat["l"]["L"][6][1] = fmgs_dat_get("crz fl", crz_fl_init_txt, crz_fl_init_col, "cyan", 
            --formatting
            function (val) 
                if #val > 4 then
                    return "FL" .. val:sub(1,3)
                else
                    return val:sub(1,4)
                end
            end
        )
        mcdu_dat["l"]["L"][6][1].txt = mcdu_dat["l"]["L"][6][1].txt .. "/" --append slant

        --has crz temp been altered?
        if fmgs_dat["crz temp alt"] then
            crz_temp_size = "l"
        else
            crz_temp_size = "s"
        end
        --changes on fmgs airport init
        if fmgs_dat["fmgs init"] then
            mcdu_dat["l"]["L"][6][2] = {txt = "      " .. fmgs_dat_get_txt("crz temp", "{{{") .. "°", col = mcdu_dat["l"]["L"][6][1].col, size = crz_temp_size}
        else
            mcdu_dat["l"]["L"][6][2] = {txt = "      " .. fmgs_dat_get_txt("crz temp", "---") .. "°", col = mcdu_dat["l"]["L"][6][1].col, size = crz_temp_size}
        end

        --[[ TROPO --]]
        mcdu_dat["s"]["R"][6].txt = "tropo "
        fmgs_dat_init("tropo", 39060)
        --grows bigger if changed
        if fmgs_dat["tropo"] == 39060 then
            tropo_size = "s"
        else
            tropo_size = "l"
        end
        mcdu_dat["l"]["R"][6] = {txt = fmgs_dat["tropo"], col = "cyan", size = tropo_size}

        draw_update()
    end
	-- flt nbr
    if phase == "L3" then
        input = mcdu_get_entry()
        fmgs_dat["flt nbr"] = input
        mcdu_open_page(400) -- reload
    end
    -- cost index
    if phase == "L5" then
        --format e.g. 100
        input, variation = mcdu_get_entry({
            "!!!", -- 100 cost index
            "!!",  -- 10 cost index
            "!"    -- 1 cost index
        })
        if input ~= NIL then
            fmgs_dat["cost index"] = input
        end
        mcdu_open_page(400) -- reload
    end
    -- crz fl/temp
    if phase == "L6" then
        --format e.g. FL230
        input, variation = mcdu_get_entry({
            "!!",   -- 80 (8000 feet)
            "!!!",  -- 230 (23000 feet)
            "fl!!!",-- FL230 (23000 feet)
            "fl!!!/!",-- FL230/7 (23000 feet, -7 celcius)
            "fl!!!/!!",-- FL230/40 (23000 feet, -40 celcius)
            "fl!!!/-!",-- FL230/-7 (23000 feet, -40 celcius)
            "fl!!!/-!!",-- FL230/-40 (23000 feet, -40 celcius)
            "/!",   -- 7 (-7 celcius)
            "/!!",  -- 40 (-40 celcius)
            "/-!",  -- -7 (-7 celcius)
            "/-!!"  -- -40 (-40 celcius)
        })

        if input ~= NIL then
            --automatically calculate crz temp
            if variation >= 1 and variation <= 3 then
                if variation ~= 3 then
                    alt = input
                else
                    alt = input:sub(3,5)
                end
                fmgs_dat["crz temp"] = math.floor(tonumber(alt) * -0.2 + 16)
                fmgs_dat["crz temp alt"] = false --crz temp has not been altered

            else
                fmgs_dat["crz temp alt"] = true --crz temp has been manually altered
            end

            --set crz FL or crz temp
            if variation == 1 then
                fmgs_dat["crz fl"] = input * 100
            elseif variation == 2 then
                fmgs_dat["crz fl"] = input * 100
            elseif variation == 3 then
                fmgs_dat["crz fl"] = tonumber(input:sub(3,5)) * 100
            elseif variation == 4 then
                fmgs_dat["crz fl"] = input:sub(3,5) * 100
                fmgs_dat["crz temp"] = input:sub(7,7) * -1
            elseif variation == 5 then
                fmgs_dat["crz fl"] = input:sub(3,5) * 100
                fmgs_dat["crz temp"] = input:sub(7,8) * -1
            elseif variation == 6 then
                fmgs_dat["crz fl"] = input:sub(3,5) * 100
                fmgs_dat["crz temp"] = input:sub(7,8)
            elseif variation == 7 then
                fmgs_dat["crz fl"] = input:sub(3,5) * 100
                fmgs_dat["crz temp"] = input:sub(7,9)
            elseif variation == 8 then
                fmgs_dat["crz temp"] = input:sub(2,2) * -1
            elseif variation == 9 then
                fmgs_dat["crz temp"] = input:sub(2,3) * -1
            elseif variation == 10 then
                fmgs_dat["crz temp"] = input:sub(2,3)
            elseif variation == 11 then
                fmgs_dat["crz temp"] = input:sub(2,4)
            end
            mcdu_open_page(400) -- reload
        end
    end

    -- from/to
    if phase == "R1" then
        --format e.g. ksea/kbfi
        input = mcdu_get_entry("####/####")
        if input ~= NIL then

            print("b1")
			-- parse data
			airp_origin_name = input:sub(1,4):lower()
            airp_dest_name = input:sub(6,9):lower()

            print("b2")
            airp_origin = mcdu_ctrl_get_nav(airp_origin_name, NAV_AIRPORT)
            airp_dest = mcdu_ctrl_get_nav(airp_dest_name, NAV_AIRPORT)

            print("b3")
            -- do these airports exist?
			if airp_origin.navtype == NAV_UNKNOWN or
			   airp_dest.navtype == NAV_UNKNOWN then
				mcdu_send_message("NOT IN DATABASE")
				mcdu_open_page(400) -- reload
				return
			end			

            print("b4")
			-- init data
			fmgs_dat["fmgs init"] = true
			fmgs_dat["origin"] = airp_origin.id
			fmgs_dat["dest"] = airp_dest.id

            print("b5")
            deg, min, sec, dir = mcdu_ctrl_dd_to_dmsd(airp_origin.lat, "lat")
            fmgs_dat["lat fmt"] = tostring(deg) .. tostring(Round(min, 1)) .. tostring(dir)
            deg, min, sec, dir = mcdu_ctrl_dd_to_dmsd(airp_origin.lon, "lon")
            fmgs_dat["lon fmt"] = tostring(deg) .. tostring(Round(min, 1)) .. tostring(dir)

			mcdu_open_page(401) -- open 401 init routes

			--[[
            --set orgin for XP FMC
            --format e.g. ksea/kbfi
            airp_origin = input:sub(1,4):lower()
            airp_dest = input:sub(6,9):lower()

            --get origin from XP FMC
            mcdu_ctrl_set_fpln_origin(airp_origin, function(val) --callback
            fmgs_dat["origin"] = airp_origin

            --get dest from XP FMC
            mcdu_ctrl_set_fpln_dest(airp_dest, function(val) --callback
            fmgs_dat["dest"] = airp_dest

            --set co rte
            fmgs_dat["fmgs init"] = true
            mcdu_open_page(400) -- reload

            --get lat lon from XP FMC
            mcdu_ctrl_get_origin_latlon(input:sub(1,4), function(val) --callback
            --format e.g. N12°34.56 must be convert to 1234.5N
            fmgs_dat["lat fmt"] = val:sub(2,3) .. val:sub(6,9) .. val:sub(1,1)
            --format e.g. W123°45.67 must be convert to 12345.67W
            fmgs_dat["lon fmt"] = val:sub(13,15) .. val:sub(18,22) .. val:sub(12,12)
            print("lat lon upload")

            mcdu_open_page(400) -- reload

            --add listener for when ADIRS are turned on
            mcdu_ctrl_add_listener(
                function () --data listener function
                    if get(Adirs_capt_has_ADR) == 1 then
                        return "EXIT" -- exit loop, execute callback
                    end 
                end,
                function () --callback
                    --IRS are in NAV or ATT but irs are not aligned
                    if get(mcdu_irs_aligned) == 0 and get(Adirs_capt_has_ADR) == 1 then
                        fmgs_dat["irs aligned"] = "show"
                        fmgs_dat["latlon sel"] = "lat"
                    end

                    --set lat
                    --format e.g. 1234.5N
                    fmgs_dat["lat"] = tonumber(fmgs_dat["lat fmt"]:sub(1,6))
                    fmgs_dat["lat_dir"] = fmgs_dat["lat fmt"]:sub(7,7)

                    --set lon
                    --format e.g. 12345.67W
                    fmgs_dat["lon"] = tonumber(fmgs_dat["lon fmt"]:sub(1,8))
                    fmgs_dat["lon_dir"] = fmgs_dat["lon fmt"]:sub(9,9)

                    --if on init page, reload it
                    if get(mcdu_page) == 400 then
                        mcdu_open_page(400) -- reload
                    end
                end
            )

            --get SID
            fmgs_dat["runways"] = {}
            terminate = false
            mcdu_ctrl_get_runways_origin(function (val) --accessor callback
            --val is runway name
            runway_name = val:sub(22,24)
            --is there any more runways?
            if not terminate then
                --is this not a blank line?
                if runway_name ~= "   " then

                    --get runway length
                    airport = fmgs_dat["origin"]:upper()

                    index = 0
                    mcdu_ctrl_get_runway_length(
                        airport .. runway_name, --input arg
                        runway_name, --refcon arg
                        function (val, refcon) --callback arg
                            --val is runway length
                            --format e.g. from  9420FT to 9420
                            runway_length = ""
                            --start after space, so at i = 2 not i = 1
                            for i = 2, string.len(val) do
                                --has it reached f in FT?
                                if val:sub(i,i) == "F" then
                                    break
                                end
                                runway_length = val:sub(2,i)
                            end
                            --refcon is runway_name
                            runway_name = refcon

                            --record name and length
                            table.insert(fmgs_dat["runways"], {index = index, name = runway_name, length = runway_length})

                            index = index + 1
                        end
                    ) --end callback
                else
                    --all runways recorded. stop
                    fmgs_dat["terminate"] = true
                end
            end

            end) --end callback
            end) --end callback
            end) --end callback
            end) --end callback

            mcdu_open_page(400) -- reload
			--]]
        end
    end

    -- irs init>
    if phase == "R3" then
        mcdu_open_page(402) -- open 402 init irs init
    end

    -- tropo
    if phase == "R6" then
        input = mcdu_get_entry("!!!")
		if input ~= NIL then
      	  fmgs_dat["tropo"] = input * 100
		end
        mcdu_open_page(400) -- reload
    end

    -- slew left/right (used for lat lon)
    if phase == "slew_left" or phase == "slew_right" then
        --toggle between lat and lon select
        fmgs_dat["latlon sel"] = mcdu_toggle(fmgs_dat["latlon sel"], "lat", "lon")
        mcdu_open_page(400) -- reload
    end

    -- slew up (used for lat lon)
    if phase == "slew_up" or phase == "slew_down" then
        if phase == "slew_up" then
            increment = 1
        else
            increment = -1
        end
        if fmgs_dat["latlon sel"] == "lat" then
            --change lat from 0-9000.0
            fmgs_dat["lat"] = Math_clamp(fmgs_dat["lat"] + increment * 0.1, 0, 9000)
            --flip
            if fmgs_dat["lat"] == 0 or fmgs_dat["lat"] == 9000 then
                fmgs_dat["lat"] = fmgs_dat["lat"] - increment * 0.1
                fmgs_dat["lat_dir"] = mcdu_toggle(fmgs_dat["lat_dir"], "N", "S") --flip
            end
            --padding decimal
            fmgs_dat["lat"] = mcdu_pad_dp(fmgs_dat["lat"], 1)
            --assign
            fmgs_dat["lat fmt"] = fmgs_dat["lat"] .. fmgs_dat["lat_dir"]
        elseif fmgs_dat["latlon sel"] == "lon" then
            --change lon from 0-180000.00
            fmgs_dat["lon"] = Math_clamp(fmgs_dat["lon"] + increment * 0.01, 0, 18000)
            --flip
            if fmgs_dat["lon"] == 0 or fmgs_dat["lon"] == 18000 then
                fmgs_dat["lon"] = fmgs_dat["lon"] - increment * 0.01
                fmgs_dat["lon_dir"] = mcdu_toggle(fmgs_dat["lon_dir"], "W", "E") --flip
            end
            --padding decimal
            fmgs_dat["lon"] = mcdu_pad_dp(fmgs_dat["lon"], 2)
            --assign
            fmgs_dat["lon fmt"] = fmgs_dat["lon"] .. fmgs_dat["lon_dir"]
        end
        mcdu_open_page(400) -- reload
    end
end

-- 401 init routes
mcdu_sim_page[401] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "       " ..  fmgs_dat["origin"] .. "/" .. fmgs_dat["dest"]

		mcdu_dat["l"]["L"][1] = {txt = " none", col = "green"}
		mcdu_dat["l"]["L"][6].txt = "<return"

        draw_update()
    end
	if phase == "L6" then
        mcdu_open_page(400) -- open 400 init
    end
end

-- 402 init irs init
mcdu_sim_page[402] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        irs init"

        --[[ LAT / LONG --]]

        if fmgs_dat["fmgs init"] then
            mcdu_dat["s"]["L"][1].txt = "lat"
            mcdu_dat["s"]["R"][1].txt = "long"

            --irs latlon change selection
            if fmgs_dat["latlon sel"] == "lat" then
                mcdu_dat["s"]["L"][1].txt = "lat^"
            elseif fmgs_dat["latlon sel"] == "lon" then
                mcdu_dat["s"]["R"][1].txt = "^long"
            end

        end

		mcdu_dat["s"]["L"][3].txt = "   irs1 off"
        mcdu_dat["l"]["L"][3].txt = "    --'--.--/---'--.--"
		mcdu_dat["s"]["L"][4].txt = "   irs2 off"
        mcdu_dat["l"]["L"][4].txt = "    --'--.--/---'--.--"
		mcdu_dat["s"]["L"][5].txt = "   irs3 off"
        mcdu_dat["l"]["L"][5].txt = "    --'--.--/---'--.--"
		mcdu_dat["l"]["L"][6].txt = "<return"

        draw_update()
    end
    if phase == "L6" then
        mcdu_open_page(400) -- open 400 init
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
            mcdu_dat_title.txt = "        a321-271nx"
            mcdu_dat["l"]["L"][1] = {txt = "cfm-leap-1a", col = "green"}
        else
            --mcdu_dat_title.txt = "        a321-251nx"
            --mcdu_dat["l"]["L"][1] = {txt = "pw-1130g-jm", col = "green"}
        end
        
        mcdu_dat["s"]["L"][2].txt = " active data base"
		mcdu_dat["l"]["L"][2] = {txt = " 28 nov-25dec", col = "cyan"}
		mcdu_dat["l"]["R"][2] = {txt = "ab49012001", col = "green"}
        mcdu_dat["s"]["L"][3].txt = " second data base"
        mcdu_dat["l"]["L"][3] = {txt = " none", col = "cyan", size = "s"}

        mcdu_dat["s"]["L"][5].txt = "chg code"
        fmgs_dat_init("chg code", "[ ]")
        mcdu_dat["l"]["L"][5] = {txt = fmgs_dat["chg code"], col = "cyan"}

        mcdu_dat["s"]["L"][6].txt = "idle/perf"
        fmgs_dat_init("chg code lock", true)
        if fmgs_dat["chg code lock"] then
            mcdu_dat["l"]["L"][6] = {txt = "+0.0/+0.0", col = "green"}
        else
            mcdu_dat["l"]["L"][6] = {txt = fmgs_dat_get_txt("idle/perf", "+0.0/+0.0"), col = "cyan"}
        end

		mcdu_dat["s"]["R"][6].txt = "software"
        mcdu_dat["l"]["R"][6].txt = "options>"

       
        draw_update()
    end

    -- chg code
    if phase == "L5" then
        input = mcdu_get_entry({"###"})
        if input ~= NIL then
            if input == "ARM" then
                fmgs_dat["chg code"] = input
                fmgs_dat["chg code lock"] = false
                mcdu_open_page(505) -- reload
            else
                mcdu_send_message("invalid change code")
            end
        end
    end

    -- idle/perf
    if phase == "L6" then
        if fmgs_dat["chg code lock"] then
            mcdu_send_message("enter change code")
            return
        end
        -- format possible inputs
        possible_inputs = {}
        possible_inputs_a = {
            "!",
            "!.!"
        }
        possible_inputs_b = {}
        for _, i in ipairs(possible_inputs_a) do
            table.insert(possible_inputs_b, i)
            table.insert(possible_inputs_b, "+" .. i)
            table.insert(possible_inputs_b, "-" .. i)
        end
        for _, i in ipairs(possible_inputs_b) do
            for _, j in ipairs(possible_inputs_b) do
                table.insert(possible_inputs, i .. "/" .. j)
            end
        end
        for _, i in ipairs(possible_inputs_b) do
            table.insert(possible_inputs, i)
            table.insert(possible_inputs, "/" .. i)
        end
        input = mcdu_get_entry(possible_inputs)

        -- is input valid?
        if input ~= NIL then
            i = 1
            while string.sub(input, i, i) ~= "/" or i == string.len(input) do
                i = i + 1
            end

            -- set idle and perf to input
            fmgs_dat["idle"] = tonumber(string.sub(input, 1, i - 1))
            fmgs_dat["perf"] = tonumber(string.sub(input, i + 1, -1))

            -- e.g. 1.0
            if i == string.len(input) then
                -- set idle to input
                fmgs_dat["idle"] = tonumber(input)
            end
            -- e.g. /1.0
            if i == 1 then
                -- set perf to input
                fmgs_dat["perf"] = tonumber(string.sub(input, 2, -1))
            end

            -- output idle/perf
            fmgs_dat["idle/perf"] = ""
            idle = tostring(fmgs_dat["idle"])
            perf = tostring(fmgs_dat["perf"])
            if fmgs_dat["idle"] % 1 == 0 then
                idle = idle .. ".0"
            end
            if fmgs_dat["perf"] % 1 == 0 then
                perf = perf .. ".0"
            end
            if fmgs_dat["idle"] >= 0 then
                fmgs_dat["idle/perf"] = "+" .. idle
            else
                fmgs_dat["idle/perf"] = idle
            end
            if fmgs_dat["perf"] >= 0 then
                fmgs_dat["idle/perf"] = fmgs_dat["idle/perf"] .. "/+" .. perf
            else
                fmgs_dat["idle/perf"] = fmgs_dat["idle/perf"] .. "/" .. perf
            end

            mcdu_open_page(505) -- reload
        end
    end

    -- options>
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu options
    end
end

-- 600 f-pln
mcdu_sim_page[600] =
function (phase)
    if phase == "render" then
        fmgs_dat_init("fpln index", 0)
        fmgs_dat_init("fpln page", 1)
        --load the fpln
        fpln_load()
        --format the fpln
        fpln_format()
        --initialize fpln page index
        fpln_index = fmgs_dat["fpln index"]
        --draw the f-pln
        for i = 1, math.min(#fmgs_dat["fpln fmt"], 5) do
            --increment fpln index, loop around flight plan.
            fpln_index = fpln_index % #fmgs_dat["fpln fmt"] + 1

            fpln_wpt = fmgs_dat["fpln fmt"][fpln_index] or ""
            --is it a simple message?
            if type(fpln_wpt) == "string" then
                mcdu_dat["l"]["L"][i].txt = fpln_wpt
            --is it a waypoint?
            else
                --set title
                if i == 1 and fpln_wpt.name:sub(1,4) == fmgs_dat["origin"] then
                    mcdu_dat_title.txt = " from"
                end
                --[[ VIA --]]
                --is via an airway/note or heading?
                if type(fpln_wpt.via) == "string" then
                    --is via an airway or note?
                    if fpln_wpt.via:sub(1,1) ~= "(" then
                        mcdu_dat["s"]["L"][i][1] = {txt = " " .. fpln_wpt.via}
                    --via must be a note
                    else
                        mcdu_dat["s"]["L"][i][1] = {txt = " " .. fpln_wpt.via, col = "green"}
                    end
                --via must be a heading
                else
                    mcdu_dat["s"]["L"][i][1] = {txt = " H" .. fpln_wpt.via .. "°"}
                end

                --[[ NAME --]]
                mcdu_dat["l"]["L"][i][1] = {txt = fpln_wpt.name, col = "green"}

                --[[ TRK --]]
                mcdu_dat["s"]["L"][i][2] = {txt = "        " .. fpln_wpt.trk, col = "green"}

                --[[ DIST --]]
                mcdu_dat["s"]["R"][i] = {txt = fpln_wpt.dist .. "     ", col = "green", size = "s"}

                if fmgs_dat["fpln page"] == 1 then
                    --[[ TIME --]]
                    mcdu_dat["l"]["L"][i][2] = {txt = "        " .. fpln_wpt.time, col = "green", size = "s"}

                    --[[ SPD --]]
                    mcdu_dat["l"]["R"][i][1] = {txt = fpln_wpt.spd .. "/      ", col = "green", size = "s"}

                    --[[ ALT --]]
                    mcdu_dat["l"]["R"][i][2] = {txt = fpln_wpt.alt, col = "green", size = "s"}
                else
                    --[[ EFOB --]]
                    mcdu_dat["l"]["L"][i][2] = {txt = "        " .. fpln_wpt.efob, col = "green", size = "s"}

                    --[[ WIND SPD --]]
                    mcdu_dat["l"]["R"][i][1] = {txt = fpln_wpt.windspd, col = "green", size = "s"}

                    --[[ WIND ALT --]]
                    mcdu_dat["l"]["R"][i][2] = {txt = mcdu_pad_num(fpln_wpt.windhdg, 3) ..  "°/   ", col = "green", size = "s"}
                end
            end
        end

        --[[ DEST --]]
        mcdu_dat["s"]["L"][6] = {txt = "dest    time  "}
        mcdu_dat["s"]["R"][6] = {txt = "dist  efob"}
        --the last index of the f-pln must be the destination
        dest_index = #fmgs_dat["fpln"]
        if #fmgs_dat ~= 0 then
            dest_wpt = fmgs_dat["fpln"][dest_index]
        else
            dest_wpt = {name = "", time = "", dist = "", efob = ""}
        end
        mcdu_dat["l"]["L"][6][1] = {txt = dest_wpt.name}
        --formatting
        if dest_wpt.time == "" then
            mcdu_dat["l"]["L"][6][2] = {txt = "        ----"}
        else
            mcdu_dat["l"]["L"][6][2] = {txt = "        " .. dest_wpt.time}
        end
        --formatting
        if dest_wpt.dist == "" then
            mcdu_dat["l"]["R"][6][2] = {txt = "-----      "}
        else
            mcdu_dat["l"]["R"][6][2] = {txt = dest_wpt.dist .. "      "}
        end
        --formatting
        if dest_wpt.efob == "" then
            mcdu_dat["l"]["R"][6][1] = {txt = "--.- "}
        else
            mcdu_dat["l"]["R"][6][1] = {txt = dest_wpt.efob .. " "}
        end

        draw_update()
    end

    --if any of the side buttons are pushed
    if phase:sub(1,1) == "R" or phase:sub(1,1) == "L" then

        index = phase:sub(2,2)
        wpt_check = mcdu_dat["l"]["L"][tonumber(index)][1] or "invalid"

        --if valid wpt, open 601 f-pln lat rev page
        if wpt_check ~= "invalid" then
            fmgs_dat["lat rev wpt"] = wpt_check.txt
            mcdu_open_page(601) -- 601 f-pln lat rev page
        end
    end

    -- slew left/right (used for lat lon)
    if phase == "slew_left" or phase == "slew_right" then
        --toggle between lat and lon select
        fmgs_dat["fpln page"] = mcdu_toggle(fmgs_dat["fpln page"], 1, 2)
        mcdu_open_page(600) -- reload
    end

    --slew up or down
    if phase == "slew_up" or phase == "slew_down" then
        if phase == "slew_up" then
            increment = -1
        else
            increment = 1
        end
        --is flight plan long enough to slew up and down?
        if #fmgs_dat["fpln fmt"] > 2 then
            fmgs_dat["fpln index"] = fmgs_dat["fpln index"] % #fmgs_dat["fpln fmt"] + increment 
            print(fmgs_dat["fpln index"])
        end
        mcdu_open_page(600)
    end
end

-- 601 f-pln lat rev page
mcdu_sim_page[601] =
function (phase)
    if phase == "render" then
        fmgs_dat_init("lat rev wpt", "none")
        --get the wpt in question's name
        wpt_find_name = fmgs_dat["lat rev wpt"]
        wpt = "invalid"
        --find the wpt data with the name
        for i, wpt_find in ipairs(fmgs_dat["fpln"]) do
            if wpt_find.name == wpt_find_name then
                wpt = wpt_find
                break
            end
        end
        if wpt == "invalid" then
            mcdu_send_message("error 601 " .. wpt_find_name) --throw error!
            return
        end
        mcdu_dat_title[1] = {txt = "   lat rev"}
        mcdu_dat_title[2] = {txt = "           from", size = "s"}
        mcdu_dat_title[3] = {txt = "                " .. wpt.name, col = "green"}

        --get lat lon
        nav = mcdu_ctrl_get_nav(wpt.name, wpt.navtype)
        mcdu_dat["s"]["L"][1] = {txt = "   " .. Coordinates_format_degrees(nav.lat, nav.lon, 1, 1), col = "green"}

        mcdu_dat["s"]["R"][2].txt = "ll xing/incr/no"
        mcdu_dat["l"]["R"][2] = {txt = "[  ]°/[ ]°/[ ]", col = "cyan"}

        mcdu_dat["s"]["R"][3].txt = "next wpt "
        mcdu_dat["l"]["R"][3] = {txt = "[    ]", col = "cyan"}
        --if wpt is not dept airport
        if wpt.name:upper():sub(1,4) ~= fmgs_dat["dest"] then
            mcdu_dat["s"]["R"][4].txt = "new dest "
            mcdu_dat["l"]["R"][4] = {txt = "[  ]", col = "cyan"}
        end

        --is wpt the dept airport?
        if wpt.name:sub(1,4) == fmgs_dat["origin"] then
            mcdu_dat["l"]["L"][1].txt = "<departure"
            mcdu_dat["l"]["R"][1].txt = "fix info>"
        --is wpt the dept airport?
        elseif wpt.name:sub(1,4) == fmgs_dat["dest"] then
            mcdu_dat["l"]["R"][1].txt = "arrival>"
            mcdu_dat["l"]["L"][3].txt = "<altn"
        end

        mcdu_dat["l"]["L"][6].txt = "<return"

        draw_update()
    end
    
    --departure
    if phase == "L1" then
        --is wpt the dept airport?
        if wpt.name:sub(1,4) == fmgs_dat["origin"] then
            mcdu_open_page(602) -- open 602 f-pln lat rev page dept airport
        end
    end
    --arrival/fix info
    if phase == "R1" then
        --is wpt the dept airport?
        if wpt.name:sub(1,4) == fmgs_dat["dest"] then
            mcdu_open_page(603) -- open 603 f-pln lat rev page dest airport
        else
            mcdu_send_message("not yet implemented!")
        end
    end
    --altn
    if phase == "L3" then
        --is wpt the dept airport?
        if wpt.name:sub(1,4) == fmgs_dat["origin"] then
            mcdu_open_page(602) -- open 602 f-pln lat rev page dept airport
        end
    end
    if phase == "R2" or phase == "R3" or phase == "R4" then
        mcdu_send_message("not yet implemented!")
    end
    if phase == "L6" then
        mcdu_open_page(600) -- open 600 f-pln
    end
end

-- 602 f-pln lat rev page dept airport
mcdu_sim_page[602] =
function (phase)
    if phase == "render" then
        mcdu_dat_title[1] = {txt = " departure"}
        mcdu_dat_title[2] = {txt = "             from", size = "s"}
        mcdu_dat_title[3] = {txt = "                  " .. wpt.name, col = "green"}

        mcdu_dat["s"]["L"][1].txt = " rwy      sid     trans"
        mcdu_dat["l"]["L"][1].txt = " ---     ------  ------"
            
        mcdu_dat["s"]["L"][2].txt = " available runways"
        fmgs_dat_init("fpln latrev index", 1)   -- init the increment/offset of runway data to 0
        offset = 0

        --set airport in question
        airport = fmgs_dat["origin"]
        for i,runway in ipairs(fmgs_dat["runways"]) do
            print (i .. runway.name)
        end
        for i = 1, 4 do
            line = (offset % 4) + 2
            print (line)
            print((fmgs_dat["fpln latrev index"] + offset) % #fmgs_dat["runways"] + 1)
            --get ILS data
            runway = fmgs_dat["runways"][(fmgs_dat["fpln latrev index"] + offset) % #fmgs_dat["runways"] + 1]
            ils = mcdu_ctrl_get_nav(airport .. " " .. runway.name, NAV_ILS)

            --get ILS freq
            --format e.g. 11170 to 111.70
            ils.freq = tostring(ils.freq)
            freq = ils.freq:sub(1,3) .. "." .. ils.freq:sub(4,5)

            --get ILS crs
            ils.hdg = degTrueToDegMagnetic(ils.hdg)
            if ils.hdg > 180 then
                --format e.g. 342 to -18
                ils.hdg = Round(ils.hdg - 360,0)
            end
            --how many digits?
            ils.hdg = tostring(ils.hdg)
            if string.len(ils.hdg) == 1 then
                ils.hdg = ils.hdg:sub(1,1)
            elseif string.len(ils.hdg) == 2 then
                ils.hdg = ils.hdg:sub(1,2)
            else
                ils.hdg = ils.hdg:sub(1,3)
            end
            
            --format e.g. from RW16C to 16C

            mcdu_dat["l"]["L"][line] = {txt = "<" .. runway.name .. "   " .. runway.length .. "FT", col = "cyan"}
            mcdu_dat["l"]["R"][line] = {txt = "crs" .. ils.hdg .. "   ", col = "cyan", size = "s"}
            --display runway length
            mcdu_dat["s"]["L"][line + 1] = {txt = "       ILS", col = "cyan"}
            mcdu_dat["s"]["R"][line + 1] = {txt = ils.id .. "/" .. freq, col = "cyan"}

            --does runway length already exist for this runway?
            offset = offset + 1
        end

        mcdu_dat["l"]["L"][6].txt = "<return"

        draw_update()
    end

    --if any of the side buttons are pushed
    if phase:sub(1,1) == "R" or phase:sub(1,1) == "L" and tonumber(phase:sub(2,2)) >= 2 and tonumber(phase:sub(2,2)) <= 5 then

        --find the index of which button was pressed, and -2 to make it equal to `offset` in the function above
        index = tonumber(phase:sub(2,2)) - 2
        runway = fmgs_dat["runways"][(fmgs_dat["fpln latrev index"] + index) % #fmgs_dat["runways"] + 1]
    end

    --<return
    if phase == "L6" then
        mcdu_open_page(600) -- open 600 f-pln
    end

    --slew up or down
    if phase == "slew_up" or phase == "slew_down" then
        if phase == "slew_up" then
            increment = -1
        else
            increment = 1
        end
        --is flight plan long enough to slew up and down?
        if #fmgs_dat["runways"] > 4 then
            fmgs_dat["fpln latrev index"] = fmgs_dat["fpln latrev index"] + increment
            print(fmgs_dat["fpln latrev index"])
        end
        mcdu_open_page(602)
    end
end

-- 603 f-pln lat rev page dest airport
mcdu_sim_page[603] =
function (phase)
    if phase == "render" then
        mcdu_dat_title[1] = {txt = " arrival"}
        mcdu_dat_title[2] = {txt = "           from", size = "s"}
        mcdu_dat_title[3] = {txt = "                  " .. wpt.name, col = "green"}

        mcdu_dat["l"]["L"][6].txt = "<return"

        draw_update()
    end
    
    if phase == "R2" or phase == "R3" or phase == "R4" then
        mcdu_send_message("not yet implemented!")
    end
    if phase == "L6" then
        mcdu_open_page(600) -- open 600 f-pln
    end
end

-- 700 rad nav
mcdu_sim_page[700] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        radio nav"
        mcdu_dat["s"]["L"][1].txt = "vor1/freq"

        mcdu_dat["l"]["L"][1][1] = {txt = " [ ]", col = "cyan"}
        mcdu_dat["l"]["L"][1][2] = {txt = "    /111.00", col = "cyan", size = "s"}

        mcdu_dat["s"]["R"][1].txt = "freq/vor2"

        mcdu_dat["l"]["R"][1][1] = {txt = "[ ] ", col = "cyan"}
        mcdu_dat["l"]["R"][1][2] = {txt = "110.90/    ", col = "cyan", size = "s"}

        mcdu_dat["s"]["L"][2].txt = "crs"
        mcdu_dat["l"]["L"][2] = {txt = "315", col = "cyan"}
        mcdu_dat["s"]["R"][2].txt = "crs"
        mcdu_dat["l"]["R"][2] = {txt = "315", col = "cyan"}

        mcdu_dat["s"]["L"][3].txt = "ils /freq"
        mcdu_dat["l"]["L"][3][1] = {txt = "[  ]", col = "cyan"}
        mcdu_dat["l"]["L"][3][2] = {txt = "    /08.10", col = "cyan", size = "s"}

        mcdu_dat["s"]["R"][3].txt = "chan/ mls"
        mcdu_dat["l"]["R"][3].txt = "---/--- "

        mcdu_dat["s"]["L"][4].txt = "crs"
        mcdu_dat["l"]["L"][4].txt = "---"

        mcdu_dat["s"]["R"][4].txt = "slope   crs"
        mcdu_dat["l"]["R"][4].txt = " -.-    ---"

        mcdu_dat["s"]["L"][5].txt = "adf1/freq"
        mcdu_dat["l"]["L"][5][1] = {txt = " [ ]", col = "cyan"}
        mcdu_dat["l"]["L"][5][2] = {txt = "    / 210.0", col = "cyan", size = "s"}

        mcdu_dat["s"]["R"][5].txt = "freq/adf2"
        mcdu_dat["l"]["R"][5][1] = {txt = "[ ] ", col = "cyan"}
        mcdu_dat["l"]["R"][5][2] = {txt = "210.0/    ", col = "cyan", size = "s"}

        draw_update()
    end
end

-- 800 fuel pred
mcdu_sim_page[800] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          fuel pred"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 900 sec f-pln
mcdu_sim_page[900] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        sec f-pln"

		mcdu_dat["l"]["L"][1] = {txt = "←copy active", col = "cyan"}
		mcdu_dat["l"]["R"][1].txt = "init>"
		mcdu_dat["l"]["L"][2].txt = "<sec f-pln"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 1000 atc comm
mcdu_sim_page[1000] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          atc comm"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- 1100 mcdu menu
mcdu_sim_page[1100] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "        mcdu menu"
        mcdu_dat["l"]["L"][1].txt = "<fmgc"

        mcdu_dat["l"]["R"][6].txt = "options>"
        draw_update()
    end
    if phase == "L1" then
        mcdu_open_page(505) -- open 505 data a/c status
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu options
    end
end

-- 1101 mcdu menu options
mcdu_sim_page[1101] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "     a32nx project"

        mcdu_dat["l"]["L"][1].txt = "<about"
        mcdu_dat["l"]["L"][2].txt = "<colours"
        mcdu_dat["l"]["R"][2].txt = "debug>"

        mcdu_dat["s"]["R"][3] = {txt = "head developer      ", col = "white"}
        mcdu_dat["l"]["R"][3] = {txt = "jonathan orr       ", col = "cyan"}
		mcdu_dat["s"]["R"][4] = {txt = "avionics         ", col = "white"}
        mcdu_dat["l"]["R"][4] = {txt = "henrick ku        ", col = "green"}
		mcdu_dat["s"]["R"][5] = {txt = "programmer        ", col = "white"}
        mcdu_dat["l"]["R"][5] = {txt = "ricorico         ", col = "green"}
        mcdu_dat["s"]["R"][6] = {txt = "mcdu written by     ", col = "white"}
        mcdu_dat["l"]["R"][6][1] = {txt = "chaidhat chaimongkol   ", col = "green"}
        mcdu_dat["l"]["R"][6][2] = {txt = ">", col = "white"}

        draw_update()
    end
    if phase == "L1" then
        mcdu_open_page(1102) -- open 1102 mcdu menu options about
    end
    if phase == "L2" then
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
    if phase == "R2" then
        mcdu_open_page(1106) -- open 1106 mcdu menu options debug
    end
    if phase == "R6" then
        mcdu_open_page(1100) -- open 1100 mcdu menu
    end
end

-- 1102 mcdu menu options about
mcdu_sim_page[1102] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "  version and license"
        mcdu_dat["s"]["L"][1].txt = "mcdu version"
        mcdu_dat["l"]["L"][1].txt = "v1.0 not finished"
        mcdu_dat["s"]["L"][2].txt = "license"
        mcdu_dat["l"]["L"][2].txt = "gpl 3.0"
        mcdu_dat["s"]["L"][3].txt = "github.com"
        mcdu_dat["l"]["L"][3].txt = "jonathanorr/a321neo-fxpl"

        mcdu_dat["l"]["L"][4] = {txt = "join our discord!", col = "cyan"}

        mcdu_dat["l"]["R"][6].txt = "return>"

        draw_update()
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu options
    end
end

-- 1103 mcdu menu options colours
mcdu_sim_page[1103] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "     a32nx colours"
        mcdu_dat["l"]["L"][1].txt = " colour change utility"

        for i,col in ipairs({"white", "cyan", "green", "amber"}) do
            mcdu_dat["l"]["L"][i + 1] = {txt = "<" .. col, col = col}
        end
        for i,col in ipairs({"yellow", "magenta", "red"}) do
            mcdu_dat["l"]["R"][i + 1] = {txt = col .. ">", col = col}
        end

        mcdu_dat["l"]["R"][5].txt = "load palette>"

        mcdu_dat["l"]["L"][6].txt = "←disco mode"
        mcdu_dat["l"]["R"][6].txt = "return>"
        draw_update()
    end
    if phase == "L2" then
        fmgs_dat["colour"] = "white"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end
    if phase == "L3" then
        fmgs_dat["colour"] = "cyan"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end
    if phase == "L4" then
        fmgs_dat["colour"] = "green"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end
    if phase == "L5" then
        fmgs_dat["colour"] = "amber"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end

    if phase == "R2" then
        fmgs_dat["colour"] = "yellow"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end
    if phase == "R3" then
        fmgs_dat["colour"] = "magenta"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end
    if phase == "R4" then
        fmgs_dat["colour"] = "red"
        mcdu_open_page(1104) -- open 1104 mcdu menu options colours changer
    end

    if phase == "R5" then
        mcdu_open_page(1105) -- open 1105 mcdu menu options colours palette
    end

    if phase == "L6" then
        if not hokey_pokey then
            hokey_pokey = true
            for i,f in ipairs({"white", "cyan", "amber", "green", "yellow", "magenta", "red"}) do
                MCDU_DISP_COLOR[f] = {1, 0, 0} 
            end
        else
            hokey_pokey = false
            mcdu_send_message("pls load default palette")
        end
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu options
    end
end
-- 1104 mcdu menu options colours changer
mcdu_sim_page[1104] =
function (phase)
    if phase == "render" then
        colour = fmgs_dat["colour"]
        mcdu_dat_title.txt = "     change " .. colour
        mcdu_dat_title.col = colour
        mcdu_dat["l"]["L"][1] = {txt = "←red   " .. MCDU_DISP_COLOR[colour][1] * 100 .. " percent", col = colour}
        mcdu_dat["l"]["L"][2] = {txt = "←green " .. MCDU_DISP_COLOR[colour][2] * 100 .. " percent", col = colour}
        mcdu_dat["l"]["L"][3] = {txt = "←blue  " .. MCDU_DISP_COLOR[colour][3] * 100 .. " percent", col = colour}

        mcdu_dat["l"]["L"][5].txt = "format e.g. 10"
        mcdu_dat["l"]["R"][6].txt = "return>"

        draw_update()
    end
    if phase == "L1" then
        input, variation = mcdu_get_entry({"!", "!!", "!!!"})
        if input ~= NIL then
            input_col = tonumber(input) / 100
            MCDU_DISP_COLOR[fmgs_dat["colour"]][1] = input_col

            mcdu_open_page(1104) -- reload page
        else
            mcdu_send_message("please enter value")
        end
    end
    if phase == "L2" then
        input, variation = mcdu_get_entry({"!", "!!", "!!!"})
        if input ~= NIL then
            input_col = tonumber(input) / 100
            MCDU_DISP_COLOR[fmgs_dat["colour"]][2] = input_col

            mcdu_open_page(1104) -- reload page
        else
            mcdu_send_message("please enter value")
        end
    end
    if phase == "L3" then
        input, variation = mcdu_get_entry({"!", "!!", "!!!"})
        if input ~= NIL then
            input_col = tonumber(input) / 100
            MCDU_DISP_COLOR[fmgs_dat["colour"]][3] = input_col

            mcdu_open_page(1104) -- reload page
        else
            mcdu_send_message("please enter value")
        end
    end
    if phase == "R6" then
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
end

-- 1105 mcdu menu options colours palette
mcdu_sim_page[1105] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "  load colour palette"
        mcdu_dat["l"]["L"][1].txt = "←load default"
        mcdu_dat["l"]["L"][2].txt = "←load aerofsx"
        mcdu_dat["l"]["L"][3].txt = "←load classic"
        mcdu_dat["l"]["L"][5].txt = "←load high contrast"

        mcdu_dat["l"]["R"][6].txt = "return>"

        draw_update()
    end
    if phase == "L1" then
        MCDU_DISP_COLOR = 
        {
            ["white"] =   ECAM_WHITE,
            ["cyan"] =    ECAM_BLUE,
            ["green"] =   ECAM_GREEN,
            ["amber"] =   ECAM_ORANGE,
            ["yellow"] =  ECAM_YELLOW,
            ["magenta"] = ECAM_MAGENTA,
            ["red"] =     ECAM_RED,

            ["black"] =   ECAM_BLACK,
        }
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
    if phase == "L2" then
        MCDU_DISP_COLOR = 
        {
            ["white"] =   {1.00, 1.00, 1.00},
            ["cyan"] =    {0.07, 0.79, 0.94}, --11AFD7
            ["green"] =   {0.09, 0.54, 0.17}, --178A2C
            ["amber"] =   {0.95, 0.65, 0.00}, --F2BF2C
            ["yellow"] =  {0.95, 0.75, 0.00}, --F2BF2C
            ["magenta"] = {0.57, 0.29, 0.63}, --924AA1
            ["red"] =     {1.00, 0.00, 0.00},

            ["black"] =   {0.00, 0.00, 0.00},
        }
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
    if phase == "L3" then
        MCDU_DISP_COLOR = 
        {
            ["white"] =   {0.92, 0.94, 0.93}, --EBEFEC
            ["cyan"] =    {0.68, 0.84, 1.00}, --ADD7FF
            ["green"] =   {0.73, 1.00, 0.87}, --BBFDDD
            ["amber"] =   {1.00, 0.67, 0.70}, --FFAAB3
            ["yellow"] =  {1.00, 0.67, 0.70}, --FFAAB3
            ["magenta"] = {0.92, 0.54, 1.00}, --EC8AFF
            ["red"] =     {1.00, 0.50, 0.50},

            ["black"] =   {0.00, 0.00, 0.00},
        }
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
    --[[
    if phase == "L4" then
        MCDU_DISP_COLOR = 
        {
            ["white"] =   {1.00, 1.00, 1.00},
            ["cyan"] =    {0.00, 0.68, 0.78}, --00AEC7
            ["green"] =   {0.52, 0.74, 0.00}, --84BD00
            ["amber"] =   {1.00, 0.31, 0.00}, --FE5000
            ["yellow"] =  {0.88, 0.88, 0.00}, --E1E000
            ["magenta"] = {0.64, 0.09, 0.56}, --A51890
            ["red"] =     {0.89, 0.00, 0.17}, --E4002B

            ["black"] =   {0.00, 0.00, 0.00},
        }
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
    --]]
    if phase == "L5" then
        MCDU_DISP_COLOR = 
        {
            ["white"] =   {1.00, 1.00, 1.00},
            ["cyan"] =    {0.00, 1.00, 1.00}, 
            ["green"] =   {0.00, 1.00, 0.00},
            ["amber"] =   {1.00, 0.50, 0.00},
            ["yellow"] =  {1.00, 1.00, 0.00},
            ["magenta"] = {1.00, 0.00, 1.00},
            ["red"] =     {1.00, 0.00, 0.00},

            ["black"] =   {0.00, 0.00, 0.00},
        }
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end

    if phase == "R6" then
        mcdu_open_page(1103) -- open 1103 mcdu menu options colours
    end
end

-- 1106 mcdu menu options debug
mcdu_sim_page[1106] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["L"][1].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["L"][1].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["R"][2].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["R"][2].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["L"][3].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["L"][3].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["R"][4].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["R"][4].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["L"][5].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["L"][5].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["s"]["R"][6].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"
        mcdu_dat["l"]["R"][6].txt = "xxxxxxxxxxxxxxxxxxxxxxxx"

        draw_update()
    end
    if phase == "R6" then
        mcdu_open_page(1101) -- open 1101 mcdu menu options
    end
end


-- 1200 air port
mcdu_sim_page[1200] =
function (phase)
    if phase == "render" then
        mcdu_dat_title.txt = "          air port"

        mcdu_dat["l"]["L"][1].txt = "not yet implemented"
		mcdu_dat["l"]["L"][6] = {txt = "        inop page", col = "amber"}

        draw_update()
    end
end

-- END OF MCDU CODE
-- END OF MCDU CODE
-- END OF MCDU CODE

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- EMULATOR SHELL CODE CONTINUED (II of II)
--    Simulates SASL running on a lua intrepreter (or https://repl.it)
--    instead of booting up X-Plane everytime you want to run this.

if EMULATOR then
    -- initialize all global variables which would otherwise be done by other parts of the script
	Mcdu_enabled = "Mcdu_enabled"
	mcdu_page = "mcdu_page"
	mcdu_debug_busy = "mcdu_debug_busy"
	TIME = "time"
	DELTA_TIME = "delta_time"
	Engine_option = "Engine_option"
	set(Mcdu_enabled, 1)
	set(mcdu_page, 0)
	set(TIME, 1)
	set(DELTA_TIME, 0)
	set(Engine_option, 0)

	print("")
	print(EMULATOR_HEADER .. "Initalization done!")
	if EMULATOR_PROMPT_BEFORE_RUN then
		print("")
		print("PRESS ENTER TO RUN.")
		s = io.read("*l")
	end
	os.execute("clear")
	found_command = true
	while true do
		os.execute("clear")
		set(TIME, get(TIME) + 1)
		
		print()
		if not found_command then
			print(EMULATOR_HEADER .. "COMMAND NOT FOUND")
		end

		update()
		draw()

		print()
		print()
		print()

		chars = {}
		for i = 0,14,1 do -- columns
			chars[i] = "                        "
		end

		color_codes = {} -- colour codes, which are inserted later into the text

		--draw all horizontal lines
        for i,line in ipairs(draw_lines) do
			str = line.disp_text
			color = line.disp_color

			x = math.floor(((line.disp_x - 20) / 520) + 1.1)
			y = math.floor(14.1 -((line.disp_y - 31.7) / 35.3))

			if x == 2 then
				x = 25 - #str
			end

			if line.disp_color == MCDU_DISP_COLOR["cyan"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[1;36m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end
			if line.disp_color == MCDU_DISP_COLOR["green"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[1;32m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end
			if line.disp_color == MCDU_DISP_COLOR["amber"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[1;33m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end
			if line.disp_color == MCDU_DISP_COLOR["yellow"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[0;33m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end
			if line.disp_color == MCDU_DISP_COLOR["magenta"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[1;35m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end
			if line.disp_color == MCDU_DISP_COLOR["red"] then
				table.insert(color_codes, {x = x, y = y, word = "\27[1;31m"})
				table.insert(color_codes, {x = x + #str + 1, y = y, word = "\27[0m"})
			end

			for i = 1, 24, 1 do
				j = i - x + 1-- i relative to str
				if j < 1 then
					 j = 999
				end
				if string.sub(str,j,j) ~= " " then
					chars[y] = string.sub(chars[y], 1, i) .. string.sub(str, j, j) .. string.sub(chars[y], i+1, #chars[y])
				end
			end
        end 

		for k = 1, #color_codes, 1 do
			spec = color_codes[k]
			i = 1
			j = 1
			while i <= spec.x do
				if string.sub(chars[spec.y], j, j) == "\27" then
					j = j + 7
				end
				--print(string.sub(chars[spec.y], j, j) .. " " .. i)
				j = j + 1
				i = i + 1
			end 
			j = j - 1
			chars[spec.y] = string.sub(chars[spec.y], 1, j-1) .. spec.word .. string.sub(chars[spec.y], j, #chars[spec.y])
		end

		chars[14] = mcdu_entry

		for i = 1,14,1 do -- columns
			if (math.fmod((i+1)*0.5,1) == 0) then
				out_line = (i - 1) / 2
			else
				out_line = " "
			end
			print(out_line .. "|" .. chars[i] .. "")
		end

		print()
		print()
		print()

		print("List of commands:")
		print("  a321neo/cockpit/mcdu/key <-- to enter key mode")
		print("  a321neo/cockpit/mcdu/side/L1 <-- side keys: L1-L6, R1-R6")

		for i = 1, #commands, 1 do
			if string.sub(commands[i].name,0,24) ~= "a321neo/cockpit/mcdu/key" and
			   string.sub(commands[i].name,0,25) ~= "a321neo/cockpit/mcdu/side" then
				print("  " .. commands[i].name)
			end
		end

		print()
		print("\27[101;93mSCROLL UP TO FIND THE MCDU\27[0m")

		print()
		print("Please enter a command name.")
		io.write("	a321neo/cockpit/mcdu/")
		user_command = io.read("*l")
		
		if user_command == "key" then --enter keymode
			print("Please enter mcdu entry")
			user_entry = io.read("*l")
			mcdu_entry = string.upper(user_entry)
		end

		found_command = false
		for i = 1, #commands, 1 do
			if string.sub(commands[i].name,22,-1) == user_command then
				commands[i].ref(SASL_COMMAND_BEGIN) -- call the command
				found_command = true
			end
		end
	end
end
-- END OF EMULATOR SHELL CODE II OF II (CONTINUED AT END OF SCRIPT)
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

