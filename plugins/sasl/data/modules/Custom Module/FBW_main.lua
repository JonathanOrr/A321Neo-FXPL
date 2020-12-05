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
-- File: FBW_main.lua
-- Short description: Fly-by-wire main file
-------------------------------------------------------------------------------

--include("FBW_subcomponents/limits_calculations.lua")
include("PID.lua")
include("FBW_subcomponents/fbw_system_subcomponents/flt_computers.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW_subcomponents/")

components = {
    autothrust {},
    limits_calculations {},
    flight_controls {}
}

--register commands
sasl.registerCommandHandler (Toggle_ELAC_1, 0, Toggle_elac_1_callback)
sasl.registerCommandHandler (Toggle_ELAC_2, 0, Toggle_elac_2_callback)
sasl.registerCommandHandler (Toggle_FAC_1, 0, Toggle_fac_1_callback)
sasl.registerCommandHandler (Toggle_FAC_2, 0, Toggle_fac_2_callback)
sasl.registerCommandHandler (Toggle_SEC_1, 0, Toggle_sec_1_callback)
sasl.registerCommandHandler (Toggle_SEC_2, 0, Toggle_sec_2_callback)
sasl.registerCommandHandler (Toggle_SEC_3, 0, Toggle_sec_3_callback)

--previous values
local last_kill_value = 0--used to put the controls to nuetural when killing the FBW
local kill_delta = 0--used to put the controls to nuetural when killing the FBW
local last_roll = 0
local last_pitch = 0
local last_vpath = 0

local roll_limits = 67
local Roll_rate_input = 0
local Roll_rate_output = 0
local vmax_prot_activation_ratio = 0
local vmax_prot_output = 0

local stick_moving_vertically = false
local wait_for_v_stability = 5--seconds
local v_stability_wait_timer = 0--seconds
local G_input = 0
local G_output = 0
local pitch_rate_correction = 0

local lvl_flt_load_constant = math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(Math_clamp(get(Flightmodel_roll), -33, 33)))

