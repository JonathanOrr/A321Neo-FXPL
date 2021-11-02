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
-- Helper functions
-------------------------------------------------------------------------------

local function get_airport_or_nil(name)
    local apt = AvionicsBay.apts.get_by_name(name, false)
    if #apt > 0 then
        return apt[1]
    else
        return nil
    end
end

local function pop_vspeeds()
    FMGS_sys.perf.takeoff.v1_popped = FMGS_sys.perf.takeoff.v1
    FMGS_sys.perf.takeoff.vr_popped = FMGS_sys.perf.takeoff.vr
    FMGS_sys.perf.takeoff.v2_popped = FMGS_sys.perf.takeoff.v2
    FMGS_sys.perf.takeoff.v1 = nil
    FMGS_sys.perf.takeoff.vr = nil
    FMGS_sys.perf.takeoff.v2 = nil
end

local function check_rwy_change_triggers()
    if not FMGS_sys.fpln.temp then
        return
    end
    if not FMGS_sys.fpln.active.apts.dep_rwy then
        return
    end
    if FMGS_sys.fpln.active.apts.dep_rwy[1].id ~= FMGS_sys.fpln.temp.apts.dep_rwy[1].id
       or FMGS_sys.fpln.active.apts.dep_rwy[2] ~= FMGS_sys.fpln.temp.apts.dep_rwy[2] then
        -- Ok we have a runway change
        pop_vspeeds()
        MCDU.send_message("CHECK TAKE OFF DATA", ECAM_ORANGE)
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

    for k,x in pairs(FMGS_sys.fpln.active.apts) do
        FMGS_sys.fpln.temp.apts[k] = FMGS_sys.fpln.active.apts[k]
    end

end


function FMGS_erase_temp_fpln()
    FMGS_sys.fpln.temp = nil
end

function FMGS_insert_temp_fpln()
    check_rwy_change_triggers()
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


-------------------------------------------------------------------------------
-- Direct To
-------------------------------------------------------------------------------

function FMGS_dirto_get_direct_to_waypoint()
    return FMGS_sys.dirto.directing_wpt
end

function FMGS_dirto_set_direct_to_waypoint(wpt)
    FMGS_sys.dirto.directing_wpt = wpt
end

function FMGS_dirto_get_inbound_radial()
    return FMGS_sys.dirto.radial_in
end

function FMGS_dirto_set_inbound_radial(hdg)
    FMGS_sys.dirto.radial_in = hdg
end

function FMGS_dirto_get_outbound_radial()
    return FMGS_sys.dirto.radial_out
end

function FMGS_dirto_set_outbound_radial(hdg)
    FMGS_sys.dirto.radial_out = hdg
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

function FMGS_perf_set_user_trans_alt(trans_alt)
    FMGS_sys.perf.takeoff.user_trans_alt = trans_alt
end

function FMGS_perf_get_user_trans_alt()
    return FMGS_sys.perf.takeoff.user_trans_alt
end

function FMGS_perf_get_v_speeds()
    return FMGS_sys.perf.takeoff.v1, FMGS_sys.perf.takeoff.vr, FMGS_sys.perf.takeoff.v2
end

function FMGS_perf_set_v1(v1)
    FMGS_sys.perf.takeoff.v1 = v1
end

function FMGS_perf_set_vr(vr)
    FMGS_sys.perf.takeoff.vr = vr
end

function FMGS_perf_set_v2(v2)
    FMGS_sys.perf.takeoff.v2 = v2
end

function FMGS_perf_reset_v1_popped()
    FMGS_sys.perf.takeoff.v1_popped = nil
end

function FMGS_perf_reset_vr_popped()
    FMGS_sys.perf.takeoff.vr_popped = nil
end

function FMGS_perf_reset_v2_popped()
    FMGS_sys.perf.takeoff.v2_popped = nil
end

function FMGS_perf_swap_v1_popped()
    FMGS_sys.perf.takeoff.v1 = FMGS_sys.perf.takeoff.v1_popped
    FMGS_sys.perf.takeoff.v1_popped = nil
end

function FMGS_perf_swap_vr_popped()
    FMGS_sys.perf.takeoff.vr = FMGS_sys.perf.takeoff.vr_popped
    FMGS_sys.perf.takeoff.vr_popped = nil
end

function FMGS_perf_swap_v2_popped()
    FMGS_sys.perf.takeoff.v2 = FMGS_sys.perf.takeoff.v2_popped
    FMGS_sys.perf.takeoff.v2_popped = nil
end

function FMGS_perf_get_v_speeds_popped()
    return FMGS_sys.perf.takeoff.v1_popped, FMGS_sys.perf.takeoff.vr_popped, FMGS_sys.perf.takeoff.v2_popped
end

function FMGS_get_takeoff_thrust_reduction()
    return FMGS_sys.perf.takeoff.thr_red, FMGS_sys.perf.takeoff.user_thr_red
end

