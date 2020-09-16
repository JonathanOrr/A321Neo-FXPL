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
        switch_status = false,
        source_status = false,
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

