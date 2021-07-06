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

-------------------------------------------------------------------------------
-- FMGS config
-------------------------------------------------------------------------------

function FMGS_get_phase()
    return FMGS_sys.config.phase
end

function FMGS_get_status()
    return FMGS_sys.config.status
end

function FMGS_get_master()
    return FMGS_sys.config.master
end

-------------------------------------------------------------------------------
-- INIT stuffs
-------------------------------------------------------------------------------
function FMGS_init_set_flt_nbr(id)
    FMGS_sys.data.init.flt_nbr = id
end

function FMGS_init_get_flt_nbr()
    return FMGS_sys.data.init.flt_nbr
end

function FMGS_init_set_cost_idx(cost)
    FMGS_sys.data.init.cost_index = cost
end

function FMGS_init_get_cost_idx()
    return FMGS_sys.data.init.cost_index
end

function FMGS_init_set_crz_fl(crz_fl, crz_temp)
    FMGS_sys.data.init.crz_fl = crz_fl
    FMGS_sys.data.init.crz_temp = crz_temp
end

function FMGS_init_get_crz_fl_temp()
    return FMGS_sys.data.init.crz_fl, FMGS_sys.data.init.crz_temp
end

function FMGS_init_set_tropo_alt(tropo)
    FMGS_sys.data.init.tropo = tropo
end

function FMGS_init_get_tropo_alt()
    return FMGS_sys.data.init.tropo
end

function FMGS_init_get_taxi_fuel()
    return FMGS_sys.data.init.weights.taxi_fuel
end

function FMGS_init_set_taxi_fuel(fuel)
    FMGS_sys.data.init.weights.taxi_fuel = fuel
end

function FMGS_init_get_block_fuel()
    return FMGS_sys.data.init.weights.block_fuel
end

function FMGS_init_set_block_fuel(fuel)
    FMGS_sys.data.init.weights.block_fuel = fuel
end

function FMGS_init_get_rsv_fuel()
    return FMGS_sys.data.init.weights.rsv_fuel
end

function FMGS_init_get_rsv_fuel_perc()
    return FMGS_sys.data.init.weights.rsv_fuel_perc
end

function FMGS_init_set_rsv_fuel(fuel)
    FMGS_sys.data.init.weights.rsv_fuel = fuel
end


function FMGS_init_get_weight_zfw_cg()
    return FMGS_sys.data.init.weights.zfw, FMGS_sys.data.init.weights.zfwcg
end

function FMGS_init_set_weight_zfw_cg(zfw, zfwcg)
    FMGS_sys.data.init.weights.zfw = zfw
    FMGS_sys.data.init.weights.zfwcg = zfwcg
end

-------------------------------------------------------------------------------
-- Airports
-------------------------------------------------------------------------------

