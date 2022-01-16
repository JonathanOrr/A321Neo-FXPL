addSearchPath(moduleDirectory .. "/Custom Module/NAV/ADIRS")
addSearchPath(moduleDirectory .. "/Custom Module/NAV/GPS")
addSearchPath(moduleDirectory .. "/Custom Module/NAV/RA")

components = {
    ADIRS {},
    GPS {},
    RA_main {},
}

function update()
    updateAll(components)
end