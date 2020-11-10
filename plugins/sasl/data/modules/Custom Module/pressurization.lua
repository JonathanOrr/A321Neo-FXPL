----------------------------------------------------------------------------------------------------
-- Pressurization system
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------------------------------
include('constants.lua')

local DRY_AIR_CONSTANT=287.058
local TOTAL_VOLUME=50+200+200+25 -- in m3
local OUTFLOW_VALVE_AREA=0.034   -- in m2

----------------------------------------------------------------------------------------------------
-- Variables
----------------------------------------------------------------------------------------------------
local current_cabin_pressure_in_pa = get(Weather_curr_press_sea_level) * 3386.39
local current_cabin_altitude = 0

set(Override_pressurization, 1)

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
sasl.registerCommandHandler (Press_manual_control_dn, 0, function(phase) manual_control_handler(phase, -1) end)
sasl.registerCommandHandler (Press_manual_control_up, 0, function(phase) manual_control_handler(phase, 1) end)

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
    elseif phase == SASL_COMMAND_END then
        set(Press_manual_control_lever_pos, 0)    
    end
end

local function compute_pressure_diff(curr_press, volume, volume_increase)
    return curr_pres * (volume_increase / volume)
end

local function get_air_density(pressure, temperature)
    return pressure / (DRY_AIR_CONSTANT * temperature) 
end

local function airmass_to_airflow(airmass, temp)
    return airmass / get_air_density(current_cabin_pressure_in_pa, temp)
end


local function update_cabin_pressure()

    local input_airmass_pack_1 = get(L_pack_Flow_value) -- kg/s
    local input_airmass_pack_2 = get(R_pack_Flow_value) -- kg/s

    local input_airflow_pack_1 = airmass_to_airflow(input_airmass_pack_1, get(R_pack_temp)) -- m3/s
    local input_airflow_pack_2 = airmass_to_airflow(input_airmass_pack_2, get(R_pack_temp)) -- m3/s     

    local input_delta_pressure = current_cabin_pressure_in_pa * (input_airflow_pack_1+input_airflow_pack_2) / TOTAL_VOLUME -- Pa
    
    
    local outflow_valve_actual_area = get(Out_flow_valve_ratio) * OUTFLOW_VALVE_AREA -- Let's assume is linare (m2)
    
    local outside_pressure = get(Weather_curr_press_flight_level) * 3386.39 -- Pa
    
    local output_airflow     = 0
    if current_cabin_pressure_in_pa-outside_pressure > 0 then
        output_airflow = 0.840 * outflow_valve_actual_area * math.sqrt(current_cabin_pressure_in_pa-outside_pressure) -- m3/s
    end
    
    local output_delta_pressure = current_cabin_pressure_in_pa * (output_airflow) / TOTAL_VOLUME -- Pa

    current_cabin_pressure_in_pa = current_cabin_pressure_in_pa + (input_delta_pressure - output_delta_pressure) * get(DELTA_TIME)

    current_cabin_altitude = (29.92*3386.39 - current_cabin_pressure_in_pa) / 3.378431

end

local prev_cabin_altitude = 0 

function update()

    update_cabin_pressure()
    
    --print("OUTSIDE: " .. get(Weather_curr_press_flight_level) * 3386.39)
    --print(current_cabin_pressure_in_pa, current_cabin_altitude, (current_cabin_altitude-prev_cabin_altitude) / get(DELTA_TIME)*60)

    prev_cabin_altitude = current_cabin_altitude

end

