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


include("FLT_SYS/FBW/FAC_computation/common_functions.lua");

function update()
    set(S_speed, 1.23 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 0, false))
    set(F_speed, 1.22 * FBW.FAC_COMPUTATION.Extract_vs1g(get(Aircraft_total_weight_kgs), 2, false))
    set(GD, compute_green_dot(get(Aircraft_total_weight_kgs), adirs_get_avg_alt()))
end