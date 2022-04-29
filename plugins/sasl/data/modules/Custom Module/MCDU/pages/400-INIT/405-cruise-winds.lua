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


local THIS_PAGE = MCDU_Page:new({id=405})

function THIS_PAGE:render(mcdu_data)

    local legs = FMGS_get_enroute_legs()
    assert(#legs > 0)

    if not mcdu_data.page_data[405] then
        mcdu_data.page_data[405] = {    -- Reset by 404 and 406 at every entry point
            curr_id = 1
        }
    end

    local leg = legs[mcdu_data.page_data[405].curr_id]
    if not leg then -- Safety check
        leg = legs[1] -- This always exists
        mcdu_data.page_data[405].curr_id = 1
    end

    self:set_multi_title(mcdu_data, {
        {txt="  CRUISE WIND " .. mcdu_format_force_to_small("AT").."         ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="              " .. (leg.id or "UNKN"), col=ECAM_GREEN, size=MCDU_LARGE}
    })

    self:set_updn_arrows_bottom(mcdu_data, true)

    -- List of winds
    self:set_line(mcdu_data, MCDU_LEFT, 1, "TRU WIND/ALT", MCDU_SMALL, ECAM_WHITE)


    -- REQUEST
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "WIND", MCDU_SMALL, ECAM_ORANGE)
    if FMGS_winds_req_in_progress() then
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "REQUEST ", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "REQUEST*", MCDU_LARGE, ECAM_ORANGE)
    end

    -- PAGES
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "PREV", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "PHASE>", MCDU_LARGE, ECAM_WHITE)

    self:set_line(mcdu_data, MCDU_RIGHT, 5, "NEXT", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "PHASE>", MCDU_LARGE, ECAM_WHITE)
    
end

function THIS_PAGE:R2(mcdu_data)
    FMGS_winds_req_go()
end

function THIS_PAGE:R4(mcdu_data)
    mcdu_open_page(mcdu_data, 404)
end

function THIS_PAGE:R5(mcdu_data)
    mcdu_open_page(mcdu_data, 406)
end

function THIS_PAGE:Slew_Down(mcdu_data)
    mcdu_data.page_data[405].curr_id = (mcdu_data.page_data[405].curr_id - 1)
    if mcdu_data.page_data[405].curr_id == 0 then
        mcdu_data.page_data[405].curr_id = #FMGS_get_enroute_legs()
    end
end

function THIS_PAGE:Slew_Up(mcdu_data)
    mcdu_data.page_data[405].curr_id = (mcdu_data.page_data[405].curr_id) % (#FMGS_get_enroute_legs()) + 1
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