function FMGS_set_apt_dep(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end
    
    FMGS_sys.fpln.active.apts.dep = get_airport_or_nil(name)
end

function FMGS_get_apt_dep()
    return FMGS_sys.fpln.active.apts.dep
end

function FMGS_set_apt_arr(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.active.apts.arr = get_airport_or_nil(name)
end

function FMGS_get_apt_arr()
    return FMGS_sys.fpln.active.apts.arr
end

function FMGS_set_apt_alt(name)
    if not AvionicsBay.is_initialized() or not AvionicsBay.is_ready() then
        return
    end

    FMGS_sys.fpln.active.apts.alt = get_airport_or_nil(name)
end

function FMGS_get_apt_alt()
    return FMGS_sys.fpln.active.apts.alt
end

function FMGS_are_main_apts_set()
    return FMGS_sys.fpln.active.apts.dep and FMGS_sys.fpln.active.apts.arr
end

-------------------------------------------------------------------------------
-- Airports - Runways
-------------------------------------------------------------------------------


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

function FMGS_arr_get_rwy(ret_temp_if_avail)

    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        if not FMGS_sys.fpln.temp.apts.arr_rwy then
            return nil,nil
        else
            return FMGS_sys.fpln.temp.apts.arr_rwy[1], FMGS_sys.fpln.temp.apts.arr_rwy[2]
        end
    elseif not FMGS_sys.fpln.active.apts.arr_rwy then
        return nil, nil
    else
        return FMGS_sys.fpln.active.apts.arr_rwy[1], FMGS_sys.fpln.active.apts.arr_rwy[2]
    end
end

function FMGS_dep_set_rwy(rwy, sibling)
    FMGS_sys.fpln.temp.apts.dep_rwy = {rwy, sibling}
end

function FMGS_copy_dep_rwy_active_to_temp()
    FMGS_sys.fpln.temp.apts.dep_rwy = FMGS_sys.fpln.active.apts.dep_rwy
end

-------------------------------------------------------------------------------
-- SID/STAR/TRANS
-------------------------------------------------------------------------------


function FMGS_reset_dep_trans()
    FMGS_sys.fpln.temp.apts.dep_trans = nil
end

function FMGS_reset_arr_trans()
    FMGS_sys.fpln.temp.apts.arr_trans = nil
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

function FMGS_copy_dep_sid_active_to_temp()
    FMGS_sys.fpln.temp.apts.dep_sid = FMGS_sys.fpln.active.apts.dep_sid
end

function FMGS_arr_set_appr(appr, rwy, sibling)
    FMGS_sys.fpln.temp.apts.arr_rwy = {rwy, sibling}
    FMGS_sys.fpln.temp.apts.arr_appr = appr
end

function FMGS_arr_get_appr(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_appr
    else
        return FMGS_sys.fpln.active.apts.arr_appr
    end
end

function FMGS_arr_get_star(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_star
    else
        return FMGS_sys.fpln.active.apts.arr_star
    end
end

function FMGS_arr_set_star(star)
    FMGS_sys.fpln.temp.apts.arr_star = star
end

function FMGS_arr_get_trans(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_trans
    else
        return FMGS_sys.fpln.active.apts.arr_trans
    end
end

function FMGS_arr_set_trans(trans)
    FMGS_sys.fpln.temp.apts.arr_trans = trans
end

function FMGS_arr_get_via(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_via
    else
        return FMGS_sys.fpln.active.apts.arr_via
    end
end

function FMGS_arr_set_via(via)
    FMGS_sys.fpln.temp.apts.arr_via = via
end


-------------------------------------------------------------------------------
-- F/PLN
-------------------------------------------------------------------------------


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

function FMGS_get_current_fpln()    -- CAUTION: do not abuse of this
                                    -- Authorized use only in 6** MCDU pages
    return FMGS_does_temp_fpln_exist() and FMGS_sys.fpln.temp or FMGS_sys.fpln.active
end

-------------------------------------------------------------------------------
-- Performance
-------------------------------------------------------------------------------
function FMGS_perf_set_trans_alt(trans_alt)
    FMGS_sys.perf.takeoff.trans_alt = trans_alt
end

function FMGS_perf_get_trans_alt()
    return FMGS_sys.perf.takeoff.trans_alt
end

-------------------------------------------------------------------------------
-- Predictions
-------------------------------------------------------------------------------
function FMGS_perf_get_pred_trip_time()
    return FMGS_sys.data.pred.trip_time
end

function FMGS_perf_get_pred_trip_dist()
    return FMGS_sys.data.pred.trip_dist
end

function FMGS_perf_get_pred_trip_fuel()
    return FMGS_sys.data.pred.trip_fuel
end

function FMGS_perf_get_pred_trip_efob()
    return FMGS_sys.data.pred.trip_efob
end


-------------------------------------------------------------------------------
-- Route
-------------------------------------------------------------------------------
function FMGS_get_route_legs()
    return FMGS_sys.fpln.active.legs
end

function FMGS_get_next_leg_id()
    return FMGS_sys.fpln.active.next_leg
end