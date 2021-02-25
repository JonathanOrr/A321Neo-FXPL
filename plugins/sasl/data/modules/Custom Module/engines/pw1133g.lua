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
-- File: pw1133g.lua
-- Short description: Engine data for PW1133G
-------------------------------------------------------------------------------

function configure_pw1133g()


    ENG.data = {

        display = {
            egt_scale = 1200,                -- [°C]
            egt_red_limit = 1083,            -- [°C]
            egt_amber_limit = 1043,          -- [°C]
            egt_amber_limit_on_start = nil,  -- [°C] Can be nil if not showed
        }

    }


end


