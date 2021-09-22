addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/ELEV")

FBW.fctl.ELEV = {}

components = {
    ELEV_STAT {},
    ELEV_ACT  {},
    ELEV_CTL  {},
}

function update()
    updateAll(components)
end