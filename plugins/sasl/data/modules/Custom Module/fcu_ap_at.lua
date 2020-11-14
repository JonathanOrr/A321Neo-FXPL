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
-- File: fcu_ap_at.lua
-- Short description: Autoflight
-------------------------------------------------------------------------------

--sim datarefs
local efis_map_mode = globalProperty("sim/cockpit2/EFIS/map_mode") --0=approach,1=vor,2=map,3=nav,4=plan
local efis_is_HSI = globalProperty("sim/cockpit2/EFIS/map_mode_is_HSI")
local efis_weather = globalProperty("sim/cockpit2/EFIS/EFIS_weather_on")
local efis_TCAS = globalProperty("sim/cockpit2/EFIS/EFIS_tcas_on")
local efis_airport = globalProperty("sim/cockpit2/EFIS/EFIS_airport_on")
local efis_wpt = globalProperty("sim/cockpit2/EFIS/EFIS_fix_on")
local efis_vor = globalProperty("sim/cockpit2/EFIS/EFIS_vor_on")
local efis_ndb = globalProperty("sim/cockpit2/EFIS/EFIS_ndb_on")
local efis_nav1_voradf = globalProperty("sim/cockpit2/EFIS/EFIS_1_selection_pilot") --0=ADF1, 1=OFF, or 2=VOR1
local efis_nav2_voradf = globalProperty("sim/cockpit2/EFIS/EFIS_2_selection_pilot") --0=ADF1, 1=OFF, or 2=VOR1
local efis_range = globalProperty("sim/cockpit2/EFIS/map_range")

--a321neo datarefs
local a321neo_csrt_status = createGlobalPropertyi("a321neo/cockpit/efis/csrt_on", 0, false, true, false)
local a321neo_efis_mode = createGlobalPropertyi("a321neo/cockpit/efis/map_mode", 3, false, true, false) --defaults at ARC mode (0 ILS, 1 VOR, 2 NAV, 3 ARC, 4 PLAN)

--a321neo commands
local a321neo_csrt_toggle = sasl.createCommand("a321neo/cockpit/efis/csrt_toggle", "toggle csrt on EFIS")
local a321neo_wpt_toggle = sasl.createCommand("a321neo/cockpit/efis/wpt_toggle", "toggle wpt on EFIS")
local a321neo_vor_toggle = sasl.createCommand("a321neo/cockpit/efis/vor_toggle", "toggle vor on EFIS")
local a321neo_ndb_toggle = sasl.createCommand("a321neo/cockpit/efis/ndb_toggle", "toggle ndb on EFIS")
local a321neo_airport_toggle = sasl.createCommand("a321neo/cockpit/efis/airport_toggle", "toggle airport on EFIS")
local a321neo_efis_mode_up = sasl.createCommand("a321neo/cockpit/efis/efis_mode_up", "a321 efis mode up")
local a321neo_efis_mode_dn = sasl.createCommand("a321neo/cockpit/efis/efis_mode_dn", "a321 efis mode dn")

--a321neo command handler
sasl.registerCommandHandler(a321neo_csrt_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(a321neo_csrt_status) == 0 then
            set(a321neo_csrt_status, 1)
        else
            set(a321neo_csrt_status, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_wpt_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_wpt) == 0 then
            set(efis_airport, 0)
            set(efis_vor, 0)
            set(efis_ndb, 0)
            set(efis_wpt, 1)
        else
            set(efis_wpt, 0)
            set(efis_airport, 0)
            set(efis_vor, 0)
            set(efis_ndb, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_vor_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_vor) == 0 then
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_ndb, 0)
            set(efis_vor, 1)
        else
            set(efis_vor, 0)
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_ndb, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_ndb_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_ndb) == 0 then
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
            set(efis_ndb, 1)
        else
            set(efis_ndb, 0)
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_airport_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_airport) == 0 then
            set(efis_ndb, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
            set(efis_airport, 1)
        else
            set(efis_airport, 0)
            set(efis_ndb, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_efis_mode_up, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(a321neo_efis_mode, get(a321neo_efis_mode) + 1)
    end
end)

sasl.registerCommandHandler(a321neo_efis_mode_dn, 0, function (phase)
    if phase == SASL_COMMAND_BEGIN then
        set(a321neo_efis_mode, get(a321neo_efis_mode) - 1)
    end
end)

--custom function
function Math_clamp(val, min, max)
    if min > max then LogWarning("Min is larger than Max invalid") end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif val <= max and val >= min then
        return val
    end
end

--main logic
function onPlaneLoaded()
    --initiate
    set(a321neo_efis_mode, 3)
    set(efis_is_HSI, 1)
    set(efis_weather, 1)
    set(efis_TCAS, 1)
    set(a321neo_csrt_status, 0)
    set(efis_airport, 0)
    set(efis_wpt, 0)
    set(efis_vor, 0)
    set(efis_ndb, 0)
    set(efis_nav1_voradf, 0)
    set(efis_nav2_voradf, 0)
end

function update()
    set(efis_range, Math_clamp(get(efis_range), 1 , 6))
    set(a321neo_efis_mode, Math_clamp(get(a321neo_efis_mode), 0, 4))

    --customize efis modes
    if get(a321neo_efis_mode) == 0 then
        set(efis_map_mode, 0)
    end
    if get(a321neo_efis_mode) == 1 then
        set(efis_map_mode, 1)
    end
    if get(a321neo_efis_mode) == 2 then
        set(efis_map_mode, 3)
    end
    if get(a321neo_efis_mode) == 3 then
        set(efis_map_mode, 2)
    end
    if get(a321neo_efis_mode) == 4 then
        set(efis_map_mode, 4)
    end

end
