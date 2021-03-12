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
-- File: DRAIMS_handlers.lua 
-- Short description: Radio panel command handlers
-------------------------------------------------------------------------------

include("DRAIMS/constants.lua")

local BTN_L1 = 1
local BTN_L2 = 2
local BTN_L3 = 3
local BTN_L4 = 4
local BTN_R1 = 5
local BTN_R2 = 6
local BTN_R3 = 7
local BTN_R4 = 8

local BTN_TCAS_L = 1
local BTN_TCAS_R = 2

local BTN_ARROW_UP = 1
local BTN_ARROW_DN = 2

local BTN_DOT = 10
local BTN_CLR = 11

local BTN_VHF_1_RECV  = 1
local BTN_VHF_1_TRANS = 2
local BTN_VHF_2_RECV  = 3
local BTN_VHF_2_TRANS = 4
local BTN_VHF_3_RECV  = 5
local BTN_VHF_3_TRANS = 6
local BTN_NAV_RECV    = 7


local function handler_page_button(data, which_btn)
    data.current_page = which_btn
end

local function handler_lat_button(data, which_btn)

end

local function handler_tcas_button(data, which_btn)

end

local function handler_num_button(data, which_btn)

end

local function handler_arrows(data, which_btn)

end

local function handler_trans_recv(data, which_btn)

end

local command_list = {

    -- Page buttons
    ["vhf_button"] = function(data) handler_page_button(data, PAGE_VHF) end,
    ["hf_button"]  = function(data) handler_page_button(data,  PAGE_HF) end,
    ["tel_button"] = function(data) handler_page_button(data, PAGE_TEL) end,
    ["atc_button"] = function(data) handler_page_button(data, PAGE_ATC) end,
    ["menu_button"]= function(data) handler_page_button(data, PAGE_MENU) end,
    ["nav_button"] = function(data) handler_page_button(data, PAGE_NAV) end,

    -- Lateral buttons
    ["left_1"] = function(data) handler_lat_button(data, BTN_L1) end,
    ["left_2"] = function(data) handler_lat_button(data, BTN_L2) end,
    ["left_3"] = function(data) handler_lat_button(data, BTN_L3) end,
    ["left_4"] = function(data) handler_lat_button(data, BTN_L4) end,
    ["right_1"] = function(data) handler_lat_button(data, BTN_R1) end,
    ["right_2"] = function(data) handler_lat_button(data, BTN_R2) end,
    ["right_3"] = function(data) handler_lat_button(data, BTN_R3) end,
    ["right_4"] = function(data) handler_lat_button(data, BTN_R4) end,

    -- TCAS
    ["tcas_l"] = function(data) handler_tcas_button(data, BTN_TCAS_L) end,
    ["tcas_r"] = function(data) handler_tcas_button(data, BTN_TCAS_R) end,

    -- Arrows
    ["arrow_up"]  = function(data) handler_arrows(data, BTN_ARROW_UP) end,
    ["arrow_dn"]  = function(data) handler_arrows(data, BTN_ARROW_DN) end,

    -- Numbers
    ["num_0"] = function(data) handler_num_button(data, 0) end,
    ["num_1"] = function(data) handler_num_button(data, 1) end,
    ["num_2"] = function(data) handler_num_button(data, 2) end,
    ["num_3"] = function(data) handler_num_button(data, 3) end,
    ["num_4"] = function(data) handler_num_button(data, 4) end,
    ["num_5"] = function(data) handler_num_button(data, 5) end,
    ["num_6"] = function(data) handler_num_button(data, 6) end,
    ["num_7"] = function(data) handler_num_button(data, 7) end,
    ["num_8"] = function(data) handler_num_button(data, 8) end,
    ["num_9"] = function(data) handler_num_button(data, 9) end,
    ["num_DOT"] = function(data) handler_num_button(data, BTN_DOT) end,
    ["num_CLR"] = function(data) handler_num_button(data, BTN_CLR) end,

    ["vhf1_recv"]    = function(data) handler_trans_recv(data, BTN_VHF_1_RECV) end,
    ["vhf1_transmit"]= function(data) handler_trans_recv(data, BTN_VHF_1_TRANS) end,
    ["vhf2_recv"]    = function(data) handler_trans_recv(data, BTN_VHF_2_RECV) end,
    ["vhf2_transmit"]= function(data) handler_trans_recv(data, BTN_VHF_2_TRANS) end,
    ["vhf3_recv"]    = function(data) handler_trans_recv(data, BTN_VHF_3_RECV) end,
    ["vhf3_transmit"]= function(data) handler_trans_recv(data, BTN_VHF_3_TRANS) end,
    ["nav_recv"]     = function(data) handler_trans_recv(data, BTN_NAV_RECV) end


}

function draims_init_handlers(data)

    local prefix = data.id == DRAIMS_ID_CAPT and "capt_" or "fo_"

    for k,v in pairs(command_list) do
        local cmd_name = "a321neo/cockpit/draims/" .. prefix .. k
        local cmd = sasl.createCommand(cmd_name,"")
        sasl.registerCommandHandler(cmd, 0, function(phase) if phase == SASL_COMMAND_BEGIN then v(data) end end)
    end

end


