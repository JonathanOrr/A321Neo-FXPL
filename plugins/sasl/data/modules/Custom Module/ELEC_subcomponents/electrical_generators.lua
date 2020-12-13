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
-- File: electrical_generators.lua
-- Short description: Electrical system - Generators (ENG, APU, EMERG)
-------------------------------------------------------------------------------

include('constants.lua')

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_LOW_VOLTAGE_LIMIT = 105   -- Under this value the generator does not provide any power
local GEN_LOW_HZ_LIMIT      = 385   -- Under this value the generator does not provide any power

local GEN_RANGE_VOLTAGE_LOW  = 110   -- Normal conditions - LO volt value
local GEN_RANGE_VOLTAGE_NOM  = 115   -- Normal conditions - Nominal volt value
local GEN_RANGE_VOLTAGE_HIGH = 120   -- Normal conditions - HI volt value
local GEN_RANGE_HZ_LOW  = 388        -- Normal conditions - LO freq value
local GEN_RANGE_HZ_NOM  = 400        -- Normal conditions - Nominal freq value
local GEN_RANGE_HZ_HIGH = 402        -- Normal conditions - HI freq value


----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_GEN1,  0, function(phase) elec_gen_toggle(phase, 1) end )
sasl.registerCommandHandler (ELEC_cmd_GEN2,  0, function(phase) elec_gen_toggle(phase, 2) end )
sasl.registerCommandHandler (ELEC_cmd_APU_GEN,  0, function(phase) elec_gen_toggle(phase, 3) end )
sasl.registerCommandHandler (ELEC_cmd_EXT_PWR,  0, function(phase) elec_gen_toggle(phase, 4) end )
sasl.registerCommandHandler (ELEC_cmd_EMER_RAT,  0, function(phase) elec_gen_toggle(phase, 5) end )

sasl.registerCommandHandler (ELEC_cmd_IDG1,  0, function(phase) elec_disc_idg(phase, 1) end )
sasl.registerCommandHandler (ELEC_cmd_IDG2,  0, function(phase) elec_disc_idg(phase, 2) end )

----------------------------------------------------------------------------------------------------
-- Global/Local variables
----------------------------------------------------------------------------------------------------
-- Index of the generators array:
GEN_1 = 1
GEN_2 = 2
GEN_APU = 3
GEN_EXT  = 4
GEN_EMER = 5

-- The generators array
generators = {
    {   -- GEN_1
        id = GEN_1,
        switch_status = true,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        curr_hz = 0,
        idg_status = true,
        drs = {
            pwr          = Gen_1_pwr,
            failure      = FAILURE_ELEC_GEN_1,
            switch_light = PB.ovhd.elec_gen1,
            idg_light    = PB.ovhd.elec_idg1,
            idg_temp     = IDG_1_temp,
            idg_fail_1   = FAILURE_ELEC_IDG1_temp,
            idg_fail_2   = FAILURE_ELEC_IDG1_oil,
        }
    },
    {   -- GEN_2
        id = GEN_2,
        switch_status = true, 
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        curr_hz = 0,
        idg_status = true,
        drs = {
            pwr          = Gen_2_pwr,
            failure      = FAILURE_ELEC_GEN_2,
            switch_light = PB.ovhd.elec_gen2,
            idg_light    = PB.ovhd.elec_idg2,
            idg_temp     = IDG_2_temp,
            idg_fail_1   = FAILURE_ELEC_IDG2_temp,
            idg_fail_2   = FAILURE_ELEC_IDG2_oil,
        }
    },
    {   -- GEN_APU
        id = GEN_APU,
        switch_status = true,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        curr_hz = 0,
        drs = {
            pwr          = Gen_APU_pwr,
            failure      = FAILURE_ELEC_GEN_APU,
            switch_light = PB.ovhd.elec_apu_gen
        }
    },
    {   -- GEN_EXT
        id = GEN_EXT,
        switch_status = false,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        curr_hz = 0,
        drs = {
            pwr          = Gen_EXT_pwr,
            failure      = FAILURE_ELEC_GEN_EXT,
            switch_light = PB.ovhd.elec_ext_pwr
        }
    },
    {   -- GEN_EMER (RAT)
        id = GEN_EMER,
        switch_status = false,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative (unless you want the RAT to become your desk fan :))
        curr_hz = 0,
        drs = {
            pwr          = Gen_EMER_pwr,
            failure      = FAILURE_ELEC_GEN_EMER,
            switch_light = PB.ovhd.elec_rat_fault
        }
    }
}

