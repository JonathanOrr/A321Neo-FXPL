----------------------------------------------------------------------------------------------------
-- BLEED & PACKS systems
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

ENG_NOMINAL_MAX_PRESS = 56
ENG_NOMINAL_MIN_PRESS = 38
APU_NOMINAL_PRESS = 42

GAS_PRESSURE = 39

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

----------------------------------------------------------------------------------------------------
-- Global variables
----------------------------------------------------------------------------------------------------
local eng_bleed_switch    = {true, true}
local eng_bleed_valve_pos = {false, false}

local apu_bleed_switch    = false
local apu_bleed_valve_pos = false

local gas_is_providing_air = false

local x_bleed_status = false

local eng_lp_pressure     = {0,0}
local apu_pressure        = 0
local bleed_consumption   = {0,0}
local bleed_pressure      = {0,0}

----------------------------------------------------------------------------------------------------
-- Initialisation
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler(Pack_flow_dial_up, 0, function(phase) Knob_handler_up_int(phase, A321_Pack_Flow_dial, 0, 2) end)
sasl.registerCommandHandler(Pack_flow_dial_dn, 0, function(phase) Knob_handler_down_int(phase, A321_Pack_Flow_dial, 0, 2) end)
sasl.registerCommandHandler(X_bleed_dial_up, 0, function(phase) Knob_handler_up_int(phase, X_bleed_dial, 0, 2) end)
sasl.registerCommandHandler(X_bleed_dial_dn, 0, function(phase) Knob_handler_down_int(phase, X_bleed_dial, 0, 2) end)

sasl.registerCommandHandler (Toggle_apu_bleed, 0,  function(phase) if phase == SASL_COMMAND_BEGIN then apu_bleed_switch = not apu_bleed_switch end end)
sasl.registerCommandHandler (Toggle_eng1_bleed, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_bleed_switch[1] = not eng_bleed_switch[1] end end)
sasl.registerCommandHandler (Toggle_eng2_bleed, 0, function(phase) if phase == SASL_COMMAND_BEGIN then eng_bleed_switch[2] = not eng_bleed_switch[2] end end)

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

local function update_override()
    if override_BLEED_always_ok then
        -- TODO
    end
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
                             and (get(Fire_pb_ENG1_status) == 0) and not apu_bleed_valve_pos
                             
    eng_bleed_valve_pos[2] = eng_bleed_switch[2] and (eng_lp_pressure[2] >= 8) 
                             and (get(Fire_pb_ENG2_status) == 0) and not apu_bleed_valve_pos   


    --X bleed valve logic--
    if get(X_bleed_dial) == 0 then --closed
        x_bleed_status = false
    elseif get(X_bleed_dial) == 1 then --auto
        x_bleed_status = apu_bleed_valve_pos
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
end

local function update_apu_pressure()
    target = get(Apu_avail) == 1 and APU_NOMINAL_PRESS or 0
    apu_pressure = Set_anim_value(apu_pressure, target, 0, APU_NOMINAL_PRESS, 0.85)
end

local function update_bleed_consumption()
    -- Left side
    bleed_consumption[1] = get(AI_wing_L_operating) * LOSS_PSI_WING_ANTICE_L
                         + get(Cargo_hot_air) * LOSS_PSI_CARGO_HEAT
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
    if gas_is_providing_air then
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

    bleed_pressure[1] = Set_anim_value(bleed_pressure[1], left_side_press, 0, 100, 0.7)
    bleed_pressure[2] = Set_anim_value(bleed_pressure[2], right_side_press, 0, 100, 0.7)

end

