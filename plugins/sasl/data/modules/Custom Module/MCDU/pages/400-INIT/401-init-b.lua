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


local THIS_PAGE = MCDU_Page:new({id=401})

function THIS_PAGE:render(mcdu_data)
    self:set_title(mcdu_data, "INIT")
    self:set_lr_arrows(mcdu_data, true)

    -------------------------------------
    -- LEFT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 1, "TAXI", MCDU_SMALL, ECAM_WHITE)
    self:set_line(mcdu_data, MCDU_LEFT, 1, FMGS_sys.fpln.init.weights.taxi_fuel, MCDU_LARGE, ECAM_BLUE)

    -------------------------------------
    -- RIGHT 1
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 1, "ZFW/ZFWCG", MCDU_SMALL, ECAM_WHITE)
    if FMGS_sys.fpln.init.weights.zfw == nil or FMGS_sys.fpln.init.weights.zfwcg == nil then
        self:set_line(mcdu_data, MCDU_RIGHT, 1, "___._/ __._", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 1, Round_fill(FMGS_sys.fpln.init.weights.zfw, 1) .. "/ " .. Round_fill(FMGS_sys.fpln.init.weights.zfwcg, 1), MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- LEFT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 2, "TRIP /TIME", MCDU_SMALL, ECAM_WHITE)
    if FMGS_sys.fpln.pred.trip_fuel == nil or FMGS_sys.fpln.pred.trip_time == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 2, "---.-/----", MCDU_LARGE, ECAM_WHITE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 2, Round_fill(FMGS_sys.fpln.pred.trip_fuel,1) .. "/" .. FMGS_sys.fpln.pred.trip_time, MCDU_LARGE, ECAM_BLUE)
    end


    -------------------------------------
    -- RIGHT 2
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 2, "BLOCK", MCDU_SMALL, ECAM_WHITE)
    if FMGS_sys.fpln.init.weights.block_fuel == nil then
        self:set_line(mcdu_data, MCDU_RIGHT, 2, "___._", MCDU_LARGE, ECAM_ORANGE)
    else
        self:set_line(mcdu_data, MCDU_RIGHT, 2, Round_fill(FMGS_sys.fpln.init.weights.block_fuel, 1), MCDU_LARGE, ECAM_BLUE)
    end
    
    -------------------------------------
    -- LEFT 3
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 3, "RTE RSV/%", MCDU_SMALL, ECAM_WHITE)
    if FMGS_sys.fpln.init.weights.rsv_fuel == nil then
        self:set_line(mcdu_data, MCDU_LEFT, 3, "---.-/" .. Round_fill(FMGS_sys.fpln.init.weights.rsv_fuel_perc,1), MCDU_LARGE, ECAM_BLUE)
    else
        self:set_line(mcdu_data, MCDU_LEFT, 3, Round_fill(FMGS_sys.fpln.init.weights.rsv_fuel,1) .. "/" .. Round_fill(FMGS_sys.fpln.init.weights.rsv_fuel_perc,1), MCDU_LARGE, ECAM_BLUE)
    end

    -------------------------------------
    -- RIGHT 3
    -------------------------------------
    if FMGS_sys.fpln.init.weights.zfw ~= nil and FMGS_sys.fpln.init.weights.zfwcg ~= nil then
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "FUEL ", MCDU_SMALL, ECAM_ORANGE)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "PLANNING→", MCDU_LARGE, ECAM_ORANGE)
    end
    
    -------------------------------------
    -- LEFT 4
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 4, "ALTN /TIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 4, "---.-/----", MCDU_LARGE)

    -------------------------------------
    -- RIGHT 4
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "TOW/   LW", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 4, "---.-/---.-", MCDU_LARGE)
    
    -------------------------------------
    -- LEFT 5
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 5, "FINAL/TIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 5, "---.-/----", MCDU_LARGE)

    -------------------------------------
    -- RIGHT 5
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "TRIP WIND", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 5, "HD000", MCDU_LARGE, ECAM_BLUE)

    -------------------------------------
    -- LEFT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_LEFT, 6, "MIN DEST FOB", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_LEFT, 6, "---.-", MCDU_LARGE)

    -------------------------------------
    -- RIGHT 6
    -------------------------------------
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "EXTRA/TIME", MCDU_SMALL)
    self:set_line(mcdu_data, MCDU_RIGHT, 6, "---.-/----", MCDU_LARGE)


end

function THIS_PAGE:Slew_Left(mcdu_data)
    mcdu_open_page(mcdu_data, 400)
end

function THIS_PAGE:Slew_Right(mcdu_data)
    mcdu_open_page(mcdu_data, 400)
end


mcdu_pages[THIS_PAGE.id] = THIS_PAGE
