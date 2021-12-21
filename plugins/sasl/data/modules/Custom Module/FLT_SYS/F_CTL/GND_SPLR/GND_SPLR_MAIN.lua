addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/GND_SPLR")

FCTL.GND_SPLR = {}

components = {
    GND_SPLR_CMD  {},
    GND_SPLR_CTL  {},
}

function update()
    updateAll(components)
end