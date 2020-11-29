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
-- File: packs.lua 
-- Short description: BLEED & PACKS systems
-------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

ENG_NOMINAL_MAX_PRESS = 56
ENG_NOMINAL_MIN_PRESS = 38
APU_NOMINAL_PRESS = 42

GAS_PRESSURE = 45

BLEED_UP_TARGET = 40
BLEED_LO_TARGET = 34

LOSS_PSI_HYD           = 0.5
LOSS_PSI_WATER_TANK    = 0.5
LOSS_PSI_CARGO_HEAT    = 1
LOSS_PSI_WING_ANTICE_L = 3
LOSS_PSI_WING_ANTICE_R = 3
LOSS_PSI_PACK_L        = 3
LOSS_PSI_PACK_R        = 3
LOSS_PSI_ENG_CRANK     = 6

PACK_KG_PER_SEC_NOM    = 1

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local eng_bleed_switch    = {true, true}
local eng_bleed_valve_pos = {false, false}
local pack_valve_switch   = {true, true}
local pack_valve_pos      = {false, false}

local apu_bleed_switch    = false
local apu_bleed_valve_pos = false

local econ_flow_switch = false

local x_bleed_status = false
local ditching_switch = false

local eng_lp_pressure      = {0,0}
local apu_pressure         = 0
local bleed_consumption    = {0,0}
local bleed_pressure       = {0,0}
local pack_time_open_valve = {0,0}

local cabin_hot_air    = true
local cargo_hot_air    = true
local cargo_isol_valve = false
local ram_air_status   = false

local cabin_fan_switch = true

----------------------------------------------------------------------------------------------------
-- Initialisation
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler(Toggle_ECON_flow, 0, function(phase) if phase == SASL_COMMAND_BEGIN then econ_flow_switch = not econ_flow_switch end end)
sasl.registerCommandHandler(X_bleed_dial_up, 0, function(phase) Knob_handler_up_int(phase, X_bleed_dial, 0, 2) end)
sasl.registerCommandHandler(X_bleed_dial_dn, 0, function(phase) Knob_handler_down_int(phase, X_bleed_dial, 0, 2) end)

sasl.registerCommandHandler (Toggle_apu_bleed, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then apu_bleed_switch = not apu_bleed_switch end end)
sasl.registerCommandHandler (Toggle_eng1_bleed, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_bleed_switch[1] = not eng_bleed_switch[1] end end)
sasl.registerCommandHandler (Toggle_eng2_bleed, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_bleed_switch[2] = not eng_bleed_switch[2] end end)
sasl.registerCommandHandler (Toggle_pack1, 0, function(phase) if phase == SASL_COMMAND_BEGIN then pack_valve_switch[1] = not pack_valve_switch[1] end end)
sasl.registerCommandHandler (Toggle_pack2, 0, function(phase) if phase == SASL_COMMAND_BEGIN then pack_valve_switch[2] = not pack_valve_switch[2] end end)
sasl.registerCommandHandler (Press_ditching, 0, function(phase) if phase == SASL_COMMAND_BEGIN then ditching_switch = not ditching_switch end end)

sasl.registerCommandHandler (Toggle_cab_hotair,          0, function(phase) if phase == SASL_COMMAND_BEGIN then cabin_hot_air    = not cabin_hot_air end end)
sasl.registerCommandHandler (Toggle_cargo_hotair,        0, function(phase) if phase == SASL_COMMAND_BEGIN then cargo_hot_air    = not cargo_hot_air end end)
sasl.registerCommandHandler (Toggle_aft_cargo_iso_valve, 0, function(phase) if phase == SASL_COMMAND_BEGIN then cargo_isol_valve = not cargo_isol_valve end end)

sasl.registerCommandHandler (Toggle_ram_air, 0, function(phase) if phase == SASL_COMMAND_BEGIN then ram_air_status = not ram_air_status end end)
sasl.registerCommandHandler (Toggle_cab_fan, 0, function(phase) if phase == SASL_COMMAND_BEGIN then cabin_fan_switch = not cabin_fan_switch end end)


function onPlaneLoaded()
    set(Pack_L, 1)
    set(Pack_M, 0)
    set(Pack_R, 1)
    set(Left_pack_iso_valve, 1)
    set(Right_pack_iso_valve, 0)
end

function onAirportLoaded()
    set(Pack_L, 1)
    set(Pack_M, 0)
    set(Pack_R, 1)
    set(Left_pack_iso_valve, 1)
    set(Right_pack_iso_valve, 0)
end

