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

function FMGS_get_phase()
    return FMGS_sys.config.phase
end

function FMGS_get_status()
    return FMGS_sys.config.status
end

function FMGS_get_master()
    return FMGS_sys.config.master
end

function FMGS_set_apt_dep(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end
    
    FMGS_sys.fpln.active.apts.dep = get_airport_or_nil(name)
end

function FMGS_set_apt_arr(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.active.apts.arr = get_airport_or_nil(name)
end

function FMGS_set_apt_alt(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.active.apts.alt = get_airport_or_nil(name)
end

function FMGS_dep_get_rwy(ret_temp_if_avail)

    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        if not FMGS_sys.fpln.temp.apts.dep_rwy then
            return nil,nil
        else
            return FMGS_sys.fpln.temp.apts.dep_rwy[1], FMGS_sys.fpln.temp.apts.dep_rwy[2]
        end
    elseif not FMGS_sys.fpln.active.apts.dep_rwy then
        return nil, nil
    else
        return FMGS_sys.fpln.active.apts.dep_rwy[1], FMGS_sys.fpln.active.apts.dep_rwy[2]
    end
end

function FMGS_dep_set_rwy(rwy, sibling)
    FMGS_sys.fpln.temp.apts.dep_rwy = {rwy, sibling}
end

function FMGS_reset_dep_trans()
    FMGS_sys.fpln.temp.apts.dep_trans = nil
end


function FMGS_reset_alt_airports()
    FMGS_sys.fpln.temp.apts.alt = nil
    FMGS_sys.fpln.temp.apts.alt_cifp = nil
end


function FMGS_reset_dep_arr_airports()
    FMGS_sys.fpln.active.apts.dep       = nil
    FMGS_sys.fpln.active.apts.dep_cifp  = nil
    FMGS_sys.fpln.active.apts.dep_rwy   = nil
    FMGS_sys.fpln.active.apts.dep_sid   = nil
    FMGS_sys.fpln.active.apts.dep_trans = nil

    FMGS_sys.fpln.active.apts.arr = nil
    FMGS_sys.fpln.active.apts.arr_cifp = nil
    FMGS_sys.fpln.active.apts.arr_rwy = nil
    
    FMGS_sys.fpln.temp = nil
end

function FMGS_create_temp_fpln()
    FMGS_sys.fpln.temp = {}

    FMGS_sys.fpln.temp.apts = {}
    FMGS_sys.fpln.temp.apts.dep = FMGS_sys.fpln.active.apts.dep
    FMGS_sys.fpln.temp.apts.dep_cifp = FMGS_sys.fpln.active.apts.dep_cifp
    FMGS_sys.fpln.temp.apts.arr = FMGS_sys.fpln.active.apts.arr
    FMGS_sys.fpln.temp.apts.arr_cifp = FMGS_sys.fpln.active.apts.arr_cifp
    FMGS_sys.fpln.temp.apts.alt = FMGS_sys.fpln.active.apts.alt
    FMGS_sys.fpln.temp.apts.alt_cifp = FMGS_sys.fpln.active.apts.alt_cifp
    
    FMGS_sys.fpln.temp.legs     = FMGS_sys.fpln.active.legs
    FMGS_sys.fpln.temp.next_leg = FMGS_sys.fpln.active.next_leg

end

function FMGS_erase_temp_fpln()
    FMGS_sys.fpln.temp = nil
end

function FMGS_insert_temp_fpln()
    FMGS_sys.fpln.active = FMGS_sys.fpln.temp
    FMGS_erase_temp_fpln()
end

function FMGS_does_temp_fpln_exist()
    return FMGS_sys.fpln.temp ~= nil
end

function FMGS_dep_get_sid(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.dep_sid
    else
        return FMGS_sys.fpln.active.apts.dep_sid
    end
end

function FMGS_dep_set_sid(sid)
    FMGS_sys.fpln.temp.apts.dep_sid = sid
end

function FMGS_dep_get_trans(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.dep_trans
    else
        return FMGS_sys.fpln.active.apts.dep_trans
    end
end

function FMGS_dep_set_trans(trans)
    FMGS_sys.fpln.temp.apts.dep_trans = trans
end


