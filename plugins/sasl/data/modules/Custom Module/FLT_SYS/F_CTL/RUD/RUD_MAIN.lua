addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/RUD")

FBW.fctl.RUD = {}

components = {
    RUD_CMD  {},
    RUD_STAT {},
    RUD_ACT  {},
    RUD_CTL  {},
}

function update()
    updateAll(components)
end