local function update_datarefs()

    -- XP System
    set(ENG_1_bleed_switch, eng_bleed_valve_pos[1] and 1 or 0)
    set(ENG_2_bleed_switch, eng_bleed_valve_pos[2] and 1 or 0)
    set(Apu_bleed_switch, apu_bleed_valve_pos and 1 or 0)
    set(X_bleed_valve, x_bleed_status and 1 or 0)
    set(Left_pack_iso_valve, 1) -- In X-Plane system APU always connected to ENG1
    set(Right_pack_iso_valve, get(X_bleed_valve))
    set(Pack_M, 0)--turning the center pack off as A320 doesn't have one        

    -- Pressures and temps
    set(Apu_bleed_psi, apu_pressure)
    set(L_bleed_press, bleed_pressure[1])
    set(R_bleed_press, bleed_pressure[2])

    -- Buttons
    set(Eng1_bleed_off_button, get(OVHR_elec_panel_pwrd) * (eng_bleed_switch[1] and 0 or 1))
    set(Eng2_bleed_off_button, get(OVHR_elec_panel_pwrd) * (eng_bleed_switch[2] and 0 or 1))
    set(APU_bleed_on_button,   get(OVHR_elec_panel_pwrd) * (apu_bleed_switch and 1 or 0))
    

    -- ECAM stuffs
    set(L_bleed_state, get(Engine_1_avail) * (eng_bleed_switch[1] and 2 or 1))
    set(R_bleed_state, get(Engine_2_avail) * (eng_bleed_switch[2] and 2 or 1))
    if apu_bleed_valve_pos and not x_bleed_status then
        set(X_bleed_bridge_state, 1)--bridged but closed
    else
        set(X_bleed_bridge_state, x_bleed_status and 2 or 0)
    end
    
end

