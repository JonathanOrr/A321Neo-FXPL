FBW.vertical.dynamics = {
    NEU_FLT_G = function ()
        local MAX_BANK_COMP = 33
        local RAD_VPATH = math.rad(get(Vpath))
        local RAD_BANK_ClAMPED = math.rad(Math_clamp(get(Flightmodel_roll), -MAX_BANK_COMP, MAX_BANK_COMP))

        return math.cos(RAD_VPATH) / math.cos(RAD_BANK_ClAMPED)
    end,
    NEU_FLT_G_NO_LIM = function ()
        local RAD_VPATH = math.rad(get(Vpath))
        local RAD_BANK  = math.rad(get(Flightmodel_roll))

        return math.cos(RAD_VPATH) / math.cos(RAD_BANK)
    end,

    GET_NEU_Q = function ()
        local g         = get(Weather_g)
        local RAD_VPATH = math.rad(get(Vpath))
        local RAD_BANK  = math.rad(get(Flightmodel_roll))
        local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

        return (g / TAS_MS) * (math.cos(RAD_VPATH) * math.sin(RAD_BANK)^2 / math.cos(RAD_BANK))
    end,
    GET_MANEUVER_Q = function (G)
        local g         = get(Weather_g)
        local RAD_VPATH = math.rad(get(Vpath))
        local RAD_BANK  = math.rad(get(Flightmodel_roll))
        local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

        return (g / TAS_MS) * (G - math.cos(RAD_VPATH) * math.cos(RAD_BANK))
    end,

    Path_Load_Factor = function (axis)
        local msin = function (a) return math.sin(math.rad(a)) end
        local mcos = function (a) return math.cos(math.rad(a)) end

        local ALPHA = get(Alpha)
        local BETA  = get(Beta)

        local ACF_X_F = -get(Flightmodel_TOT_AXL_FORCE) --reversed 
        local ACF_Y_F = get(Flightmodel_TOT_SDE_FORCE)
        local ACF_Z_F = get(Flightmodel_TOT_NRM_FORCE)

        local PATH_X_F =  ACF_X_F * mcos(ALPHA) * mcos(BETA) + ACF_Y_F * msin(BETA) - ACF_Z_F * msin(ALPHA) * mcos(BETA)
        local PATH_Y_F = -ACF_X_F * mcos(ALPHA) * msin(BETA) + ACF_Y_F * mcos(BETA) + ACF_Z_F * msin(ALPHA) * msin(BETA)
        local PATH_Z_F =  ACF_X_F * msin(ALPHA)                                     + ACF_Z_F * mcos(ALPHA)

        local WEIGHT_F = get(Gross_weight) * get(Weather_g)

        local PATH_N = {
            ["x"] = PATH_X_F / WEIGHT_F,
            ["y"] = PATH_Y_F / WEIGHT_F,
            ["z"] = PATH_Z_F / WEIGHT_F,
        }

        return PATH_N[axis]
    end,

    GET_CSTAR = function (Nz, Q)
        local Vco = 100
        local g   = get(Weather_g)
        return Nz + (Vco * Q) / g
    end,
}