--[[ informations

the vertical line spacing for large text is 36 sasl units and the text size is 20
the lines' y coordinate in desending order for large text is 108, 72, 36, 0, -36, -72, -108

the vertical line spacing for large text is 36 sasl units and the text size is 12
the lines' y coordinate in desending order for large text is 90, 54, 18, 0, -18, -54, -90


--]]

position= {75,1690,320,285}
size = {320, 285}

--sim dataref

--a321neo dataref
local mcdu_page = createGlobalPropertyi("a321neo/cockpit/mcdu/mcdu_page", 0, false, true, false) --0 mcdu info page, 1 init page, 2 f-pln page
local mcdu_enabled = createGlobalPropertyi("a321neo/debug/mcdu/mcdu_enabled", 1, false, true, false)
local mcdu_message_index = createGlobalPropertyi("a321neo/debug/mcdu/message_index", 0, false, true, false)
--sim commands

--a321neo commands
--debugging commands
local mcdu_debug_message = sasl.createCommand("a321neo/debug/mcdu/debug_message", "send a mcdu debug message")

--mcdu keyboard commands
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
--mcdu letters
local mcdu_A_key = createCommand("a321neo/cockpit/mcdu/A", "MCDU A Key")
local mcdu_B_key = createCommand("a321neo/cockpit/mcdu/B", "MCDU B Key")
local mcdu_C_key = createCommand("a321neo/cockpit/mcdu/C", "MCDU C Key")
local mcdu_D_key = createCommand("a321neo/cockpit/mcdu/D", "MCDU D Key")
local mcdu_E_key = createCommand("a321neo/cockpit/mcdu/E", "MCDU E Key")
local mcdu_F_key = createCommand("a321neo/cockpit/mcdu/F", "MCDU F Key")
local mcdu_G_key = createCommand("a321neo/cockpit/mcdu/G", "MCDU G Key")
local mcdu_H_key = createCommand("a321neo/cockpit/mcdu/H", "MCDU H Key")
local mcdu_I_key = createCommand("a321neo/cockpit/mcdu/I", "MCDU I Key")
local mcdu_J_key = createCommand("a321neo/cockpit/mcdu/J", "MCDU J Key")
local mcdu_K_key = createCommand("a321neo/cockpit/mcdu/K", "MCDU K Key")
local mcdu_L_key = createCommand("a321neo/cockpit/mcdu/L", "MCDU L Key")
local mcdu_M_key = createCommand("a321neo/cockpit/mcdu/M", "MCDU M Key")
local mcdu_N_key = createCommand("a321neo/cockpit/mcdu/N", "MCDU N Key")
local mcdu_O_key = createCommand("a321neo/cockpit/mcdu/O", "MCDU O Key")
local mcdu_P_key = createCommand("a321neo/cockpit/mcdu/P", "MCDU P Key")
local mcdu_Q_key = createCommand("a321neo/cockpit/mcdu/Q", "MCDU Q Key")
local mcdu_R_key = createCommand("a321neo/cockpit/mcdu/R", "MCDU R Key")
local mcdu_S_key = createCommand("a321neo/cockpit/mcdu/S", "MCDU S Key")
local mcdu_T_key = createCommand("a321neo/cockpit/mcdu/T", "MCDU T Key")
local mcdu_U_key = createCommand("a321neo/cockpit/mcdu/U", "MCDU U Key")
local mcdu_V_key = createCommand("a321neo/cockpit/mcdu/V", "MCDU V Key")
local mcdu_W_key = createCommand("a321neo/cockpit/mcdu/W", "MCDU W Key")
local mcdu_X_key = createCommand("a321neo/cockpit/mcdu/X", "MCDU X Key")
local mcdu_Y_key = createCommand("a321neo/cockpit/mcdu/Y", "MCDU Y Key")
local mcdu_Z_key = createCommand("a321neo/cockpit/mcdu/Z", "MCDU Z Key")
--MCDU numpad
local mcdu_1_key = createCommand("a321neo/cockpit/mcdu/1", "MCDU 1 Key")
local mcdu_2_key = createCommand("a321neo/cockpit/mcdu/2", "MCDU 2 Key")
local mcdu_3_key = createCommand("a321neo/cockpit/mcdu/3", "MCDU 3 Key")
local mcdu_4_key = createCommand("a321neo/cockpit/mcdu/4", "MCDU 4 Key")
local mcdu_5_key = createCommand("a321neo/cockpit/mcdu/5", "MCDU 5 Key")
local mcdu_6_key = createCommand("a321neo/cockpit/mcdu/6", "MCDU 6 Key")
local mcdu_7_key = createCommand("a321neo/cockpit/mcdu/7", "MCDU 7 Key")
local mcdu_8_key = createCommand("a321neo/cockpit/mcdu/8", "MCDU 8 Key")
local mcdu_9_key = createCommand("a321neo/cockpit/mcdu/9", "MCDU 9 Key")
local mcdu_0_key = createCommand("a321neo/cockpit/mcdu/0", "MCDU 0 Key")
local mcdu_decimal_key = createCommand("a321neo/cockpit/mcdu/decimal", "MCDU Decimal Key")
local mcdu_positive_negative_key = createCommand("a321neo/cockpit/mcdu/positive_negative", "MCDU Positive Negative Key")

