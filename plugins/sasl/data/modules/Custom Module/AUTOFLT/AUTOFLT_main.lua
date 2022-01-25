addSearchPath(moduleDirectory .. "/Custom Module/AUTOFLT/FCU/")
addSearchPath(moduleDirectory .. "/Custom Module/AUTOFLT/ATHRS/")

components = {
    ATHRS_MAIN {},
    FCU {},
}

function update()
    updateAll(components)
end

function draw()
    drawAll(components)
end

