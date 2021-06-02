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


local THIS_PAGE = MCDU_Page:new({id=500})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "DATA INDEX")
    self:set_subpages(mcdu_data, 1, 2)
    MCDU_Page:set_lr_arrows(mcdu_data, true)
    
    self:set_line(mcdu_data, MCDU_LEFT, 1, "POSITION", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 1, "<MONITOR", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "IRS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<MONITOR", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "GPS", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "<MONITOR", MCDU_LARGE)
    
    self:set_line(mcdu_data, MCDU_LEFT, 4, "<A/C STATUS", MCDU_LARGE)

    self:set_line(mcdu_data, MCDU_LEFT, 5, "CLOSEST", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "<AIRPORTS", MCDU_LARGE)

    self:set_line(mcdu_data, MCDU_LEFT, 6, "EQUITIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "<POINTS", MCDU_LARGE)

    self:set_line(mcdu_data, MCDU_RIGHT, 6, "ACARS/PRINT", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "FUNCTION>", MCDU_LARGE)
end


function THIS_PAGE:L1(mcdu_data)
    mcdu_open_page(mcdu_data, 502)
end

function THIS_PAGE:L2(mcdu_data)
    mcdu_open_page(mcdu_data, 503)
end

function THIS_PAGE:L3(mcdu_data)
    mcdu_open_page(mcdu_data, 504)
end


function THIS_PAGE:L4(mcdu_data)
    mcdu_open_page(mcdu_data, 505)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 501)
end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 501)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
