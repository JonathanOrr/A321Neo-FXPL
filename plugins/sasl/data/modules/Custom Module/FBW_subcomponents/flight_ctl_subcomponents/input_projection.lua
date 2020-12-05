function Project_circle_to_square_inputs(roll, pitch)

    local input_quadrant = 1
    if pitch > 0 and roll > 0 then
        input_quadrant = 1
    elseif pitch > 0 and roll < 0 then
        input_quadrant = 2
    elseif pitch < 0 and roll < 0 then
        input_quadrant = 3
    elseif pitch < 0 and roll > 0 then
        input_quadrant = 4
    end

    local input_radius = Math_clamp_higher(math.sqrt(pitch^2 + roll^2), 1)
    local input_angle_rad = math.atan(pitch / roll)
    local input_angle_deg = math.deg(math.atan(get(Pitch) / get(Roll)))
    local input_gradient = math.tan(input_angle_rad)
    local projected_roll = 0
    local projected_pitch = 0

    if input_quadrant == 1 then
        if input_angle_deg <= 45 then
            projected_roll = input_radius
            projected_pitch = input_gradient * input_radius
        else--swap gradient axis
            projected_roll = input_radius / input_gradient
            projected_pitch = input_radius
        end
    elseif input_quadrant == 2 then
        if input_angle_deg >= -45 then
            projected_roll =  - input_radius
            projected_pitch = - input_gradient * input_radius
        else--swap gradient axis
            projected_roll = - input_radius / -input_gradient
            projected_pitch = input_radius
        end
    elseif input_quadrant == 3 then
        if input_angle_deg <= 45 then
            projected_roll = - input_radius
            projected_pitch =  - input_gradient * input_radius
        else--swap gradient axis
            projected_roll =  - input_radius / input_gradient
            projected_pitch =  - input_radius
        end
    elseif input_quadrant == 4 then
        if input_angle_deg >= -45 then
            projected_roll = input_radius
            projected_pitch = input_gradient * input_radius
        else
            projected_roll = input_radius / -input_gradient
            projected_pitch = - input_radius
        end
    end

    if roll == 0 then
        set(Augmented_roll, 0)
    else
        set(Augmented_roll, projected_roll)
    end

    if pitch == 0 then
        set(Augmented_roll, 0)
    else
        set(Augmented_pitch, projected_pitch)
    end
end