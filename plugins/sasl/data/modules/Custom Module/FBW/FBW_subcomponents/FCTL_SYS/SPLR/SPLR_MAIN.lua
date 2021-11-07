addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/SPLR")

FBW.fctl.SPLR = {}

components = {
    SPLR_STAT {},
    SPLR_ACT  {},
    SPLR_CTL  {},
}

function update()
    updateAll(components)
end