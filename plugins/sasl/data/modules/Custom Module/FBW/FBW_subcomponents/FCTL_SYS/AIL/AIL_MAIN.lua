addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/AIL")

FBW.fctl.AIL = {}

components = {
    AIL_STAT {},
    AIL_ACT  {},
    AIL_CTL  {},
}

function update()
    updateAll(components)
end