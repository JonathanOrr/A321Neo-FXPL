addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/ELEV")

FBW.fctl.ELEV = {}

components = {
    ELEV_STAT {},
    ELEV_ACT  {},
    ELEV_CTL  {},
}

function update()
    updateAll(components)
end