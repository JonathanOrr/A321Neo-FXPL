--local variables

--sim dataref
local avionics = globalProperty("sim/cockpit2/switches/avionics_power_on")
local apu_start_position = globalProperty("sim/cockpit2/electrical/APU_starter_switch")
local apu_gen = globalProperty("sim/cockpit2/electrical/APU_generator_on")
local apu_flap_open_ratio = globalProperty("sim/cockpit2/electrical/APU_door")
local engine_1_ignition_switch = globalProperty("sim/cockpit2/engine/actuators/ignition_key[0]")
local engine_2_ignition_switch = globalProperty("sim/cockpit2/engine/actuators/ignition_key[1]")
local engine_1_mixture = globalProperty("sim/cockpit2/engine/actuators/mixture_ratio[0]")
local engine_2_mixture = globalProperty("sim/cockpit2/engine/actuators/mixture_ratio[1]")
local engine_1_N2 = globalProperty("sim/cockpit2/engine/indicators/N2_percent[0]")
local engine_2_N2 = globalProperty("sim/cockpit2/engine/indicators/N2_percent[1]")
local startup_running = globalProperty("sim/operation/prefs/startup_running")

--a321neo dataref
local apu_start_button_state = createGlobalPropertyi("a321neo/engine/apu_start_button", 0, false, true, false)
local apu_avail = createGlobalPropertyi("a321neo/engine/apu_avil", 0, false, true, false)
local apu_fuel_lo_pr = createGlobalPropertyi("a321neo/cockpit/apu/apu_fuel_lo_pr", 0, false, true, false)
local engine_mode_knob = createGlobalPropertyi("a321neo/engine/engine_mode", 0, false, true, false)

--sim command
local instant_start_eng = sasl.findCommand("sim/operation/quick_start")
local slow_start_eng = sasl.findCommand("sim/operation/auto_start")

--a321neo command
local apu_gen_toggle = sasl.createCommand("a321neo/electrical/APU_gen_toggle", "toggle apu generator")
local a321_auto_start = sasl.createCommand("a321neo/engine/auto_start", "auto_start")
local apu_master = sasl.createCommand("a321neo/engine/apu_master_toggle", "toggle APU master button")
local apu_start = sasl.createCommand("a321neo/engine/apu_start_toggle", "toggle APU start button")
local engine_mode_up = sasl.createCommand("a321neo/engine/mode_up", "engine mode selector up")
local engine_mode_dn = sasl.createCommand("a321neo/engine/mode_dn", "engine mode selector down")

--unregistering sim commands


--sim command handler
sasl.registerCommandHandler ( instant_start_eng, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Battery_1, 1)
        set(Battery_2, 1)
        set(apu_start_position, 2)
        set(Apu_bleed_switch, 1)
        set(apu_gen, 1)
        set(engine_mode_knob, 1)
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
    end
end)

sasl.registerCommandHandler ( slow_start_eng, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Battery_1, 1)
        set(Battery_2, 1)
        set(apu_start_position, 2)
        set(Apu_bleed_switch, 1)
        set(apu_gen, 1)
        set(engine_mode_knob, 1)
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
    end
end)

--a321neo command handler
sasl.registerCommandHandler ( apu_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(apu_start_position) == 0 then
            set(apu_start_position, 1)
            Goto_ecam(7)
        elseif get(apu_start_position) > 0 then
            set(apu_start_position, 0)
        end
    end
end)

sasl.registerCommandHandler ( apu_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(apu_start_position) == 1 then
            set(apu_start_position, 2)
        end
    end
end)

sasl.registerCommandHandler ( apu_gen_toggle, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(apu_gen) == 1 then
            set(apu_gen, 0)
        elseif get(apu_gen) == 0 then
            set(apu_gen, 1)
        end
    end
end)

sasl.registerCommandHandler ( a321_auto_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Battery_1, 1)
        set(Battery_2, 1)
        set(apu_start_position, 2)
        set(Apu_bleed_switch, 1)
        set(apu_gen, 1)
        set(engine_mode_knob, 1)
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
    end
end)

sasl.registerCommandHandler ( engine_mode_up, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(engine_mode_knob, get(engine_mode_knob) + 1)
    end
end)

sasl.registerCommandHandler ( engine_mode_dn, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(engine_mode_knob, get(engine_mode_knob) - 1)
    end
end)

--script variables
local ignition_1_required = 0
local ignition_2_required = 0

--custom functions
function Math_clamp(val, min, max)
    if min > max then LogWarning("Min is larger than Max invalid") end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif val <= max and val >= min then
        return val
    end
end

--init
function onPlaneLoaded()
    set(apu_gen, 1)
    set(Apu_bleed_switch, 0)
    
    if get(startup_running) == 1 then
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
    end
end

onPlaneLoaded()

