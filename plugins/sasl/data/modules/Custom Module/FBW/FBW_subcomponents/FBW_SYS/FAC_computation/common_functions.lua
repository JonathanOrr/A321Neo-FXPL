function compute_green_dot(weight, altitude)
    return (1.5 * weight / 1000 + 110) + Math_clamp_lower((altitude - 20000) / 1000, 0);
end