--sim dataref
local battery_1 = globalProperty("sim/cockpit/electrical/battery_array_on[0]")
local battery_2 = globalProperty("sim/cockpit/electrical/battery_array_on[1]")
local apu_N1 = globalProperty("sim/cockpit2/electrical/APU_N1_percent")
local apu_start_position = globalProperty("sim/cockpit2/electrical/APU_starter_switch")
local apu_bleed_switch = globalProperty("sim/cockpit2/bleedair/actuators/apu_bleed")
local apu_gen = globalProperty("sim/cockpit2/electrical/APU_generator_on")
local apu_flap_open_ratio = globalProperty("sim/cockpit2/electrical/APU_door")
local engine_1_ignition_switch = globalProperty("sim/cockpit2/engine/actuators/ignition_key[0]")
local engine_2_ignition_switch = globalProperty("sim/cockpit2/engine/actuators/ignition_key[1]")
local engine_1_mixture = globalProperty("sim/cockpit2/engine/actuators/mixture_ratio[0]")
local engine_2_mixture = globalProperty("sim/cockpit2/engine/actuators/mixture_ratio[1]")
local engine_1_avail = globalProperty("sim/flightmodel/engine/ENGN_running[0]")
local engine_2_avail = globalProperty("sim/flightmodel/engine/ENGN_running[1]")
local startup_running = globalProperty("sim/operation/prefs/startup_running")

--a321neo dataref
local apu_start_button_state = createGlobalPropertyi("a321neo/engine/apu_start_button", 0, false, true, false)
local apu_avail = createGlobalPropertyi("a321neo/engine/apu_avil", 0, false, true, false)
local engine_mode_knob = createGlobalPropertyi("a321neo/engine/engine_mode", 0, false, true, false)
local engine_1_master_switch = createGlobalPropertyi("a321neo/engine/master_1", 0, false, true, false)
local engine_2_master_switch = createGlobalPropertyi("a321neo/engine/master_2", 0, false, true, false)

--a321neo command
local apu_gen_toggle = sasl.createCommand("a321neo/electrical/APU_gen_toggle", "toggle apu generator")
local a321_auto_start = sasl.createCommand("a321neo/engine/auto_start", "auto_start")
local apu_master = sasl.createCommand("a321neo/engine/apu_master_toggle", "toggle APU master button")
local apu_start = sasl.createCommand("a321neo/engine/apu_start_toggle", "toggle APU start button")
local engine_mode_up = sasl.createCommand("a321neo/engine/mode_up", "engine mode selector up")
local engine_mode_dn = sasl.createCommand("a321neo/engine/mode_dn", "engine mode selector down")

--a321neo command handler
sasl.registerCommandHandler ( apu_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(apu_start_position) == 0 then
            set(apu_start_position, 1)
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
        set(battery_1, 1)
        set(battery_1, 1)
        set(apu_start_position, 2)
        set(apu_bleed_switch, 1)
        set(engine_mode_knob, 1)
        set(engine_1_master_switch, 1)
        set(engine_2_master_switch, 1)
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
set(apu_bleed_switch, 0)
set(apu_gen, 1)

function update()
    
    --start enging running
    if get(startup_running) == 1 then
        set(engine_1_master_switch, 1)
        set(engine_2_master_switch, 1)
        set(startup_running, 0)
    end
    
    --setting integer dataref range
    set(engine_mode_knob,Math_clamp(get(engine_mode_knob), -1, 1))
    set(engine_1_master_switch,Math_clamp(get(engine_1_master_switch), 0, 1))
    set(engine_2_master_switch,Math_clamp(get(engine_2_master_switch), 0, 1))
    
    --engine mode start
    if get(engine_mode_knob) == 1 
    then 
        -- to confirm the engine needs starting to stop repetitive start
        if get(engine_1_avail) ~= 1 then
            ignition_1_required = 1
        end
        if get(engine_2_avail) ~= 1 then
            ignition_2_required = 1
        end
        
        if get(engine_1_master_switch) == 1 then
            if ignition_1_required == 1 then
                set(engine_1_ignition_switch,4)
            end
        end
        
        if get(engine_2_master_switch) == 1 then
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
    if get(engine_1_master_switch) == 1
    then
        set(engine_1_mixture, 1.0)
    elseif get(engine_1_master_switch) == 0
    then
        set(engine_1_mixture, 0.0)
    end

    --engine master 2
    if get(engine_2_master_switch) == 1
    then
        set(engine_2_mixture, 1.0)
    elseif get(engine_2_master_switch) == 0
    then
        set(engine_2_mixture, 0.0)
    end

    --apu availability
    if get(apu_N1) == 100 then
        set(apu_avail, 1)
    elseif get(apu_N1) < 100 then
        set(apu_avail, 0)
    end

    --apu start button state 0: off, 1: on, 2: avail
    if get(apu_start_position) == 0 and get(apu_N1) < 100 then
        set(apu_start_button_state, 0)
    end
    
    if get(apu_start_position) == 1 and get(apu_N1) < 100 then
        set(apu_start_button_state, 0)
    end

    if get(apu_start_position) == 0 and get(apu_N1) == 100 then
        set(apu_start_button_state, 2)
    end 
    
    if get(apu_start_position) == 1 and get(apu_N1) == 100 then
        set(apu_start_button_state, 2)
    end    
    
    if get(apu_start_position) == 2 and get(apu_N1) < 100 then
        set(apu_start_button_state, 1)
    end 
    
    if get(apu_start_position) == 2 and get(apu_N1) == 100 then
        set(apu_start_button_state, 2)
    end
end