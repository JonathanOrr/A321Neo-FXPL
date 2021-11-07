addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/THS")

FBW.fctl.THS = {}
FBW.fctl.THS_MOTOR = {}

components = {
    THS_CMD {},
    THS_STAT {},
    THS_ACT  {},
    THS_CTL  {},
}

function update()
    updateAll(components)
end