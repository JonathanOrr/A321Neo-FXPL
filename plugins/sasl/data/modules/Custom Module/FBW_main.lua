--include("FBW_subcomponents/limits_calculations.lua")
--include("FBW_subcomponents/flight_controls.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW_subcomponents/")

components = {
    autothrust {},
    limits_calculations {},
    flight_controls {}
}

--previous values
local last_kill_value = 0--used to put the controls to nuetural when killing the FBW
local kill_delta = 0--used to put the controls to nuetural when killing the FBW
local last_roll = 0
local last_vpath = 0

local roll_limits = 67
local Roll_rate_input = 0
local vmax_prot_activation_ratio = 0
local vmax_prot_output = 0
local left_roll_limit_output = 0
local right_roll_limit_output = 0
local G_input = 0
local G_output = 0

function update()
    updateAll(components)

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
            roll_limits = 45
        else
            roll_limits = 67
        end

        --avoid delayed actuall or previouse compensation while transitioning
        SSS_FBW_roll_rate.I_gain = 0
        SSS_FBW_roll_rate.Integral_sum = 0
        Roll_rate_input = 15 * get(Roll)
    else
        if vmax_prot_activation_ratio > 0 then
            roll_limits = 1
        else
            roll_limits = 33
        end

        SSS_FBW_roll_rate.I_gain = 0.5
        Roll_rate_input = 0
    end

    --pitch---------------------------------------------------------------------------------------
    if get(Flaps_internal_config) == 0 then
        if get(Pitch) > 0.05 then
            --SSS_FBW_G_load_pitch.I_gain = 0
            --SSS_FBW_G_load_pitch.Integral_sum = 0
            G_input = Set_anim_value(G_input, 1.5 * get(Pitch) + 1, -1, 2.5, 1)
        elseif get(Pitch) < -0.05 then
            --SSS_FBW_G_load_pitch.I_gain = 0
            --SSS_FBW_G_load_pitch.Integral_sum = 0
            G_input = Set_anim_value(G_input, 2 * get(Pitch) + 1, -1, 2.5, 1)
        else
            G_input = Set_anim_value(G_input, 1, -1, 2.5, 2)
            --SSS_FBW_G_load_pitch.I_gain = 0.04
        end
    else
        if get(Pitch) > 0.05 then
            G_input = get(Pitch) + 1
        elseif get(Pitch) < -0.05 then
            G_input = get(Pitch) + 1
        else
            G_input = 1
        end
    end

    G_output = SSS_PID(SSS_FBW_G_load_pitch, G_input - get(Total_vertical_g_load))
    vmax_prot_activation_ratio = Math_clamp((get(PFD_Capt_IAS) - get(Capt_VMAX)) / (get(Capt_VMAX_prot) - get(Capt_VMAX)), 0, 1)

    if get(DELTA_TIME) ~= 0 then
        left_roll_limit_output = SSS_PID(SSS_FBW_roll_left_limit, -roll_limits - get(Flightmodel_roll))
        right_roll_limit_output = SSS_PID(SSS_FBW_roll_right_limit, roll_limits - get(Flightmodel_roll))

        --slowly start to enable the pitch for vmax protection as the speed overshoots vmax and heads towards vmax prot
        vmax_prot_output = Math_lerp(-1, SSS_PID(SSS_FBW_vmax_prot_pitch, (get(PFD_Capt_IAS) + get(PFD_Fo_IAS)) / 2 - (get(Capt_VMAX_prot) + get(Fo_VMAX_prot)) / 2), vmax_prot_activation_ratio)

        if get(FBW_kill_switch) == 0 then
            set(Roll_artstab, Set_anim_value(get(Roll_artstab), Math_clamp_higher(Math_clamp_lower(SSS_PID(SSS_FBW_roll_rate, Roll_rate_input - get(True_roll_rate)), left_roll_limit_output), right_roll_limit_output), -1, 1, 0.8))
            set(Pitch_artstab, Set_anim_value(get(Pitch_artstab), Math_clamp(Math_clamp_higher(Math_clamp_lower(G_output, vmax_prot_output), SSS_PID(SSS_FBW_stall_prot_pitch, 11 - get(Alpha))), SSS_PID(SSS_FBW_pitch_down_limit, -15 - get(Flightmodel_pitch)), SSS_PID(SSS_FBW_pitch_up_limit, 30 - get(Flightmodel_pitch))),-1, 1, 0.55))

            if get(Any_wheel_on_ground) ~= 1 then
                --set(Elev_trim_ratio, Set_anim_value(get(Elev_trim_ratio), SSS_PID(SSS_FBW_CWS_trim, 0 - get(Vpath_pitch_rate)), -1, 1, 0.1))
            end
        end

    end

end