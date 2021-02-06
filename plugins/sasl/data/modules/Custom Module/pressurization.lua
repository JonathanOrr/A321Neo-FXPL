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
-- File: pressurization.lua 
-- Short description: Pressurization system
-------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('PID.lua')

local DRY_AIR_CONSTANT=287.058
local TOTAL_VOLUME=50+200+200+50    -- in m3
local OUTFLOW_VALVE_AREA=0.034   -- in m2
local AIRCRAFT_LEAKAGE  = 0.02   -- m3/s
local SPD_MANUAL_OUTFLOW = 0.025

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local mode_sel_manual = false   -- false: auto, true: manual
local manual_mode_lever_req = 0 -- 0 stay, 1 go up, -1 go down

local current_cabin_pressure_in_pa = 0
local current_cabin_altitude = 0
local prev_cabin_altitude    = 0  -- Pressure at the previous frame (to compute V/S)

local last_update_safety_valve = 0 -- To introduce some delay for safety valve closing
local touchdown_time = 0

local setpoint_cabin_vs = 500

local pid_array_outflow =
{
        P_gain = 0.001,
        I_gain = 0.0005,
        D_gain = 0.000001,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0
}


local pid_array_cab_alt =
{
        P_gain = 1,
        I_gain = 0.02,
        D_gain = 0.00001,
        B_gain = 1,
        Actual_output = 0,
        Desired_output = 0,
        Integral_sum = 0,
        Current_error = 0
}

----------------------------------------------------------------------------------------------------
-- Initialization
----------------------------------------------------------------------------------------------------

set(Override_pressurization, 1)

-- the starting pressure is the outside pressure (unless cabin altitude over 15k feet)
current_cabin_pressure_in_pa = math.max(57200, get(Weather_curr_press_flight_level) * 3386.39)
local data_current_cabin_pressure_in_pa = { -- Filter
    x = current_cabin_pressure_in_pa,
    cut_frequency = 10
}

current_cabin_altitude = math.min(7000, get(Capt_baro_alt_ft))

function onAirportLoaded()
    current_cabin_altitude = math.min(7000, get(Capt_baro_alt_ft))
end

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (Press_manual_control_dn, 0, function(phase) manual_control_handler(phase, -1) end)
sasl.registerCommandHandler (Press_manual_control_up, 0, function(phase) manual_control_handler(phase, 1) end)
sasl.registerCommandHandler (Press_mode_sel, 0, function(phase) if phase == SASL_COMMAND_BEGIN then mode_sel_manual = not mode_sel_manual end end)


sasl.registerCommandHandler (Press_ldg_elev_dial_dn, 0, function(phase) 
    if get(Press_ldg_elev_knob_pos) < -2 then
        set(Press_ldg_elev_knob_pos, -3)
    else
        Knob_handler_down_float(phase, Press_ldg_elev_knob_pos, -3, 14, 2)
    end
end)
sasl.registerCommandHandler (Press_ldg_elev_dial_up, 0, function(phase)
    if get(Press_ldg_elev_knob_pos) < -2 then
        set(Press_ldg_elev_knob_pos, -2)
    else
        Knob_handler_up_float(phase, Press_ldg_elev_knob_pos, -3, 14, 2)
    end
end)


----------------------------------------------------------------------------------------------------
-- Commands handlers
----------------------------------------------------------------------------------------------------
function manual_control_handler(phase, direction)

    if phase == SASL_COMMAND_BEGIN then
        set(Press_manual_control_lever_pos, direction)
        manual_mode_lever_req = direction
    elseif phase == SASL_COMMAND_CONTINUE then
        manual_mode_lever_req = direction
    elseif phase == SASL_COMMAND_END then
        set(Press_manual_control_lever_pos, 0)
    end
end

local function compute_pressure_diff(curr_press, volume, volume_increase)
    return curr_pres * (volume_increase / volume)
end

local function get_air_density(pressure, temperature)
    return pressure / (DRY_AIR_CONSTANT * (temperature+273.15)) 
end

local function airmass_to_airflow(airmass, temp)
    if current_cabin_pressure_in_pa <= 0 then
        -- This happens on startup (or in space lol)
        return 0
    end
    return airmass / get_air_density(current_cabin_pressure_in_pa, temp)
end

