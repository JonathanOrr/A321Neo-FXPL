
function ECAM_status_get_max_speed()

    max_kn   = 999
    max_mach = 999

    -- Brakes
    if get(L_brakes_temp) > 300 or get(R_brakes_temp) > 300 or get(LL_brakes_temp) > 300 or get(RR_brakes_temp) > 300 then
        -- For landing gear down
        max_kn   = math.min(max_kn, 280)
        max_mach = math.min(max_mach, 67)
    end

    if get(FAILURE_ENG_REV_UNLOCK, 1) == 1 or get(FAILURE_ENG_REV_UNLOCK, 2) == 1 then
        max_kn   = math.min(max_kn, 300)
        max_mach = math.min(max_mach, 78)
    end
    
    if get(FAILURE_AVIONICS_SMOKE) == 1 then
        max_kn   = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 77)
    end

    -- HYD
    if get(Hydraulic_Y_press) < 1750 and get(Hydraulic_B_press) < 1750 then
        max_kn   = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 77)
    end

    -- FAC

    if get(FBW_total_control_law) == FBW_DIRECT_LAW then    -- direct law
        max_kn   = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 77)
    elseif get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW then
        max_kn   = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 82)-- TODO should be .77 if dual HYD failure
    end

    if get(FAILURE_gear) == 1 then
        max_kn   = math.min(max_kn, 280)
        max_mach = math.min(max_mach, 67)
    end

    -- ENG
    if !ENG.dyn[2].is_avail and !ENG.dyn[1].is_avail then
        max_kn   = math.min(max_kn, 320)
        max_mach = math.min(max_mach, 77)
    end

    if max_kn == 999 then
        return 0,0
    else
        return max_kn, max_mach
    end
end


function ECAM_status_get_max_fl()
    local max_fl = 999

    -- In any door is open...
    if get(Overwing_exit_1_l_ratio) > 0 or get(Overwing_exit_1_r_ratio) > 0 or
       get(Overwing_exit_2_l_ratio) > 0 or get(Overwing_exit_2_r_ratio) > 0 or
       get(Cargo_1_ratio) > 0 or get(Cargo_2_ratio) > 0 or get(Door_1_l_ratio) > 0 or
       get(Door_1_r_ratio) > 0 or get(Door_2_l_ratio) > 0 or get(Door_2_r_ratio) > 0 or
       get(Door_3_l_ratio) > 0 or get(Door_3_r_ratio) > 0 then
        max_fl = math.min(max_fl, 100)
    end
    
    if get(Cabin_alt_ft) > 9550 then
        max_fl = math.min(max_fl, 100)
    end
    
    return max_fl
end
