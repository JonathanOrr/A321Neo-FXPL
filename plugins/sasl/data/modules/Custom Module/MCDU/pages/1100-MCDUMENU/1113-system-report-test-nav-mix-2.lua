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


local THIS_PAGE = MCDU_Page:new({id=1113})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "NAV - MIX")
    self:set_lr_arrows(mcdu_data, true)
    
    self:set_line(mcdu_data, MCDU_LEFT, 1, "AVG PITCH", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, Round(adirs_get_avg_pitch(),1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "AVG ROLL", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, Round(adirs_get_avg_roll(),1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "AVG VPATH", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, Round(adirs_get_avg_vpath(),1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 2, "AVG TRACK", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, Round(adirs_get_avg_track(),1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_LEFT, 3, "AVG HDG", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, Round(adirs_get_avg_hdg(),1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, "AVG T.HDG", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, Round(adirs_get_avg_true_hdg(),1), MCDU_LARGE, ECAM_GREEN)


    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)

end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1111)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 1112)
end
function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 1112)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
