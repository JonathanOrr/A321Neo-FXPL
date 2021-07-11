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


local THIS_PAGE = MCDU_Page:new({id=403})

local function format_wind_fl(data)
  return mcdu_wind_to_str(data.dir, data.spd).." "..mcdu_fl_to_str(data.fl)
end

local function parse_wind_str(wind_str)
  _, _, dir, spd, fl = string.find(wind_str, "^(%d+)/(%d+)/(%d+)$")
  return tonumber(dir), tonumber(spd), tonumber(fl)
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "CLIMB WIND")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "TRU WIND/ALT", MCDU_SMALL, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "HISTORY", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "WIND", MCDU_LARGE, ECAM_WHITE)
    local cruise_winds = FMGS_winds_get_winds(FMGS_PHASE_CLIMB)
    for i = 1,5 do
      local winds = cruise_winds[i]
      if winds ~= nil then
        local fmt_wind = format_wind_fl(winds)
        self:set_line(mcdu_data, MCDU_LEFT, i, fmt_wind, MCDU_LARGE, ECAM_BLUE)
      else
        self:set_line(mcdu_data, MCDU_LEFT, i, "[ ]°/[ ]/[   ]", MCDU_LARGE, ECAM_BLUE)
        break
      end
    end
end

local function input_winds(mcdu_data, i)
  if mcdu_data.clr then
    FMGS_winds_clear_wind(FMGS_PHASE_CLIMB, i)
    mcdu_data.clr = false
    mcdu_send_message(mcdu_data, "")
    return
  end
  local input = mcdu_get_entry_simple(mcdu_data, {"###/###/###", "###/##/###"}, false)
  if input == nil then
    --   MCDU.send_message(mcdu_data, "INVALID INPUT")
    return
  end
  if FMGS_sys.data.winds[FMGS_PHASE_CLIMB][i] ~= nil then
    mcdu_send_message(mcdu_data, "FORMAT ERROR")
    print("FORMAT ERROR")
  else
    FMGS_winds_set_wind(FMGS_PHASE_CLIMB, parse_wind_str(input))
  end
end

function THIS_PAGE:L1(mcdu_data)
  input_winds(mcdu_data, 1)
end

function THIS_PAGE:L2(mcdu_data)
  input_winds(mcdu_data, 2)
end

function THIS_PAGE:L3(mcdu_data)
  input_winds(mcdu_data, 3)
end

function THIS_PAGE:L4(mcdu_data)
  input_winds(mcdu_data, 4)
end

function THIS_PAGE:L5(mcdu_data)
  input_winds(mcdu_data, 5)
end

function THIS_PAGE:R1(mcdu_data)
  -- MCDU.send_message(mcdu_data, "350-53-350")
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
