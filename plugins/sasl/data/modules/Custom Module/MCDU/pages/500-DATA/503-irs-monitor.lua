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


local THIS_PAGE = MCDU_Page:new({id=503})

function THIS_PAGE:calc(mcdu_data, i)
    self:set_line(mcdu_data, MCDU_LEFT, i, "<IRS" .. i, MCDU_LARGE, ECAM_WHITE)
    if ADIRS_sys[i].ir_status == IR_STATUS_IN_ALIGN then
      self:set_line(mcdu_data, MCDU_LEFT, i+1, " ALIGN TTN " .. ADIRS_sys[i]:get_align_ttn(), MCDU_SMALL, ECAM_GREEN)
    elseif ADIRS_sys[i].ir_status == IR_STATUS_ALIGNED then
      self:set_line(mcdu_data, MCDU_LEFT, i+1, string.format(" NAV   DRIFT  %.2fNM/H", ADIRS_sys[i].ir_drift), MCDU_SMALL, ECAM_GREEN)
    end
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "IRS MONITOR")

    self:calc(mcdu_data, ADIRS_1)
    self:calc(mcdu_data, ADIRS_2)
    self:calc(mcdu_data, ADIRS_3)

    if adirs_how_many_irs_in_align() > 0 then
      self:set_line(mcdu_data, MCDU_RIGHT, 5, "SET HDG", MCDU_SMALL, ECAM_WHITE)
      self:set_line(mcdu_data, MCDU_RIGHT, 5, mcdu_format_force_to_small("___.__"), MCDU_LARGE, ECAM_ORANGE)
    end
end

function THIS_PAGE:R5(mcdu_data)
  if adirs_how_many_irs_fully_work() == 3 then
    return
  end

  local input = mcdu_get_entry_simple(mcdu_data, {"###.##", "###.#", "###", "##.##", "##.#", "##", "#.##", "#.#", "#"}, false)
  if input == nil then
    MCDU.send_message(mcdu_data, "INVALID INPUT")
    return
  end
  input = tonumber(input)
  if input < 0 or input >= 360 then
    MCDU.send_message(mcdu_data, "ENTRY OUT OF RANGE")
    return
  end
  adirs_set_hdg(input)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
