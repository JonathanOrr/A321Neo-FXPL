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


local THIS_PAGE = MCDU_Page:new({id=300})


function THIS_PAGE:render(mcdu_data)
    if FMGS_sys.config.phase == FMGS_PHASE_PREFLIGHT or FMGS_sys.config.phase == FMGS_PHASE_DONE then
        mcdu_open_page(mcdu_data, 300 + FMGS_PHASE_TAKEOFF)
    else
        mcdu_open_page(mcdu_data, 300 + FMGS_sys.config.phase)
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
