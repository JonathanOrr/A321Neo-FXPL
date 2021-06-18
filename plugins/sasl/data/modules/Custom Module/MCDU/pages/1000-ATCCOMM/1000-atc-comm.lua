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


local THIS_PAGE = MCDU_Page:new({id=1000})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "ATSU DATALINK")

    
    self:set_line(mcdu_data, MCDU_LEFT, 4, "PAGE NOT YET IMPLEMENTED", MCDU_LARGE, ECAM_MAGENTA)

    self:new_multi_line(mcdu_data, MCDU_LEFT, 2, MCDU_LARGE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "GREEN", MCDU_LARGE, ECAM_GREEN)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "      RED", MCDU_LARGE, ECAM_RED)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "          BLUE", MCDU_LARGE, ECAM_BLUE)
    self:add_multi_line(mcdu_data, MCDU_LEFT, 2, "               MAGENTA", MCDU_LARGE, ECAM_MAGENTA)

end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
