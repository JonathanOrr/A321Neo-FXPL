addSearchPath(moduleDirectory .. "/Custom Module/FBW/FBW_subcomponents/flight_ctl_subcomponents/INPUT")

FBW.fctl.INPUT = {}

components = {
    SIDESTICK      {},
    INPUT_PRIORITY {},
    INPUT_SUM      {},
}

function update()
    updateAll(components)
end