local function compute_leakage(area_leakage, delta_P, air_density, flow_coeff)

    local computed_value = flow_coeff * area_leakage * math.sqrt(2*delta_P/air_density)

    if computed_value ~= computed_value then
        -- Sometimes it happens that this value is temporary NaN, in this case, let's return a zero
        return 0
    end
    
    return computed_value

end

local function update_cabin_pressure()

    local input_airmass_pack_1 = get(L_pack_Flow_value) -- kg/s
    local input_airmass_pack_2 = get(R_pack_Flow_value) -- kg/s

    local input_airflow_pack_1 = airmass_to_airflow(input_airmass_pack_1, get(L_pack_temp)) -- m3/s
    local input_airflow_pack_2 = airmass_to_airflow(input_airmass_pack_2, get(R_pack_temp)) -- m3/s

    local input_delta_pressure = current_cabin_pressure_in_pa * (input_airflow_pack_1+input_airflow_pack_2) / TOTAL_VOLUME -- Pa
   
    local outflow_valve_actual_area = get(Out_flow_valve_ratio) * OUTFLOW_VALVE_AREA -- Let's assume is linear (m2)
    
    if get(Press_safety_valve_pos) == 1 then
        -- if the safety valve is open, we assume like we have another outflow valve open
        outflow_valve_actual_area = outflow_valve_actual_area + OUTFLOW_VALVE_AREA
    end
    
    local outside_pressure = get(Weather_curr_press_flight_level) * 3386.39 -- Pa
    
    local output_airflow     = 0
    local cabin_air_density  = get_air_density(current_cabin_pressure_in_pa, get(Aft_cab_temp))
    
    local press_diff = current_cabin_pressure_in_pa - outside_pressure

    if press_diff > 1 then
        output_airflow = compute_leakage(outflow_valve_actual_area, current_cabin_pressure_in_pa-outside_pressure, cabin_air_density, 2.5) + AIRCRAFT_LEAKAGE -- m3/s
    elseif press_diff < -1 then
        output_airflow =  -compute_leakage(outflow_valve_actual_area, outside_pressure-current_cabin_pressure_in_pa, cabin_air_density, 2.5) - AIRCRAFT_LEAKAGE -- m3/s
    end


    set(Press_outflow_valve_flow, output_airflow)
    set(Press_outflow_valve_press, current_cabin_pressure_in_pa * (output_airflow) / TOTAL_VOLUME / 3386.39)
    
    local output_delta_pressure = current_cabin_pressure_in_pa * (output_airflow) / TOTAL_VOLUME -- Pa

    -- If the sfety valve is closed, then the aircraft can be pressurized or not
    local new_press = current_cabin_pressure_in_pa + (input_delta_pressure - output_delta_pressure) * get(DELTA_TIME)
    
    current_cabin_pressure_in_pa = Set_linear_anim_value(current_cabin_pressure_in_pa, new_press, 0, 1000000, 100)
     
    current_cabin_altitude = (29.92*3386.39 - current_cabin_pressure_in_pa) / 3.378431

end

local function get_delta_in_psi()
    local outside_pressure = get(Weather_curr_press_flight_level) * 3386.39 -- Pa
    local delta_pa = current_cabin_pressure_in_pa-outside_pressure
    return delta_pa * 0.000145038
end

local function update_safety_valve()

    if get(FAILURE_PRESS_SAFETY_OPEN) == 1 then
        set(Press_safety_valve_pos, 1)
        return
    end
    local delta = get_delta_in_psi()
    
    if delta > 8.6 or delta < -1 then
        set(Press_safety_valve_pos, 1)
        last_update_safety_valve = 0
    elseif last_update_safety_valve ~= 0 then
        -- Add a delay for reclosing to avoid oscillation open-close-open-close
        if get(TIME) - last_update_safety_valve > 0.5 then
            set(Press_safety_valve_pos, 0)
        end
    else
        last_update_safety_valve = get(TIME)
    end
end

local function set_outflow(x)

    if get(Press_ditching_enabled) == 1 then
        -- If ditching pushbutton is pressed, no matter what automatic system decides, the
        -- outflow valve closes.
        x = 0
    end
    x = Math_clamp(x, 0, 1)
    pid_array_outflow.Actual_output = x
        
    Set_dataref_linear_anim(Out_flow_valve_ratio, x, 0, 1, 0.1)
end

