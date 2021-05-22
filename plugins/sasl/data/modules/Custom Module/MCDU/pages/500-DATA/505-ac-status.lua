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

local THIS_PAGE = MCDU_Page:new({id=505})


function THIS_PAGE:render(mcdu_data)

    self:set_title(mcdu_data, "A321-271NX")

    self:set_line(mcdu_data, MCDU_LEFT, 1, "ENG",         MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 1, "PW-1133G", MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_LEFT, 2, "ACTIVE DATA BASE", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "XP DEFAULT",      MCDU_LARGE, ECAM_BLUE)
    self:set_line(mcdu_data, MCDU_RIGHT,2, "NW93821172",       MCDU_LARGE, ECAM_GREEN)

    self:set_line(mcdu_data, MCDU_LEFT, 3, "SECOND DATA BASE", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "N/A",              MCDU_LARGE, ECAM_BLUE)

    self:set_line(mcdu_data, MCDU_LEFT, 4, "DO NOT USE MCDU", MCDU_SMALL, ECAM_RED)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "DEVELOPMENT IN PROGRESS", MCDU_LARGE, ECAM_RED)

    if FMGS_sys.config.phase == FMGS_PHASE_PREFLIGHT or FMGS_sys.config.phase == FMGS_PHASE_DONE then
        self:set_line(mcdu_data, MCDU_LEFT, 5, "CHG CODE", MCDU_SMALL)
        local content = "   "
        if mcdu_data.v.chg_code_unlocked then
            content = "***"
        end
        self:set_line(mcdu_data, MCDU_LEFT, 5, "[".. content .. "]",    MCDU_LARGE, ECAM_BLUE)
    end

    self:set_line(mcdu_data, MCDU_LEFT, 6, "IDLE/PERF", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "+0.0/+0.0", MCDU_LARGE, mcdu_data.v.chg_code_unlocked and ECAM_BLUE or ECAM_GREEN)


    self:set_line(mcdu_data, MCDU_RIGHT, 6, "SOFTWARE",      MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "STATUS/XLOAD>", MCDU_LARGE)

end

function THIS_PAGE:L5(mcdu_data)
    if mcdu_data.v.chg_code_unlocked then
        mcdu_data.v.chg_code_unlocked = false
        return 
    end

    local input = mcdu_get_entry(mcdu_data, {"word", length = 3, dp = 0})
    if input == "A32" then
        mcdu_data.v.chg_code_unlocked = true
    else
        mcdu_data.v.chg_code_unlocked = false
        mcdu_send_message(mcdu_data, "INVALID CODE")
    end
end

function THIS_PAGE:R6(mcdu_data)
    mcdu_open_page(mcdu_data, 507)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
