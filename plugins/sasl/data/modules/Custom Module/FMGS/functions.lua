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
-- File: FMGS_functions.lua 
-- Short description: FMGS functions used by non-FMGS modules
-------------------------------------------------------------------------------

local function get_airport_or_nil(name)
    local apt = AvionicsBay.apts.get_by_name(name, false)
    if #apt > 0 then
        return apt[1]
    else
        return nil
    end
end

function FMGS_set_apt_dep(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end
    
    FMGS_sys.fpln.apts.dep = get_airport_or_nil(name)
end

function FMGS_set_apt_arr(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.apts.arr = get_airport_or_nil(name)
end

function FMGS_set_apt_alt(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.apts.alt = get_airport_or_nil(name)
end

function FMGS_dep_get_rwy()
    if not FMGS_sys.fpln.apts.dep_rwy then
        return nil, nil
    else
        return FMGS_sys.fpln.apts.dep_rwy[1], FMGS_sys.fpln.apts.dep_rwy[2]
    end
end

function FMGS_dep_set_rwy(rwy, sibling)
    FMGS_sys.fpln.apts.dep_rwy = {rwy, sibling}
end

function FMGS_reset_dep_arr_airports()
    FMGS_sys.fpln.apts.dep       = nil
    FMGS_sys.fpln.apts.dep_cifp  = nil
    FMGS_sys.fpln.apts.dep_rwy   = nil
    FMGS_sys.fpln.apts.dep_sid   = nil
    FMGS_sys.fpln.apts.dep_trans = nil

    FMGS_sys.fpln.apts.arr = nil
    FMGS_sys.fpln.apts.arr_cifp = nil
    FMGS_sys.fpln.apts.arr_rwy = nil
end

function FMGS_reset_alt_airport()
    FMGS_sys.fpln.apts.alt = nil
    FMGS_sys.fpln.apts.alt_cifp = nil
end

function FMGS_dep_get_sid()
    return FMGS_sys.fpln.apts.dep_sid
end

function FMGS_dep_set_sid(sid)
    FMGS_sys.fpln.apts.dep_sid = sid
end

function FMGS_dep_get_trans()
    return FMGS_sys.fpln.apts.dep_trans
end


