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
local THIS_PAGE = MCDU_Page:new({id = 509})

local function has_pos_changed(mcdu_data, pos)
    if mcdu_data.nrst[1] == nil then return true end
    return Round(mcdu_data.nrst.last.lat, 2) ~= Round(pos.lat, 2)
       and Round(mcdu_data.nrst.last.lon, 2) ~= Round(pos.lon, 2)
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "CLOSEST AIRPORTS")

    mcdu_data.nrst = mcdu_data.nrst or {
          frozen = false,
          freeze_time = "0000",
          last = {lat = 0, lon = 0}
      }

    local acf_lat, acf_lon = get(Aircraft_lat), get(Aircraft_long)
    if has_pos_changed(mcdu_data, {lat = acf_lat, lon = acf_lon}) then
        if not mcdu_data.nrst.frozen then
            if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
                local apts = AvionicsBay.apts.get_by_coords(acf_lat, acf_lon)

                for _, x in ipairs(apts) do
                    local distance = GC_distance_kt(x.lat, x.lon, acf_lat, acf_lon)
                    local brg = get_bearing(x.lat, x.lon, acf_lat, acf_lon)
                    x.distance = distance
                    x.brg = brg
                end
                table.sort(apts, function(a, b) return a.distance < b.distance end)

                for i, x in ipairs(apts) do
                    if i > 5 then break end
                    mcdu_data.nrst[i] = x
                end
            end
        end
    end

    self:set_line(mcdu_data, MCDU_LEFT, 1, "        BRG", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "DIST  UTC ", MCDU_SMALL, ECAM_WHITE)

    if mcdu_data.nrst[2] ~= nil then
        self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_data.nrst[2].id .. "    " .. string.format("%.0f°", tostring(mcdu_data.nrst[2].brg)), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 1, string.format("%.0f", tostring(mcdu_data.nrst[2].distance)) .. "      ", MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_data.nrst[3].id .. "    " .. string.format("%.0f°", tostring(mcdu_data.nrst[3].brg)), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, string.format("%.0f", tostring(mcdu_data.nrst[3].distance)) .. "      ", MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_data.nrst[4].id .. "    " .. string.format("%.0f°", tostring(mcdu_data.nrst[4].brg)), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, string.format("%.0f", tostring(mcdu_data.nrst[4].distance)) .. "      ", MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_data.nrst[5].id .. "    " .. string.format("%.0f°", tostring(mcdu_data.nrst[5].brg)), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 4, string.format("%.0f", tostring(mcdu_data.nrst[5].distance)) .. "      ", MCDU_LARGE, ECAM_GREEN)

        self:set_line(mcdu_data, MCDU_LEFT, 6, mcdu_data.nrst.frozen and "←UNFREEZE" or "←FREEZE", MCDU_LARGE, ECAM_BLUE)
    end
    mcdu_data.nrst.last = {lat = acf_lat, lon = acf_lon}
end

function THIS_PAGE:L6(mcdu_data)
    mcdu_data.nrst.frozen = not mcdu_data.nrst.frozen
    if mcdu_data.nrst.frozen then
        mcdu_data.nrst.freeze_time = Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2) .. Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2)
    end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
