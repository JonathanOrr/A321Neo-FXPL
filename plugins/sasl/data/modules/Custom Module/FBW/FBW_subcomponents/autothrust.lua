--inclue components
include("FBW_subcomponents/autothrust_subcomponents/lever_input_functions.lua")
include("FBW_subcomponents/autothrust_subcomponents/AT_PID_functions.lua")

--sim dataref
local reverse_L_deployed = globalProperty("sim/cockpit2/annunciators/reverser_on[0]")
local reverse_R_deployed = globalProperty("sim/cockpit2/annunciators/reverser_on[1]")

--custom datarefs
Lever_in_TOGA =       createGlobalPropertyi("a321neo/cockpit/autothrust/lever_in_toga", 0, false, true, false)
Lever_in_FLEX_MCT =   createGlobalPropertyi("a321neo/cockpit/autothrust/lever_in_flex_mct", 0, false, true, false)
Lever_in_CL =         createGlobalPropertyi("a321neo/cockpit/autothrust/lever_in_cl", 0, false, true, false)
Lever_in_MAN_thrust = createGlobalPropertyi("a321neo/cockpit/autothrust/lever_in_man_thrust", 0, false, true, false)

--sim commands
local sim_throttle_up =       sasl.findCommand("sim/engines/throttle_up")
local sim_throttle_dn =       sasl.findCommand("sim/engines/throttle_down")
local toggle_reverse_thrust = sasl.findCommand("sim/engines/thrust_reverse_toggle")
local hold_reverse_thrust_all   = sasl.findCommand("sim/engines/thrust_reverse_hold")
local hold_reverse_thrust_1   = sasl.findCommand("sim/engines/thrust_reverse_hold_1")
local hold_reverse_thrust_2   = sasl.findCommand("sim/engines/thrust_reverse_hold_2")

--register command handlers
sasl.registerCommandHandler(sim_throttle_up, 1, Lever_fwd)
sasl.registerCommandHandler(sim_throttle_dn, 1, Lever_revs)
sasl.registerCommandHandler(toggle_reverse_thrust,  1, Toggle_reverse)
sasl.registerCommandHandler(hold_reverse_thrust_all,1, Hold_reverse_all)
sasl.registerCommandHandler(hold_reverse_thrust_1,  1, function(phase) Hold_reverse_single(phase,1) end)
sasl.registerCommandHandler(hold_reverse_thrust_2,  1, function(phase) Hold_reverse_single(phase,2) end)

--ensure to override throttles
set(Override_throttle, 1)

function onPlaneLoaded()
    set(Override_throttle, 1)
end

function onAirportLoaded()
    set(Override_throttle, 1)
end

function onModuleShutdown()--reset things back so other planes will work
    set(Override_throttle, 0)
end

function update()
    --FADEC N1 CONTROL--
    N1_control(AT_PID_arrays.SSS_L_N1, AT_PID_arrays.SSS_R_N1, false)

    --throttle detents
    --TOGA
    if get(Cockpit_throttle_lever_L) >= THR_TOGA_START and get(Cockpit_throttle_lever_R) >= THR_TOGA_START and get(Cockpit_throttle_lever_L) <= 1 and get(Cockpit_throttle_lever_R) <= 1 then
        set(Lever_in_TOGA, 1)
    else
        set(Lever_in_TOGA, 0)
    end

    --TOGA > MAN_thrust > FLEX_MCT
    if get(Cockpit_throttle_lever_L) > THR_MCT_END and get(Cockpit_throttle_lever_R) > THR_MCT_END and get(Cockpit_throttle_lever_L) < THR_TOGA_START and get(Cockpit_throttle_lever_R) <THR_TOGA_START then
        set(Lever_in_MAN_thrust, 1)
    else
        set(Lever_in_MAN_thrust, 0)
    end

    --FLEX/MCT
    if get(Cockpit_throttle_lever_L) >= THR_MCT_START and get(Cockpit_throttle_lever_R) >= THR_MCT_START and get(Cockpit_throttle_lever_L) <= THR_MCT_END and get(Cockpit_throttle_lever_R) <= THR_MCT_END then
        set(Lever_in_FLEX_MCT, 1)
    else
        set(Lever_in_FLEX_MCT, 0)
    end

    --CL
    if get(Cockpit_throttle_lever_L) >= THR_CLB_START and get(Cockpit_throttle_lever_R) >= THR_CLB_START and get(Cockpit_throttle_lever_L) <= THR_CLB_END and get(Cockpit_throttle_lever_R) <= THR_CLB_END then
        set(Lever_in_CL, 1)
    else
        set(Lever_in_CL, 0)
    end

    --CL > MAN_thrust > 0
    if get(Cockpit_throttle_lever_L) < THR_CLB_START and get(Cockpit_throttle_lever_R) < THR_CLB_START then
        set(Lever_in_MAN_thrust, 1)
    else
        set(Lever_in_MAN_thrust, 0)
    end


    update_levers()
end
