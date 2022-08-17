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

    GET_GLOAD = function ()
        local msin = math.sin
        local mcos = math.cos
        local mrad = math.rad

        local RAD_ALPHA = mrad(get(Alpha))
        local RAD_BANK = mrad(get(Flightmodel_roll))

        local SDE_F = -get(Flightmodel_TOT_SDE_FORCE)
        local AXL_F = -get(Flightmodel_TOT_AXL_FORCE) --reversed 
        local NML_F = get(Flightmodel_TOT_NRM_FORCE)

        local SDE_Nz = SDE_F * msin(RAD_BANK) * mcos(RAD_ALPHA)
        local AXL_Nz = AXL_F * msin(RAD_ALPHA)
        local NML_Nz = NML_F * mcos(RAD_ALPHA)

        local Nz = (NML_Nz + AXL_Nz + SDE_Nz) / (get(Weather_g) * get(Gross_weight))

        return Nz
    end,

    GET_CSTAR = function (Nz, Q)
        local Vco = 100
        local g   = get(Weather_g)
        return Nz + (Vco * Q) / g
    end,
}