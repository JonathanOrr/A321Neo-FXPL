addSearchPath(moduleDirectory .. "/Custom Module/NAV/RA")

components = {
    RA_sensors {},
    RA_user {},
}

function update()
    updateAll(components)
end