local function update_hp_valves()

    -- HP valve keep pressure in the range 32-40
    if get(Engine_1_avail) == 1 and eng_bleed_switch[1] and get(L_bleed_press) <= BLEED_LO_TARGET then
        set(L_HP_valve, 1)
    elseif get(Engine_1_avail) == 0 or (not eng_bleed_switch[1]) or get(L_bleed_press) > BLEED_UP_TARGET then
        set(L_HP_valve, 0)
    end

    if get(Engine_2_avail) == 1 and eng_bleed_switch[2] and get(R_bleed_press) <= BLEED_LO_TARGET then
        set(R_HP_valve, 1)
    elseif get(Engine_2_avail) == 0 or (not eng_bleed_switch[2]) or get(R_bleed_press) > BLEED_UP_TARGET then
        set(R_HP_valve, 0)
    end

end

local function update_bleed_valves()

    -- TODO Failures

    apu_bleed_valve_pos = get(Apu_N1) > 95 and apu_bleed_switch

    eng_bleed_valve_pos[1] = eng_bleed_switch[1] and (eng_lp_pressure[1] >= 8) 
                             and (get(Fire_pb_ENG1_status) == 0) and not apu_bleed_valve_pos and get(GAS_bleed_avail) == 0
                             
    eng_bleed_valve_pos[2] = eng_bleed_switch[2] and (eng_lp_pressure[2] >= 8) 
                             and (get(Fire_pb_ENG2_status) == 0) and not apu_bleed_valve_pos and get(GAS_bleed_avail) == 0


    --X bleed valve logic--
    if get(X_bleed_dial) == 0 then --closed
        x_bleed_status = false
    elseif get(X_bleed_dial) == 1 then --auto
        x_bleed_status = apu_bleed_valve_pos or get(GAS_bleed_avail) == 1
    elseif get(X_bleed_dial) == 2 then --open
        x_bleed_status = true
    end

end

local function update_eng_pressures()
    if get(Engine_1_avail) == 0 then
        eng_lp_pressure[1] = Set_linear_anim_value(eng_lp_pressure[1], 0, 0, 100, 1)
    else
        local target = Math_rescale(18, ENG_NOMINAL_MIN_PRESS, 101, ENG_NOMINAL_MAX_PRESS, get(Eng_1_N1)) + math.random()
        eng_lp_pressure[1] = Set_linear_anim_value(eng_lp_pressure[1], target, 0, 100, 1)
    end
    
    if get(Engine_2_avail) == 0 then
        eng_lp_pressure[2] = Set_linear_anim_value(eng_lp_pressure[2], 0, 0, 100, 1)
    else
        local target = Math_rescale(18, ENG_NOMINAL_MIN_PRESS, 101, ENG_NOMINAL_MAX_PRESS, get(Eng_2_N1)) + math.random()
        eng_lp_pressure[2] = Set_linear_anim_value(eng_lp_pressure[2], target, 0, 100, 1)
    end
    
    set(L_Eng_LP_press, eng_lp_pressure[1])
    set(R_Eng_LP_press, eng_lp_pressure[2])
    
end

local function update_apu_pressure()
    target = get(Apu_avail) == 1 and APU_NOMINAL_PRESS or 0
    apu_pressure = Set_anim_value(apu_pressure, target, 0, APU_NOMINAL_PRESS, 0.85)
end

local function update_bleed_consumption()
    -- Left side
    bleed_consumption[1] = get(AI_wing_L_operating) * LOSS_PSI_WING_ANTICE_L
                         + get(Hot_air_valve_pos_cargo) * LOSS_PSI_CARGO_HEAT
                         + LOSS_PSI_HYD/2
                         + LOSS_PSI_WATER_TANK/2
                         + get(Pack_L) * LOSS_PSI_PACK_L
                         + get(Eng_is_spooling_up, 1) * LOSS_PSI_ENG_CRANK
    
    -- Right side
    bleed_consumption[2] = get(AI_wing_R_operating) * LOSS_PSI_WING_ANTICE_R
                         + LOSS_PSI_HYD/2
                         + LOSS_PSI_WATER_TANK/2
                         + get(Pack_R) * LOSS_PSI_PACK_R
                         + get(Eng_is_spooling_up, 2) * LOSS_PSI_ENG_CRANK

end

