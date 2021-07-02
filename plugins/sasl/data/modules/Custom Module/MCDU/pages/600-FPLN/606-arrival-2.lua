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


local THIS_PAGE = MCDU_Page:new({id=606})


function THIS_PAGE:render(mcdu_data)
    assert(mcdu_data.lat_rev_subject and mcdu_data.lat_rev_subject.type == 4)

    if not mcdu_data.page_data[606] then
        mcdu_data.page_data[606] = {}
    end

    mcdu_data.page_data[606].main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    mcdu_data.page_data[606].curr_fpln = FMGS_get_current_fpln()

    self:set_lr_arrows(mcdu_data, true)

    local subject_id = mcdu_data.lat_rev_subject.data.id

    self:set_multi_title(mcdu_data, {
        {txt="  ARRIVAL " .. mcdu_format_force_to_small("TO").."         ", col=ECAM_WHITE, size=MCDU_LARGE},
        {txt="          " .. subject_id, col=ECAM_GREEN, size=MCDU_LARGE}
    })

    -------------------------------------
    -- STATIC
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, " APPR", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "STAR ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 1, "VIA", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "TRANS ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, " APPR", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<VIAS", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "STARS  AVAILABLE   TRANS", MCDU_SMALL)

    if FMGS_does_temp_fpln_exist() then
        self:set_line(mcdu_data, MCDU_LEFT, 6, "←ERASE", MCDU_LARGE, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "INSERT*", MCDU_LARGE, ECAM_ORANGE)
    end

    -------------------------------------
    -- DYNAMIC
    -------------------------------------
    self:render_top_data(mcdu_data)

end

function THIS_PAGE:render_top_data(mcdu_data)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    local appr_name = dest_get_selected_appr_procedure()
    self:set_line(mcdu_data, MCDU_LEFT,  1, appr_name and appr_name or "------", MCDU_LARGE, appr_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "------", MCDU_LARGE, main_col)
    self:set_line(mcdu_data, MCDU_CENTER,1, " ------", MCDU_LARGE, main_col)
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "------", MCDU_LARGE,  main_col)

end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 605)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 605)
end

function THIS_PAGE:L6(mcdu_data)
    FMGS_erase_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end

function THIS_PAGE:R6(mcdu_data)
    FMGS_insert_temp_fpln()
    mcdu_open_page(mcdu_data, 600)
end

mcdu_pages[THIS_PAGE.id] = THIS_PAGE
