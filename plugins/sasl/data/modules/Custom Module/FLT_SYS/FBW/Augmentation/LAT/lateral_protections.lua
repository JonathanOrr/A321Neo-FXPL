FBW.lateral.protections = {
    bank_limit = {33, 67},
    AoA_bank_angle_mode = false,
    HSP_bank_angle_mode = false,
    bank_angle_protection = function ()
        --properties
        local bank_angle_speed = 7.5
        local bank_limit_target = {33, 67}
        local max_bank = 67

        if FBW.vertical.protections.General.AoA.H_AOA_PROT_ACTIVE then--alpha protection bank angle protection
            bank_limit_target = {33, 45}
        end
        if FBW.vertical.protections.Flight.HSP.ACTIVE then--high speed bank angle protection
            bank_limit_target = {0, 40}
        end

        --avoid strange reconfigurations--
        if get(FBW_lateral_law) ~= FBW_NORMAL_LAW then
            bank_limit_target = {33, 67}
        end

        FBW.lateral.protections.bank_limit[1] = Set_linear_anim_value(FBW.lateral.protections.bank_limit[1], bank_limit_target[1], 0, max_bank, bank_angle_speed)
        FBW.lateral.protections.bank_limit[2] = Set_linear_anim_value(FBW.lateral.protections.bank_limit[2], bank_limit_target[2], 0, max_bank, bank_angle_speed)
    end
}