local function update_bleed_pressures()

    local left_side_press = 0
    if eng_bleed_valve_pos[1] then
        left_side_press = left_side_press + eng_lp_pressure[1] + get(L_HP_valve) * 10
    end
    if apu_bleed_valve_pos then
        left_side_press = left_side_press + apu_pressure
    end
    if get(GAS_bleed_avail) == 1 then
        left_side_press = left_side_press + GAS_PRESSURE + math.random()
    end

    local right_side_press = 0
    if eng_bleed_valve_pos[2] then
        right_side_press = right_side_press + eng_lp_pressure[2] + get(R_HP_valve) * 10
    end



    if x_bleed_status then
        if left_side_press > right_side_press then
            left_side_press  = left_side_press - bleed_consumption[1] - bleed_consumption[2]
            right_side_press = left_side_press 
        else
            right_side_press  = right_side_press - bleed_consumption[1] - bleed_consumption[2]
            left_side_press  = right_side_press  
        end
        
        
    else
        left_side_press  = left_side_press - bleed_consumption[1]
        right_side_press = right_side_press - bleed_consumption[2]
    end
    
    left_side_press  = math.max(0, left_side_press)
    right_side_press = math.max(0, right_side_press)

    bleed_pressure[1] = Set_anim_value(bleed_pressure[1], left_side_press, 0, 100, 0.6)
    bleed_pressure[2] = Set_anim_value(bleed_pressure[2], right_side_press, 0, 100, 0.6)

end

local function set_overhead_dr(dataref, condition_btm_light, condition_fault)
    set(dataref, get(OVHR_elec_panel_pwrd) * ((condition_btm_light and 1 or 0) + (condition_fault and 10 or 0)))
end

local function update_datarefs()

    -- XP System
    set(ENG_1_bleed_switch, eng_bleed_valve_pos[1] and 1 or 0)
    set(ENG_2_bleed_switch, eng_bleed_valve_pos[2] and 1 or 0)
    set(Apu_bleed_switch, apu_bleed_valve_pos and 1 or 0)
    set(X_bleed_valve, x_bleed_status and 1 or 0)
    set(Left_pack_iso_valve, 1) -- In X-Plane system APU always connected to ENG1
    set(Right_pack_iso_valve, get(X_bleed_valve))
    set(Pack_L, pack_valve_pos[1] and 1 or 0)
    set(Pack_M, 0)--turning the center pack off as A320 doesn't have one        
    set(Pack_R, pack_valve_pos[2] and 1 or 0)
    set(Gpu_bleed_switch, get(GAS_bleed_avail))

    -- Pressures and temps
    set(Apu_bleed_psi, apu_pressure)
    set(L_bleed_press, bleed_pressure[1])
    set(R_bleed_press, bleed_pressure[2])

    -- Buttons
    -- TODO FAULTS
    local cond_eng1_bleed_fail = get(FAILURE_BLEED_HP_1_VALVE_STUCK) + get(FAILURE_BLEED_IP_1_VALVE_STUCK) > 0  -- TODO other conditions
    local cond_eng2_bleed_fail = get(FAILURE_BLEED_HP_2_VALVE_STUCK) + get(FAILURE_BLEED_IP_2_VALVE_STUCK) > 0  -- TODO other conditions

    pb_set(PB.ovhd.ac_bleed_1, not eng_bleed_switch[1], cond_eng1_bleed_fail)
    pb_set(PB.ovhd.ac_bleed_2, not eng_bleed_switch[2], cond_eng2_bleed_fail)
    pb_set(PB.ovhd.ac_bleed_apu, apu_bleed_switch, false) -- TODO FAILURE
    pb_set(PB.ovhd.ac_hot_air,  not cabin_hot_air, false) -- TODO FAILURE
    pb_set(PB.ovhd.ac_pack_1, not pack_valve_switch[1], false) -- TODO FAILURE
    pb_set(PB.ovhd.ac_pack_2, not pack_valve_switch[2], false) -- TODO FAILURE

    pb_set(PB.ovhd.ac_ram_air, get(Emer_ram_air) == 1, false) -- RAM air button does not have fault
    pb_set(PB.ovhd.ac_econ_flow, econ_flow_switch, false) -- ECON FLOW air button does not have fault

    pb_set(PB.ovhd.cargo_hot_air, not cargo_hot_air, false) -- TODO FAILURE
    pb_set(PB.ovhd.cargo_aft_isol, cargo_isol_valve, false) -- TODO FAILURE

    pb_set(PB.ovhd.press_ditching, ditching_switch, false)
    
    set(Press_ditching_enabled, ditching_switch and 1 or 0)
    
    -- ECAM stuffs
    if apu_bleed_valve_pos and not x_bleed_status then
        set(X_bleed_bridge_state, 1)--bridged but closed
    else
        set(X_bleed_bridge_state, x_bleed_status and 2 or 0)
    end

