-------------------------------------------------------------------------------
-- Filesystem helpers
-------------------------------------------------------------------------------

--- Checks if specified file exists.
--- @param fileName string
--- @return boolean
function isFileExists(fileName)
    local f = io.open(fileName)
    if f == nil then
        return false
    else
        io.close(f)
        return true
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Removes extension from path to file.
--- @param filePath string
--- @return string
function extractFileName(filePath)
    for i = string.len(filePath), 1, -1 do
        if string.sub(filePath, i, i) == '.' then
            return string.sub(filePath, 1, i - 1)
        end
    end
    return filePath
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Loads chunk of Lua code from specified file.
--- Will be searched according to the current list of search paths.
--- @param fileName string
--- @return function
function openFile(fileName)
    local name = extractFileName(fileName)

    for _, v in ipairs(private.searchPath) do
        local fullName
        local subdir
        if 0 < string.len(v) then
            fullName = v..'/'..fileName
            subdir = v..'/'..name
        else
            fullName = fileName
            subdir = name
        end

        if isFileExists(fullName) then
            local f, errorMsg = loadfile(fullName)
            if f then
                return f
            else
                logError(errorMsg)
            end
        end

        local subFullName = subdir .. '/' .. fileName
        if isFileExists(subFullName) then
            local f, errorMsg = loadfile(subFullName)
            if f then
                return f, subdir
            else
                logError(errorMsg)
            end
        end
    end

    return nil
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Finds specified resource file.
--- Will be searched according to the current list of search resources paths.
--- @param fileName string
--- @return string
function findResourceFile(fileName)
    for _, v in ipairs(private.searchResourcesPath) do
        local f = v .. '/' .. fileName
        if isFileExists(f) then
            return f
        end
    end

    if not isFileExists(fileName) then
        return nil
    else
        return fileName
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------