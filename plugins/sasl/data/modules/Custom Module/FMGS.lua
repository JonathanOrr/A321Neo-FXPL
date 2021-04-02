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
-- File: FMGS.lua 
-- Short description: The Flight Management Systems main file
-------------------------------------------------------------------------------

local config = {
    status = FMGS_MODE_OFF,
    master = 0,
    backup_req = false
}

FMGS_sys.config = config

local function update_status()
    -- NOTE: As far as I know, INDEPENDENT MODE is activated only when databases of FMCUs is different
    --       This has no sense in our aircraft, so this mode doesn't exist.

    local fmgc_1_works = get(FAILURE_FMGC_1) == 0 and get(DC_shed_ess_pwrd) == 1
    local fmgc_2_works = get(FAILURE_FMGC_2) == 0 and get(DC_bus_2_pwrd) == 1
    
    if fmgc_1_works and fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_DUAL
        FMGS_sys.config.master = 1  -- TODO: It depends on AP and FD selections
    elseif fmgc_1_works and not fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_SINGLE
        FMGS_sys.config.master = 1
    elseif not fmgc_1_works and fmgc_2_works then
        FMGS_sys.config.status = FMGS_MODE_SINGLE
        FMGS_sys.config.master = 2
    elseif FMGS_sys.config.backup_req then
        FMGS_sys.config.status = FMGS_MODE_BACKUP
        FMGS_sys.config.master = 0  -- In backup mode no FMGC works
    else
        FMGS_sys.config.status = FMGS_MODE_OFF
        FMGS_sys.config.master = 0
    end

end

function update()
    update_status()
end
