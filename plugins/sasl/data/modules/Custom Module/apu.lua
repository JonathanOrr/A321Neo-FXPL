--sim dataref

local apu_gen = globalProperty("sim/cockpit2/electrical/APU_generator_on")
local apu_flap_open_ratio = globalProperty("sim/cockpit2/electrical/APU_door")

--a321neo dataref
local apu_fuel_lo_pr = createGlobalPropertyi("a321neo/cockpit/apu/apu_fuel_lo_pr", 0, false, true, false)

--a321neo command
local apu_gen_toggle = sasl.createCommand("a321neo/electrical/APU_gen_toggle", "toggle apu generator")
local apu_master = sasl.createCommand("a321neo/cockpit/engine/apu_master_toggle", "toggle APU master button")
local apu_start = sasl.createCommand("a321neo/cockpit/engine/apu_start_toggle", "toggle APU start button")

--a321neo command handler
sasl.registerCommandHandler ( apu_master, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(Apu_start_position) == 0 then
            set(Apu_start_position, 1)
        elseif get(Apu_start_position) > 0 then
            set(Apu_start_position, 0)
        end
    end
end)

sasl.registerCommandHandler ( apu_start, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(Apu_start_position) == 1 then
            set(Apu_start_position, 2)
        end
    end
    return 1
end)

sasl.registerCommandHandler ( apu_gen_toggle, 0 , function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(apu_gen, 1 - get(apu_gen))
    end
    return 1
end)


--init
set(apu_gen, 1)
set(Apu_bleed_switch, 0)


function update()

    --apu availability
    if get(Apu_N1) > 95 then
        set(Apu_avail, 1)
    elseif get(Apu_N1) < 100 then
        set(Apu_avail, 0)
    end

    --apu (ecam) bleed states
    if get(Apu_avail) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 0)
    elseif get(Apu_avail) == 1 and get(Apu_bleed_switch) == 0 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 0, 0, 39, 0.85))
        set(Apu_bleed_state, 1)
    elseif get(Apu_avail) == 1 and get(Apu_bleed_switch) == 1 then
        set(Apu_bleed_psi, Set_anim_value(get(Apu_bleed_psi), 39, 0, 39, 0.85))
        set(Apu_bleed_state, 2)
    end

    --apu (ecam) gen states
    if get(Apu_avail) == 0 then
        set(Apu_gen_volts, Set_anim_value(get(Apu_gen_volts), 0, 0, 115, 0.95))
        set(Apu_gen_hz, Set_anim_value(get(Apu_gen_hz), 0, 0, 400, 0.99))
        set(Apu_gen_state, 0)
    elseif get(Apu_avail) == 1 and get(apu_gen) == 0 then
        set(Apu_gen_volts, Set_anim_value(get(Apu_gen_volts), 0, 0, 115, 0.95))
        set(Apu_gen_hz, Set_anim_value(get(Apu_gen_hz), 0, 0, 400, 0.99))
        set(Apu_gen_state, 1)
    elseif get(Apu_avail) == 1 and get(apu_gen) == 1 then
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

    --apu master button state
    if get(Apu_start_position) == 0 then
        set(Apu_master_button_state, 0)--blank
    else
        set(Apu_master_button_state, 1)--on
    end

    --apu start button state 0: off, 1: on, 2: avail
    if get(Apu_start_position) == 0 and get(Apu_N1) < 100 then
        set(Apu_start_button_state, 0)
    elseif get(Apu_start_position) == 1 and get(Apu_N1) < 100 then
        set(Apu_start_button_state, 0)
    elseif get(Apu_start_position) == 0 and get(Apu_N1) > 95 then
        set(Apu_start_button_state, 2)
    elseif get(Apu_start_position) == 1 and get(Apu_N1) > 95 then
        set(Apu_start_button_state, 2)
    elseif get(Apu_start_position) == 2 and get(Apu_N1) < 100 then
        set(Apu_start_button_state, 1)
    elseif get(Apu_start_position) == 2 and get(Apu_N1) > 100 then
        set(Apu_start_button_state, 2)
    end
end
