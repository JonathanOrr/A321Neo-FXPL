include("FBW/FBW_subcomponents/FBW_SYS/FAC_computation/common_functions.lua");

function update()
    set(S_speed, 1.23 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.22 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(GD, compute_green_dot(get(Aircraft_total_weight_kgs), adirs_get_avg_alt()))
end