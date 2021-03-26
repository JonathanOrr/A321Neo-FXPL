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
-- File: nav_updater.lua
-- Short description: Update the information of the NAV aids
-------------------------------------------------------------------------------

include('DRAIMS/radio_logic.lua')

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local UPDATE_INTERVAL = 0.25

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------
local last_update = 0

-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------
DRAIMS_common.radio = {}
DRAIMS_common.radio.vor = {nil, nil}
DRAIMS_common.radio.adf = {nil, nil}

-------------------------------------------------------------------------------
-- Helpers
-------------------------------------------------------------------------------
local function get_nearest_navaid(list)
    local min_distance = 999999999
    local min_distance_i = 0
    local acf_lat = get(Aircraft_lat)
    local acf_lon = get(Aircraft_long)
    for k,v in ipairs(list) do
        local distance = GC_distance_kt(acf_lat, acf_lon, v.lat, v.lon)
        if distance < min_distance then
            min_distance = distance
            min_distance_i = k
        end
    end
    
    assert(min_distance_i ~= 0) -- This is not possible
    return list[min_distance_i], min_distance
end

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------
local function update_vor_nearest(i)
    DRAIMS_common.radio.vor[i] = nil
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local frequency_int = Round(radio_vor_get_freq(i)*100, 0)
        local out = AvionicsBay.navaids.get_by_freq(NAV_ID_VOR, frequency_int, false)
        if #out > 0 then
            local nearest, dist_out = get_nearest_navaid(out)
            DRAIMS_common.radio.vor[i] = nearest
            DRAIMS_common.radio.vor[i].curr_distance = dist_out
        end
    end
end

local function update_adf_nearest(i)
    DRAIMS_common.radio.adf[i] = nil
    if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
        local frequency_int = math.floor(radio_adf_get_freq(i))
        local out = AvionicsBay.navaids.get_by_freq(NAV_ID_NDB, frequency_int, false)
        if #out > 0 then
            local nearest, dist_out = get_nearest_navaid(out)
            DRAIMS_common.radio.adf[i] = nearest
            DRAIMS_common.radio.adf[i].curr_distance = dist_out
        end
    end
end


-------------------------------------------------------------------------------
-- main update()
-------------------------------------------------------------------------------
function update()
    perf_measure_start("nav_updater:update()")
    if get(TIME) - last_update <= UPDATE_INTERVAL then
        return
    end

    last_update = get(TIME)
    
    update_vor_nearest(1)
    update_vor_nearest(2)
    update_adf_nearest(1)
    update_adf_nearest(2)
    
    perf_measure_stop("nav_updater:update()")
end
