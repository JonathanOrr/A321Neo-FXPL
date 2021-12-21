FBW.LAF.controllers = {
    SYS_status = function ()
        set(FBW_LAF_DATA_AVAIL, 1)
        set(FBW_LAF_DEGRADED_AIL, 0)
        set(FBW_LAF_DEGRADED_SPLR_4, 0)
        set(FBW_LAF_DEGRADED_SPLR_5, 0)

        --surface degradation--
        if not FCTL.AIL.STAT.L.controlled or not FCTL.AIL.STAT.R.controlled then
            set(FBW_LAF_DEGRADED_AIL, 1)
        end
        if not FCTL.SPLR.STAT.L[4].controlled or not FCTL.SPLR.STAT.R[4].controlled then
            set(FBW_LAF_DEGRADED_SPLR_4, 1)
        end
        if not FCTL.SPLR.STAT.L[5].controlled or not FCTL.SPLR.STAT.R[5].controlled then
            set(FBW_LAF_DEGRADED_SPLR_5, 1)
        end

        --data concentrater gone--
        if get(FCDC_1_status) == 0 and get(FCDC_2_status) == 0 then
            set(FBW_LAF_DATA_AVAIL, 0)
        end
    end,

    MLA_PID = {
        output = 0,
        bumpless_transfer = function ()
        end,
        control = function ()
            local PROCESSED_NZ = math.max(0, get(Total_vertical_g_load) - 1.8)

            --MANEUVERING LOAD ALLEVIATION--
            FBW.LAF.controllers.MLA_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_MLA_PID,
                0,
                PROCESSED_NZ
            )

            if get(Flaps_internal_config) > 1 or
               get(FBW_total_control_law) == FBW_DIRECT_LAW or
               adirs_get_avg_ias() < 200 or
               get(FBW_LAF_DEGRADED_AIL) == 1 or
               (get(FBW_LAF_DEGRADED_AIL) == 1 and get(FBW_LAF_DEGRADED_SPLR_4) == 1 and get(FBW_LAF_DEGRADED_SPLR_5) == 1) then
                FBW.LAF.controllers.MLA_PID.output = 0
            end
        end,
        bp = function ()
        end,
    },
    GLA_PID = {
        output = 0,
        status = function ()
        end,
        bumpless_transfer = function ()
        end,
        control = function ()
            --GUST LOAD ALLEVIATION--
            FBW.LAF.controllers.GLA_PID.output = FBW_PID_BP(
                FBW_PID_arrays.FBW_GLA_PID,
                0,
                math.abs(FBW.filtered_sensors.GS_TAS_DELTA.filtered)
            )

            if get(Flaps_internal_config) > 1 or
               get(FBW_total_control_law) == FBW_DIRECT_LAW or
               adirs_get_avg_ias() < 200 or
               (get(FBW_LAF_DEGRADED_AIL) == 1 and get(FBW_LAF_DEGRADED_SPLR_4) == 1 and get(FBW_LAF_DEGRADED_SPLR_5) == 1) then
                FBW.LAF.controllers.GLA_PID.output = 0
            end
        end,
        bp = function ()
        end,
    },

    output_blending = function ()
        set(
            FBW_MLA_output,
            Math_clamp(
                FBW.LAF.controllers.MLA_PID.output * get(FBW_vertical_flight_mode_ratio),
                0,
                5
            )
        )
        set(
            FBW_GLA_output,
            Math_clamp(
                FBW.LAF.controllers.GLA_PID.output * get(FBW_vertical_flight_mode_ratio),
                0,
                5
            )
        )
    end,
}