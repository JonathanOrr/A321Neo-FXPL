addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/AIL")

FBW.fctl.AIL = {}

components = {
    AIL_STAT {},
    AIL_ACT  {},
    AIL_CTL  {},
}

function update()
    updateAll(components)
end