----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
local GEN_LOW_VOLTAGE_LIMIT = 105   -- Under this value the generator does not provide any power (used for RAT)

local GEN_RANGE_VOLTAGE_LOW  = 115   -- Normal conditions - LO volt value
local GEN_RANGE_VOLTAGE_HIGH = 120   -- Normal conditions - HI volt value
local GEN_RANGE_HZ_LOW  = 388        -- Normal conditions - LO freq value
local GEN_RANGE_HZ_HIGH = 402        -- Normal conditions - HI freq value

local GEN_ENGINE_RATED_CURR = 261    -- Maximum current provided by the engine gen (this is not enforced but used to compute the load %)
local GEN_ENGINE_APU_CURR   = 261    -- Maximum current provided by the APU gen (this is not enforced but used to compute the load %)

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (ELEC_cmd_GEN1,  0, function(phase) elec_gen_toggle(phase, 1) end )
sasl.registerCommandHandler (ELEC_cmd_GEN2,  0, function(phase) elec_gen_toggle(phase, 2) end )
sasl.registerCommandHandler (ELEC_cmd_APU_GEN,  0, function(phase) elec_gen_toggle(phase, 3) end )
sasl.registerCommandHandler (ELEC_cmd_EXT_PWR,  0, function(phase) elec_gen_toggle(phase, 4) end )
sasl.registerCommandHandler (ELEC_cmd_EMER_RAT,  0, function(phase) elec_gen_toggle(phase, 5) end )

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
        is_connected_to_ac_bus = false,
        drs = {
            pwr          = Gen_1_pwr,
            failure      = FAILURE_ELEC_GEN_1,
            switch_light = Elec_light_GEN1
        }
    },
    {   -- GEN_2
        id = GEN_2,
        switch_status = true, 
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        is_connected_to_ac_bus = false,
        drs = {
            pwr          = Gen_2_pwr,
            failure      = FAILURE_ELEC_GEN_2,
            switch_light = Elec_light_GEN2
        }
    },
    {   -- GEN_APU
        id = GEN_APU,
        switch_status = true,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        is_connected_to_ac_bus = false,
        drs = {
            pwr          = Gen_APU_pwr,
            failure      = FAILURE_ELEC_GEN_APU,
            switch_light = Elec_light_APU_GEN
        }
    },
    {   -- GEN_EXT
        id = GEN_EXT,
        switch_status = false,
        source_status = false,  -- get(All_on_ground) == 1 and get(Actual_brake_ratio) == 1 and get(Ground_speed_ms) < 0.01
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        is_connected_to_ac_bus = false,
        drs = {
            pwr          = Gen_EXT_pwr,
            failure      = FAILURE_ELEC_GEN_EXT,
            switch_light = Elec_light_EXT_PWR
        }
    },
    {   -- GEN_EMER (RAT)
        id = GEN_EMER,
        switch_status = false,
        source_status = false,
        curr_voltage = 0,
        curr_amps    = 0, -- Always negative
        is_connected_to_ac_bus = false,
        drs = {
            pwr          = Gen_EMER_pwr,
            failure      = FAILURE_ELEC_GEN_EMER,
            switch_light = Elec_light_RAT_FAULT
        }
    }
}

ELEC_sys.generators = generators

----------------------------------------------------------------------------------------------------
-- Functions
----------------------------------------------------------------------------------------------------

function elec_gen_toggle(phase, id)
    if phase ~= SASL_COMMAND_BEGIN then
        return
    end
    
    generators[id].switch_status = not generators[id].switch_status
    
    if id == GEN_EMER then
        -- Extract the RAT
        sasl.commandOnce(HYD_cmd_RAT_man_on)
    end
    
end

local function update_generator_datarefs(x)
    int_value = x.switch_status and 0 or 1
    
    if x.id == GEN_EMER then
        int_value = get(x.drs.failure)==1 and 10 or 0 -- Switch status not showed
    elseif x.id == GEN_EXT then
        int_value = (1-int_value) + (x.source_status and 10 or 0)
    else
        int_value = int_value + (get(x.drs.failure)==1 and 10 or 0)
    end
    
    set(x.drs.switch_light, int_value)
    
end

function update_generators()

    for i,x in ipairs(generators) do
        update_generator_datarefs(x)
    end
end
