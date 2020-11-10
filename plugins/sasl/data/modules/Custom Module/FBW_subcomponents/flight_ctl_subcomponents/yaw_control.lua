function Rudder_control(yaw_input, in_normal_or_alt_law, is_in_auto_flight, trim_input)
    --[[in auto flight the rudder trim is controlled by the FMGC, otherwise the pilot can change the value by thing the knob on the center pedestal

    reversions
    flight computers FAC 1 --> FAC 2
    hyd(rudder)      G | B | Y
    hyd(damper)      G | Y
    mech             full mechanical link
    ]]

    --PROPERTIES--
    local rudder_speed = 0
    local rudder_trim_speed = 0
    local rudder_travel_target = set(Rudder, Math_rescale(-1, get(Rudder_travel_lim), 0, -get(Rudder_travel_lim) * get(Rudder_trim_ratio), yaw_input) + Math_rescale(0, -get(Rudder_travel_lim) * get(Rudder_trim_ratio), 1, -get(Rudder_travel_lim), yaw_input))

    --RUDDER LIMITS--
    if in_normal_or_alt_law == true and (get(FAC_1_status) == 1 or get(FAC_2_status) == 1) then
        set(Rudder_travel_lim, -22.1 * math.sqrt(1 - ( (get(PFD_Capt_IAS) + get(PFD_Fo_IAS) / 2) / 220)^2 ) + 25)
    end

    if in_normal_or_alt_law == false or get(Slats) > 0 then
        set(Rudder_travel_lim, Set_anim_value(get(Rudder_travel_lim), 30, 0, 30, 0.5))
    end

    --set(Rudder, rudder_travel_target)
end
