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
local irs_data = {}

for k, irs in ipairs(irs_details) do
    local THIS_PAGE = MCDU_Page:new({id=530+irs})
    irs_data[irs] = {
        frozen = false,
        freeze_time = "0000",
        pos = "0000.0N/00000.0E",
        ttrack = 0.0,
        gs = 0.0,
        thdg = 0.0,
        mhdg = 0.0,
        wind = "---°/---"
    }

    function THIS_PAGE:render(mcdu_data)
        self:set_title(mcdu_data, "IRS"..irs)

        self:set_line(mcdu_data, MCDU_LEFT, 1, "POSITION", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 2, "TTRK", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 3, "THDG", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_LEFT, 4, "WIND", MCDU_SMALL, ECAM_WHITE)

        self:set_line(mcdu_data, MCDU_RIGHT, 2, "GS", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, "MHDG", MCDU_SMALL, ECAM_WHITE)
        self:set_line(mcdu_data, MCDU_RIGHT, 6, "NEXT IRS>", MCDU_LARGE, ECAM_WHITE)

        if not irs_data[irs].frozen then
            irs_data[irs].pos = mcdu_lat_lon_to_str(ADIRS_sys[irs].lat, ADIRS_sys[irs].lon)
            irs_data[irs].ttrack = mcdu_pad_dp(ADIRS_sys[irs].track, 1)
            irs_data[irs].thdg = mcdu_pad_dp(ADIRS_sys[irs].true_hdg, 1)
            irs_data[irs].wind = mcdu_wind_to_str(ADIRS_sys[irs].wind_dir, ADIRS_sys[irs].wind_spd)
            irs_data[irs].gs = math.floor(ADIRS_sys[irs].gs)

            if ADIRS_sys[irs].adirs_switch_status == ADIRS_CONFIG_ATT then
                irs_data[irs].mhdg = mcdu_pad_dp(ADIRS_sys[irs].manual_hdg, 1)
            else
                irs_data[irs].mhdg = mcdu_pad_dp(ADIRS_sys[irs].hdg, 1)
            end

            self:set_line(mcdu_data, MCDU_LEFT, 6, "←FREEZE", MCDU_LARGE, ECAM_BLUE)
        else
            -- TODO the freeze time needs to be in ECAM_GREEN
            self:set_multi_title(mcdu_data, {
                {txt="IRS"..ADIRS_sys[irs].id.." FROZEN "..mcdu_format_force_to_small("AT ")..irs_data[irs].freeze_time, col=ECAM_WHITE, size=MCDU_LARGE},
            })
            self:set_line(mcdu_data, MCDU_LEFT, 6, "←UNFREEZE", MCDU_LARGE, ECAM_BLUE)
        end
        self:set_line(mcdu_data, MCDU_LEFT, 1, irs_data[irs].pos, MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 2, irs_data[irs].ttrack, MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 3, irs_data[irs].thdg, MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_LEFT, 4, irs_data[irs].wind, MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 2, irs_data[irs].gs, MCDU_LARGE, ECAM_GREEN)
        self:set_line(mcdu_data, MCDU_RIGHT, 3, irs_data[irs].mhdg, MCDU_LARGE, ECAM_GREEN)
    end

    function THIS_PAGE:L6(mcdu_data)
        irs_data[irs].frozen = not irs_data[irs].frozen
        if irs_data[irs].frozen then
            irs_data[irs].freeze_time = Fwd_string_fill(tostring(get(ZULU_hours)), "0", 2)..Fwd_string_fill(tostring(get(ZULU_mins)), "0", 2)
        end
    end

    function THIS_PAGE:R6(mcdu_data)
        local nextIrs = 530 + (irs == 3 and 1 or irs+1)
        mcdu_open_page(mcdu_data, nextIrs)
    end

    mcdu_pages[THIS_PAGE.id] = THIS_PAGE
end