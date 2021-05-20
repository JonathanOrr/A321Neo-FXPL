
local THIS_PAGE = MCDU_Page:new({id=501})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "DATA INDEX")
    self:set_subpages(mcdu_data, 2, 2)
    MCDU_Page:set_lr_arrows(mcdu_data, true)

    self:set_line(mcdu_data, MCDU_LEFT, 1, "<WAYPOINTS", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 2, "<NAVAIDS", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 3, "<RUNWAYS", MCDU_LARGE)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "<ROUTES", MCDU_LARGE)

end


function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 500)
end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 500)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
