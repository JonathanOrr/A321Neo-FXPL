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


local THIS_PAGE = MCDU_Page:new({id=1121})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, get(All_on_ground) == 1 and "LAST LEG ECAM REP" or "CURRENT LEG ECAM REP")

    self:set_line(mcdu_data, MCDU_RIGHT, 1, "DATE: " .. get(ZULU_month) .. "/" .. get(ZULU_day), MCDU_SMALL, ECAM_WHITE)


    if #MCDU.cfds_active_maintain_messages == 0 then
        self:set_line(mcdu_data, MCDU_LEFT, 3, "NO MESSAGES", MCDU_LARGE, ECAM_GREEN)
    end

    local line_n = 1

    for _,x in ipairs(MCDU.cfds_active_maintain_messages) do
        self:set_line(mcdu_data, MCDU_LEFT, line_n, "GMT " .. x[2] .. x[3], MCDU_LARGE, ECAM_WHITE)
        line_n = line_n + 1
        self:set_line(mcdu_data, MCDU_LEFT, line_n, x[1] .. " - " .. x[4], MCDU_SMALL, ECAM_ORANGE)
        if line_n == 6 then
            break
        end
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE, ECAM_WHITE)

end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 1101)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE

