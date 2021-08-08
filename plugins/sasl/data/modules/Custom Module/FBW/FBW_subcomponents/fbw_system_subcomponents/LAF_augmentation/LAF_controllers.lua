FBW.LAF.controllers = {
    SYS_status = function ()
        set(FBW_LAF_DATA_AVAIL, 1)
        set(FBW_LAF_DEGRADED_AIL, 0)
        set(FBW_LAF_DEGRADED_SPLR_4, 0)
        set(FBW_LAF_DEGRADED_SPLR_5, 0)

        --surface degradation--
        if not FBW.fctl.surfaces.ail.L.controlled or not FBW.fctl.surfaces.ail.R.controlled then
            set(FBW_LAF_DEGRADED_AIL, 1)
        end
        if not FBW.fctl.surfaces.splr.L[4].controlled or not FBW.fctl.surfaces.splr.R[4].controlled then
            set(FBW_LAF_DEGRADED_SPLR_4, 1)
        end
        if not FBW.fctl.surfaces.splr.L[5].controlled or not FBW.fctl.surfaces.splr.R[5].controlled then
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
        end,
        bp = function ()
        end,
    },

    output_blending = function ()
    end,
}