end

local function update_pack(n)

    -- PACK valve logic: 
    -- Closed if:
    -- - Pushbutton pressed
    -- - No bleed pressure
    -- - Packs Overheat TODO
    -- - Fire button corresponding engine pressed
    -- - During engine start if:
    --   - if X BLEED = closed: when IGN mode, close the side of engine not started until N2 >= 50
    --   - if X BLEED = open: both pack closes
    -- - On ground it remains closed for 30 seconds after an open command
    -- - Ditching pushbutton pressed
    
    local fire_push_button_status = (n == 1 and get(Fire_pb_ENG1_status) == 1) or (n == 2 and get(Fire_pb_ENG2_status) == 1) 
    local eng_n2 = n == 1 and get(Eng_1_N2) or get(Eng_2_N2)
    local both_eng_avail = get(Engine_1_avail) == 1 and get(Engine_2_avail) == 1
    
    if  pack_valve_switch[n] 
    and bleed_pressure[n] > 4 
    and (not fire_push_button_status) 
    and (get(Engine_mode_knob) == 0 or ((not x_bleed_status) and (eng_n2 >= 50)) or both_eng_avail)
    and (not ditching_switch)
    then
        
        if get(Engine_mode_knob) ~= 0 and get(All_on_ground) == 1 then
                -- If in flight, packs open after 30 second
            if pack_time_open_valve[n] == 0 then
                pack_time_open_valve[n] = get(TIME)
            elseif get(TIME) - pack_time_open_valve[n] > 30 then
                pack_valve_pos[n] = true
            end
        else    -- If in flight, packs open immediately
            pack_valve_pos[n] = true
        end    
    else
        pack_valve_pos[n] = false
        pack_time_open_valve[n] = 0 -- Reset
    end
end

local function update_bleed_temperatures()
    --bleed temp--
    if bleed_pressure[1] > 4 then--left side has bleed air
        if not apu_bleed_valve_pos then
            set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), 180 + bleed_pressure[1]/2 + math.random()*3, -100, 250, 0.2))--eng bleed with 190C
        else--apu bleed
            set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), 150 + bleed_pressure[1]/2 + math.random()*3, -100, 250, 0.2))--apu bleed with 150C
        end
    else
        set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), get(OTA), -100, 200, 0.15))--no bleed with outside temp
    end

    if bleed_pressure[2] > 4 then--right side has bleed air
        if not apu_bleed_valve_pos then
            set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), 180 + bleed_pressure[2]/2 + math.random()*3, -100, 250, 0.2))--eng bleed with 190C
        else--apu bleed
            set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), 150 + bleed_pressure[2]/2 + math.random()*3, -100, 250, 0.2))--apu bleed with 150C
        end
    else
        set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), get(OTA), -100, 200, 0.15))--no bleed with outside temp
    end
end

local function update_hot_air()
    -- TODO Failures
    
    if get(L_pack_Flow) + get(R_pack_Flow) > 0 then
        set(Hot_air_valve_pos, cabin_hot_air and 1 or 0)
    else
        set(Hot_air_valve_pos, 0)
    end
    
    if cargo_isol_valve or ditching_switch then
        set(Cargo_isol_in_valve, 0)
        set(Cargo_isol_out_valve, 0)
        set(Hot_air_valve_pos_cargo, 0)
    else
        set(Cargo_isol_in_valve, 1)
        set(Cargo_isol_out_valve, 1)
        set(Hot_air_valve_pos_cargo, (get(L_pack_Flow) + get(R_pack_Flow) > 0 and cargo_hot_air) and 1 or 0)
    end

end

