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
   
   if stat_inv.status and get(stat_inv.drs.failure)==0 then
        if time_start_stinv == 0 then
            time_start_stinv = get(TIME)
        elseif get(TIME) - time_start_stinv > WAIT_TIME_STINV then
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
    
    if trs[TR_1].curr_voltage >= DC_VOLTAGE_NOM*0.9 then
        set(TR_1_online, 1)
    else
        set(TR_1_online, 0)
    end
    
    if trs[TR_2].curr_voltage >= DC_VOLTAGE_NOM*0.9 then
        set(TR_2_online, 1)
    else
        set(TR_2_online, 0)    
    end
    
    if trs[TR_ESS].curr_voltage >= DC_VOLTAGE_NOM*0.9 then
        set(TR_ESS_online, 1)
    else
        set(TR_ESS_online, 0)    
    end
    
end

function update_trs_and_inv()

    update_tr(trs[1])
    update_tr(trs[2])
    update_tr(trs[3])
    update_static_inv()
    
    update_datarefs()
end
