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


local THIS_PAGE = MCDU_Page:new({id="11045c7"})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "NAV - MIX")
    self:set_lr_arrows(mcdu_data, true)
    
    self:set_line(mcdu_data, MCDU_LEFT, 1, "ADRs " .. adirs_how_many_adrs_work() .. " WORKING" , MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "FULL", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "IRs " .. adirs_how_many_irs_fully_work() .. " WORKING", MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "PARTIAL", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "IRs " .. adirs_how_many_irs_partially_work() .. " WORKING", MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_LEFT, 4, "AVG AOA", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, Round(adirs_get_avg_aoa(),1), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "AVG IAS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 5, math.floor(adirs_get_avg_ias()), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "AVG ALT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, math.floor(adirs_get_avg_alt()), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 2, "AVG VS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, math.floor(adirs_get_avg_vs()), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_RIGHT, 3, "AVG MACH", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 3, Round(adirs_get_avg_mach(),2), MCDU_LARGE, ECAM_GREEN)


    self:set_line(mcdu_data, MCDU_RIGHT, 4, "AVG TAS", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, math.floor(adirs_get_avg_tas()), MCDU_LARGE, ECAM_GREEN)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "AVG IAS TR", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, Round(adirs_get_avg_ias_trend(),1), MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT PAGE>", MCDU_LARGE, ECAM_WHITE)
end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, "11045c")
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, "11045c7_")
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, "11045c7_")
end
function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, "11045c7_")
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
