function update()
    set(S_speed, 1.23 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.22 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(GD, (1.5 * get(Aircraft_total_weight_kgs) / 1000 + 110) + Math_clamp_lower((adirs_get_avg_alt() - 20000) / 1000, 0))
end