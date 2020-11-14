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
-- File: aircond.lua 
-- Short description: The code for the air conditioning system
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- AIR_CONDITIONING systems
----------------------------------------------------------------------------------------------------

include('aircond_cabinmodel.lua')
include('constants.lua')
include('PID.lua')

-- Constants for the ventilation of the avionics bay
local AVIO_CLOSED   = 0
local AVIO_OPEN     = 1
local AVIO_INTERM   = 2
local AVIO_ISOLATED = 3
local AVIO_SMOKE    = 4


--PID arrays
local PID_PACK_FLOW = 100   -- Just a random id

local function create_aircond_pid(P, I, D) 
    return {
            P_gain = P,
            I_gain = I,
            D_gain = D,
            B_gain = 1,
            Actual_output = 0,
            Desired_output = 0,
            Integral_sum = 0,
            Current_error = 0,
            Min_out = 0,
            Max_out = 1
    }
end

local pid_arrays = {
    [CKPT]         = create_aircond_pid(0.075, 0.001, 0),
    [CABIN_FWD]    = create_aircond_pid(0.07, 0.00075, 0),
    [CABIN_AFT]    = create_aircond_pid(0.075, 0.00075, 0),
    [CARGO_AFT]    = create_aircond_pid(0.025, 0.0001, 0),
    [PID_PACK_FLOW]= create_aircond_pid(0.5, 0.001, 0)
}



--register commands
sasl.registerCommandHandler ( Cockpit_temp_dial_up, 0, function(phase)  Knob_handler_up_float(phase, Cockpit_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Cockpit_temp_dial_dn, 0, function(phase)  Knob_handler_down_float(phase, Cockpit_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Front_cab_temp_dial_up, 0, function(phase)  Knob_handler_up_float(phase, Front_cab_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Front_cab_temp_dial_dn, 0, function(phase)  Knob_handler_down_float(phase, Front_cab_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Aft_cab_temp_dial_up, 0, function(phase)  Knob_handler_up_float(phase, Aft_cab_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Aft_cab_temp_dial_dn, 0, function(phase)  Knob_handler_down_float(phase, Aft_cab_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Aft_cargo_temp_dial_up, 0, function(phase)  Knob_handler_up_float(phase, Aft_cargo_temp_dial, 0, 1, 0.4) end)
sasl.registerCommandHandler ( Aft_cargo_temp_dial_dn, 0, function(phase)  Knob_handler_down_float(phase, Aft_cargo_temp_dial, 0, 1, 0.4) end)


local pack_valves_last_update = 0
local time_started_blower = 0
local time_started_extract = 0

local avio_skin_temperature = get(OTA)
local avio_configuration    = AVIO_CLOSED

sasl.registerCommandHandler ( ELEC_vent_blower, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Ventilation_blower_override, 1 - get(Ventilation_blower_override))
    end
end)

sasl.registerCommandHandler ( ELEC_vent_extract, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Ventilation_extract_override, 1 - get(Ventilation_extract_override))
    end
end)


--custom functions
local function update_avio_ventilation()
    set(Ventilation_light_blower, get(Ventilation_blower_override) + ((get(FAILURE_AIRCOND_VENT_BLOWER) == 1 or get(FAILURE_AVIONICS_SMOKE) == 1) and 10 or 0))
    set(Ventilation_light_extract, get(Ventilation_extract_override)+ ((get(FAILURE_AIRCOND_VENT_EXTRACT) == 1 or get(FAILURE_AVIONICS_SMOKE) == 1) and 10 or 0))
    

    if get(AC_bus_1_pwrd) == 1 and get(FAILURE_AIRCOND_VENT_BLOWER) == 0 and get(Ventilation_blower_override) == 0 then
        if time_started_blower == 0 then time_started_blower = get(TIME) end
    else
        time_started_blower = 0
    end
    
    if time_started_blower ~= 0 and get(TIME) - time_started_blower > 5 then
        set(Ventilation_blower_running, 1)
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.05, 0.05)
    else
        set(Ventilation_blower_running, 0)
    end
    
    if get(AC_bus_2_pwrd) == 1 and get(FAILURE_AIRCOND_VENT_EXTRACT) == 0 then
        if time_started_extract == 0 then time_started_extract = get(TIME) end
    else
        time_started_extract = 0
    end
    
    if time_started_extract ~= 0 and get(TIME) - time_started_extract > 5 then
        set(Ventilation_extract_running, 1)
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.05, 0.05)
    else
        set(Ventilation_extract_running, 0)
    end
    
end



local function update_knobs()
    set(Cockpit_temp_dial, Math_clamp(get(Cockpit_temp_dial), 0, 1))
    set(Front_cab_temp_dial, Math_clamp(get(Front_cab_temp_dial), 0, 1))
    set(Aft_cab_temp_dial, Math_clamp(get(Aft_cab_temp_dial), 0, 1))
    set(Aft_cargo_temp_dial, Math_clamp(get(Aft_cargo_temp_dial), 0, 1))

    set(Cockpit_temp_req, 18 + 12 * get(Cockpit_temp_dial))
    set(Front_cab_temp_req, 18 + 12 * get(Front_cab_temp_dial))
    set(Aft_cab_temp_req, 18 + 12 * get(Aft_cab_temp_dial))
    set(Aft_cargo_temp_req, 5 + 20 * get(Aft_cargo_temp_dial))
end

local function update_temp_from_valves()
    local mixer_temp = 0

    if get(Pack_L) == 0 and get(Pack_R) == 0 then  -- TODO ADD RAM AIR
        mixer_temp = get(OTA)
    elseif  get(Pack_L) == 0 then
        mixer_temp = get(L_pack_temp)
    elseif  get(Pack_R) == 0 then
        mixer_temp = get(R_pack_temp)
    else
        mixer_temp = (get(L_pack_temp) + get(R_pack_temp)) / 2 
    end
    
    set(Aircond_mixer_temp, mixer_temp)
    
    if get(Hot_air_valve_pos) == 0 then
        set(Hot_air_temp, 0)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CKPT), mixer_temp, -30, 200, 5), CKPT)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_FWD), mixer_temp, -30, 200, 5), CABIN_FWD)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_AFT), mixer_temp, -30, 200, 5), CABIN_AFT)
    else
        local hot_air_temp = math.max(get(L_bleed_temp), get(R_bleed_temp))
        set(Hot_air_temp, hot_air_temp)
        
        temp_duct_ckpt  = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CKPT))
        temp_duct_c_fwd = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CABIN_FWD))
        temp_duct_c_aft = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CABIN_AFT))
    
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CKPT), temp_duct_ckpt, -30, 200, 5), CKPT)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_FWD), temp_duct_c_fwd, -30, 200, 5), CABIN_FWD)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_AFT), temp_duct_c_aft, -30, 200, 5), CABIN_AFT)
    end
    

    -- The cargo injected air flow is took from the cabin, so let's assume an average value.    
    local cargo_flow_temp = (get(Front_cab_temp) + get(Aft_cab_temp))/2
    
    -- And the cargo heat air is added to it in a similar way we did previously
    if get(Hot_air_valve_pos_cargo) == 0 then
        set(Hot_air_temp_cargo, 0)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CARGO_AFT), cargo_flow_temp, -30, 100, 5), CARGO_AFT)
    else
        local hot_air_temp = math.max(get(L_bleed_temp), get(R_bleed_temp))
        set(Hot_air_temp_cargo, hot_air_temp)
        temp_duct_cargo  = Math_lerp(cargo_flow_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CARGO_AFT))
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CARGO_AFT), temp_duct_cargo, -30, 100, 5), CARGO_AFT)
    end
