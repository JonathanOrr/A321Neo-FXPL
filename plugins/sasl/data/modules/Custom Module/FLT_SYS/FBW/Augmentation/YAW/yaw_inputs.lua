FBW.yaw.inputs = {
    get_curr_turbolence = function ()  -- returns [0;1] range
        local alt_0 = get(Wind_layer_1_alt)
        local alt_1 = get(Wind_layer_2_alt)
        local alt_2 = get(Wind_layer_3_alt)

        local my_altitude = get(Elevation_m)
        local wind_turb = 0

        if my_altitude <= alt_0 then
            -- Lower than the first layer, turbolence extends to ground
            wind_turb = get(Wind_layer_1_turbulence)
        elseif my_altitude <= alt_1 then
            -- In the middle layer 0 and layer 1: interpolate
            wind_turb = Math_rescale(alt_0, get(Wind_layer_1_turbulence), alt_1, get(Wind_layer_2_turbulence), my_altitude)
        elseif my_altitude <= alt_2 then
            -- In the middle layer 1 and layer 2: interpolate
            wind_turb = Math_rescale(alt_1, get(Wind_layer_2_turbulence), alt_2, get(Wind_layer_3_turbulence), my_altitude)
        else
            -- Highest than the last layer, turbolence extends to space
            wind_turb = get(Wind_layer_3_turbulence)
        end

        return wind_turb / 10 -- XP datarefs are on scale [0;10], we change it to [0;1]
    end,

    damper_r_deg = function ()
        local msin = function (a) return math.sin(math.rad(a)) end
        local mcos = function (a) return math.cos(math.rad(a)) end
        local TAS_MS = Math_clamp_lower(adirs_get_avg_tas() / 1.944, 0.1)
        local VPATH = adirs_get_avg_vpath()
        local ROLL = adirs_get_avg_roll()

        local r_rad = (get(Weather_g) / TAS_MS) * (msin(ROLL) * mcos(VPATH) + get(Total_lateral_g_load))

        return (r_rad / math.pi) * 180
    end,

    x_to_beta = function (x)
        local MAX_RUD_DEF = 25

        --blend max beta according to speed of the aircraft and the A350 FCOM
        --15 degrees of beta at 160kts to 2 degrees at VMO [modified maximum beta to 8 due to difference in lateral static stability]
        --linear interpolation is used to avoid significant change in value during circular falloff
        local MAX_BETA = 8
        local MIN_BETA = 2
        local beta_range = MAX_BETA - MIN_BETA
        local Speed_range = get(Fixed_VMAX) - 160
        local IAS_KTS = Math_clamp(FBW.filtered_sensors.IAS.filtered, 160, get(Fixed_VMAX))
        set(Max_beta_demand_lim, -beta_range * math.sqrt(1 - ((IAS_KTS - get(Fixed_VMAX)) / Speed_range)^2) + MAX_BETA)

        local SI_demand = {
            {-MAX_RUD_DEF,                                        -MAX_BETA},
            {0,            get(RUD_TRIM_ANGLE) / MAX_RUD_DEF * MAX_BETA},
            {MAX_RUD_DEF,                                          MAX_BETA},
        }

        return Math_clamp(Table_interpolate(SI_demand, x), -get(Max_beta_demand_lim), get(Max_beta_demand_lim))
    end
}
