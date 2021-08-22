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

-------------------------------------------------------------------------------
-- Local Helpers
-------------------------------------------------------------------------------

local function get_airport_or_nil(name)
    local apt = AvionicsBay.apts.get_by_name(name, false)
    if #apt > 0 then
        return apt[1]
    else
        return nil
    end
end

local function itable_shallow_copy_legs(t1)
    assert(t1)
    assert(t1.legs)
    local t2 = {}

    -- Copy the whole table but NOT the legs
    for k,v in pairs(t1) do
        if k ~= "legs" then
            t2[k] = v
        end
    end
    t2.legs = {}
    for k,v in ipairs(t1.legs) do
      t2.legs[k] = v
    end
    return t2
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

-------------------------------------------------------------------------------
-- SID/STAR/TRANS
-------------------------------------------------------------------------------

function FMGS_reset_dep_sid()
    FMGS_sys.fpln.temp.apts.dep_sid = nil
end

function FMGS_reset_dep_trans()
    FMGS_sys.fpln.temp.apts.dep_trans = nil
end

function FMGS_reset_arr_star()
    FMGS_sys.fpln.temp.apts.arr_star = nil
end

function FMGS_reset_arr_via()
    FMGS_sys.fpln.temp.apts.arr_via = nil
end

function FMGS_reset_arr_trans()
    FMGS_sys.fpln.temp.apts.arr_trans = nil
end

function FMGS_reset_alt_airports()
    if FMGS_sys.fpln.temp then
        FMGS_sys.fpln.temp.apts.alt = nil
        FMGS_sys.fpln.temp.apts.alt_cifp = nil
    end
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
    FMGS_sys.fpln.active.apts.arr_appr=nil
    FMGS_sys.fpln.active.apts.arr_star=nil
    FMGS_sys.fpln.active.apts.arr_trans=nil
    FMGS_sys.fpln.active.apts.arr_via=nil
    
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
    FMGS_sys.fpln.temp.apts.dep_sid = itable_shallow_copy_legs(sid)
end

