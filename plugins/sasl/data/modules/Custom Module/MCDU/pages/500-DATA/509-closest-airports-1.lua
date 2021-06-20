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
  return Round(last.lat, 2) ~= Round(pos.lat, 2) and Round(last.lon, 2) ~= Round(pos.lon, 2)
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "CLOSEST AIRPORTS")

    mcdu_data.nrst = mcdu_data.nrst or { frozen = false, freeze_time = "0000" }

    local acf_lat, acf_lon = get(Aircraft_lat), get(Aircraft_long)
    if has_pos_changed(mcdu_data.nrst.last, {lat=acf_lat, lon=acf_lon}) then
        if not mcdu_data.nrst.frozen then
          if AvionicsBay.is_initialized() and AvionicsBay.is_ready() then
              local apts = AvionicsBay.apts.get_by_coords(acf_lat, acf_lon)

              for _,x in ipairs(apts) do
                  local distance = GC_distance_kt(x.lat, x.lon, acf_lat, acf_lon)
                  local brg = get_bearing(x.lat, x.lon, acf_lat, acf_lon)
                  x.distance = distance
                  x.brg = brg
              end
              table.sort(apts, function(a, b) return a.distance < b.distance end)

              for i,x in ipairs(apts) do
                if i > 4 then
                  break
                end
                print(x.id, x.distance, x.brg)
                mcdu_data.nrst[i] = x
              end
              self:set_line(mcdu_data, MCDU_LEFT, 6, "←FREEZE", MCDU_LARGE, ECAM_BLUE)
          end
        else
          self:set_line(mcdu_data, MCDU_LEFT, 6, "←UNFREEZE", MCDU_LARGE, ECAM_BLUE)
        end
    end

    self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_data.nrst[1].id, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_data.nrst[2].id, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_data.nrst[3].id, MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_data.nrst[4].id, MCDU_LARGE, ECAM_GREEN)
    mcdu_data.nrst.last = {lat=acf_lat, lon=acf_lon}
end

function THIS_PAGE:L6(mcdu_data)
  mcdu_data.nrst.frozen = not mcdu_data.nrst.frozen
  if mcdu_data.nrst.frozen then
    mcdu_data.nrst.freeze_time = Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2)..Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2)
  end
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
