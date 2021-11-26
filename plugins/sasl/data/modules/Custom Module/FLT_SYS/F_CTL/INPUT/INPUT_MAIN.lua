addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/INPUT")

FBW.fctl.INPUT = {}

components = {
    SIDESTICK      {},
    INPUT_PRIORITY {},
    INPUT_SUM      {},
}

function update()
    updateAll(components)
end