include('constants.lua')

function ECAM_status_get_max_speed()

    max_kn   = 999
    max_mach = 999

    if get(FBW_status) == 0 then    -- direct law
        max_kn = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 77)
    elseif get(FBW_status) == 1 then
        max_kn = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 82)-- TODO should be .77 if dual HYD failure
    end
    
    if get(FAILURE_gear) == 1 then
        max_kn = math.min(max_kn, 280)
        max_mach = math.min(max_mach, 67)
    end
    
    if max_kn == 999 then
        return 0,0
    else
        return max_kn, max_mach
    end
end


function ECAM_status_get_max_fl()
    local max_fl = 0
    
    -- In any door is open...
    if get(Overwing_exit_1_l_ratio) > 0 or get(Overwing_exit_1_r_ratio) > 0 or
       get(Overwing_exit_2_l_ratio) > 0 or get(Overwing_exit_2_r_ratio) > 0 or
       get(Cargo_1_ratio) > 0 or get(Cargo_2_ratio) > 0 or get(Door_1_l_ratio) > 0 or
       get(Door_1_r_ratio) > 0 or get(Door_2_l_ratio) > 0 or get(Door_2_r_ratio) > 0 or
       get(Door_3_l_ratio) > 0 or get(Door_3_r_ratio) > 0 then
        max_fl = 100
    end
    return max_fl
end
