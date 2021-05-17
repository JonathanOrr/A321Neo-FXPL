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
-- File: electrical_tr_and_inv.lua
-- Short description: Electrical system - TRs and ST.INV
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_LOW_VOLTAGE_LIMIT = 105   -- Under this value the generator does not provide any power
local GEN_LOW_HZ_LIMIT      = 385   -- Under this value the generator does not provide any power
local TR_MAX_AMPS  = 200   -- Max output current in *DC*
local INV_MAX_AMPS = 8.69  -- Max output current in *AC*

local AC_VOLTAGE_NOM  = 115   -- Normal conditions - Nominal volt value
local AC_HZ_NOM       = 400   -- Normal conditions - Nominal freq value
local DC_VOLTAGE_NOM  = 28    -- Normal conditions - Nominal volt value

local WAIT_TIME_STINV = 0.2   -- Wait time for static inverter to start (ms)

local POWER_LOSS = 0.02 -- The TR is not perfect, it will loose some power...
local MIN_STINV_LOAD = 1
----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
-- Index of the TR array:
local TR_1 = 1
local TR_2 = 2
local TR_ESS = 3

trs = {
    {
        id = TR_1,
        status = false,
        curr_voltage  = 0,
        curr_out_amps = 0,
        curr_in_amps = 0,
        drs = {
            input_bus    = AC_bus_1_pwrd,
            pwr          = TR_1_online,
            failure      = FAILURE_ELEC_TR_1
        }
    },
    {
        id = TR_2,
        status = false,
        curr_voltage  = 0,
        curr_out_amps = 0,
        curr_in_amps = 0,
        drs = {
            input_bus    = AC_bus_2_pwrd,
            pwr          = TR_2_online,
            failure      = FAILURE_ELEC_TR_2
        }
    },
    {
        id = TR_ESS,
        status = false,
        curr_voltage  = 0,
        curr_out_amps = 0,
        curr_in_amps = 0,
        drs = {
            input_bus    = AC_ess_bus_pwrd,
            pwr          = TR_ESS_online,
            failure      = FAILURE_ELEC_TR_ESS
        }
    }
}

ELEC_sys.trs = trs


stat_inv = {
    status = false,
    curr_voltage  = 0,
    curr_hz = 0,
    curr_out_amps = 0,
    curr_in_amps  = 0,
    drs = {
        input_bus    = HOT_bus_1_pwrd,
        pwr          = INV_online,
        failure      = FAILURE_ELEC_STATIC_INV
    }
}

ELEC_sys.stat_inv = stat_inv

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

local time_start_stinv = 0

local function update_static_inv()

    stat_inv.status = false

    -- Static inverter is enabled only if a total loss of power occurs (including RAT!)
    if get(Gen_EMER_pwr) == 0 and get(Gen_EXT_pwr) == 0 and get(Gen_APU_pwr) == 0
       and get(Gen_2_pwr) == 0 and get(Gen_1_pwr) == 0 then 
        if get(Ground_speed_ms) > 50 then
            stat_inv.status = get(HOT_bus_1_pwrd) == 1  -- In this case who cares about battery pushbutton status
        else
            if ELEC_sys.batteries[1].switch_status == true and ELEC_sys.batteries[2].switch_status == true then
                -- If the speed is low, static inv is enabled only if both switches are at on
                stat_inv.status = get(HOT_bus_1_pwrd) == 1
            end
        end
    end

    -- OR if GEN TEST is pressed and no AC buses are powered
    if get(Gen_TEST_pressed) == 1 and get(AC_bus_1_pwrd) == 0 and get(AC_bus_2_pwrd) == 0 then
        stat_inv.status = get(HOT_bus_1_pwrd) == 1
    end

    if stat_inv.status and get(stat_inv.drs.failure)==0 then
        if time_start_stinv == 0 then
            time_start_stinv = get(TIME)
        end
        if get(Gen_TEST_pressed) == 1  or (get(TIME) - time_start_stinv > WAIT_TIME_STINV) then
            stat_inv.curr_voltage = AC_VOLTAGE_NOM
            stat_inv.curr_hz      = AC_HZ_NOM
        end
    else
        time_start_stinv = 0
        stat_inv.curr_voltage = 0
        stat_inv.curr_hz      = 0
    end
end

