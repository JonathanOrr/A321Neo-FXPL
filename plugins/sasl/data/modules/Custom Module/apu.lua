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
-- File: apu.lua 
-- Short description: APU-related part (see also fuel, electrical and bleed)
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- APU management file
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

FLAP_OPEN_TIME_SEC = 20


----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local master_switch_status  = false
local master_switch_disabled_time = 0
local master_switch_enabled_time = 0
local start_requested = false

local random_egt_apu = 0
local random_egt_apu_last_update = 0
----------------------------------------------------------------------------------------------------
-- Init
----------------------------------------------------------------------------------------------------
function onAirportLoaded()
    set(Apu_bleed_xplane, 0)
    set(APU_EGT, get(OTA))
end
----------------------------------------------------------------------------------------------------
-- Command handlers
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler ( APU_cmd_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            if master_switch_disabled_time ~= 0 then 
                master_switch_disabled_time = 0
            else
                master_switch_disabled_time = get(TIME)
            end
        else
            master_switch_status = true
            if master_switch_disabled_time == 0 then
                master_switch_enabled_time = get(TIME)
            end
        end
    end
end)

sasl.registerCommandHandler ( APU_cmd_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if master_switch_status then
            start_requested = true
        end
    end
    return 1
end)


function update_egt()

    if get(TIME) - random_egt_apu_last_update > 2 then
        random_egt_apu = math.random() * 6 - 3
        random_egt_apu_last_update = get(TIME)
    end

    local apu_n1 = get(Apu_N1)

    if master_switch_status and get(FAILURE_ENG_APU_FAIL) == 0 then
        if apu_n1 < 1 then
            Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 1)
        elseif apu_n1 <= 25 then
             local target_egt = Math_rescale(0, get(OTA), 25, 900+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 <= 50 then
            local target_egt = Math_rescale(25, 900, 50,  800+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        elseif apu_n1 > 50 then
            local target_egt = Math_rescale(50, 800, 100, 400+random_egt_apu, apu_n1)
            Set_dataref_linear_anim(APU_EGT, target_egt, -50, 1000, 50)
        end
    else
        Set_dataref_linear_anim(APU_EGT, get(OTA), -50, 1000, 3)
    end
end

local function update_button_datarefs()

    local is_faulty = get(FAILURE_ENG_APU_FAIL) == 1 or get(DC_bat_bus_pwrd) == 0

    set(Apu_master_button_state,(master_switch_status and 1 or 0))

    pb_set(PB.ovhd.apu_master, master_switch_status and master_switch_disabled_time == 0, is_faulty)
    pb_set(PB.ovhd.apu_start, start_requested, get(Apu_avail) == 1)

end

local function update_apu_flap()
    if master_switch_status and get(TIME) - master_switch_enabled_time > FLAP_OPEN_TIME_SEC then
        set(APU_flap, 1)
    else
        set(APU_flap, 0)
    end
end

local function update_start()
    if master_switch_status and get(FAILURE_ENG_APU_FAIL) == 0 then 

        if start_requested and get(APU_flap) == 1 and get(Apu_avail) == 0 and get(DC_bat_bus_pwrd) == 1 and get(Apu_fuel_source) > 0 then
            set(Apu_start_position, 2)
        elseif get(Apu_avail) == 1 and get(Apu_fuel_source) > 0 then
            set(Apu_start_position, 1)
            start_requested = false
        else
            set(Apu_start_position, 0)
        end
    else
        set(Apu_start_position, 0)
        start_requested = false
    end
end

local function update_gen()
    if not master_switch_status or get(FAILURE_ENG_APU_FAIL) == 1 then
        set(Ecam_apu_gen_state, 0)
    else
        if ELEC_sys.generators[3].switch_status == false then
            set(Ecam_apu_gen_state, 1)
        elseif ELEC_sys.generators[3].curr_voltage > 105 and ELEC_sys.generators[3].curr_hz > 385 then
            set(Ecam_apu_gen_state, 2)
        else
            set(Ecam_apu_gen_state, 3)
        end
    end
end

local function update_off_status()

    if master_switch_disabled_time ~= 0 then
        if get(TIME) - master_switch_disabled_time > 60 or not PB.ovhd.ac_bleed_apu.status_bottom then
            master_switch_status = false
            master_switch_disabled_time = 0
        end
    end

end

function update()

    perf_measure_start("apu:update()")

    --apu availability
    if get(Apu_N1) > 95 then
        set(Apu_avail, 1)
    elseif get(Apu_N1) < 100 then
        set(Apu_avail, 0)
    end

    update_off_status()
    update_egt()
    update_button_datarefs()
    update_apu_flap()
    update_start()
    update_gen()

    perf_measure_stop("apu:update()")
end
