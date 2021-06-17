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

local irs_details = {ADIRS_1, ADIRS_2, ADIRS_3}
for k, irs in ipairs(irs_details) do
    local THIS_PAGE = MCDU_Page:new({id=530+irs})

    function THIS_PAGE:render(mcdu_data)
        self:set_title(mcdu_data, "IRS"..irs)

        self:set_line(mcdu_data, MCDU_LEFT, 1, "POSITION", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 1, mcdu_lat_lon_to_str(ADIRS_sys[irs].lat, ADIRS_sys[irs].lon), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "TTRK", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, mcdu_pad_dp(ADIRS_sys[irs].track, 1), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 3, "THDG", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 3, mcdu_pad_dp(ADIRS_sys[irs].true_hdg, 1), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "WIND", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, mcdu_wind_to_str(ADIRS_sys[irs].wind_dir, ADIRS_sys[irs].wind_spd), MCDU_LARGE, ECAM_GREEN)

        self:set_line(mcdu_data, MCDU_RIGHT, 2, "GS", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, math.floor(ADIRS_sys[irs].gs), MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "MHDG", MCDU_SMALL, ECAM_WHITE)
        if ADIRS_sys[irs].adirs_switch_status == ADIRS_CONFIG_ATT then
            self:set_line(mcdu_data, MCDU_RIGHT, 3, mcdu_pad_dp(ADIRS_sys[irs].manual_hdg, 1), MCDU_LARGE, ECAM_GREEN)
        else
            self:set_line(mcdu_data, MCDU_RIGHT, 3, mcdu_pad_dp(ADIRS_sys[irs].hdg, 1), MCDU_LARGE, ECAM_GREEN)
        end

        if mcdu_data.irs_frozen ~= nil and mcdu_data.irs_frozen[irs] ~= nil then
            print("looks like we are frozen...")
            self:set_line(mcdu_data, MCDU_LEFT, 6, "<UNFREEZE", MCDU_LARGE, ECAM_BLUE)
            self:set_multi_title(mcdu_data, {
                {txt="IRS"..ADIRS_sys[irs].id.." FROZEN "..mcdu_format_force_to_small("AT "), col=ECAM_WHITE, size=MCDU_LARGE},
                {txt="1446", col=ECAM_GREEN, size=MCDU_LARGE},            
            })

        else
            self:set_line(mcdu_data, MCDU_LEFT, 6, "<FREEZE", MCDU_LARGE, ECAM_BLUE)
        end
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT IRS>", MCDU_LARGE, ECAM_WHITE)
    end

    function THIS_PAGE:L6(mcdu_data)
        mcdu_send_message(mcdu_data, "NOT IMPLEMENTED")
    end
    -- function THIS_PAGE:L6(mcdu_data)
    --     if mcdu_data.irs_frozen == nil then
    --         mcdu_data.irs_frozen = {}
    --     end
    --     if mcdu_data.irs_frozen[irs] ~= nil then
    --         mcdu_data.irs_frozen[irs] = nil
    --     else
    --         if mcdu_data.irs_frozen[irs] == nil then
    --             mcdu_data.irs_frozen[irs] = {{freeze_time=get(TIME)}}
    --         end
    --         for i, x in ipairs(ADIRS_sys[irs]) do
    --             mcdu_data.irs_frozen[irs][i] = x
    --         end
    --     end
    -- end

    function THIS_PAGE:R6(mcdu_data)
        local nextIrs = 530 + (irs == 3 and 1 or irs+1)
        mcdu_open_page(mcdu_data, nextIrs)
    end

    mcdu_pages[THIS_PAGE.id] = THIS_PAGE
end