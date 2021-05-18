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
-- File: 505-ac-status.lua 
-------------------------------------------------------------------------------

THIS_PAGE = MCDU_Page:new()


function THIS_PAGE:render(mcdu_data)
        mcdu_data.title.txt = "TEST"

        mcdu_data.dat[MCDU_LARGE][MCDU_L][1].txt = "TEST"
		mcdu_data.dat[MCDU_LARGE][MCDU_L][6] = {txt = "        TEST", col = ECAM_ORANGE}
end




mcdu_pages[505] = THIS_PAGE