local mcdu_clr_key = createCommand("a321neo/cockpit/mcdu/clr", "MCDU CLR Key")

local mcdu_page_up = sasl.createCommand("a321neo/cockpit/mcdu/page_up", "mcdu page up")
local mcdu_page_dn = sasl.createCommand("a321neo/cockpit/mcdu/page_dn", "mcdu page down")

--fonts
local B612MONO_regular = sasl.gl.loadFont("fonts/B612Mono-Regular.ttf")

--colors
local mcdu_white = {1.0, 1.0, 1.0}
local mcdu_blue = {0.004, 1.0, 1.0}
local mcdu_green = {0.004, 1, 0.004}
local mcdu_orange = {0.843, 0.49, 0}
local mcdu_black = {0,0,0,1}

--mcdu line colors
local mcdu_title_L_cl = mcdu_white
local mcdu_title_M_cl = mcdu_white
local mcdu_title_R_cl = mcdu_white
--mcdu left section
local mcdu_s_L_cl = {}
mcdu_s_L_cl[1] = mcdu_white
mcdu_s_L_cl[2] = mcdu_white
mcdu_s_L_cl[3] = mcdu_white
mcdu_s_L_cl[4] = mcdu_white
mcdu_s_L_cl[5] = mcdu_white
mcdu_s_L_cl[6] = mcdu_white
local mcdu_l_L_cl = {}
mcdu_l_L_cl[1] = mcdu_white
mcdu_l_L_cl[2] = mcdu_white
mcdu_l_L_cl[3] = mcdu_white
mcdu_l_L_cl[4] = mcdu_white
mcdu_l_L_cl[5] = mcdu_white
mcdu_l_L_cl[6] = mcdu_white
--mcdu center section
local mcdu_s_M_cl = {}
mcdu_s_M_cl[1] = mcdu_white
mcdu_s_M_cl[2] = mcdu_white
mcdu_s_M_cl[3] = mcdu_white
mcdu_s_M_cl[4] = mcdu_white
mcdu_s_M_cl[5] = mcdu_white
mcdu_s_M_cl[6] = mcdu_white
local mcdu_l_M_cl = {}
mcdu_l_M_cl[1] = mcdu_white
mcdu_l_M_cl[2] = mcdu_white
mcdu_l_M_cl[3] = mcdu_white
mcdu_l_M_cl[4] = mcdu_white
mcdu_l_M_cl[5] = mcdu_white
mcdu_l_M_cl[6] = mcdu_white
--mcdu right section
local mcdu_s_R_cl = {}
mcdu_s_R_cl[1] = mcdu_white
mcdu_s_R_cl[2] = mcdu_white
mcdu_s_R_cl[3] = mcdu_white
mcdu_s_R_cl[4] = mcdu_white
mcdu_s_R_cl[5] = mcdu_white
mcdu_s_R_cl[6] = mcdu_white
local mcdu_l_R_cl = {}
mcdu_l_R_cl[1] = mcdu_white
mcdu_l_R_cl[2] = mcdu_white
mcdu_l_R_cl[3] = mcdu_white
mcdu_l_R_cl[4] = mcdu_white
mcdu_l_R_cl[5] = mcdu_white
mcdu_l_R_cl[6] = mcdu_white

