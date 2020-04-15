--script variables
local throttle_press_moving_up_by_user = 0
local throttle_press_moving_dn_by_user = 0
local throttle_held_moving_up_by_user = 0
local throttle_held_moving_dn_by_user = 0

--sim datarefs
local efis_range = globalProperty("sim/cockpit2/EFIS/map_range")
local L_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[0]")
local R_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[1]")
local front_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[0]")
local left_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
local right_gear_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[2]")
local auto_throttle_on = globalProperty("sim/cockpit2/autopilot/autothrottle_on")
local reverse_L_deployed = globalProperty("sim/cockpit2/annunciators/reverser_on[0]")
local reverse_R_deployed = globalProperty("sim/cockpit2/annunciators/reverser_on[1]")

--a321neo datarefs
local TOGA = createGlobalPropertyi("a321neo/cockpit/controls/thrust/TOGA")
local FLEX_MCT = createGlobalPropertyi("a321neo/cockpit/controls/thrust/FLEX_MCT")
local CL = createGlobalPropertyi("a321neo/cockpit/controls/thrust/CL")
local MAN_thrust = createGlobalPropertyi("a321neo/cockpit/controls/thrust/MAN_thrust")
local all_on_ground = createGlobalPropertyi("a321neo/dynamics/all_wheels_on_ground", 0, false, true, false)
local L_throttle = createGlobalPropertyf("a321neo/cockpit/controls/throttle_1", 0, false, true, false)
local R_throttle = createGlobalPropertyf("a321neo/cockpit/controls/throttle_2", 0, false, true, false)

--sim commands
local sim_throttle_up = sasl.findCommand("sim/engines/throttle_up")
local sim_throttle_dn = sasl.findCommand("sim/engines/throttle_down")
local auto_throttle_on_cmd = sasl.findCommand("sim/autopilot/autothrottle_on")
local auto_throttle_off_cmd = sasl.findCommand("sim/autopilot/autothrottle_off")
local toggle_reverse_thrust = sasl.findCommand("sim/engines/thrust_reverse_toggle")

--a321neo commands


--sim command handlers
sasl.registerCommandHandler(sim_throttle_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        throttle_press_moving_up_by_user = 1
        --throttle sync
        if get(reverse_L_deployed) == 0 and get(reverse_R_deployed) then
            set(L_sim_throttle, get(L_throttle))
            set(R_sim_throttle, get(R_throttle))
        end
    else
        throttle_press_moving_up_by_user = 0
    end
    
    if phase == SASL_COMMAND_CONTINUE then
        throttle_held_moving_up_by_user = 1
        --throttle sync
        set(L_throttle, get(L_sim_throttle))
        set(R_throttle, get(R_sim_throttle))
    else
        throttle_held_moving_up_by_user = 0
    end
end)

sasl.registerCommandHandler(sim_throttle_dn, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        throttle_press_moving_dn_by_user = 1
        --throttle sync
        if get(reverse_L_deployed) == 0 and get(reverse_R_deployed) then
            set(L_sim_throttle, get(L_throttle))
            set(R_sim_throttle, get(R_throttle))
        end
    else
        throttle_press_moving_dn_by_user = 0
    end

    if phase == SASL_COMMAND_CONTINUE then
        throttle_held_moving_dn_by_user = 1
        --throttle sync
        set(L_throttle, get(L_sim_throttle))
        set(R_throttle, get(R_sim_throttle))

        if get(all_on_ground) == 0 and get(L_sim_throttle) == 0 and get(R_sim_throttle) then
            sasl.commandBegin(auto_throttle_off_cmd)
        end
    else
        throttle_held_moving_dn_by_user = 0
    end
end)

--custom function
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

function update()
    set(efis_range, Math_clamp(get(efis_range), 1 , 6))

    set(all_on_ground, (get(front_gear_on_ground) + get(left_gear_on_ground) + get(right_gear_on_ground))/3)


    --throttle detents
    --TOGA
    if get(L_sim_throttle) > 0.95 and get(R_sim_throttle) > 0.95 and get(L_sim_throttle) < 1 and get(R_sim_throttle) < 1 then
        set(TOGA, 1)
    end

    --TOGA > MAN_thrust > FLEX_MCT
    if get(L_sim_throttle) > 0.85 and get(R_sim_throttle) > 0.85 and get(L_sim_throttle) < 0.95 and get(R_sim_throttle) < 0.95 then
        set(MAN_thrust, 1)
    end

    --FLEX/MCT
    if get(L_sim_throttle) > 0.8 and get(R_sim_throttle) > 0.8 and get(L_sim_throttle) < 0.85 and get(R_sim_throttle) < 0.85 then
        set(FLEX_MCT, 1)
    end
    
    --CL
    if get(L_sim_throttle) > 0.65 and get(R_sim_throttle) > 0.65 and get(L_sim_throttle) < 0.7 and get(R_sim_throttle) < 0.7 then
        set(CL, 1)
    end

    --CL > MAN_thrust > 0
    if get(L_sim_throttle) < 0.65 and get(R_sim_throttle) < 0.65 then
        set(MAN_thrust, 1)
    end

    --ground auto thrust trigger
    if get(all_on_ground) == 1 then
        --TOGA
        if get(L_sim_throttle) > 0.95 and get(R_sim_throttle) > 0.95 and get(L_sim_throttle) < 1 and get(R_sim_throttle) < 1 then
            sasl.commandBegin(auto_throttle_on_cmd)
        end

        --FLEX/MCT
        if get(L_sim_throttle) > 0.8 and get(R_sim_throttle) > 0.8 and get(L_sim_throttle) < 0.85 and get(R_sim_throttle) < 0.85 then
            sasl.commandBegin(auto_throttle_on_cmd)
        end
        
        --autothrust off on ground
        if get(L_sim_throttle) < 0.8 and get(R_sim_throttle) < 0.8 then
            sasl.commandBegin(auto_throttle_off_cmd)
        end
    end

    
    if get(auto_throttle_on) == 0 then
        set(L_throttle, get(L_sim_throttle))
        set(R_throttle, get(R_sim_throttle))
    end

end