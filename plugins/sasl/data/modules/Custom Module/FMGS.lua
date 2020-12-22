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
-- File: FMGS.lua 
-- Short description: Flight Management Guidance System implementation.
--                    This is a helper file, used by MCDU.lua
-------------------------------------------------------------------------------

include('FMGS_parser.lua') -- Reads and parses FMGS data
include('FMGS_f-pln.lua') -- Flight Management and planning implementation

--[[
--
--
--      DATA & COMMAND REGISTERATION
--
--
--]]

fmgs_dat = {}

fmgs_debug_pointer = createGlobalPropertys("a321neo/debug/fmgs/fmgs_pointer")
fmgs_debug_dat = createGlobalPropertys("a321neo/debug/fmgs/fmgs_dat")

fmgs_debug_get = sasl.createCommand("a321neo/debug/fmgs/get_data", "retrieve FMGS data from pointer a321neo/cockpit/mdu/fmgs_debug_pointer to a321neo/cockpit/fmgs/fmgs_debug_dat")
fmgs_debug_set = sasl.createCommand("a321neo/debug/fmgs/set_data", "inject FMGS data from pointer a321neo/cockpit/mdu/fmgs_debug_pointer to a321neo/cockpit/fmgs/fmgs_debug_dat")

--debugging
sasl.registerCommandHandler(fmgs_debug_get, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        print("FMGS DEBUG get " .. fmgs_dat[get(fmgs_debug_pointer)])
        set(fmgs_debug_dat, fmgs_dat[get(fmgs_debug_pointer)])
        fmgs_open_page(get(fmgs_page))
    end
end)
sasl.registerCommandHandler(fmgs_debug_set, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        print("FMGS DEBUG set " .. fmgs_dat[get(fmgs_debug_pointer)])
        fmgs_dat[get(fmgs_debug_pointer)] = get(fmgs_debug_dat)
        fmgs_open_page(get(fmgs_page))
    end
end)



--[[
--
--
--      FMGS DATA INITIALIZATION
--
--
--]]

--init FMGS data to 2nd argument
function fmgs_dat_init(dat_name, dat_init)
    --is data uninitialised?
    if fmgs_dat[dat_name] == nil then
        fmgs_dat[dat_name] = dat_init
    end
end

--get FMGS data with initialisation
function fmgs_dat_get(dat_name, dat_init, dat_init_col, dat_set_col, dat_format_callback)
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
function fmgs_dat_get_txt(dat_name, dat_init, dat_format_callback)
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