--sasl variables
--mcdu lines vertical locations
local mcdu_s_ypos = {
    90,
    54,
    18,
    -18,
    -54,
    -90
}
local mcdu_l_ypos = {
    72,
    36,
    0,
    -36,
    -72,
    -108
}
--mcdu lines(max munber of character is 22)
local mcdu_title_L = "TITLE"
local mcdu_title_M = "TITLE"
local mcdu_title_R = "TITLE"
--MCDU left section
local mcdu_s_L = {}
mcdu_s_L[1] = "1 s L"
mcdu_s_L[2] = "2 s L"
mcdu_s_L[3] = "3 s L"
mcdu_s_L[4] = "4 s L"
mcdu_s_L[5] = "5 s L"
mcdu_s_L[6] = "6 s L"
local mcdu_l_L = {}
mcdu_l_L[1] = "1 l L"
mcdu_l_L[2] = "2 l L"
mcdu_l_L[3] = "3 l L"
mcdu_l_L[4] = "4 l L"
mcdu_l_L[5] = "5 l L"
mcdu_l_L[6] = "6 l L"
--MCDU center section
local mcdu_s_M = {}
mcdu_s_M[1] = "1 s M"
mcdu_s_M[2] = "2 s M"
mcdu_s_M[3] = "3 s M"
mcdu_s_M[4] = "4 s M"
mcdu_s_M[5] = "5 s M"
mcdu_s_M[6] = "6 s M"
local mcdu_l_M = {}
mcdu_l_M[1] = "1 l M"
mcdu_l_M[2] = "2 l M"
mcdu_l_M[3] = "3 l M"
mcdu_l_M[4] = "4 l M"
mcdu_l_M[5] = "5 l M"
mcdu_l_M[6] = "6 l M"
--MCDU right section
local mcdu_s_R = {}
mcdu_s_R[1] = "1 s R"
mcdu_s_R[2] = "2 s R"
mcdu_s_R[3] = "3 s R"
mcdu_s_R[4] = "4 s R"
mcdu_s_R[5] = "5 s R"
mcdu_s_R[6] = "6 s R"
local mcdu_l_R = {}
mcdu_l_R[1] = "1 l R"
mcdu_l_R[2] = "2 l R"
mcdu_l_R[3] = "3 l R"
mcdu_l_R[4] = "4 l R"
mcdu_l_R[5] = "5 l R"
mcdu_l_R[6] = "6 l R"
--entry line
local mcdu_entry = ""
local mcdu_messages = {}

--mcdu status
local mcdu_message_active = 0
local mcdu_init_status = 0

--mcdu input fields
local co_routes = nil --□□□□□□□
local flight_number = nil --□□□□□□□□
local mcdu_dep = nil --□□□□
local mcdu_dest = nil --□□□□
local init_lat = nil -- ----.-
local init_long = nil -- ----.-
local cost_index = nil -- --

--mcdu subpages
local mcdu_fpln_page = 0

--flight info
local dep_type, dep_name, dep_id, dep_alt, dep_lat, dep_lon
local dest_type, dest_name, dest_id, dest_alt, dest_lat, dest_lon
local distance_to_dest_km

--F-PLN waypoints
local wpt1_type, wpt1_name, wpt1_id, wpt1_alt, wpt1_lat, wpt1_lon
local wpt2_type, wpt2_name, wpt2_id, wpt2_alt, wpt2_lat, wpt2_lon
local wpt3_type, wpt3_name, wpt3_id, wpt3_alt, wpt3_lat, wpt3_lon
local wpt4_type, wpt4_name, wpt4_id, wpt4_alt, wpt4_lat, wpt4_lon
local wpt5_type, wpt5_name, wpt5_id, wpt5_alt, wpt5_lat, wpt5_lon

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

--mcdu alphabets
sasl.registerCommandHandler(mcdu_A_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "A"
        end
    end
end)

sasl.registerCommandHandler(mcdu_B_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "B"
        end
    end
end)

sasl.registerCommandHandler(mcdu_C_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "C"
        end
    end
end)

