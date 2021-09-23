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


local THIS_PAGE = MCDU_Page:new({id="11045_2_"})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "APU")
    MCDU_Page:set_lr_arrows(mcdu_data, true)

    self:set_line(mcdu_data, MCDU_LEFT, 1, "<APU DATA/OIL", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<CLASS 3 FAULTS", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)


end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, "11045_")
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, "11045_2")
end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, "11045_2")
end
mcdu_pages[THIS_PAGE.id] = THIS_PAGE
