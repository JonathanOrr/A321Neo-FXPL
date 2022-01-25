local DISAGREE_MARGIN = 5 --ft
RA_sys.flaps_full_time = 0

local function update_flaps_timer()
    if get(Slats) == 1 and get(Flaps_deployed_angle) == 30 and RA_sys.flaps_full_time <= 10 then
        RA_sys.flaps_full_time = RA_sys.flaps_full_time + get(DELTA_TIME)
    else
        RA_sys.flaps_full_time = RA_sys.flaps_full_time + get(DELTA_TIME)
    end
end

local function RA_sensor_validation(sensors)
    for i = 1, #sensors do
        if (adirs_get_avg_ias() > 200 and sensors[i].ALT_FT < 50) or get(RA_sys.Sensors[i].Status_dataref) == 0 then
            sensors[i].Valid = false
        else
            sensors[i].Valid = true
        end
    end
end

RA_sys.RA_disagree = function ()
    local RA_1 = RA_sys.Sensors[1].ALT_FT
    local RA_2 = RA_sys.Sensors[2].ALT_FT
    local RA_1_valid = RA_sys.Sensors[1].Valid
    local RA_2_valid = RA_sys.Sensors[2].Valid

    local RAs_valid = (RA_1_valid and 1 or 0) + (RA_2_valid and 1 or 0)

    --incapable of detection
    if RAs_valid < 2 then
        return false
    end

    --disagreement detection
    if math.abs(RA_1 - RA_2) > DISAGREE_MARGIN then
        return true
    end
end

--uses both RA sensors, the voter will try to resturn the most sensible value
RA_sys.all_RA_user = function ()
    local RA_1 = RA_sys.Sensors[1].ALT_FT
    local RA_2 = RA_sys.Sensors[2].ALT_FT
    local RA_1_valid = RA_sys.Sensors[1].Valid
    local RA_2_valid = RA_sys.Sensors[2].Valid

    local RAs_valid = (RA_1_valid and 1 or 0) + (RA_2_valid and 1 or 0)

    --RA RAW OUPUT
    local RA_ouptut = (RA_1 + RA_2) / 2          --Both Valid
    if RA_1_valid and not RA_2_valid then        --RA 1 Valid
        RA_ouptut = RA_1
    elseif not RA_1_valid and RA_2_valid then    --RA 2 Valid
        RA_ouptut = RA_2
    elseif not RA_1_valid and not RA_2_valid then--Non Valid
        RA_ouptut = 0
    end

    --MIXED COMPUTATION
    if RAs_valid == 2 then
        if RA_sys.RA_disagree() and RA_sys.flaps_full_time < 10 then--disagree
            RA_ouptut = Math_clamp_lower(RA_ouptut, 220)
        end
    elseif RAs_valid == 1 then
        if adirs_get_avg_ias() > 180 then
            RA_ouptut = Math_clamp_lower(RA_ouptut, 220)
        end
    else
        RA_ouptut = Math_clamp_lower(RA_ouptut, 220)
    end

    return RA_ouptut
end

--the user swaps source if its primary sensor is broken, erroneous value may be returned
RA_sys.single_RA_user = function (primary_RA)
    local Secondary_RA = Math_cycle(primary_RA + 1, 1, 2)
    local RAs = {
        RA_sys.Sensors[1].ALT_FT,
        RA_sys.Sensors[2].ALT_FT
    }
    local RAs_on = {
        get(RA_sys.Sensors[1].Status_dataref) == 1,
        get(RA_sys.Sensors[2].Status_dataref) == 1
    }

    if RAs_on[primary_RA] then
        return RAs[primary_RA]
    elseif RAs_on[Secondary_RA] then
        return RAs[Secondary_RA]
    else
        return 0
    end
end

function update()
    update_flaps_timer()
    RA_sensor_validation(RA_sys.Sensors)
end