local function update_pack_flow()

    local single_pack_operation = (get(Pack_L) == 0 and get(Pack_R) == 1) or (get(Pack_L) == 1 and get(Pack_R) == 0)
    
    -- If in single pack operation or APU providing bleed or GAS or require strong cooling, then manual settings doesn't matter, go for HI
    if single_pack_operation or apu_bleed_valve_pos or get(GAS_bleed_avail) == 1 or get(L_pack_byp_valve) < 0.1 or get(R_pack_byp_valve) < 0.1 then
        if get(Pack_L) == 1 then
            set(L_pack_Flow, 3)
            Set_dataref_linear_anim(L_pack_Flow_value, 1.2*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
        else
            set(L_pack_Flow, 0)
            Set_dataref_linear_anim(L_pack_Flow_value, 0, 0, 2000, 0.1)
        end
        
        if get(Pack_R) == 1 then
            set(R_pack_Flow, 3)
            Set_dataref_linear_anim(R_pack_Flow_value, 1.2*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
        else
            set(R_pack_Flow, 0)
            Set_dataref_linear_anim(R_pack_Flow_value, 0, 0, 2000, 0.1)
        end
        return
    end

    local mult_L = get(Pack_L) == 1 and 1 or 0
    local mult_R = get(Pack_R) == 1 and 1 or 0

    if econ_flow_switch then    -- LO flow
        set(L_pack_Flow, mult_L * 1)
        set(R_pack_Flow, mult_R * 1)
        Set_dataref_linear_anim(L_pack_Flow_value, mult_L*0.8*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
        Set_dataref_linear_anim(R_pack_Flow_value, mult_R*0.8*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
    else                        -- NORM flow
        set(L_pack_Flow, mult_L * 2)
        set(R_pack_Flow, mult_R * 2)
        Set_dataref_linear_anim(L_pack_Flow_value, mult_L*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
        Set_dataref_linear_anim(R_pack_Flow_value, mult_R*PACK_KG_PER_SEC_NOM, 0, 2000, 0.1)
    end

end

local function update_pack_temperatures()
    --PACKs systems temperature--
    if get(Pack_L) == 1 and get(L_pack_Flow) > 0 then
        -- Compressor temp
        local max_temp = get(L_bleed_temp)
        local temp_corrected_flow = max_temp - 20 * (3-get(L_pack_Flow))
        set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), temp_corrected_flow, -100, 250, 0.1))
        
        base_temp = 5 + 25 * get(L_pack_byp_valve)
        set(L_pack_temp, Set_anim_value(get(L_pack_temp), base_temp + math.random()*1, -100, 100, 0.1))
    else --left bleed not avail
        set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), get(OTA), -100, 200, 0.05))
        set(L_pack_temp, Set_anim_value(get(L_pack_temp), get(OTA), -100, 100, 0.05))
    end

    if get(Pack_R) == 1 and get(R_pack_Flow) > 0 then
        -- Compressor temp
        local max_temp = get(R_bleed_temp)
        local temp_corrected_flow = max_temp - 20 * (3-get(R_pack_Flow))
        set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), temp_corrected_flow, -100, 250, 0.1))
        
        base_temp = 5 + 25 * get(R_pack_byp_valve)
        set(R_pack_temp, Set_anim_value(get(R_pack_temp), base_temp + math.random()*2, -100, 100, 0.1))
    else --left bleed not avail
        set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), get(OTA), -100, 200, 0.05))
        set(R_pack_temp, Set_anim_value(get(R_pack_temp), get(OTA), -100, 100, 0.05))
    end

end

local function update_ram_air()
    set(Emer_ram_air, (ram_air_status and not ditching_switch) and 1 or 0)
end

local function update_fans()
    if cabin_fan_switch and not ditching_switch then
        local can_fwd_running = get(AC_bus_1_pwrd) == 1 and get(DC_bus_1_pwrd) == 1 and get(FAILURE_AIRCOND_FAN_FWD) == 0
        set(Cab_fan_fwd_running, can_fwd_running and 1 or 0)

        local can_aft_running = get(AC_bus_2_pwrd) == 1 and get(DC_bus_2_pwrd) == 1 and get(FAILURE_AIRCOND_FAN_AFT) == 0
        set(Cab_fan_aft_running, can_aft_running and 1 or 0)
    else
        set(Cab_fan_fwd_running, 0)
        set(Cab_fan_aft_running, 0)
    end
    
    if get(Cab_fan_fwd_running) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_1, 0.75, 0.75)
    end

    if get(Cab_fan_aft_running) == 1 then
        ELEC_sys.add_power_consumption(ELEC_BUS_AC_2, 0.75, 0.75)
    end
    
    pb_set(PB.ovhd.vent_cab_fans, not cabin_fan_switch, false)
end

function update()
    perf_measure_start("packs:update()")
    --create the A321 pack system--

    update_apu_pressure()
    update_eng_pressures()
    update_bleed_valves()
    update_hp_valves()
    update_bleed_consumption()
    update_bleed_pressures()
    update_bleed_temperatures()
    update_pack(1)
    update_pack(2)
    update_hot_air()
    update_pack_flow()
    update_pack_temperatures()
    update_ram_air()
    
    update_datarefs()
    update_fans()

    -- Fix GAS if moving
     if get(Ground_speed_ms) > 0.1 or get(Parkbrake_switch_pos) < 1 or get(All_on_ground) ~= 1 then
        set(GAS_bleed_avail, 0)
     end
    perf_measure_stop("packs:update()")

end