ELEC_sys.generators = generators

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function elec_disc_idg(phase, id)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    generators[id].idg_status = false
end

function elec_gen_toggle(phase, id)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    if id == GEN_EMER then
        -- Extract the RAT
        sasl.commandOnce(HYD_cmd_RAT_man_on)
        generators[id].switch_status = true
    else
        generators[id].switch_status = not generators[id].switch_status    
    end
    
end

local function update_eng_gen(x)

    if x.id == 1 then
        x.source_status = get(Engine_1_avail) == 1 and get(Eng_1_N1) > 10
    else
        x.source_status = get(Engine_2_avail) == 1 and get(Eng_2_N1) > 10
    end
    
    if x.switch_status then
        if x.source_status and get(x.drs.failure) == 0 and x.idg_status then
            x.curr_voltage = Set_anim_value(x.curr_voltage, GEN_RANGE_VOLTAGE_NOM, 0, GEN_RANGE_VOLTAGE_NOM, 0.90)
            x.curr_hz = Set_anim_value(x.curr_hz, GEN_RANGE_HZ_NOM, 0, 400, 0.90)
        else
            x.curr_voltage = Set_anim_value(x.curr_voltage, 0, 0, GEN_RANGE_VOLTAGE_NOM, 0.90)
            x.curr_hz = Set_anim_value(x.curr_hz, 0, 0, GEN_RANGE_HZ_NOM, 0.90)
        end
    else
        x.curr_voltage = 0
        x.curr_hz = 0
    end    
end

local function update_apu_gen(x)

    x.source_status = get(Apu_avail) == 1

    if x.switch_status then
        if x.source_status and get(x.drs.failure) == 0 then
            x.curr_voltage = Set_anim_value(x.curr_voltage, GEN_RANGE_VOLTAGE_NOM, 0, GEN_RANGE_VOLTAGE_NOM, 0.95)
            x.curr_hz = Set_anim_value(x.curr_hz, GEN_RANGE_HZ_NOM, 0, 400, 0.90)
        else
            x.curr_voltage = Set_anim_value(x.curr_voltage, 0, 0, GEN_RANGE_VOLTAGE_NOM, 0.95)
            x.curr_hz = Set_anim_value(x.curr_hz, 0, 0, GEN_RANGE_HZ_NOM, 0.95)
        end
    else
        x.curr_voltage = 0
        x.curr_hz = 0
    end    
end

local function update_ext_gen(x)

    x.source_status = get(All_on_ground) == 1 and get(Brakes_mode) == 4 and get(Ground_speed_ms) < 0.01

    if x.switch_status and x.source_status and get(x.drs.failure) == 0 then
        x.curr_voltage = 115
        x.curr_hz = 400
    else
        x.curr_voltage = 0
        x.curr_hz = 0
    end
    
end

local function update_rat_gen(x)

    if get(Adirs_adr_is_ok[1]) == 1 and get(Capt_IAS) > 100 and get(FLIGHT_TIME) > 5 then
        if get(AC_bus_1_pwrd) == 0 and get(AC_bus_2_pwrd) == 0 and not generators[GEN_EMER].switch_status then
            elec_gen_toggle(SASL_COMMAND_BEGIN, GEN_EMER)
        end
    end
    
    
    x.source_status = get(Hydraulic_B_press) > 1400 and (get(is_RAT_out) == 1)

    local gen_test_condition = get(Hydraulic_B_press) > 1400 and get(Gen_TEST_pressed) == 1 and get(AC_bus_1_pwrd) == 1 and get(AC_bus_2_pwrd) == 1

    if ((x.switch_status and x.source_status) or gen_test_condition) and get(x.drs.failure) == 0 then
        x.curr_voltage = GEN_LOW_VOLTAGE_LIMIT + 12 * (get(Hydraulic_B_press) - 1400) / 1500
        x.curr_hz = GEN_LOW_HZ_LIMIT + 25 * (get(Hydraulic_B_press) - 1400) / 1500
        if x.curr_hz > 402 then
            x.curr_hz = 402
        end
    else
        x.curr_voltage = 0
        x.curr_hz = 0
    end
    
