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
-- File: FMGS_f-pln.lua 
-- Short description: Flight Management and planning implementation
--                    This is a helper file used by FMGS.lua
-------------------------------------------------------------------------------

fmgs_dat["fpln"] = {}
fmgs_dat["fpln fmt"] = {}

local function fpln_wpt(navtype, loc, via, name, time, dist, spd, alt, efob, windspd, windhdg, nextname)
    wpt = {}
    wpt.name = name or ""
    wpt.navtype = navtype or ""
    wpt.time = time or "----"
    wpt.dist = dist or ""
    wpt.spd = spd or "---"
    wpt.alt = alt or "-----"
    wpt.via = via or ""
    wpt.nextname = nextname or "-"
    wpt.efob = efob or "-.-"
    wpt.windspd = windspd or "---"
    wpt.windhdg = windhdg or "---"
    return wpt
end

FPLN_DISCON = fpln_wpt("discon", nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)

local function fpln_add_wpt(wpt, loc)
    table.insert(fmgs_dat["fpln"], wpt, loc)
end

--find flight discontinuities
local function fpln_find_discons()
    fpln = 
    if #fmgs_dat["fpln"] == 0 then
        return
    end

    print(fmgs_dat["fpln"][1])
    wpt_prev = fmgs_dat["fpln"][1] or {nextname = ""}

    for no,wpt in ipairs(fpln) do
        if wpt_prev.nextname ~= wpt.name then
            fpln_add_wpt(FPLN_DISCON, no)
        end
        --set previous waypoint
        wpt_prev = wpt
    end
end

--formats the fpln
function fpln_format()
    fpln_fmt = {}
    fpln = fmgs_dat["fpln"]

    fpln_find_discons()

    for i,wpt in ipairs(fpln) do
        --is waypoint a blank?
        if wpt.name ~= "" then
            --check for flight discontinuities
            if wpt.navtype == FPLN_DISCON.navtype then
                table.insert(fpln_fmt, "---f-pln discontinuity--")
            else
                --insert waypoint
                table.insert(fpln_fmt, wpt)
            end
        end
    end
    table.insert(fpln_fmt, "----- end of f-pln -----")
    table.insert(fpln_fmt, "----- no altn fpln -----")

    --output
    fmgs_dat["fpln fmt"] = fpln_fmt
end

function fpln_add_airports(origin, destination)
    fpln_add_wpt(fpln_wpt(NAV_AIRPORT, nil, destination.id, nil, nil, nil, nil, nil, nil, nil, nil), 1)
    fpln_add_wpt(fpln_wpt(NAV_AIRPORT, nil, origin.id, nil, nil, nil, nil, nil, nil, nil, nil), 1)
end



--DEMO
--fpln_addwpt(NAV_FIX, 1, "chins3", "humpp", nil, 2341, 14, 297, 15000, nil, nil, nil, "aubrn")