sasl.registerCommandHandler(mcdu_D_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "D"
        end
    end
end)

sasl.registerCommandHandler(mcdu_E_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "E"
        end
    end
end)

sasl.registerCommandHandler(mcdu_F_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "F"
        end
    end
end)

sasl.registerCommandHandler(mcdu_G_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "G"
        end
    end
end)

sasl.registerCommandHandler(mcdu_H_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "H"
        end
    end
end)

sasl.registerCommandHandler(mcdu_I_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "I"
        end
    end
end)

sasl.registerCommandHandler(mcdu_J_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "J"
        end
    end
end)

sasl.registerCommandHandler(mcdu_K_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "K"
        end
    end
end)

sasl.registerCommandHandler(mcdu_L_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "L"
        end
    end
end)

sasl.registerCommandHandler(mcdu_M_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "M"
        end
    end
end)

sasl.registerCommandHandler(mcdu_N_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "N"
        end
    end
end)

sasl.registerCommandHandler(mcdu_O_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "O"
        end
    end
end)

sasl.registerCommandHandler(mcdu_P_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "P"
        end
    end
end)

sasl.registerCommandHandler(mcdu_Q_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "Q"
        end
    end
end)

sasl.registerCommandHandler(mcdu_R_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "R"
        end
    end
end)

sasl.registerCommandHandler(mcdu_S_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "S"
        end
    end
end)

sasl.registerCommandHandler(mcdu_T_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "T"
        end
    end
end)

sasl.registerCommandHandler(mcdu_U_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "U"
        end
    end
end)

sasl.registerCommandHandler(mcdu_V_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "V"
        end
    end
end)

sasl.registerCommandHandler(mcdu_W_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "W"
        end
    end
end)

sasl.registerCommandHandler(mcdu_X_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "X"
        end
    end
end)

sasl.registerCommandHandler(mcdu_Y_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "Y"
        end
    end
end)

sasl.registerCommandHandler(mcdu_Z_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "Z"
        end
    end
end)
--mcdu numpad
sasl.registerCommandHandler(mcdu_1_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 1
        end
    end
end)

sasl.registerCommandHandler(mcdu_2_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 2
        end
    end
end)

sasl.registerCommandHandler(mcdu_3_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 3
        end
    end
end)

sasl.registerCommandHandler(mcdu_4_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 4
        end
    end
end)

sasl.registerCommandHandler(mcdu_5_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 5
        end
    end
end)

sasl.registerCommandHandler(mcdu_6_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 6
        end
    end
end)

sasl.registerCommandHandler(mcdu_7_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 7
        end
    end
end)

sasl.registerCommandHandler(mcdu_8_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 8
        end
    end
end)

sasl.registerCommandHandler(mcdu_9_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 9
        end
    end
end)

sasl.registerCommandHandler(mcdu_0_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. 0
        end
    end
end)

sasl.registerCommandHandler(mcdu_decimal_key, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        if #mcdu_entry < 22 then
            mcdu_entry = mcdu_entry .. "."
        end
    end
end)

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


--define all page functionalities(!!!!!!!!!because of 60 upvalue limit per function!!!!!!!!!)
local function mcdu_info_page()
        --title
        mcdu_title_M = "A321 NEO"
        --author info
        mcdu_s_L[1] = "AUTHOR"
        mcdu_l_L[1] = "Jonathan Orr"
        mcdu_l_L_cl[1] = mcdu_blue
        --display the enigne type
        mcdu_s_L[2] = "ENG"
        mcdu_l_L_cl[2] = mcdu_green
        if get(Engine_option) == 0 then
            mcdu_l_L[2] = "CFM-LEAP-1A"
        else
            mcdu_l_L[2] = "PW-1130G-JM"
        end
        --active nav
        mcdu_s_L[3] = "ACTIVE NAV DATA BASE"
        mcdu_l_L[3] = ""
        mcdu_l_L_cl[3] = mcdu_blue
        
        --secondary nav
        mcdu_s_L[4] = "SECOND NAV DATA BASE"
        mcdu_l_L[4] = ""
        mcdu_l_L_cl[4] = mcdu_blue

        --CHG code
        mcdu_s_L[5] = "CHG CODE"
        mcdu_l_L[5] = "[ ]"
        mcdu_l_L_cl[5] = mcdu_blue

        --IDLE PERF
        mcdu_s_L[6] = "IDLE PERF"
        mcdu_l_L[6] = "+0.0/+0.0"
        mcdu_l_L_cl[6] = mcdu_green
