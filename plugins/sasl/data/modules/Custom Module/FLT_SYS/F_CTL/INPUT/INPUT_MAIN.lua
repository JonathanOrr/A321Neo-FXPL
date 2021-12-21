addSearchPath(moduleDirectory .. "/Custom Module/FLT_SYS/F_CTL/INPUT")

FCTL.INPUT = {}

components = {
    SIDESTICK      {},
    INPUT_PRIORITY {},
    INPUT_SUM      {},
}

function update()
    updateAll(components)
end