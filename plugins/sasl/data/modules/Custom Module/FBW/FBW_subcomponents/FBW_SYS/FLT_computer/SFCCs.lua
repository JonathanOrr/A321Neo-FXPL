FBW.FLT_computer.SFCC = {
    [1] = {
        Status_dataref = SFCC_1_status,
        Failure_dataref = FAILURE_FCTL_SFCC_1,
        Power = function ()
            return get(DC_ess_bus_pwrd) == 1
        end
    },
    [2] = {
        Status_dataref = SFCC_2_status,
        Failure_dataref = FAILURE_FCTL_SFCC_2,
        Power = function ()
            return get(DC_bus_2_pwrd) == 1
        end
    },
}