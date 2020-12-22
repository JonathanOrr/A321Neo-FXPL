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

local function fpln_wpt(navtype, loc, via, name, dist, time, spd, alt, efob, windspd, windhdg, nextname)
    wpt = {}
    wpt.name = name or ""
    wpt.navtype = navtype or ""
    wpt.dist = dist or 0
    wpt.time = time or -1
    wpt.spd = spd or -1
    wpt.alt = alt or -1
    wpt.via = via or ""
    wpt.nextname = nextname or ""
    wpt.efob = efob or -1
    wpt.windspd = windspd or -1
    wpt.windhdg = windhdg or -1
    return wpt
end

local function fpln_add_wpt(wpt, loc)
    if loc then
        table.insert(fmgs_dat["fpln"], loc, wpt)
    else
        table.insert(fmgs_dat["fpln"], wpt)
    end
end

--formats the fpln
function fpln_format()
    fpln_fmt = {}
    fpln = fmgs_dat["fpln"]

    --init previous waypoint
    wpt_prev = {}
    if #fpln > 0 then
        wpt_prev = {nextname = fpln[1].name}
    end

    for i,wpt in ipairs(fpln) do
        --is waypoint a blank?
        if wpt.name ~= "" then
            --check for flight discontinuities
            if wpt_prev.nextname ~= wpt.name then
                table.insert(fpln_fmt, "---f-pln discontinuity--")
            end

            --insert waypoint
            table.insert(fpln_fmt, wpt)
            --set previous waypoint
            wpt_prev = wpt
        end
    end
    table.insert(fpln_fmt, "----- end of f-pln -----")
    table.insert(fpln_fmt, "----- no altn fpln -----")

    --output
    fmgs_dat["fpln fmt"] = fpln_fmt
end

function fpln_add_airports(origin, destination)
    fpln_add_wpt(fpln_wpt(NAV_AIRPORT, nil, nil, origin.id, nil, nil, nil, nil, nil, nil, nil))
    fpln_add_wpt(fpln_wpt(NAV_AIRPORT, nil, nil, destination.id, nil, nil, nil, nil, nil, nil, nil))
end



--DEMO
--fpln_addwpt(NAV_FIX, 1, "chins3", "humpp", nil, 2341, 14, 297, 15000, nil, nil, nil, "aubrn")


