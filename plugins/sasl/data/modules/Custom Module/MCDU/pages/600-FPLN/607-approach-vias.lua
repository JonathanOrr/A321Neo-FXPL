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


local THIS_PAGE = MCDU_Page:new({id=607})




function THIS_PAGE:render_via(mcdu_data)
    if not dest_get_selected_appr_procedure() then
        return -- No approach selected
    end
    
    local vias = FMGS_arr_get_available_vias(true)

    mcdu_data.page_data[607].via_references = {0,0,0}    -- These will contain the references for buttons

    local i = 0
    local n_line = 3
    local curr_page = mcdu_data.page_data[607].curr_page
    for idx,via in pairs(vias) do
        i = i + 1
        if i > 3 * (curr_page-1) and i <= 3 * (curr_page) then
            local arrow = false and " " or "←"
            local text = via.trans_name
            self:set_line(mcdu_data, MCDU_LEFT, n_line, arrow .. text, MCDU_LARGE, ECAM_BLUE)
            mcdu_data.page_data[606].star_references[n_line-2] = idx
            n_line = n_line + 1
        end
    end
    
end

function THIS_PAGE:render(mcdu_data)

    if not mcdu_data.page_data[607] then
        mcdu_data.page_data[607] = {}
        mcdu_data.page_data[607].via_references = {0,0,0}
        mcdu_data.page_data[607].curr_page = 1
    end

    mcdu_data.page_data[607].main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN
    mcdu_data.page_data[607].curr_fpln = FMGS_get_current_fpln()

    self:set_title(mcdu_data, "APPROACH VIAS")

    self:set_line(mcdu_data, MCDU_LEFT, 1, " APPR", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "STAR ", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_CENTER, 1, "VIA", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "APPR AVAILABLE", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "VIAS", MCDU_LARGE)


    self:set_line(mcdu_data, MCDU_LEFT, 6, "<RETURN", MCDU_LARGE)

    THIS_PAGE:render_top_data(mcdu_data)
    THIS_PAGE:render_via(mcdu_data)

end

function THIS_PAGE:render_top_data(mcdu_data)

    local main_col = FMGS_does_temp_fpln_exist() and ECAM_YELLOW or ECAM_GREEN

    local appr_name  = dest_get_selected_appr_procedure()
    local star_name  = FMGS_arr_get_star(true) and FMGS_arr_get_star(true).proc_name or nil
    local via_name   = FMGS_arr_get_via(true) and FMGS_arr_get_via(true).id or nil
    self:set_line(mcdu_data, MCDU_LEFT,  1, appr_name and appr_name or "------", MCDU_LARGE, appr_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_RIGHT, 1, star_name and star_name or "------", MCDU_LARGE, star_name and main_col or ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_CENTER,1, via_name and via_name or " ------", MCDU_LARGE, via_name and main_col or ECAM_WHITE)

end


function THIS_PAGE:L6(mcdu_data)
    mcdu_open_page(mcdu_data, 606)
end



mcdu_pages[THIS_PAGE.id] = THIS_PAGE
