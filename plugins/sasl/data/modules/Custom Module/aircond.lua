include('aircond_cabinmodel.lua')

----------------------------------------------------------------------------------------------------
-- AIR_CONDITIONING systems
----------------------------------------------------------------------------------------------------
--a32NX datarefs

-- TODO Sim_pack_flow (check x plane manual for values)

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
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CKPT), mixer_temp, -10, 200, 5), CKPT)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_FWD), mixer_temp, -10, 200, 5), CABIN_FWD)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_AFT), mixer_temp, -10, 200, 5), CABIN_AFT)
    else
        local hot_air_temp = math.max(get(L_bleed_temp), get(R_bleed_temp))
        set(Hot_air_temp, hot_air_temp)
        
        temp_duct_ckpt  = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CKPT))
        temp_duct_c_fwd = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CABIN_FWD))
        temp_duct_c_aft = Math_lerp(mixer_temp, hot_air_temp, 0.2 * get(Aircond_trim_valve, CABIN_AFT))
    
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CKPT), temp_duct_ckpt, -10, 200, 5), CKPT)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_FWD), temp_duct_c_fwd, -10, 200, 5), CABIN_FWD)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CABIN_AFT), temp_duct_c_aft, -10, 200, 5), CABIN_AFT)
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
        print(temp_duct_cargo)
        set(Aircond_injected_flow_temp, Set_linear_anim_value(get(Aircond_injected_flow_temp, CARGO_AFT), temp_duct_cargo, -30, 100, 5), CARGO_AFT)
    end
end

local function update_pack_valves()

    if get(TIME) - pack_valves_last_update < 10 then -- Update the pack valves every 10 sec
        return
    end
    pack_valves_last_update = get(TIME)

    if math.max(get(Aircond_trim_valve, CKPT), get(Aircond_trim_valve, CABIN_FWD), get(Aircond_trim_valve, CABIN_AFT)) > 0.9 then
        -- Too much hot hair, let's increase the bypass valve
        set(L_pack_byp_valve, math.min(1, get(L_pack_byp_valve) + 0.1))
        set(R_pack_byp_valve, math.min(1, get(R_pack_byp_valve) + 0.1))
    elseif math.min(get(Aircond_trim_valve, CKPT), get(Aircond_trim_valve, CABIN_FWD), get(Aircond_trim_valve, CABIN_AFT)) < 0.1 then
        set(L_pack_byp_valve, math.max(0, get(L_pack_byp_valve) - 0.1))     
        set(R_pack_byp_valve, math.max(0, get(R_pack_byp_valve) - 0.1))
    end

end

local function run_pids()

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
