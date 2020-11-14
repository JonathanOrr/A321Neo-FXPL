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
-- File: doors.lua 
-- Short description: Command handlers for doors
-------------------------------------------------------------------------------

--register commands
sasl.registerCommandHandler ( Door_1_l_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_1_l_switch, 1 - get(Door_1_l_switch))
    end
end)

sasl.registerCommandHandler ( Door_1_r_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_1_r_switch, 1 - get(Door_1_r_switch))
    end
end)

sasl.registerCommandHandler ( Door_2_l_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_2_l_switch, 1 - get(Door_2_l_switch))
    end
end)

sasl.registerCommandHandler ( Door_2_r_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_2_r_switch, 1 - get(Door_2_r_switch))
    end
end)

sasl.registerCommandHandler ( Door_3_l_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_3_l_switch, 1 - get(Door_3_l_switch))
    end
end)

sasl.registerCommandHandler ( Door_3_r_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Door_3_r_switch, 1 - get(Door_3_r_switch))
    end
end)

sasl.registerCommandHandler ( Overwing_exit_1_l_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Overwing_exit_1_l_switch, 1 - get(Overwing_exit_1_l_switch))
    end
end)

sasl.registerCommandHandler ( Overwing_exit_1_r_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Overwing_exit_1_r_switch, 1 - get(Overwing_exit_1_r_switch))
    end
end)

sasl.registerCommandHandler ( Overwing_exit_2_l_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Overwing_exit_2_l_switch, 1 - get(Overwing_exit_2_l_switch))
    end
end)

sasl.registerCommandHandler ( Overwing_exit_2_r_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Overwing_exit_2_r_switch, 1 - get(Overwing_exit_2_r_switch))
    end
end)

sasl.registerCommandHandler ( Cargo_1_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cargo_1_switch, 1 - get(Cargo_1_switch))
    end
end)

sasl.registerCommandHandler ( Cargo_2_toggle, 0, function(phase)
    if phase == SASL_COMMAND_BEGIN then
        set(Cargo_2_switch, 1 - get(Cargo_2_switch))
    end
end)

function update()
    if get(Ecam_current_page) == 9 then
        set(Ecam_door_click_shown, 1)
    else
        set(Ecam_door_click_shown, 0)
    end

    if get(DELTA_TIME) ~= 0 then
        set(Door_1_l_ratio, Set_linear_anim_value(get(Door_1_l_ratio), get(Door_1_l_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Door_1_r_ratio, Set_linear_anim_value(get(Door_1_r_ratio), get(Door_1_r_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Door_2_l_ratio, Set_linear_anim_value(get(Door_2_l_ratio), get(Door_2_l_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Door_2_r_ratio, Set_linear_anim_value(get(Door_2_r_ratio), get(Door_2_r_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Door_3_l_ratio, Set_linear_anim_value(get(Door_3_l_ratio), get(Door_3_l_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Door_3_r_ratio, Set_linear_anim_value(get(Door_3_r_ratio), get(Door_3_r_switch), 0, 1, 0.25, 0.26 * get(DELTA_TIME)))
        set(Overwing_exit_1_l_ratio, Set_linear_anim_value(get(Overwing_exit_1_l_ratio), get(Overwing_exit_1_l_switch), 0, 1, 0.9, 0.91 * get(DELTA_TIME)))
        set(Overwing_exit_1_r_ratio, Set_linear_anim_value(get(Overwing_exit_1_r_ratio), get(Overwing_exit_1_r_switch), 0, 1, 0.9, 0.91 * get(DELTA_TIME)))
        set(Overwing_exit_2_l_ratio, Set_linear_anim_value(get(Overwing_exit_2_l_ratio), get(Overwing_exit_2_l_switch), 0, 1, 0.9, 0.91 * get(DELTA_TIME)))
        set(Overwing_exit_2_r_ratio, Set_linear_anim_value(get(Overwing_exit_2_r_ratio), get(Overwing_exit_2_r_switch), 0, 1, 0.9, 0.91 * get(DELTA_TIME)))
        set(Cargo_1_ratio, Set_linear_anim_value(get(Cargo_1_ratio), get(Cargo_1_switch), 0, 1, 0.15, 0.16 * get(DELTA_TIME)))
        set(Cargo_2_ratio, Set_linear_anim_value(get(Cargo_2_ratio), get(Cargo_2_switch), 0, 1, 0.15, 0.16 * get(DELTA_TIME)))
    end
end
