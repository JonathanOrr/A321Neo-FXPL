FBW.vertical.dynamics = {
    neutral_flight_G = function ()
        local MAX_COMP_A = 33
        local VAPTH = math.rad(get(Vpath))
        local ClAMPED_A = math.rad(Math_clamp(adirs_get_avg_roll(), -MAX_COMP_A, MAX_COMP_A))
        return math.cos(VAPTH) / math.cos(ClAMPED_A)
    end,
    neutral_flight_G_NO_LIM = function ()
        local VAPTH = math.rad(get(Vpath))
        local ClAMPED_A = math.rad(adirs_get_avg_roll())
        return math.cos(VAPTH) / math.cos(ClAMPED_A)
    end,

    GET_CSTAR = function (Nz, Q)
        --define 120m/s as the Vco
        return Nz + (120 * math.rad(Q)) / 9.8
    end,

    MAX_CSTAR = function ()
        local max_G = get(Flaps_internal_config) > 1 and 2 or 2.4565

        local rad_vpath = math.rad(get(Vpath))
        local rad_bank  = math.rad(adirs_get_avg_roll())

        local nz_trim = math.cos(rad_vpath) * math.cos(rad_bank)
        local delta_nz_turn = math.cos(rad_vpath) * (math.sin(math.rad(33))^2 / math.cos(math.rad(33)))

        local U_offset = (2 * (max_G - math.cos(rad_vpath) * math.cos(math.rad(67))) - delta_nz_turn) - (-2 * (max_G - math.cos(rad_vpath)) - delta_nz_turn)

        local upper_C_star_lim = -(1 - 1 + 2) * (max_G - nz_trim) - delta_nz_turn + U_offset --TODO cross over speed

        return upper_C_star_lim
    end,

    MIN_CSTAR = function ()
        local min_G = get(Flaps_internal_config) > 1 and 0 or -1

        local rad_vpath = math.rad(get(Vpath))
        local rad_bank  = math.rad(adirs_get_avg_roll())

        local nz_trim = math.cos(rad_vpath) * math.cos(rad_bank)

        local U_offset = (2 * (min_G - math.cos(rad_vpath) * math.cos(math.rad(67)))) - (-2 * (min_G - math.cos(rad_vpath)))

        local lower_C_star_lim = -(1 - 1 + 2) * (min_G - nz_trim) + U_offset --TODO cross over speed

        return lower_C_star_lim
    end

    --[[CSTAR_Lim = function ()
        local C_STAR_LIM = 3.775
        local G_LIM = 2.5
        local A_COMP = math.rad(33)
        local VPATH = math.rad(get(Vpath))
        local BANK = math.rad(adirs_get_avg_roll())

        local H_DILATION = math.acos(1/G_LIM) / math.acos(G_LIM/C_STAR_LIM)

        local UP_LIM = C_STAR_LIM * math.cos(VPATH) * math.cos(BANK/H_DILATION)           * BoolToNum(-math.pi/2 < BANK and BANK < math.pi/2)--  -90 <--> 90
        local LD_LIM = C_STAR_LIM * math.cos(VPATH) * math.cos(BANK + math.pi/H_DILATION) * BoolToNum(BANK <= -math.pi/2)                    -- -180 <--> 90
        local RD_LIM = C_STAR_LIM * math.cos(VPATH) * math.cos(BANK - math.pi/H_DILATION) * BoolToNum(math.pi/2 <= BANK)                     --   90 <--> 180

        local UP_COMP = math.cos(VPATH) / math.cos(BANK)                      * BoolToNum(-math.pi/2 + A_COMP < BANK and BANK < math.pi/2 - A_COMP)--  -90 <--> 90
        local LD_COMP = math.cos(VPATH) / math.cos(BANK + math.pi/H_DILATION) * BoolToNum(BANK <= -math.pi + A_COMP)                               -- -180 <--> 90
        local RD_COMP = math.cos(VPATH) / math.cos(BANK - math.pi/H_DILATION) * BoolToNum(math.pi/2 + A_COMP <= BANK)                              --   90 <--> 180
        local CS_COMP = math.cos(VPATH) / math.cos(A_COMP)                    * BoolToNum(not(-math.pi/2 + A_COMP < BANK and BANK < math.pi/2 - A_COMP) and not(BANK <= -math.pi + A_COMP) and not(math.pi/2 + A_COMP <= BANK))


        local LIM_OUT = UP_LIM + LD_LIM + RD_LIM
        local COMP_OUT = UP_COMP + LD_COMP + RD_COMP + CS_COMP

        return print(LIM_OUT, COMP_OUT)
    end,]]
}