end

local function update_pack_valves()

    if get(Pack_L) == 0 then
        Set_dataref_linear_anim(L_pack_byp_valve, 0, 0, 1, 0.1)
    end
    if get(Pack_R) == 0 then
        Set_dataref_linear_anim(R_pack_byp_valve, 0, 0, 1, 0.1)
    end



    local curr_avg_value  = (get(Aircond_trim_valve, CKPT)
                           + get(Aircond_trim_valve, CABIN_FWD)
                           + get(Aircond_trim_valve, CABIN_AFT))
                           / 3
    local curr_error = curr_avg_value - 0.3 -- Let's try to keep the hot air valve to 0.3
    local actual_u = SSS_PID_BP_LIM(pid_arrays[PID_PACK_FLOW], curr_error)

    if get(Pack_L) == 1 then
        Set_dataref_linear_anim(L_pack_byp_valve, actual_u, 0, 1, 0.1)
    end
    if get(Pack_R) == 1  then
        Set_dataref_linear_anim(R_pack_byp_valve, actual_u, 0, 1, 0.1)
    end

end

local function run_pids()

    -- Cockpit
    -- ERROR: get(Cockpit_temp_req) - get(Cockpit_temp))
    -- CONTROL VARIABLE [0;1]: set(Aircond_trim_valve, trim, CKPT)
    
    local curr_err  = get(Cockpit_temp_req) - get(Cockpit_temp)
    local u = SSS_PID_BP_LIM(pid_arrays[CKPT], curr_err)
    set(Aircond_trim_valve, u, CKPT)

    -- Cabin FWD
    -- ERROR: get(Front_cab_temp_req) - get(Front_cab_temp)
    -- CONTROL VARIABLE [0;1]: set(Aircond_trim_valve, trim, CABIN_FWD)

    local curr_err  = get(Front_cab_temp_req) - get(Front_cab_temp)
    local u = SSS_PID_BP_LIM(pid_arrays[CABIN_FWD], curr_err)
    set(Aircond_trim_valve, u, CABIN_FWD)

    -- Cabin AFT
    -- ERROR: get(Aft_cab_temp_req) - get(Aft_cab_temp)
    -- CONTROL VARIABLE [0;1]: set(Aircond_trim_valve, trim, CABIN_AFT)

    local curr_err  = get(Aft_cab_temp_req) - get(Aft_cab_temp)
    local u = SSS_PID_BP_LIM(pid_arrays[CABIN_AFT], curr_err)
    set(Aircond_trim_valve, u, CABIN_AFT)

    -- Cargo AFT
    -- ERROR: get(Aft_cargo_temp_req) - get(Aft_cargo_temp)
    -- CONTROL VARIABLE [0;1]: set(Aircond_trim_valve, trim, CARGO_AFT)
    
    local curr_err  = get(Aft_cargo_temp_req) - get(Aft_cargo_temp)
    local u = SSS_PID_BP_LIM(pid_arrays[CARGO_AFT], curr_err)
    set(Aircond_trim_valve, u, CARGO_AFT)
    
end

function udpate_avio_temps()

    local temp_target_avio = (200 + get(TAT)) / 3
    local avio_heating = get(OVHR_elec_panel_pwrd) == 0 -- I'm using this value to know if some avionics is powered or not

    if avio_configuration == AVIO_SMOKE or avio_configuration == AVIO_OPEN or avio_heating then
        -- Temperature in such configurations is decreasing in the skin heat exchanger
        avio_skin_temperature = Set_linear_anim_value(avio_skin_temperature, get(TAT), -100, 150, 0.1)
    elseif avio_configuration == AVIO_CLOSED then
        avio_skin_temperature = Set_linear_anim_value(avio_skin_temperature, temp_target_avio*0.8, -100, 150, 0.2)    
    elseif avio_configuration == AVIO_INTERM then
        avio_skin_temperature = Set_linear_anim_value(avio_skin_temperature, temp_target_avio*0.6, -100, 150, 0.1)
    elseif avio_configuration == AVIO_ISOLATED then
        avio_skin_temperature = Set_linear_anim_value(avio_skin_temperature, temp_target_avio, -100, 150, 0.3)
    end

end

function udpate_avio_config()

    if get(Any_wheel_on_ground) == 1 and get(EWD_flight_phase) ~= PHASE_1ST_ENG_TO_PWR and get(EWD_flight_phase) ~= PHASE_ABOVE_80_KTS then
        -- If on ground and no takeoff power
    
        -- Reset the configuration to a valid ground configuration
        if avio_configuration ~= AVIO_CLOSED and avio_configuration ~= AVIO_OPEN then
            avio_configuration = AVIO_CLOSED
        end
    
        -- Threshold based when THR not in takeoff power
        if avio_configuration == AVIO_CLOSED and avio_skin_temperature > 12 then
            avio_configuration = AVIO_OPEN
        elseif avio_configuration == AVIO_OPEN and avio_skin_temperature < 9 then
            avio_configuration = AVIO_CLOSED        
        end
        
    else

        -- Reset the configuration to a valid flight configuration
        if avio_configuration ~= AVIO_CLOSED and avio_configuration ~= AVIO_INTERM then
            avio_configuration = AVIO_CLOSED
        end

        -- Threshold based when THR not in takeoff power
        if avio_configuration == AVIO_CLOSED and avio_skin_temperature > 12 then
            avio_configuration = AVIO_INTERM
        elseif avio_configuration == AVIO_INTERM and avio_skin_temperature < 9 then
            avio_configuration = AVIO_CLOSED        
        end
    end

    if get(FAILURE_AVIONICS_SMOKE) == 1 then
        avio_configuration = AVIO_SMOKE
    elseif get(Ventilation_blower_override) == 1 or get(Ventilation_extract_override) == 1 then
        avio_configuration = AVIO_ISOLATED
    end
end

function update_avio_valves()

    -- If a valve is not failed ...
    if get(FAILURE_AVIONICS_INLET) == 0 then
        if avio_configuration == AVIO_OPEN then
            Set_dataref_linear_anim(Ventilation_avio_inlet_valve, 10, 0, 10, 1+math.random())
        else
            Set_dataref_linear_anim(Ventilation_avio_inlet_valve, 0, 0, 10, 1+math.random())
        end
    end
    
    -- If a valve is not failed ...
    if get(FAILURE_AVIONICS_OUTLET) == 0 then
        if avio_configuration == AVIO_OPEN then
            Set_dataref_linear_anim(Ventilation_avio_outlet_valve, 10, 0, 10, 1+math.random())
        elseif avio_configuration == AVIO_SMOKE or avio_configuration == AVIO_INTERM  then
            Set_dataref_linear_anim(Ventilation_avio_outlet_valve, 5, 0, 10, 1+math.random())
        else
            Set_dataref_linear_anim(Ventilation_avio_outlet_valve, 0, 0, 10, 1+math.random())
        end
    end
end

function onAirportLoaded()
    reset_cabin_model()
end

function update()

    perf_measure_start("aircond:update()")

    update_knobs()
    update_avio_ventilation()
    udpate_avio_temps()
    udpate_avio_config()
    update_avio_valves()
    update_cabin_model()
    update_pack_valves()
    update_temp_from_valves()

    run_pids()

    perf_measure_stop("aircond:update()")
end
