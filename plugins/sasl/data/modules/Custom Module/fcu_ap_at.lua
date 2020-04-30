--script variables
local throttle_press_moving_up_by_user = 0
local throttle_press_moving_dn_by_user = 0
local throttle_held_moving_up_by_user = 0
local throttle_held_moving_dn_by_user = 0

--sim datarefs
local efis_map_mode = globalProperty("sim/cockpit2/EFIS/map_mode") --0=approach,1=vor,2=map,3=nav,4=plan
local efis_is_HSI = globalProperty("sim/cockpit2/EFIS/map_mode_is_HSI")
local efis_weather = globalProperty("sim/cockpit2/EFIS/EFIS_weather_on")
local efis_TCAS = globalProperty("sim/cockpit2/EFIS/EFIS_tcas_on")
local efis_airport = globalProperty("sim/cockpit2/EFIS/EFIS_airport_on")
local efis_wpt = globalProperty("sim/cockpit2/EFIS/EFIS_fix_on")
local efis_vor = globalProperty("sim/cockpit2/EFIS/EFIS_vor_on")
local efis_ndb = globalProperty("sim/cockpit2/EFIS/EFIS_ndb_on")
local efis_nav1_voradf = globalProperty("sim/cockpit2/EFIS/EFIS_1_selection_pilot") --0=ADF1, 1=OFF, or 2=VOR1
local efis_nav2_voradf = globalProperty("sim/cockpit2/EFIS/EFIS_2_selection_pilot") --0=ADF1, 1=OFF, or 2=VOR1
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
local a321neo_csrt_status = createGlobalPropertyi("a321neo/cockpit/efis/csrt_on", 0, false, true, false)
local a321neo_efis_mode = createGlobalPropertyi("a321neo/cockpit/efis/map_mode", 3, false, true, false) --defaults at ARC mode (0 ILS, 1 VOR, 2 NAV, 3 ARC, 4 PLAN)
local TOGA = createGlobalPropertyi("a321neo/cockpit/controls/thrust/TOGA", 0, false, true, false)
local FLEX_MCT = createGlobalPropertyi("a321neo/cockpit/controls/thrust/FLEX_MCT", 0, false, true, false)
local CL = createGlobalPropertyi("a321neo/cockpit/controls/thrust/CL", 0, false, true, false)
local MAN_thrust = createGlobalPropertyi("a321neo/cockpit/controls/thrust/MAN_thrust", 0, false, true, false)
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
local a321neo_csrt_toggle = sasl.createCommand("a321neo/cockpit/efis/csrt_toggle", "toggle csrt on EFIS")
local a321neo_wpt_toggle = sasl.createCommand("a321neo/cockpit/efis/wpt_toggle", "toggle wpt on EFIS")
local a321neo_vor_toggle = sasl.createCommand("a321neo/cockpit/efis/vor_toggle", "toggle vor on EFIS")
local a321neo_ndb_toggle = sasl.createCommand("a321neo/cockpit/efis/ndb_toggle", "toggle ndb on EFIS")
local a321neo_airport_toggle = sasl.createCommand("a321neo/cockpit/efis/airport_toggle", "toggle airport on EFIS")

--sim command handlers
sasl.registerCommandHandler(sim_throttle_up, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        throttle_press_moving_up_by_user = 1
        --throttle sync
        if get(reverse_L_deployed) == 0 and get(reverse_R_deployed) == 0 then
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
        if get(reverse_L_deployed) == 0 and get(reverse_R_deployed) == 0 then
            set(L_sim_throttle, get(L_throttle))
            set(R_sim_throttle, get(R_throttle))
            print("throttle sync dn")
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

--a321neo command handler
sasl.registerCommandHandler(a321neo_csrt_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(a321neo_csrt_status) == 0 then
            set(a321neo_csrt_status, 1)
        else
            set(a321neo_csrt_status, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_wpt_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_wpt) == 0 then
            set(efis_airport, 0)
            set(efis_vor, 0)
            set(efis_ndb, 0)
            set(efis_wpt, 1)
        else
            set(efis_wpt, 0)
            set(efis_airport, 0)
            set(efis_vor, 0)
            set(efis_ndb, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_vor_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_vor) == 0 then
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_ndb, 0)
            set(efis_vor, 1)
        else
            set(efis_vor, 0)
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_ndb, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_ndb_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_ndb) == 0 then
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
            set(efis_ndb, 1)
        else
            set(efis_ndb, 0)
            set(efis_airport, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
        end
    end
end)

sasl.registerCommandHandler(a321neo_airport_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        if get(efis_airport) == 0 then
            set(efis_ndb, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
            set(efis_airport, 1)
        else
            set(efis_airport, 0)
            set(efis_ndb, 0)
            set(efis_wpt, 0)
            set(efis_vor, 0)
        end
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


--main logic
function onPlaneLoaded()
    --initiate
    set(a321neo_efis_mode, 3)
    set(efis_is_HSI, 1)
    set(efis_weather, 1)
    set(efis_TCAS, 1)
    set(a321neo_csrt_status, 0)
    set(efis_airport, 0)
    set(efis_wpt, 0)
    set(efis_vor, 0)
    set(efis_ndb, 0)
    set(efis_nav1_voradf, 0)
    set(efis_nav2_voradf, 0)
end

onPlaneLoaded()

function update()
    set(efis_range, Math_clamp(get(efis_range), 1 , 6))

    set(all_on_ground, (get(front_gear_on_ground) + get(left_gear_on_ground) + get(right_gear_on_ground))/3)


    --throttle detents
    --TOGA
    if get(L_sim_throttle) > 0.95 and get(R_sim_throttle) > 0.95 and get(L_sim_throttle) < 1 and get(R_sim_throttle) < 1 then
        set(TOGA, 1)
    else
        set(TOGA, 0)
    end

    --TOGA > MAN_thrust > FLEX_MCT
    if get(L_sim_throttle) > 0.85 and get(R_sim_throttle) > 0.85 and get(L_sim_throttle) < 0.95 and get(R_sim_throttle) < 0.95 then
        set(MAN_thrust, 1)
    else
        set(MAN_thrust, 0)
    end

    --FLEX/MCT
    if get(L_sim_throttle) > 0.8 and get(R_sim_throttle) > 0.8 and get(L_sim_throttle) < 0.85 and get(R_sim_throttle) < 0.85 then
        set(FLEX_MCT, 1)
    else
        set(FLEX_MCT, 0)
    end
    
    --CL
    if get(L_sim_throttle) > 0.65 and get(R_sim_throttle) > 0.65 and get(L_sim_throttle) < 0.7 and get(R_sim_throttle) < 0.7 then
        set(CL, 1)
    else
        set(CL, 0)
    end

    --CL > MAN_thrust > 0
    if get(L_sim_throttle) < 0.65 and get(R_sim_throttle) < 0.65 then
        set(MAN_thrust, 1)
    else
        set(MAN_thrust, 0)
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