end

local function mcdu_fpln()
    wpt1_type, wpt1_name, wpt1_id, wpt1_alt, wpt1_lat, wpt1_lon = sasl.getFMSEntryInfo(0+5*mcdu_fpln_page)
    wpt2_type, wpt2_name, wpt2_id, wpt2_alt, wpt2_lat, wpt2_lon = sasl.getFMSEntryInfo(1+5*mcdu_fpln_page)
    wpt3_type, wpt3_name, wpt3_id, wpt3_alt, wpt3_lat, wpt3_lon = sasl.getFMSEntryInfo(2+5*mcdu_fpln_page)
    wpt4_type, wpt4_name, wpt4_id, wpt4_alt, wpt4_lat, wpt4_lon = sasl.getFMSEntryInfo(3+5*mcdu_fpln_page)
    wpt5_type, wpt5_name, wpt5_id, wpt5_alt, wpt5_lat, wpt5_lon = sasl.getFMSEntryInfo(4+5*mcdu_fpln_page)

    --f-plan legs color
    if sasl.getDestinationFMSEntry() == 0+5*mcdu_fpln_page then
        mcdu_l_L_cl[1] = mcdu_white
        mcdu_l_R_cl[1] = mcdu_white
    else
        mcdu_l_L_cl[1] = mcdu_green
        mcdu_l_R_cl[1] = mcdu_green
    end
    
    if sasl.getDestinationFMSEntry() == 1+5*mcdu_fpln_page then
        mcdu_s_L_cl[2] = mcdu_white
        mcdu_l_L_cl[2] = mcdu_white
        mcdu_s_R_cl[2] = mcdu_white
        mcdu_l_R_cl[2] = mcdu_white
    else
        mcdu_s_L_cl[2] = mcdu_green
        mcdu_l_L_cl[2] = mcdu_green
        mcdu_s_R_cl[2] = mcdu_green
        mcdu_l_R_cl[2] = mcdu_green
    end

    if sasl.getDestinationFMSEntry() == 2+5*mcdu_fpln_page then
        mcdu_s_L_cl[3] = mcdu_white
        mcdu_l_L_cl[3] = mcdu_white
        mcdu_s_R_cl[3] = mcdu_white
        mcdu_l_R_cl[3] = mcdu_white
    else
        mcdu_s_L_cl[3] = mcdu_green
        mcdu_l_L_cl[3] = mcdu_green
        mcdu_s_R_cl[3] = mcdu_green
        mcdu_l_R_cl[3] = mcdu_green
    end

    if sasl.getDestinationFMSEntry() == 3+5*mcdu_fpln_page then
        mcdu_s_L_cl[4] = mcdu_white
        mcdu_l_L_cl[4] = mcdu_white
        mcdu_s_R_cl[4] = mcdu_white
        mcdu_l_R_cl[4] = mcdu_white
    else
        mcdu_s_L_cl[4] = mcdu_green
        mcdu_l_L_cl[4] = mcdu_green
        mcdu_s_R_cl[4] = mcdu_green
        mcdu_l_R_cl[4] = mcdu_green
    end

    if sasl.getDestinationFMSEntry() == 4+5*mcdu_fpln_page then
        mcdu_s_L_cl[5] = mcdu_white
        mcdu_l_L_cl[5] = mcdu_white
        mcdu_s_R_cl[5] = mcdu_white
        mcdu_l_R_cl[5] = mcdu_white
    else
        mcdu_s_L_cl[5] = mcdu_green
        mcdu_l_L_cl[5] = mcdu_green
        mcdu_s_R_cl[5] = mcdu_green
        mcdu_l_R_cl[5] = mcdu_green
    end

        mcdu_l_L[1] = wpt1_name
        mcdu_l_L[2] = wpt2_name
        mcdu_l_L[3] = wpt3_name
        mcdu_l_L[4] = wpt4_name
        mcdu_l_L[5] = wpt5_name
        mcdu_l_L[6] = dest_name .. "        " .. tostring(math.floor(distance_to_dest_km)) .. "KM" 

        mcdu_s_R[1] = "SPD/alt"
        mcdu_l_R[1] = wpt1_alt
        mcdu_l_R[2] = wpt2_alt
        mcdu_l_R[3] = wpt3_alt
        mcdu_l_R[4] = wpt4_alt
        mcdu_l_R[5] = wpt5_alt
