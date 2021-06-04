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

function getAlignTTN(i)
  return math.max(0, IR_TIME_TO_GET_ATTITUDE - (get(TIME) - ADIRS_sys[i].ir_align_start_time))
end

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "IRS MONITOR")

    -- self:set_line(mcdu_data, MCDU_LEFT, 4, "PAGE NOT YET IMPLEMENTED", MCDU_LARGE, ECAM_MAGENTA)
    self:set_line(mcdu_data, MCDU_LEFT, 1, "<IRS1", MCDU_LARGE, ECAM_WHITE)
    if ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_IN_ALIGN then
      self:set_line(mcdu_data, MCDU_LEFT, 2, " ALIGN TTN " .. getAlignTTN(ADIRS_1), MCDU_SMALL, ECAM_WHITE)
    elseif ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_ALIGNED then
      self:set_line(mcdu_data, MCDU_LEFT, 2, " NAV", MCDU_SMALL, ECAM_GREEN)
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
