RA_sys.Sensors = {
    [1] = {
        ALT_FT = 0,
        Valid = true,
        Source_dataref = Capt_ra_alt_ft,
        Status_dataref = RA_1_status,
        Erroneous_dataref = FAILURE_RA_1_ERR,
        Last_erroneous_time = 0,
        Failure_dataref = FAILURE_RA_1_FAIL,
        Power = function ()
            return get(AC_bus_1_pwrd) == 1
        end
    },
    [2] = {
        ALT_FT = 0,
        Valid = true,
        Source_dataref = Fo_ra_alt_ft,
        Status_dataref = RA_2_status,
        Erroneous_dataref = FAILURE_RA_2_ERR,
        Last_erroneous_time = 0,
        Failure_dataref = FAILURE_RA_2_FAIL,
        Power = function ()
            return get(AC_bus_2_pwrd) == 1
        end
    },
}

local RA_Z_POS = 27.95276 --ft aft of pivot
local function compute_RA_sensor_status(sensors)
    for i = 1, #sensors do
        local rad_pitch = math.rad(get(Flightmodel_pitch))
        local sensor_ra = get(sensors[i].Source_dataref) - RA_Z_POS*math.sin(rad_pitch)--fuselage position

        --SET RA SENSOR STATUS--
        if sensors[i].Power() and get(sensors[i].Failure_dataref) ~= 1 then
            set(sensors[i].Status_dataref, 1)
        else
            set(sensors[i].Status_dataref, 0)
        end

        --ACQUIRE RA INFO FROM SOURCE--
        if get(sensors[i].Erroneous_dataref) ~= 1 then
            sensors[i].ALT_FT = sensor_ra
        else
            if get(TIME) - sensors[i].Last_erroneous_time > 0.25 then
                if get(All_on_ground) == 1 then
                    sensors[i].ALT_FT = sensor_ra - 50 * math.random()
                    sensors[i].Last_erroneous_time = get(TIME)
                else
                    sensors[i].ALT_FT = sensor_ra * math.random()
                    sensors[i].Last_erroneous_time = get(TIME)
                end
            end
        end
    end
end

function update()
    compute_RA_sensor_status(RA_sys.Sensors)
end