function update()
    --create the A321 pack system--

    update_apu_pressure()
    update_eng_pressures()
    update_bleed_valves()
    update_hp_valves()
    update_bleed_consumption()
    update_bleed_pressures()

    update_datarefs()






    --PACKs logic--
    if get(Left_bleed_avil) > 0.1 then
        if (get(X_bleed_valve) == 1 and get(Engine_mode_knob) == 1) or (get(X_bleed_valve) == 1 and get(Engine_mode_knob) == -1) then
            set(Pack_L, 0)
        else
            set(Pack_L, 1)
        end
    else
        set(Pack_L, 0)
    end

    if get(Right_bleed_avil) > 0.1 then
        if (get(X_bleed_valve) == 1 and get(Engine_mode_knob) == 1) or (get(X_bleed_valve) == 1 and get(Engine_mode_knob) == -1) then
            set(Pack_R, 0)
        else
            set(Pack_R, 1)
        end
    else
        set(Pack_R, 0)
    end

    --PACKs flow logic--
    if (get(Pack_L) == 0 and get(Pack_R) == 1) or (get(Pack_L) == 1 and get(Pack_R) == 0) or get(Apu_bleed_switch) == 1 then
        set(Sim_pack_flow, 2)
        if get(Pack_L) == 0 and get(Pack_R) == 1 then
            if get(Right_bleed_avil) > 0.1 then
                set(R_pack_Flow, 2)
            else
                set(R_pack_Flow, 0)
            end
        elseif get(Pack_L) == 1 and get(Pack_R) == 0 then
            if get(Left_bleed_avil) > 0.1 then
                set(L_pack_Flow, 2)
            else
                set(L_pack_Flow, 0)
            end
        elseif get(Apu_bleed_switch) == 1 and get(Apu_avail) == 1 then
            if get(Left_bleed_avil) > 0.1 and get(Right_bleed_avil) > 0.1 then
                set(L_pack_Flow, 2)
                set(R_pack_Flow, 2)
            else
                set(L_pack_Flow, 0)
                set(R_pack_Flow, 0)
            end
        end
    else
        if get(A321_Pack_Flow_dial) == 0 then
            set(Sim_pack_flow, 1) --low pack flow
            if get(Left_bleed_avil) > 0.1 and get(Right_bleed_avil) > 0.1 then--if air bleed air avail
                set(L_pack_Flow, 0)
                set(R_pack_Flow, 0)
            else
                set(L_pack_Flow, 0)
                set(R_pack_Flow, 0)
            end
        elseif get(A321_Pack_Flow_dial) == 1 then
            set(Sim_pack_flow, 0) --norm pack flow
            if get(Left_bleed_avil) > 0.1 and get(Right_bleed_avil) > 0.1 then--if air bleed air avail
                set(L_pack_Flow, 1)
                set(R_pack_Flow, 1)
            else
                set(L_pack_Flow, 0)
                set(R_pack_Flow, 0)
            end
        elseif get(A321_Pack_Flow_dial) == 2 then
            set(Sim_pack_flow, 2) --high pack flow
            if get(Left_bleed_avil) > 0.1 and get(Right_bleed_avil) > 0.1 then--if air bleed air avail
                set(L_pack_Flow, 2)
                set(R_pack_Flow, 2)
            else
                set(L_pack_Flow, 0)
                set(R_pack_Flow, 0)
            end
        end
    end

    --packs flow avail--
    if (get(Pack_L) == 1 and get(Left_bleed_avil) > 0.1) or (get(Pack_R) == 1 and get(Right_bleed_avil) > 0.1) then
        set(Packs_avail, 1)
    else
        set(Packs_avail, 0)
    end

    --PACKs systems temperature--
    if get(Left_bleed_avil) > 0.1 then
        if get(Pack_L) == 1 then
            if get(Apu_bleed_switch) == 1 and get(Apu_avail) == 1 then --apu bleeding
                set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), 150, -100, 200, 0.35))
                set(L_pack_temp, Set_anim_value(get(L_pack_temp), (get(Cockpit_temp_req) + get(Front_cab_temp_req))/2, -100, 100, 0.35))
            else --engine bleeding
                set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), 190, -100, 200, 0.35))
                if get(Pack_R) == 1 and get(Right_bleed_avil) > 0.1 then
                    set(L_pack_temp, Set_anim_value(get(L_pack_temp), (get(Cockpit_temp_req) + get(Front_cab_temp_req))/2, -100, 100, 0.35))
                else
                    set(L_pack_temp, Set_anim_value(get(L_pack_temp), math.max(get(Cockpit_temp_req), get(Front_cab_temp_req), get(Aft_cab_temp_req)), -100, 100, 0.35))
                end
            end
        else --left pack not on
            set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), get(OTA), -100, 200, 0.35))
            set(L_pack_temp, Set_anim_value(get(L_pack_temp), get(OTA), -100, 100, 0.35))
        end
    else --left bleed not avail
        set(L_compressor_temp, Set_anim_value(get(L_compressor_temp), get(OTA), -100, 200, 0.35))
        set(L_pack_temp, Set_anim_value(get(L_pack_temp), get(OTA), -100, 100, 0.35))
    end

    if get(Right_bleed_avil) > 0.1 then
        if get(Pack_R) == 1 then
            if get(Apu_bleed_switch) == 1 and get(Apu_avail) == 1 then --apu bleeding
                set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), 150, -100, 200, 0.35))
                set(R_pack_temp, Set_anim_value(get(R_pack_temp), (get(Front_cab_temp_req) + get(Aft_cab_temp_req))/2, -100, 100, 0.35))
            else --engine bleeding
                set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), 190, -100, 200, 0.35))
                if get(Pack_L) == 1 and get(Left_bleed_avil) > 0.1 then
                    set(R_pack_temp, Set_anim_value(get(R_pack_temp), (get(Front_cab_temp_req) + get(Aft_cab_temp_req))/2, -100, 100, 0.35))
                else
                    set(R_pack_temp, Set_anim_value(get(R_pack_temp), math.max(get(Cockpit_temp_req), get(Front_cab_temp_req), get(Aft_cab_temp_req)), -100, 100, 0.35))
                end
            end
        else --right pack not on
            set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), get(OTA), -100, 200, 0.35))
            set(R_pack_temp, Set_anim_value(get(R_pack_temp), get(OTA), -100, 100, 0.35))
        end
    else --right bleed not avail
        set(R_compressor_temp, Set_anim_value(get(R_compressor_temp), get(OTA), -100, 200, 0.35))
        set(R_pack_temp, Set_anim_value(get(R_pack_temp), get(OTA), -100, 100, 0.35))
    end

    --bleed temp--
    if get(Left_bleed_avil) > 0.1 then--left side has bleed air and is in the apu bleed range
        if get(Left_bleed_avil) > 1.2 then--left side has bleed air and is in the eng bleed range
            set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), 190, -100, 200, 0.35))--eng bleed with 190C
        else--apu bleed
            set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), 150, -100, 200, 0.35))--apu bleed with 150C
        end
    else
        set(L_bleed_temp, Set_anim_value(get(L_bleed_temp), get(OTA), -100, 200, 0.35))--no bleed with outside temp
    end

    if get(Right_bleed_avil) > 0.1 then--right side has bleed air and is in the apu bleed range
        if get(Right_bleed_avil) > 1.2 then--right side has bleed air and is in the eng bleed range
            set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), 190, -100, 200, 0.35))--eng bleed with 190C
        else--apu bleed
            set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), 150, -100, 200, 0.35))--apu bleed with 150C
        end
    else
        set(R_bleed_temp, Set_anim_value(get(R_bleed_temp), get(OTA), -100, 200, 0.35))--no bleed with outside temp
    end

    update_override()
end
