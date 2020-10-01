include("FBW_subcomponents/limits_calculations.lua")
include("FBW_subcomponents/flight_controls.lua")
addSearchPath(moduleDirectory .. "/Custom Module/FBW_subcomponents/")

components = {
    limits_calculations {},
    flight_controls {}
}

function update()
    updateAll(components)
end