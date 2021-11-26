addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/THS")

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