function update()
    updateAll(components)
    Fctl_computuers_status_computation(Fctl_computers_var_table)
    Compute_fctl_button_states()


    kill_delta = get(FBW_kill_switch) - last_kill_value
    last_kill_value = get(FBW_kill_switch)
    if kill_delta == 1 then
        set(Roll_artstab, 0)
        set(Pitch_artstab, 0)
        print("FBW killed reseting controls")
    end

    if get(DELTA_TIME) ~= 0 then
        --calculate true roll rate
        set(True_roll_rate, (get(Flightmodel_roll) - last_roll) / get(DELTA_TIME))
        --calculate true pitch rate
        set(True_pitch_rate, (get(Flightmodel_pitch) - last_pitch) / get(DELTA_TIME))
        --calculate Vpath pitch rate
        set(Vpath_pitch_rate, (get(Vpath) - last_vpath) / get(DELTA_TIME))
    end
    last_roll = get(Flightmodel_roll)
    last_pitch = get(Flightmodel_pitch)
    last_vpath = get(Vpath)

    --ROLL--------------------------------------------------------------------------------------
    if get(Augmented_roll) <= -0.05 or 0.05 <= get(Augmented_roll) then
        if vmax_prot_activation_ratio > 0 then
            roll_limits = Set_linear_anim_value(roll_limits, 45, -180, 180, 10)
        else
            roll_limits = Set_linear_anim_value(roll_limits, 67, -180, 180, 10)
        end

        Roll_rate_input = 15 * get(Augmented_roll)
    else
        if vmax_prot_activation_ratio > 0 then
            roll_limits = Set_linear_anim_value(roll_limits, 1, -180, 180, 10)
        else
            roll_limits = Set_linear_anim_value(roll_limits, 33, -180, 180, 10)
        end

        Roll_rate_input = 0
    end

    --pitch---------------------------------------------------------------------------------------
    --live computation required
    lvl_flt_load_constant = math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(Math_clamp(get(Flightmodel_roll), -33, 33)))
    if get(Flaps_internal_config) == 0 then
        if get(Augmented_pitch) > 0.05 then
            G_input = Math_rescale(0, lvl_flt_load_constant, 1, 2.5, get(Augmented_pitch))
            stick_moving_vertically = true
        elseif get(Augmented_pitch) < -0.05 then
            G_input = Math_rescale(-1, -1, 0, lvl_flt_load_constant, get(Augmented_pitch))
            stick_moving_vertically = true
        else
            --command static vertical flight path [THIS IS THE DEFINITION ACCORDING FLIGHT DYNAMIC LAWS]
            G_input = lvl_flt_load_constant
            stick_moving_vertically = false
        end
    else
        if get(Augmented_pitch) > 0.05 then
            G_input = Math_rescale(0, lvl_flt_load_constant, 1, 2, get(Augmented_pitch))
            stick_moving_vertically = true
        elseif get(Augmented_pitch) < -0.05 then
            G_input = Math_rescale(-1, 0, 0, lvl_flt_load_constant, get(Augmented_pitch))
            stick_moving_vertically = true
        else
            --command static vertical flight path [THIS IS THE DEFINITION ACCORDING FLIGHT DYNAMIC LAWS]
            G_input = lvl_flt_load_constant
            stick_moving_vertically = false
        end
    end


    if get(DELTA_TIME) ~= 0 then

        if stick_moving_vertically == true then
            v_stability_wait_timer = 0
        else
            if v_stability_wait_timer < wait_for_v_stability then
                v_stability_wait_timer = Math_clamp(v_stability_wait_timer + 1 * get(DELTA_TIME), 0, wait_for_v_stability)
            end
        end

        if get(FBW_kill_switch) == 0 then
            --CASCADE: SIDESTICK --> G LOAD PID --> PITCH RATE PID --> CODED STABILITY / FILTERING --> ELEVATOR
            --slowly start to enable the pitch for vmax protection as the speed overshoots vmax and heads towards vmax prot
            vmax_prot_activation_ratio = Math_clamp((get(PFD_Capt_IAS) - get(Capt_VMAX)) / (get(Capt_VMAX_prot) - get(Capt_VMAX)), 0, 1)
            vmax_prot_output = Math_lerp(-1, SSS_PID(FBW_PID_arrays.SSS_FBW_vmax_prot_pitch, (get(PFD_Capt_IAS) + get(PFD_Fo_IAS)) / 2 - (get(Capt_VMAX_prot) + get(Fo_VMAX_prot)) / 2), vmax_prot_activation_ratio)
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Min_out = Math_clamp_lower(vmax_prot_output, SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_down_limit, -15 - get(Flightmodel_pitch)))
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Max_out = Math_clamp_higher(SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_stall_prot_pitch, 100000000, get(Alpha)), SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_up_limit, 30 - get(Flightmodel_pitch)))
            --pitch rate stability[used to temperarily guard the G load before overshoot stops]
            G_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_G_load_pitch, G_input, get(Total_vertical_g_load)) * 10

            --gain scheduling--
            FBW_PID_arrays.SSS_FBW_pitch_rate.P_gain = Math_rescale(245, 0.24, 310, 0.2, get(IAS))
            FBW_PID_arrays.SSS_FBW_pitch_rate.I_time = Math_rescale(245, 2.2, 310, 2.2, get(IAS))
            FBW_PID_arrays.SSS_FBW_pitch_rate.D_gain = Math_rescale(245, 0.12, 310, 0.1, get(IAS))
            if stick_moving_vertically == true then
                pitch_rate_correction = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_pitch_rate, G_output, get(True_pitch_rate))
            else
                pitch_rate_correction = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_pitch_rate, Math_lerp(0, G_output, v_stability_wait_timer / wait_for_v_stability) - Math_lerp(0, get(Vpath_pitch_rate), v_stability_wait_timer / wait_for_v_stability) * BoolToNum(get(Flightmodel_roll) >= -33 and get(Flightmodel_roll) <= 33), get(True_pitch_rate))
            end

            FBW_PID_arrays.SSS_FBW_roll_rate.Min_out = SSS_PID(FBW_PID_arrays.SSS_FBW_roll_left_limit, -roll_limits - get(Flightmodel_roll))
            FBW_PID_arrays.SSS_FBW_roll_rate.Max_out = SSS_PID(FBW_PID_arrays.SSS_FBW_roll_right_limit, roll_limits - get(Flightmodel_roll))
            Roll_rate_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_roll_rate, Roll_rate_input, get(True_roll_rate))
        end

        if get(FBW_kill_switch) == 0 then
            set(Roll_artstab, Set_anim_value(get(Roll_artstab), Roll_rate_output, -1, 1, 1))
            set(Pitch_artstab, Set_anim_value(get(Pitch_artstab), pitch_rate_correction, -1, 1, 1))

            if get(Any_wheel_on_ground) ~= 1 then
                if stick_moving_vertically == true then
                    set(Augmented_pitch_trim_ratio, Set_anim_value(get(Augmented_pitch_trim_ratio), SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_CWS_trim, G_output, get(True_pitch_rate)), -1, 1, 0.1))
                else
                    set(Augmented_pitch_trim_ratio, Set_anim_value(get(Augmented_pitch_trim_ratio), SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_CWS_trim, 0, - get(Pitch_artstab)), -1, 1, 0.1))
                end
            end
        end

    end

end
