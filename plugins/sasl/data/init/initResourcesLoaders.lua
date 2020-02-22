-------------------------------------------------------------------------------
-- Resources loaders
-------------------------------------------------------------------------------

--- Loads texture from image.
--- @param fileName string
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @overload fun(fileName:string):number
--- @overload fun(fileName:string, x:number, y:number):number
--- @return number, number, number
function loadImage(fileName, x, y, width, height)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find texture", fileName)
        return nil
    end

    local s
    if height ~= nil then s = sasl.gl.getGLTexture(f, x, y, width, height)
    elseif y ~= nil then s = sasl.gl.getGLTexture(f, x, y)
    else s = sasl.gl.getGLTexture(f) end

    if not s then
        logError("Can't load texture", fileName)
        return nil
    end
    local w, h = sasl.gl.getTextureSize(s)
    return s, w, h
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads SVG texture from image.
--- @param fileName string
--- @param rasterWidth number
--- @param rasterHeight number
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @overload fun(fileName:string, rasterWidth:number, rasterHeight:number):number
--- @overload fun(fileName:string, rasterWidth:number, rasterHeight:number, x:number, y:number):number
--- @return number, number, number
function loadVectorImage(fileName, rasterWidth, rasterHeight, x, y, width, height)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find vector texture", fileName)
        return nil
    end

    local s
    if height ~= nil then s = sasl.gl.getGLVectorTexture(f, rasterWidth, rasterHeight, x, y, width, height)
    elseif y ~= nil then s = sasl.gl.getGLVectorTexture(f, rasterWidth, rasterHeight, x, y)
    else s = sasl.gl.getGLVectorTexture(f, rasterWidth, rasterHeight) end

    if not s then
        logError("Can't load vector texture", fileName)
        return nil
    end
    local w, h = sasl.gl.getTextureSize(s)
    return s, w, h
end

sasl.gl.loadImage = loadImage
sasl.gl.loadVectorImage = loadVectorImage

sasl.gl.unloadImage = unloadTexture
unloadImage = unloadTexture
sasl.gl.loadImageFromMemory = loadTextureFromMemory
loadImageFromMemory = loadTextureFromMemory

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads old-style bitmap font from file.
--- @param fileName string
--- @return number
function loadBitmapFont(fileName)
    return private.loadFontImpl(fileName, sasl.gl.getGLBitmapFont)
end

sasl.gl.loadBitmapFont = loadBitmapFont

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads font from file (TTF, TTC, OTF, etc).
--- @param fileName string
--- @return number
function loadFont(fileName)
    return private.loadFontImpl(fileName, sasl.gl.getGLFont)
end

sasl.gl.loadFont = loadFont

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads font using specified.
--- @param fileName string
--- @param loadingFunction fun(fileName:string):number
--- @return number
function private.loadFontImpl(fileName, loadingFunction)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find font", fileName)
        return nil
    end

    local font = loadingFunction(f)
    if not font then
        logError("Can't load font", fileName)
    end
    return font
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Load sound sample from file.
--- @param fileName string
--- @param needToCreateTimer boolean
--- @param needReversed boolean
--- @overload fun(fileName:string):number
--- @overload fun(fileName:string, needToCreateTimer:boolean):number
--- @return number
function loadSample(fileName, needToCreateTimer, needReversed)
    if needToCreateTimer == nil then needToCreateTimer = false end
    if needReversed == nil then needReversed = false end

    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find sound", fileName)
        return nil
    end

    local s = sasl.al.loadSampleFromFile(f, needToCreateTimer, needReversed)
    if s == nil then
        logError("Can't load sound", fileName)
        return nil
    end
    return s
end

sasl.al.loadSample = loadSample

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads XP object from file.
--- @param fileName string
--- @return number
function loadObject(fileName)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find object", fileName)
        return nil
    end

    local o = sasl.loadObjectFromFile(f)
    if o == nil then
        logError("Can't load object", fileName)
    end
    return o
end

sasl.loadObject = loadObject

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads XP object from file asynchronously.
--- @param fileName string
--- @param callback fun(id:number)
--- @return number
function loadObjectAsync(fileName, callback)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find object", fileName)
        return nil
    end

    local o = sasl.loadObjectAsyncFromFile(f, callback)
    if o == nil then
        logError("Can't load object", fileName)
    end
    return o
end

sasl.loadObjectAsync = loadObjectAsync

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads shader source from file.
--- @param shaderID number
--- @param fileName string
--- @param shType ShaderTypeID
function loadShader(shaderID, fileName, shType)
    local f = findResourceFile(fileName)
    if f == nil then
        logError("Can't find shader source", fileName)
        return nil
    end

    sasl.gl.addShader(shaderID, f, shType)
end

sasl.gl.loadShader = loadShader

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
