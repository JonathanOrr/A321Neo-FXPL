include('aircond_cabinmodel.lua')
include('PID.lua')

----------------------------------------------------------------------------------------------------
-- AIR_CONDITIONING systems
----------------------------------------------------------------------------------------------------
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


sasl.registerCommandHandler ( ELEC_vent_blower, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Ventilation_blower, 1 - get(Ventilation_blower))
    end
end)

sasl.registerCommandHandler ( ELEC_vent_extract, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Ventilation_extract, 1 - get(Ventilation_extract))
    end
end)

--custom functions
local function update_avio_ventilation()
    set(Ventilation_light_blower, get(Ventilation_blower))      -- TODO Faults
    set(Ventilation_light_extract, get(Ventilation_extract))    -- TODO Faults
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

function onAirportLoaded()
    reset_cabin_model()
end

function update()

    update_knobs()
    update_avio_ventilation()
    update_cabin_model()
    update_pack_valves()
    update_temp_from_valves()

    run_pids()

end