end

--main loop
function update()
    --engine option logic
    if get(Engine_option) == 0 then
        set(Leap_engien_option, 1)
        set(PW_engine_enabled, 0)
    else
        set(Leap_engien_option, 0)
        set(PW_engine_enabled, 1)
    end

    --delete all table content
    mcdu_title_L = ""
    mcdu_title_M = ""
    mcdu_title_R = ""
    for i=1,6 do
        mcdu_s_L[i]= ""
        mcdu_l_L[i]= ""
        mcdu_s_M[i]= ""
        mcdu_l_M[i]= ""
        mcdu_s_R[i]= ""
        mcdu_l_R[i]= ""
        mcdu_s_L_cl[i]= mcdu_white
        mcdu_l_L_cl[i]= mcdu_white
        mcdu_s_M_cl[i]= mcdu_white
        mcdu_l_M_cl[i]= mcdu_white
        mcdu_s_R_cl[i]= mcdu_white
        mcdu_l_R_cl[i]= mcdu_white
    end

    --mcdu messages logic
    if #mcdu_messages == 0 then
        mcdu_message_active = 0
    end
    --show the amount of mcdu messages there are
    set(mcdu_message_index, #mcdu_messages)


    --flight plan distance calculation
    dep_type, dep_name, dep_id, dep_alt, dep_lat, dep_lon = sasl.getFMSEntryInfo(0)
    dest_type, dest_name, dest_id, dest_alt, dest_lat, dest_lon = sasl.getFMSEntryInfo(sasl.countFMSEntries()-1)
    distance_to_dest_km = GC_distance_km(dep_lat, dep_lon, dest_lat, dest_lon)
    
    --mcdu info mcdu info page
    if get(mcdu_page) == 0 then
        mcdu_info_page()
    end

    --init page
    if get(mcdu_page) == 1 then
        mcdu_title_M = "INIT"
        --left section
        mcdu_s_L[1] = "CO RTE"
        mcdu_s_L[2] = "ALTN/CO RTE"
        mcdu_s_L[4] = "LAT"
        if mcdu_init_status == 0 then
            mcdu_l_L[1] = "□□□□□□□"
            mcdu_l_L_cl[1] = mcdu_orange

            mcdu_l_L[2] = "----/----------"
            mcdu_l_L_cl[2] = mcdu_white

            mcdu_l_L[4] = "----.-"
            mcdu_l_L_cl[4] = mcdu_white
        elseif mcdu_init_status == 1 then
            mcdu_l_L[1] = "NONE"
            mcdu_l_L_cl[1] = mcdu_blue

            mcdu_l_L[2] = "NONE"
            mcdu_l_L_cl[2] = mcdu_blue

            if init_lat ~= nil then
                mcdu_l_L[4] = init_lat
                mcdu_l_L_cl[4] = mcdu_blue
            end
        end

        mcdu_s_L[3] = "FLT NBR"
        if flight_number == nil then
            mcdu_l_L[3] = "□□□□□□□□"
            mcdu_l_L_cl[3] = mcdu_orange
        else
            mcdu_l_L[3] = flight_number
            mcdu_l_L_cl[3] = mcdu_blue
        end

        --right section
        mcdu_s_R[1] = "FROM/TO"
        if mcdu_dep == nil and mcdu_dest == nil then
            mcdu_l_R[1] = "□□□□/□□□□"
            mcdu_l_R_cl[1] = mcdu_orange
            elseif mcdu_dep == nil and mcdu_dest ~= nil then
                mcdu_l_R[1] = "□□□□/" .. mcdu_dest
                mcdu_l_R_cl[1] = mcdu_orange
                elseif mcdu_dep ~= nil and mcdu_dest == nil then
                    mcdu_l_R[1] = mcdu_dep .. "/□□□□"
                    mcdu_l_R_cl[1] = mcdu_orange
                    elseif mcdu_dep ~= nil and mcdu_dest ~= nil then
                        mcdu_l_R[1] = mcdu_dep .. "/" .. mcdu_dest
                        mcdu_l_R_cl[1] = mcdu_blue
        end
        mcdu_s_R[4] = "LONG"
        if mcdu_init_status == 0 then
            mcdu_l_R[4] = "----.-"
            mcdu_l_R_cl[4] = mcdu_white
        elseif mcdu_init_status == 1 then
            if init_long ~= nil then
                mcdu_l_R[4] = init_long
                mcdu_l_R_cl[4] = mcdu_blue
            end
        end
    end

    --f-pln index
    if get(mcdu_page) == 2 then
        mcdu_fpln()
    end
end

--drawing the MCDU display
function draw()
    if get(mcdu_enabled) == 1 then
        sasl.gl.drawRectangle(0, 0, 320 , 285, mcdu_black)
        --draw title line
        sasl.gl.drawText(B612MONO_regular, size[1]/2-140, size[2]/2+108, mcdu_title_L , 20, false, false,TEXT_ALIGN_LEFT,   mcdu_title_L_cl)
        sasl.gl.drawText(B612MONO_regular, size[1]/2,     size[2]/2+108, mcdu_title_M , 20, false, false,TEXT_ALIGN_CENTER, mcdu_title_M_cl)
        sasl.gl.drawText(B612MONO_regular, size[1]/2+140, size[2]/2+108, mcdu_title_R , 20, false, false,TEXT_ALIGN_RIGHT,  mcdu_title_R_cl)
        --draw all horizontal lines
        for draw_lines = 1, 6, 1 do
        --draw left section
        sasl.gl.drawText(B612MONO_regular, size[1]/2-140, size[2]/2+mcdu_s_ypos[draw_lines],  mcdu_s_L[draw_lines], 12, false, false,TEXT_ALIGN_LEFT,   mcdu_s_L_cl[draw_lines])
        sasl.gl.drawText(B612MONO_regular, size[1]/2-140, size[2]/2+mcdu_l_ypos[draw_lines],  mcdu_l_L[draw_lines], 20, false, false,TEXT_ALIGN_LEFT,   mcdu_l_L_cl[draw_lines])
        --draw center section
        sasl.gl.drawText(B612MONO_regular, size[1]/2,     size[2]/2+mcdu_s_ypos[draw_lines],  mcdu_s_M[draw_lines], 12, false, false,TEXT_ALIGN_CENTER, mcdu_s_M_cl[draw_lines])
        sasl.gl.drawText(B612MONO_regular, size[1]/2,     size[2]/2+mcdu_l_ypos[draw_lines],  mcdu_l_M[draw_lines], 20, false, false,TEXT_ALIGN_CENTER, mcdu_l_M_cl[draw_lines])
        --draw right section
        sasl.gl.drawText(B612MONO_regular, size[1]/2+140, size[2]/2+mcdu_s_ypos[draw_lines],  mcdu_s_R[draw_lines], 12, false, false,TEXT_ALIGN_RIGHT,  mcdu_s_R_cl[draw_lines])
        sasl.gl.drawText(B612MONO_regular, size[1]/2+140, size[2]/2+mcdu_l_ypos[draw_lines],  mcdu_l_R[draw_lines], 20, false, false,TEXT_ALIGN_RIGHT,  mcdu_l_R_cl[draw_lines])
        end

        --drawing entry line
        if mcdu_message_active == 0 then
            sasl.gl.drawText(B612MONO_regular, size[1]/2-140, size[2]/2-132, mcdu_entry, 20, false, false, TEXT_ALIGN_LEFT, mcdu_white)
        end

        if mcdu_message_active == 1 then
            if #mcdu_messages > 0 then
                sasl.gl.drawText(B612MONO_regular, size[1]/2-140, size[2]/2-132, mcdu_messages[#mcdu_messages], 20, false, false, TEXT_ALIGN_LEFT, mcdu_white)
            end
        end
    end
end