local function controller_outflow_valve()

    set(Press_controller_sp_ovf, setpoint_cabin_vs)   -- For debug window only
    set(Press_controller_last_ovf, get(TIME))

    local curr_err  = setpoint_cabin_vs - get(Cabin_vs) + get(Press_safety_valve_pos) * 1000 -- This is a trick to volutarily confuse the controller
                                                                                             -- otherwise, the controller keeps the outflow valve closed
                                                                                             -- if the safety valve is open, this trick avoids this.
    local u = SSS_PID_BP(pid_array_outflow, curr_err)
    return u
 
end

local function get_target_cabin_altitude()
    local current_alt = get(Capt_Baro_Alt)
    
    local to_ret =  Math_rescale(0, 0, 39000, 8000, current_alt) 
    
    return math.max(to_ret, 0) -- TODO LDG ELEV
    
end

local function pid_keep_cabin_altitude()
    local target = get_target_cabin_altitude()
    set(Press_controller_sp_vs, target)    -- For debug window only
    set(Press_controller_last_vs, get(TIME))

    local curr_err  = target - current_cabin_altitude
    local u = SSS_PID_BP(pid_array_cab_alt, curr_err)
    return Math_clamp(u, -750, 750)
end

local function set_cabin_vs_target()

    if get(All_on_ground) == 1 and get(EWD_flight_phase) > PHASE_FINAL then
        -- After 55s this branch is not taken
        setpoint_cabin_vs = 500
    elseif get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR then
        if get(Cabin_delta_psi) < 0.1 then
            setpoint_cabin_vs = -400
        else
            setpoint_cabin_vs = 0
        end
    else
        -- Controller
        setpoint_cabin_vs = pid_keep_cabin_altitude()

    end
    
    
end

local function auto_manage_pressurization()

    -- If on ground but before T/O power or 55s after landing, outflow valve is fully open
    local touchdown_condition = touchdown_time > 0 and (get(TIME) - touchdown_time > 50)
    local ground_condition = touchdown_condition
                           or (get(EWD_flight_phase) <= PHASE_1ST_ENG_ON)
   
    if get(All_on_ground) == 0 then
        -- When landing, the last time we update touchdown_time corresponds to the touchdown time 
        touchdown_time = get(TIME)
    end
    
    set_cabin_vs_target()

    local req_u = controller_outflow_valve()
    
    if get(All_on_ground) == 1 and ground_condition then
        set_outflow(1) -- Full open
    else
        set_outflow(req_u)
    end
end

local function update_datarefs()
    set(Cabin_delta_psi, get_delta_in_psi())
    set(Cabin_alt_ft, current_cabin_altitude)
    if get(DELTA_TIME) > 0 then
        local vs = (current_cabin_altitude-prev_cabin_altitude) / get(DELTA_TIME) * 60
        Set_dataref_linear_anim(Cabin_vs, vs, -50000, 50000, 100)
    end
    prev_cabin_altitude = current_cabin_altitude
    
    -- Set button light
    pb_set(PB.ovhd.press_mode_sel, mode_sel_manual, false) -- TODO Faults
end

local function update_outputs()

    if not mode_sel_manual then
        auto_manage_pressurization()
    else
        if manual_mode_lever_req ~= 0 then
            local new_value = get(Out_flow_valve_ratio) + manual_mode_lever_req * get(DELTA_TIME) * SPD_MANUAL_OUTFLOW
            Math_clamp(new_value, 0, 1)
            set(Out_flow_valve_ratio, new_value)
            manual_mode_lever_req = 0            
        end
    end
    

    -- Let's backpropagate the PID now
    pid_array_cab_alt.Actual_output = setpoint_cabin_vs

    set(Press_controller_output_vs, pid_array_cab_alt.Desired_output)    -- For debug window only
    set(Press_controller_output_ovf, pid_array_outflow.Desired_output)   -- For debug window only

    set(Press_mode_sel_is_man, mode_sel_manual and 1 or 0)

end

function update()
    perf_measure_start("pressurization:update()")
    
    if get(TIME) < 1 then   -- Wait 1 second before running pressurization
        -- This is a bad hack, but we need it. The dataref for weather pressurization stays 0 for some
        -- time on start...
        current_cabin_pressure_in_pa = get(Weather_curr_press_flight_level) * 3386.39
        return
    end
    
    update_cabin_pressure()
    update_safety_valve()

    update_datarefs()
    update_outputs()

    perf_measure_stop("pressurization:update()")

end

