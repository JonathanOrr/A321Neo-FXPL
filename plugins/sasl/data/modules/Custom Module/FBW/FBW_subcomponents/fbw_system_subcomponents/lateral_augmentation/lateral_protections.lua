FBW.lateral.protections = {
    bank_limit = {33, 67},
    AoA_bank_angle_mode = false,
    HSP_bank_angle_mode = false,
    bank_angle_protection = function ()
        --properties
        local bank_angle_speed = 7.5
        local bank_limit_target = {33, 67}
        local max_bank = 67

        --check AoA bank angle--
        if adirs_get_avg_aoa() > get(Aprot_AoA) then
            FBW.lateral.protections.AoA_bank_angle_mode = true
        elseif FBW.lateral.protections.AoA_bank_angle_mode == true and adirs_get_avg_aoa() < get(Aprot_AoA) - 1 then
            FBW.lateral.protections.AoA_bank_angle_mode = false
        end
        --check HSP bank angle--
        if adirs_get_avg_ias() >= get(VMAX_prot) then
            FBW.lateral.protections.HSP_bank_angle_mode = true
        elseif FBW.lateral.protections.HSP_bank_angle_mode == true and adirs_get_avg_ias() < get(VMAX) then
            FBW.lateral.protections.HSP_bank_angle_mode = false
        end

        --avoid strange reconfigurations--
        if get(FBW_lateral_law) ~= FBW_NORMAL_LAW then
            FBW.lateral.protections.AoA_bank_angle_mode = false
            FBW.lateral.protections.HSP_bank_angle_mode = false
        end

        if FBW.lateral.protections.AoA_bank_angle_mode == true then--alpha protection bank angle protection
            bank_limit_target = {33, 45}
        elseif FBW.lateral.protections.HSP_bank_angle_mode == true then--high speed bank angle protection
            bank_limit_target = {0, 40}
        else
            bank_limit_target = {33, 67}
        end

        FBW.lateral.protections.bank_limit[1] = Set_linear_anim_value(FBW.lateral.protections.bank_limit[1], bank_limit_target[1], 0, max_bank, bank_angle_speed)
        FBW.lateral.protections.bank_limit[2] = Set_linear_anim_value(FBW.lateral.protections.bank_limit[2], bank_limit_target[2], 0, max_bank, bank_angle_speed)
    end
}