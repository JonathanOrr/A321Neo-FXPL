addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/GND_SPLR")

FBW.fctl.GND_SPLR = {}

components = {
    GND_SPLR_CMD  {},
    GND_SPLR_CTL  {},
}

function update()
    updateAll(components)
end