FBW.FLT_computer.BCM = {
    [1] = {
        Status_dataref = BCM_status,
        Failure_dataref = FAILURE_FCTL_BCM,
        Power = function ()
            return get(Hydraulic_Y_press) >= 1450 and get(FAILURE_FCTL_BPS) ~= 1
        end
    },
}