--include("FBW_subcomponents/limits_calculations.lua")
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
local last_vpath = 0

local roll_limits = 67
local Roll_rate_input = 0
local Roll_rate_output = 0
local vmax_prot_activation_ratio = 0
local vmax_prot_output = 0
local left_roll_limit_output = 0
local right_roll_limit_output = 0
local G_input = 0
local G_output = 0

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
        --calculate Vpath pitch rate
        set(Vpath_pitch_rate, (get(Vpath) - last_vpath) / get(DELTA_TIME))
    end
    last_roll = get(Flightmodel_roll)
    last_vpath = get(Vpath)

    --ROLL--------------------------------------------------------------------------------------
    if get(Roll) <= -0.05 or 0.05 <= get(Roll) then
        if vmax_prot_activation_ratio > 0 then
            roll_limits = Set_linear_anim_value(roll_limits, 45, -180, 180, 12.5)
        else
            roll_limits = Set_linear_anim_value(roll_limits, 67, -180, 180, 12.5)
        end

        Roll_rate_input = 15 * get(Roll)
    else
        if vmax_prot_activation_ratio > 0 then
            roll_limits = Set_linear_anim_value(roll_limits, 1, -180, 180, 12.5)
        else
            roll_limits = Set_linear_anim_value(roll_limits, 33, -180, 180, 12.5)
        end

        Roll_rate_input = 0
    end

    --pitch---------------------------------------------------------------------------------------
    if get(Flaps_internal_config) == 0 then
        if get(Pitch) > 0.05 then
            --SSS_FBW_G_load_pitch.I_time = 0
            --SSS_FBW_G_load_pitch.Integral_sum = 0
            G_input = Set_anim_value(G_input, 1.5 * get(Pitch) + 1, -1, 2.5, 8)
        elseif get(Pitch) < -0.05 then
            --SSS_FBW_G_load_pitch.I_time = 0
            --SSS_FBW_G_load_pitch.Integral_sum = 0
            G_input = Set_anim_value(G_input, 2 * get(Pitch) + 1, -1, 2.5, 8)
        else
            --command static vertical flight path [THIS IS THE DEFINITION ACCORDING FLIGHT DYNAMIC LAWS]
            G_input = Set_anim_value(G_input, math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(get(Flightmodel_roll))), -1, 2.5, 8)
            --SSS_FBW_G_load_pitch.I_time = 0.04
        end
    else
        if get(Pitch) > 0.05 then
            G_input = get(Pitch) + 1
        elseif get(Pitch) < -0.05 then
            G_input = get(Pitch) + 1
        else
            --command static vertical flight path [THIS IS THE DEFINITION ACCORDING FLIGHT DYNAMIC LAWS]
            G_input = math.cos(math.rad(get(Flightmodel_pitch))) / math.cos(math.rad(get(Flightmodel_roll)))
        end
    end


    if get(DELTA_TIME) ~= 0 then
        if get(FBW_kill_switch) == 0 then
            --gain scheduling--
            FBW_PID_arrays.SSS_FBW_G_load_pitch.P_gain = Math_rescale(150, 0.2, 300, 0.12, get(IAS))
            FBW_PID_arrays.SSS_FBW_G_load_pitch.I_time = Math_rescale(150, 4, 300, 6, get(IAS))
            FBW_PID_arrays.SSS_FBW_G_load_pitch.D_gain = Math_rescale(150, 0.145, 300, 0.085, get(IAS))

            FBW_PID_arrays.SSS_FBW_G_load_pitch.Min_out = Math_clamp_lower(vmax_prot_output, SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_down_limit, -15 - get(Flightmodel_pitch)))
            FBW_PID_arrays.SSS_FBW_G_load_pitch.Max_out = Math_clamp_higher(SSS_PID(FBW_PID_arrays.SSS_FBW_stall_prot_pitch, 100 - get(Alpha)), SSS_PID(FBW_PID_arrays.SSS_FBW_pitch_up_limit, 30 - get(Flightmodel_pitch)))
            G_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_G_load_pitch, G_input, get(Total_vertical_g_load))
            vmax_prot_activation_ratio = Math_clamp((get(PFD_Capt_IAS) - get(Capt_VMAX)) / (get(Capt_VMAX_prot) - get(Capt_VMAX)), 0, 1)

            left_roll_limit_output = SSS_PID(FBW_PID_arrays.SSS_FBW_roll_left_limit, -roll_limits - get(Flightmodel_roll))
            right_roll_limit_output = SSS_PID(FBW_PID_arrays.SSS_FBW_roll_right_limit, roll_limits - get(Flightmodel_roll))

            FBW_PID_arrays.SSS_FBW_roll_rate.Min_out = left_roll_limit_output
            FBW_PID_arrays.SSS_FBW_roll_rate.Max_out = right_roll_limit_output
            Roll_rate_output = SSS_PID_DPV(FBW_PID_arrays.SSS_FBW_roll_rate, Roll_rate_input, get(True_roll_rate))

            --slowly start to enable the pitch for vmax protection as the speed overshoots vmax and heads towards vmax prot
            vmax_prot_output = Math_lerp(-1, SSS_PID(FBW_PID_arrays.SSS_FBW_vmax_prot_pitch, (get(PFD_Capt_IAS) + get(PFD_Fo_IAS)) / 2 - (get(Capt_VMAX_prot) + get(Fo_VMAX_prot)) / 2), vmax_prot_activation_ratio)
        end

        if get(FBW_kill_switch) == 0 then
            set(Roll_artstab, Set_anim_value(get(Roll_artstab), Roll_rate_output, -1, 1, 0.8))
            set(Pitch_artstab, Set_anim_value(get(Pitch_artstab), G_output,-1, 1, 0.8))

            if get(Any_wheel_on_ground) ~= 1 then
                --set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), SSS_PID(SSS_FBW_CWS_trim, 0 - get(Vpath_pitch_rate)), -1, 1, 0.1))
            end
        end

    end

end