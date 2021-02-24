addSearchPath(moduleDirectory .. "/Custom Module/AUTOFLT/FCU/")

components = {
    FCU {},
}

function update()
    updateAll(components)
end

function draw()
    drawAll(components)
end