function FMGS_set_takeoff_thrust_reduction(user_thr_red)
    FMGS_sys.perf.takeoff.user_thr_red = user_thr_red
end

function FMGS_get_takeoff_acc()
    return FMGS_sys.perf.takeoff.acc, FMGS_sys.perf.takeoff.user_acc
end

function FMGS_set_takeoff_acc(user_acc)
    FMGS_sys.perf.takeoff.user_acc = user_acc
end

function FMGS_get_takeoff_flaps()
    return FMGS_sys.perf.takeoff.flaps
end

function FMGS_set_takeoff_flaps(f)
    FMGS_sys.perf.takeoff.flaps = f
end

function FMGS_get_takeoff_ths()
    return FMGS_sys.perf.takeoff.ths
end

function FMGS_set_takeoff_ths(t)
    FMGS_sys.perf.takeoff.ths = t
end

function FMGS_get_takeoff_flex_temp()
    return FMGS_sys.perf.takeoff.flex_temp
end

function FMGS_set_takeoff_flex_temp(temp)
    FMGS_sys.perf.takeoff.flex_temp = temp
    set(Eng_N1_flex_temp, temp)    -- TODO remove
end

function FMGS_get_takeoff_eng_out_alt()
    return FMGS_sys.perf.takeoff.eng_out, FMGS_sys.perf.takeoff.user_eng_out
end

function FMGS_set_takeoff_eng_out_alt(alt)
    FMGS_sys.perf.takeoff.user_eng_out = alt
end

function FMGS_get_takeoff_shift()
    return FMGS_sys.perf.takeoff.toshift
end

function FMGS_set_takeoff_shift(shift)
    FMGS_sys.perf.takeoff.toshift = shift
end

------------------------Landing!

function FMGS_set_landing_qnh(qnh)
    FMGS_sys.perf.landing.qnh = qnh
end

function FMGS_get_landing_qnh()
    return FMGS_sys.perf.landing.qnh
end

function FMGS_set_landing_mda(mda)
    FMGS_sys.perf.landing.mda = mda
end

function FMGS_get_landing_mda()
    return FMGS_sys.perf.landing.mda
end

function FMGS_set_landing_dh(dh)
    FMGS_sys.perf.landing.dh = dh
end

function FMGS_get_landing_dh()
    return FMGS_sys.perf.landing.dh
end

function FMGS_set_landing_apt_temp(temp)
    FMGS_sys.perf.landing.temp = temp
end

function FMGS_get_landing_apt_temp()
    return FMGS_sys.perf.landing.temp
end

function FMGS_set_landing_wind_mag(mag)
    FMGS_sys.perf.landing.mag = mag
end

function FMGS_get_landing_wind_mag()
    return FMGS_sys.perf.landing.mag
end

function FMGS_set_landing_wind(wind)
    FMGS_sys.perf.landing.wind = wind
end

function FMGS_get_landing_wind()
    return FMGS_sys.perf.landing.wind
end

function FMGS_set_landing_trans_alt_internal(alt) --not user value! but fmgs computed value!
    FMGS_sys.perf.landing.trans_alt = alt
end

function FMGS_set_landing_trans_alt(alt) --caution! User! Not system default value!
    FMGS_sys.perf.landing.user_trans_alt = alt
end

function FMGS_get_landing_trans_alt()
    return FMGS_sys.perf.landing.trans_alt, FMGS_sys.perf.landing.user_trans_alt
end

function FMGS_set_landing_vapp_internal(spd) --not user value! but fmgs computed value!
    FMGS_sys.perf.landing.vapp = spd
end

function FMGS_set_landing_vapp(spd) --caution! User! Not system default value!
    FMGS_sys.perf.landing.user_vapp = spd
end

function FMGS_get_landing_vapp()
    return FMGS_sys.perf.landing.vapp, FMGS_sys.perf.landing.user_vapp
end

function FMGS_set_landing_config(flaps)
    FMGS_sys.perf.landing.landing_config = flaps
end

function FMGS_get_landing_config()
    return FMGS_sys.perf.landing.landing_config
end

function FMGS_set_landing_vls(spd) -- user should not set it, for internal computation only
    FMGS_sys.perf.landing.vls = spd
end

function FMGS_get_landing_vls()
    return FMGS_sys.perf.landing.vls
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


-------------------------------------------------------------------------------
-- Winds
-------------------------------------------------------------------------------
function FMGS_winds_clear_wind(phase, idx)
  table.remove(FMGS_sys.data.winds[phase], idx)
end

function FMGS_winds_get_winds(phase)
  table.sort(FMGS_sys.data.winds[phase], function(a, b) return a.fl > b.fl end)
  return FMGS_sys.data.winds[phase]
end

function FMGS_winds_set_wind(phase, dir, spd, fl, pos)
    table.insert(FMGS_sys.data.winds[phase], {fl = fl, dir = dir, spd = spd, pos = pos})
end