local function update_tr(x)
    x.status = false

    if x.id == TR_ESS then
        if get(TR_1_online) == 1 and get(TR_2_online) == 1 then
            return -- If the normal TR are active, it makes no sense for TR ESS to work
        end
        if get(INV_online) == 1 then
            return -- It has no sense to run the TR ESS when static elec is powering AC bus
        end
    end

    if get(x.drs.input_bus) == 1 and get(x.drs.failure) == 0 then
        x.status = true
        x.curr_voltage = DC_VOLTAGE_NOM
    else
        x.curr_voltage = 0 
    end

end

local function update_datarefs()
    if stat_inv.curr_voltage >= GEN_LOW_VOLTAGE_LIMIT and stat_inv.curr_hz >= GEN_LOW_HZ_LIMIT then
        set(INV_online, 1)
    else
        set(INV_online, 0)
    end

    if trs[TR_1].curr_voltage >= DC_VOLTAGE_NOM*0.9 and trs[TR_1].status then
        set(TR_1_online, 1)
    else
        set(TR_1_online, 0)
    end

    if trs[TR_2].curr_voltage >= DC_VOLTAGE_NOM*0.9 and trs[TR_2].status then
        set(TR_2_online, 1)
    else
        set(TR_2_online, 0)
    end

    if trs[TR_ESS].curr_voltage >= DC_VOLTAGE_NOM*0.9 and trs[TR_ESS].status then
        set(TR_ESS_online, 1)
    else
        set(TR_ESS_online, 0)
    end

end

local function update_tr_load(tr)

    tr.curr_out_amps = 0
    tr.curr_in_amps = 0

    if not tr.status then
        return
    end

    if tr.id ~= 3 then
        if ELEC_sys.buses.dc1_powered_by == 30+tr.id or ELEC_sys.buses.dc1_powered_by == 98 then
            tr.curr_out_amps = tr.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_DC_1]
        end
        if ELEC_sys.buses.dc2_powered_by == 30+tr.id or ELEC_sys.buses.dc2_powered_by == 98 then
            tr.curr_out_amps = tr.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_DC_2]
        end
    end
    if ELEC_sys.buses.dc_ess_powered_by == 30+tr.id then
        tr.curr_out_amps = tr.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_DC_ESS]
        if get(DC_shed_ess_pwrd) == 1 then
            tr.curr_out_amps = tr.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_DC_ESS_SHED]
        end
    end

    if ELEC_sys.buses.dc_bat_bus_powered_by == 30+tr.id then
        tr.curr_out_amps = tr.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_DC_BAT_BUS]
    end

    -- Now let's convert the output amps in input amps
    tr.curr_in_amps = tr.curr_out_amps * tr.curr_voltage / AC_VOLTAGE_NOM
    tr.curr_in_amps = tr.curr_in_amps * (1+POWER_LOSS)
end

function update_trs_and_inv()

    update_tr(trs[1])
    update_tr(trs[2])
    update_tr(trs[3])
    update_static_inv()

    update_datarefs()
end

function update_trs_loads()
    update_tr_load(trs[1])
    update_tr_load(trs[2])
    update_tr_load(trs[3])

    ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, trs[1].curr_in_amps, trs[1].curr_in_amps)
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, trs[2].curr_in_amps, trs[2].curr_in_amps)
    ELEC_sys.add_power_consumption(ELEC_BUS_AC_ESS, trs[3].curr_in_amps, trs[3].curr_in_amps)

end

function update_stinv_loads()
    stat_inv.curr_out_amps = 0
    stat_inv.curr_in_amps = 0

    if not stat_inv.status then
        return
    end

    if ELEC_sys.buses.ac_ess_powered_by == 21 then
        stat_inv.curr_out_amps = stat_inv.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS]
        if get(AC_ess_shed_pwrd) == 1 then
            stat_inv.curr_out_amps = stat_inv.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS_SHED]
        end
    end

    stat_inv.curr_out_amps = stat_inv.curr_out_amps + ELEC_sys.buses.pwr_consumption[ELEC_BUS_STAT_INV]

    stat_inv.curr_in_amps = stat_inv.curr_out_amps * stat_inv.curr_voltage / DC_VOLTAGE_NOM
    stat_inv.curr_in_amps = stat_inv.curr_in_amps * (1+POWER_LOSS) + MIN_STINV_LOAD

    ELEC_sys.add_power_consumption(ELEC_BUS_HOT_BUS_1, stat_inv.curr_in_amps, stat_inv.curr_in_amps)

end