function update()
    if get(Battery_1) == 1 then
        set(avionics, 1)
    else
        set(avionics, 0)
    end

    --start enging running
    if get(startup_running) == 1 then
        set(Engine_1_master_switch, 1)
        set(Engine_2_master_switch, 1)
        set(startup_running, 0)
    end
    
    --setting integer dataref range
    set(engine_mode_knob,Math_clamp(get(engine_mode_knob), -1, 1))
    set(Engine_1_master_switch,Math_clamp(get(Engine_1_master_switch), 0, 1))
    set(Engine_2_master_switch,Math_clamp(get(Engine_2_master_switch), 0, 1))
    
    --engine mode start
    if get(engine_mode_knob) == 1 
    then 
        -- to confirm the engine needs starting to stop repetitive start
        if get(Engine_1_avail) ~= 1 then
            ignition_1_required = 1
        end
        if get(Engine_2_avail) ~= 1 then
            ignition_2_required = 1
        end
        
        if get(Engine_1_master_switch) == 1 then
            if ignition_1_required == 1 then
                set(engine_1_ignition_switch,4)
            end
        end
        
        if get(Engine_2_master_switch) == 1 then
            if ignition_2_required == 1 then
                set(engine_2_ignition_switch,4)
            end
        end
    end

    --engine mode norm
    if get(engine_mode_knob) == 0
    then
        ignition_1_required = 0
        ignition_2_required = 0
        set(engine_1_ignition_switch,0)
        set(engine_2_ignition_switch,0)
    end

    --engine master 1
    if get(Engine_1_master_switch) == 1
    then
        if get(engine_1_N2) > 25 then
            set(engine_1_mixture, 1.0)
        else
            set(engine_1_mixture, 0)
        end
    elseif get(Engine_1_master_switch) == 0
    then
        set(engine_1_mixture, 0.0)
    end

    --engine master 2
    if get(Engine_2_master_switch) == 1
    then
        if get(engine_2_N2) > 25 then
            set(engine_2_mixture, 1.0)
        else
            set(engine_2_mixture, 0)
        end
    elseif get(Engine_2_master_switch) == 0
    then
        set(engine_2_mixture, 0.0)
    end

    --apu availability
    if get(Apu_N1) > 95 then
        set(apu_avail, 1)
    elseif get(Apu_N1) < 100 then
        set(apu_avail, 0)
    end

    --apu bleed states
    if get(apu_avail) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 0)
    elseif get(apu_avail) == 1 and get(Apu_bleed_switch) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 1)
    elseif get(apu_avail) == 1 and get(Apu_bleed_switch) == 1 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 39, 0, 39, 0.85))
        set(Apu_bleed_state, 2)
    end

    --apu gen states
    if get(apu_avail) == 0 then
        set(Apu_gen_volts, Set_anim_value(get(Apu_gen_volts), 0, 0, 115, 0.95))
        set(Apu_gen_hz, Set_anim_value(get(Apu_gen_hz), 0, 0, 400, 0.99))
        set(Apu_gen_state, 0)
    elseif get(apu_avail) == 1 and get(apu_gen) == 0 then
        set(Apu_gen_volts, Set_anim_value(get(Apu_gen_volts), 0, 0, 115, 0.95))
        set(Apu_gen_hz, Set_anim_value(get(Apu_gen_hz), 0, 0, 400, 0.99))
        set(Apu_gen_state, 1)
    elseif get(apu_avail) == 1 and get(apu_gen) == 1 then
        set(Apu_gen_volts, Set_anim_value(get(Apu_gen_volts), 115, 0, 115, 0.95))
        set(Apu_gen_hz, Set_anim_value(get(Apu_gen_hz), 400, 0, 400, 0.99))
        set(Apu_gen_state, 2)
    end

    if (get(Fuel_pump_1) == 0 and
       get(Fuel_pump_2) == 0 and
       get(Fuel_pump_3) == 0 and
       get(Fuel_pump_4) == 0 and
       get(Fuel_pump_5) == 0 and
       get(Fuel_pump_6) == 0 and
       get(Fuel_pump_7) == 0 and
       get(Fuel_pump_8) == 0) and get(apu_start) ==1 then
        set(apu_fuel_lo_pr, 1)
    else
        set(apu_fuel_lo_pr, 0)
    end

    --apu start button state 0: off, 1: on, 2: avail
    if get(apu_start_position) == 0 and get(Apu_N1) < 100 then
        set(apu_start_button_state, 0)
    elseif get(apu_start_position) == 1 and get(Apu_N1) < 100 then
        set(apu_start_button_state, 0)
    elseif get(apu_start_position) == 0 and get(Apu_N1) > 95 then
        set(apu_start_button_state, 2)
    elseif get(apu_start_position) == 1 and get(Apu_N1) > 95 then
        set(apu_start_button_state, 2)
    elseif get(apu_start_position) == 2 and get(Apu_N1) < 100 then
        set(apu_start_button_state, 1)
    elseif get(apu_start_position) == 2 and get(Apu_N1) > 100 then
        set(apu_start_button_state, 2)
    end
end