end

local function update_generator_value(x)
    if x.id <= 2 then
        update_eng_gen(x)
    elseif x.id == GEN_APU then
        update_apu_gen(x)
    elseif x.id == GEN_EXT then
        update_ext_gen(x)
    elseif x.id == GEN_EMER then
        update_rat_gen(x)
    end
end

local function update_generator_datarefs(x)

    local top    = false
    local bottom = not x.switch_status
    
    if x.id == GEN_EMER then
        top    = false
        bottom = get(x.drs.failure) == 1 -- Switch status not showed and top bottom swapped
    elseif x.id == GEN_EXT then
        top = x.source_status
        bottom = not bottom
    elseif x.drs.idg_light ~= nil then
        top = (get(x.drs.failure)==1 or not x.idg_status)
    else
        top = (get(x.drs.failure)==1)
    end
    
    pb_set(x.drs.switch_light, bottom, top)
    
    if x.curr_voltage >= GEN_LOW_VOLTAGE_LIMIT and x.curr_hz >= GEN_LOW_HZ_LIMIT then
        set(x.drs.pwr, 1)
    else
        set(x.drs.pwr, 0)
    end
    
    if x.drs.idg_light ~= nil then
        if get(x.drs.idg_fail_1) + get(x.drs.idg_fail_2) > 0 then
            pb_set(x.drs.idg_light, false, true)
        else
            pb_set(x.drs.idg_light, false, false)
        end
    end
    
end

local function update_generator_load(x)
    x.curr_amps = 0

    if ELEC_sys.buses.ac1_powered_by == x.id then
        x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_1]
    end
    if ELEC_sys.buses.ac2_powered_by == x.id then
        x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_2]
    end
    if ELEC_sys.buses.ac_ess_powered_by == x.id or
       (ELEC_sys.buses.ac1_powered_by == x.id and ELEC_sys.buses.ac_ess_powered_by == 11) or
       (ELEC_sys.buses.ac2_powered_by == x.id and ELEC_sys.buses.ac_ess_powered_by == 12) then
        x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS]
        if ELEC_sys.buses.is_ac_ess_shed_on then
            x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS_SHED]            
        end
    end
    
    -- BUS TIE case
    -- This is ugly, but I cannot find another solution for now...
    if x.id <= 2 and get(x.drs.pwr) == 1 then
        if ELEC_sys.buses.ac1_powered_by == 99 then
            x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_1]
            if ELEC_sys.buses.ac_ess_powered_by == 11 then
                x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS]
                if ELEC_sys.buses.is_ac_ess_shed_on then
                    x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS_SHED]
                end
            end
        end
        if ELEC_sys.buses.ac2_powered_by == 99 then
            x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_2]
            if ELEC_sys.buses.ac_ess_powered_by == 12 then
                x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS]
                if ELEC_sys.buses.is_ac_ess_shed_on then
                    x.curr_amps = x.curr_amps-ELEC_sys.buses.pwr_consumption[ELEC_BUS_AC_ESS_SHED]            
                end
            end
        end
    end
end

local function update_idg(x)

    if x.drs.idg_temp == nil then
        return
    end

    local temperature = get(x.drs.idg_temp)
    
    if x.idg_status and ((x.id == 1 and get(Eng_1_N1) > 5) or (x.id == 2 and get(Eng_2_N1) > 5)) then
        local target = 80 + 50 * (get(Eng_1_N1))/100 + (get(x.drs.idg_fail_1) == 0 and 0 or 100)
        temperature = Set_anim_value(temperature, target, get(OTA), 300, 0.02)
    else
        temperature = Set_anim_value(temperature, get(OTA), get(OTA), 300, 0.05)        
    end
    set(x.drs.idg_temp, temperature)
end

function update_generators()

    for i,x in ipairs(generators) do
        update_generator_value(x)
        update_idg(x)
    end

    for i,x in ipairs(generators) do
        update_generator_datarefs(x)
    end
end

function update_generators_loads()
    for i,x in ipairs(generators) do
        update_generator_load(x)
    end
end