function FMGS_dep_get_trans(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.dep_trans
    else
        return FMGS_sys.fpln.active.apts.dep_trans
    end
end

function FMGS_dep_set_trans(trans)
    FMGS_sys.fpln.temp.apts.dep_trans = itable_shallow_copy_legs(trans)
end

function FMGS_arr_set_appr(appr, rwy, sibling)
    FMGS_sys.fpln.temp.apts.arr_rwy = {rwy, sibling}
    FMGS_sys.fpln.temp.apts.arr_appr = itable_shallow_copy_legs(appr)
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
    FMGS_sys.fpln.temp.apts.arr_star = itable_shallow_copy_legs(star)
end

function FMGS_arr_get_trans(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_trans
    else
        return FMGS_sys.fpln.active.apts.arr_trans
    end
end

function FMGS_arr_set_trans(trans)
    FMGS_sys.fpln.temp.apts.arr_trans = itable_shallow_copy_legs(trans)
end

function FMGS_arr_get_via(ret_temp_if_avail)
    if ret_temp_if_avail and FMGS_sys.fpln.temp then
        return FMGS_sys.fpln.temp.apts.arr_via
    else
        return FMGS_sys.fpln.active.apts.arr_via
    end
end

function FMGS_arr_set_via(via)
    FMGS_sys.fpln.temp.apts.arr_via = itable_shallow_copy_legs(via)
end


function FMGS_arr_get_available_vias(ret_temp_if_avail)

    local curr_fpln = ret_temp_if_avail and (FMGS_sys.fpln.temp or FMGS_sys.fpln.active) or FMGS_sys.fpln.active

    if not curr_fpln.apts.arr_appr or not curr_fpln.apts.arr_cifp then
        return {}   -- No approach selected
    end

    local toret = {{trans_name="NO VIA", novia=true}}

    if not curr_fpln.apts.arr_star or #curr_fpln.apts.arr_star.legs==0 then
        -- If I do NOT select a STAR, the listed VIA are all the IAF points for that approach
        for _,x in ipairs(curr_fpln.apts.arr_cifp.apprs) do
            if x.type == CIFP_TYPE_APPR_APP_TRANS and x.proc_name == curr_fpln.apts.arr_appr.proc_name then
                table.insert(toret, x)
            end
        end
    else
        -- If I DO select a STAR, the listed VIA are all the STAR waypoints that are also IAF points for that approach
        for _,x in ipairs(curr_fpln.apts.arr_cifp.apprs) do
            if x.type == CIFP_TYPE_APPR_APP_TRANS and x.proc_name == curr_fpln.apts.arr_appr.proc_name then
                for _,y in ipairs(curr_fpln.apts.arr_star.legs) do
                    if x.trans_name == y.leg_name then
                        table.insert(toret, x)
                    end
                end
                
            end
        end
    end

    return toret
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

function FMGS_create_copy_temp_fpln()

    FMGS_create_temp_fpln()

    -- Copy airport data
    FMGS_sys.fpln.temp.apts = {}
    for k,x in pairs(FMGS_sys.fpln.active.apts) do
        FMGS_sys.fpln.temp.apts[k] = FMGS_sys.fpln.active.apts[k]
    end

    -- Copy leg data
    FMGS_sys.fpln.temp.legs = {}
    for i,x in ipairs(FMGS_sys.fpln.active.legs) do
        FMGS_sys.fpln.temp.legs[i] = FMGS_sys.fpln.active.legs[i]
    end

end


function FMGS_erase_temp_fpln()
    FMGS_sys.fpln.temp = nil
end

function FMGS_insert_temp_fpln()
    FMGS_sys.fpln.active = FMGS_sys.fpln.temp
    FMGS_sys.perf.takeoff.trans_alt = FMGS_sys.fpln.active.apts.dep_sid.trans_alt

    FMGS_erase_temp_fpln()
end

function FMGS_does_temp_fpln_exist()
    return FMGS_sys.fpln.temp ~= nil
end

function FMGS_get_current_fpln()    -- CAUTION: do not abuse of this
                                    -- Authorized use only in 6** MCDU pages
    return FMGS_does_temp_fpln_exist() and FMGS_sys.fpln.temp or FMGS_sys.fpln.active
end

function FMGS_reshape_temp_fpln()    -- This function removes duplicated elements and adds
                                -- discontinuity where needed. You should call this
                                -- function evertime (and after) you change the sid, 
                                -- star, fpln points, etc.

    local fpln = FMGS_sys.fpln.temp

    local nr_legs_fpln = #fpln.legs

    if nr_legs_fpln == 0 then
        -- F/PLN is empty, thus just add a discontinuity
        table.insert(fpln.legs, {discontinuity = true})
    else
        if not fpln.legs[1].discontinuity then
            -- If there is only one point and it is not a discontinuity, then
            -- check the point between the SID or TRANS and the first point of
            -- the leg

            local last_dep   = fpln.apts.dep_trans or fpln.apts.dep_sid
            if last_dep then
                local last_dep_p = last_dep.legs[#last_dep.legs]
                if fpln.legs[1].id ~= last_dep_p.leg_name then
                    table.insert(fpln.legs, 1, {discontinuity = true})
                end
            else
                table.insert(fpln.legs, 1, {discontinuity = true})
            end
        end
        if not fpln.legs[nr_legs_fpln].discontinuity then

            local first_arr   = fpln.apts.arr_trans or fpln.apts.arr_appr 
            if first_arr then
                local first_arr_p = first_arr.legs[1]
                if fpln.legs[nr_legs_fpln].id ~= first_arr_p.leg_name then
                    table.insert(fpln.legs, {discontinuity = true})
                end
            else
                table.insert(fpln.legs, {discontinuity = true})
            end
        end
    end

end

-------------------------------------------------------------------------------
-- LEGS
-------------------------------------------------------------------------------
function FMGS_fpln_temp_leg_add(leg, position)
    assert(leg)
    assert(position)
    table.insert(FMGS_sys.fpln.temp.legs, position, leg)
end

function FMGS_fpln_temp_leg_add_disc(position)
    assert(position)
    local check_d = function(p) return FMGS_sys.fpln.temp.legs[p] and FMGS_sys.fpln.temp.legs[p].discontinuity end
    if check_d(position) or check_d(position-1) then
        -- Discontinuity already exists, don't add it
        return
    end
    table.insert(FMGS_sys.fpln.temp.legs, position, {discontinuity = true})
end

function FMGS_fpln_active_leg_add(leg, position)
    assert(leg)
    assert(position)
    table.insert(FMGS_sys.fpln.active.legs, position, leg)
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