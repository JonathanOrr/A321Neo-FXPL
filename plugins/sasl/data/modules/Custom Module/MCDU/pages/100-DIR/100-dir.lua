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

local THIS_PAGE = MCDU_Page:new({id=100})



-------------SO HOW DO I USE THIS DUMMY SCRIPT?
--- LETS SAY THE USER DIRECTS TO A PONT
-- USE FMGS_dirto_get_direct_to_waypoint() TO ENTER THE NAME OF tHE WAYPOINT THAT THE USER DIRECTED TO
-- SEE HONEYWELL MANUAL 2009 PAGE 243
-- AFTER THE USER DECIDES TO DIRECT TO A WAYPOINT, FLIGHTPLAN IS DISPLAYED STARTING FROM PAGE 3

-- IF THE USER HAS NOT DECIDED TO DIRECT TO A WAYPOINT YET, FLIGHTPLAN IS DISPLAYED ON LINE TWO

-- REMEMBER TO SET ALL THE DIRTO, ABEAM ETC TO NIL AFTER THE DIRECTING PROCCESS


function THIS_PAGE:render(mcdu_data)

    local aircraft_position_is_valid = true --RICO HELP ME FIX THIS, MANUAL PAGE 243

    if not aircraft_position_is_valid then
        mcdu_send_message(mcdu_data, "A/C POSITION INVALID")
        mcdu_open_page(mcdu_data, 600)
        return
    end

    self:set_multi_title(mcdu_data, {
        {txt=Fwd_string_fill(FMGS_init_get_flt_nbr() and FMGS_init_get_flt_nbr() or "", " ", 20) .. "  ", col=ECAM_WHITE, size=MCDU_SMALL}
    })


    if FMGS_dirto_get_direct_to_waypoint() == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 1, " DIR TO", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 1, "*[     ]", MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_LEFT, 2, " RICO DISPLAY FLIGHTPLAN", MCDU_SMALL, ECAM_MAGENTA) -------------------RICO HERE!!!!!!!!!!
        self:set_line(mcdu_data, MCDU_LEFT, 3, " STARTING FROM LINE 2", MCDU_SMALL, ECAM_MAGENTA)


    else
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "RADIAL IN  ", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 1, FMGS_dirto_get_inbound_radial() ~= nil and tostring(FMGS_dirto_get_inbound_radial()).."° *" or "[ ]° *", MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_RIGHT, 2, "RADIAL OUT ", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, FMGS_dirto_get_outbound_radial() ~= nil and tostring(FMGS_dirto_get_outbound_radial()).."° *" or "[ ]° *", MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_LEFT, 1, " DIR TO", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 1, "*"..FMGS_dirto_get_direct_to_waypoint(), MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_LEFT, 2, "  WITH", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "*ABEAM PTS", MCDU_LARGE, ECAM_BLUE)

        self:set_line(mcdu_data, MCDU_LEFT, 3, " RICO DISPLAY FLIGHTPLAN", MCDU_SMALL, ECAM_MAGENTA) -------------------RICO HERE!!!!!!!!!!
        self:set_line(mcdu_data, MCDU_LEFT, 4, " STARTING FROM LINE 3", MCDU_SMALL, ECAM_MAGENTA)
    end
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
