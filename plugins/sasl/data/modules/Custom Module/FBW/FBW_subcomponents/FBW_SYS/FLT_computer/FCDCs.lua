FBW.FLT_computer.FCDC = {
    [1] = {
        Status_dataref = FCDC_1_status,
        Failure_dataref = FAILURE_FCTL_FCDC_1,
        Power = function ()
            return get(DC_shed_ess_pwrd) == 1
        end
    },
    [2] = {
        Status_dataref = FCDC_2_status,
        Failure_dataref = FAILURE_FCTL_FCDC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}