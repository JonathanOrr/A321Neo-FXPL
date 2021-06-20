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

local THIS_PAGE = MCDU_Page:new({id=509})

local function has_pos_changed(last, pos)
    return true
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "CLOSEST AIRPORTS")
    
-- if current pos has changed significantly then
--   get nearest 4 airports
--   store current pos

    mcdu_data.nrst = mcdu_data.nrst or {}
    local acf_lat, acf_lon = get(Aircraft_lat), get(Aircraft_long)
    if has_pos_changed(mcdu_data.nrst.last, {lat=acf_lat, lon=acf_lon}) then
        if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
            local apts = AvionicsBay.apts.get_by_coords(acf_lat, acf_lon)

            for _,x in ipairs(apts) do
                local distance = GC_distance_kt(x.lat, x.lon, acf_lat, acf_lon)
                local brg = get_bearing(x.lat, x.lon, acf_lat, acf_lon)
            end
        end
    end
    mcdu_data.nrst.last = {lat=acf_lat, lon=acf_lon}
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE