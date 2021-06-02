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


local THIS_PAGE = MCDU_Page:new({id=700})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "RADIO NAV")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "VOR1/FREQ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "CRS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "ILS / FREQ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "CRS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "ADF1/FREQ", MCDU_SMALL)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "FREQ/VOR2", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "CRS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "GLS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "FREQ/ADF2", MCDU_SMALL)

    if get(DRAIMS_nav_stby_mode) == 0 then
        self:set_line(mcdu_data, MCDU_LEFT, 1, "[  ]/[  . ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "[  ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 3, "[  ]/[  . ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "[  ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_LEFT, 5, "[  ]/[  .]", MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_RIGHT, 1, "[  . ]/[  ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "[  ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_RIGHT, 4, "[     ]", MCDU_LARGE, ECAM_BLUE)
        self:set_line(mcdu_data, MCDU_RIGHT, 5, "[  .]/[  ]", MCDU_LARGE, ECAM_BLUE)
    end
    
    self:set_line(mcdu_data, MCDU_LEFT, 6, "PAGE NOT YET IMPLEMENTED", MCDU_LARGE, ECAM_MAGENTA)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
