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
local THIS_PAGE = MCDU_Page:new({id=303})

function THIS_PAGE:render(mcdu_data)
    ----------
    --  L1  --
    ----------

    local climb_mode = true and "MANAGED" or "SELECTED"
    self:set_line(mcdu_data, MCDU_LEFT, 1, "ACT MODE", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, climb_mode, MCDU_LARGE, ECAM_GREEN)

    ----------
    --  L2  --
    ----------
    self:set_line(mcdu_data, MCDU_LEFT, 2, " CI", MCDU_SMALL, ECAM_WHITE)
    if FMGS_sys.fpln.active.apts.dep == nil or FMGS_sys.fpln.active.apts.arr == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "---", MCDU_LARGE)
    elseif FMGS_sys.data.init.cost_index == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "___", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 2, FMGS_sys.data.init.cost_index, MCDU_LARGE, ECAM_BLUE)
    end
    
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE