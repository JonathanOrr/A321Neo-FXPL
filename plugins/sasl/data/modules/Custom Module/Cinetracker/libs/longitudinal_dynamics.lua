function Theoretical_Q(Nz)
    local g         = get(Weather_g)
    local RAD_VPATH = math.rad(get(Vpath))
    local RAD_BANK  = math.rad(get(Flightmodel_roll))
    local TAS_MS    = Math_clamp_lower(get(TAS_ms), 0.1)

    return (g / TAS_MS) * (Nz - math.cos(RAD_VPATH) * math.cos(RAD_BANK))
end

function Neutral_Nz()
    local MAX_BANK_COMP = 45
    local RAD_VPATH = math.rad(get(Vpath))

    local BANK = math.abs(get(Flightmodel_roll))
    local RAD_BANK_ClAMPED = math.rad(Math_clamp_higher(BANK, MAX_BANK_COMP))

    local Nz = math.cos(RAD_VPATH) / math.cos(RAD_BANK_ClAMPED)

    return math.cos(RAD_VPATH)
end

function ComputeCSTAR(Nz, Q)
    local Vco = 120
    local g   = get(Weather_g)
    return Nz + (Vco * Q) / g
end