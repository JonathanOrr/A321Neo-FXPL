---@class LuaClass
---@field private __isCls boolean
---@field private __isObj boolean
---@field private __operators table
---@field private _ table
---@field protected class table
---@field protected base table
---@field protected new fun(...): LuaClass
---@field protected init fun(...)
---@field public extend fun(self:LuaClass, class?: table): table
LuaClass = {}

---Internal function to copy tables, used for inheritance
---@param src? table
---@param dest? table
---@return table
local function inherit(src, dest)
    src = src or {}
    local result = dest or {}

    for k, v in pairs(src) do
        if not result[k] then
            if type(v) == "table" and k ~= "__index" and k ~= "__newindex" and k ~= "staticClass" and k ~= "base" and k ~= "class" then
                result[k] = inherit(v)
            else
                result[k] = v
            end
        end
    end

    return result
end

---Internally used to handle indexing of a class
---@param table table
---@param key any
---@return any
local function idx(table, key)
    local member = rawget(table._, key)

    --TODO: check is the caller is an object or class
    if member then
        if member.static and table.__isObj then
            return error("Please call static members using the name of the class", 1)
        elseif member.static and table ~= member.staticClass then
            return error(
                "Static property/field/method called from derived class without override. Call from base class instead.",
                1)
        end

        if member.get or member.set then --properties
            if member.get then
                return member.get(table, member.value)
            else
                return error("Tried to get a set-only property", 1)
            end
        end

        --fields or methods
        return member.value
    else
        return member
    end
end

---Internally used to handle writing to a class
---@param table table
---@param key any
---@param value any
local function newIdx(table, key, value)
    local member = rawget(table._, key)

    --check writing to internal properties
    if key == "base" or key == "class" or key == "__isCls" or key == "__isObj" then
        return error("Tried to override internal properties", 1)
    end

    if member then
        --methods
        if type(member.value) == "function" then
            return error("Please override methods using the \"declare\" class method", 1)
        end

        if member.readonly then
            return error("Tried to override/write a readonly memeber", 1)
        end

        if table.__isObj and member.static then
            return error("Please write static members using the name of the class", 1)
        end
        if member.static and table ~= member.staticClass then
            return error(
                "Static property/field/method written from derived class without override. Write from base class instead.",
                1)
        end

        --properties
        if member.set then
            local finalValue = value
            finalValue = member.set(table, value, member.value)
            member.value = finalValue
            return
        elseif member.get then
            return error("Tried to write to a read-only property", 1)
        end

        --fields
        member.value = value
    else
        return error(("No member with the name \"%s\" is found"):format(key), 1)
    end
end

---Use to create a class/subclass (DO NOT USE TO CREATE OBJECTS)
---@param class? table
---@return table
function LuaClass:extend(class)
    local class = class or {}

    inherit(self, class)

    class._ = class._ or {}
    class.__operators = class.__operators or {}
    class.base = self
    class.__isCls = true

    local mt = {}

    -- create new objects directly, like o = Object()
    mt.__call = function(self, ...)
        return self:new(...)
    end

    -- allow for modifiers
    mt.__index = idx
    mt.__newindex = newIdx

    setmetatable(class, mt)

    return class
end

---Internal function to copy tables, used for instantiation
---@param class? table
---@param obj? table
---@return table
local function instantiate(class, obj)
    class = class or {}
    class = class._ or {}
    local result = obj or {}
    result._ = {}

    for k, v in pairs(class) do
        if not result._[k] then
            if type(v) == "table" and k ~= "__index" and k ~= "__newindex" and k ~= "protClass" and k ~= "staticClass" then
                result._[k] = inherit(v)
            else
                result._[k] = v
            end
        end
    end

    return result
end

-- default (empty) constructor
function LuaClass:init(...) end

---Internally used to construct an object everytime the class is called
---@param ... any
---@return LuaClass
function LuaClass:new(...)
    local obj = instantiate(self)

    --internal properties
    obj.class = self
    obj.__isObj = true

    --metatmethods
    local mt = {}
    mt.__index = idx
    mt.__newindex = newIdx
    --operator overloading
    for key, val in pairs(self.__operators) do
        mt[key] = val
    end
    setmetatable(obj, mt)

    if self.init then self.init(obj, ...) end

    return obj
end

---Use to declare class members
---@param name string
---@param value any
---@param ...? string
---|"readonly"
---|"sealed"
---|"static"
---|"operator"
function LuaClass:declare(name, value, ...)
    local args = { ... }
    --modifier format checking
    local mod = {}
    for key, val in ipairs(args) do --set all modifiers
        if val == "readonly" or val == "sealed" or val == "static" or val == "operator" then
            if key > 1 and val == "operator" or mod.operator then
                return error("operator cannot be use with other modifiers", 1)
            end

            -- modifier collision (check github manual)
            if mod.readonly and val == "sealed" then
                return error("readonly cannot be used with sealed", 1)
            elseif mod.sealed and val == "readonly" then
                return error("readonly cannot be used with sealed", 1)
            end

            mod[val] = true
        else
            return error(("Invalid modifier %s"):format(val), 1)
        end
    end

    --operator overloading
    if mod.operator then
        return rawset(self.__operators, name, value)
    end

    local rawMember = rawget(self._, name)
    if rawMember then
        if rawMember.sealed then
            return error("Tried to override a sealed member", 1)
        end
    end

    --properties
    if type(value) == "table" then
        if mod.sealed then
            return error("properies cannot be sealed", 1)
        elseif mod.readonly then
            return error("Make properties read-only by declaring only with setter", 1)
        end

        if not (value.get or value.set) then
            return error(("Unmeaningful declaration of property \"%s\": no getter nor setter"):format(name), 1)
        elseif not value.value then
            return error(("Please provide default value for property \"%s\""):format(name), 1)
        end

        rawset(self._, name, {
            static = mod.static,
            value  = value.value,
            get    = value.get,
            set    = value.set,
        })
        rawMember = rawget(self._, name)
        if mod.static then rawMember.staticClass = self end
        return
    end

    --methods
    if type(value) == "function" then
        if mod.readonly then
            return error("Methods cannot be read-only", 1)
        end

        rawset(self._, name, {
            sealed = mod.sealed,
            static = mod.static,
            value  = value
        })
        rawMember = rawget(self._, name)
        if mod.static then rawMember.staticClass = self end
        return
    end

    --fields
    if mod.sealed then
        return error("fields cannot be sealed", 1)
    end

    rawset(self._, name, {
        readonly = mod.readonly,
        static   = mod.static,
        value    = value
    })
    rawMember = rawget(self._, name)
    if mod.static then rawMember.staticClass = self end
end

---Prints the whole class table with indents
---@param class table|any
---@param indent? integer
function InspectLuaClass(class, indent)
    indent = indent or 0
    local indentStr = ""
    for i = 1, indent do
        indentStr = indentStr .. "    "
    end

    class = class or {}
    if class.__isCls then print("----------CLASS----------") end
    if class.__isObj then print("---------OBJECT---------") end

    for k, v in pairs(class) do
        if type(v) == "table" and k ~= "__index" and k ~= "__newindex" and k ~= "staticClass" and k ~= "base" and k ~= "class" then
            print(indentStr .. indent .. " " .. k)
            print(indentStr .. "{")
            InspectLuaClass(v, indent + 1)
            print(indentStr .. "}")
        else
            print(indentStr .. indent .. " " .. k, v)
        end
    end
end
