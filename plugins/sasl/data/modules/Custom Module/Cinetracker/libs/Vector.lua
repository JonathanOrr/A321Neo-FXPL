require "Cinetracker.libs.LuaClass"

--common lib--
local function mathSign(val)
    return val > 0 and 1 or (val == 0 and 0 or -1)
end

--Class declarations-- ============================================================== as separators

---Vector2 with 2 components and useful methods
---@class Vector2:LuaClass
---@field public x number
---@field public y number
---@field public magnitude number
---@field public normalized Vector2
---@field public sqrMagnitude number
---@field public Equals fun(self: Vector2, other: Vector2): boolean Returns true if the given vector is exactly equal to this vector.
---@field public Normalize fun(self: Vector2) Makes this vector have a magnitude of 1.
---@field public ToString fun(self: Vector2, fmt: string): string Returns a formatted string for this vector.
---@field public Angle fun(from: Vector2, to: Vector2): number Gets the unsigned angle in degrees between from and to.
---@field public ClampMagnitude fun(vec: Vector2, maxLength: number): Vector2 Returns a copy of vector with its magnitude clamped to maxLength.
---@field public Distance fun(a: Vector2, b: Vector2): number Returns the distance between a and b.
---@field public Dot fun(lhs: Vector2, rhs: Vector2): number Dot Product of two vectors.
---@field public Max fun(lhs: Vector2, rhs: Vector2): Vector2 Returns a vector that is made from the largest components of two vectors.
---@field public Min fun(lhs: Vector2, rhs: Vector2): Vector2 Returns a vector that is made from the smallest components of two vectors.
---@field public Perpendicular fun(inDirection: Vector2): Vector2 Returns the 2D vector perpendicular to this 2D vector. The result is always rotated 90-degrees in a counter-clockwise direction for a 2D coordinate system where the positive Y axis goes up.
---@field public Rotate fun(vec: Vector2, theta: number): Vector2 rotate a vector counter-clockwise, in degrees;
---@field public Scale fun(a: Vector2, b: Vector2): Vector2 Multiplies two vectors component-wise.
---@field public SignedAngle fun(from: Vector2, to: Vector2): number Gets the signed angle in degrees between from and to.
---@field private __unm fun(self: Vector2): Vector2 negate the vector itself.
---@field private __sub fun(self: Vector2, other: Vector2): Vector2 Subtracts one vector from another.
---@field private __mul fun(self: Vector2, num: number): Vector2 Multiplies a vector by a number.
---@field private __div fun(self: Vector2, num: number): Vector2 Divides a vector by a number.
---@field private __add fun(self: Vector2, other: Vector2): Vector2 Adds two vectors.
---@field private __eq fun(self: Vector2, other: Vector2): boolean Returns true if two vectors are approximately equal.
---@field private __tostring fun(self: Vector2): string Convert to string for printing
---@operator unm(Vector2): Vector2
---@operator sub(Vector2): Vector2
---@operator mul(number): Vector2
---@operator div(number): Vector2
---@operator add(Vector2): Vector2
---@overload fun(): Vector2
---@overload fun(x: Vector3): Vector2
---@overload fun(x: number, y: number): Vector2
Vector2 = LuaClass:extend()

function Vector2:init(x, y)
    if x and y then
        self.x = x
        self.y = y
    elseif x.class == Vector3 then
        self.x = x.x
        self.y = x.y
    end
end

-- Attributes --

Vector2:declare("x", 0)
Vector2:declare("y", 0)
Vector2:declare("magnitude",
    {
        value = 0,
        get = function(self, value)
            return math.sqrt(self.x ^ 2 + self.y ^ 2)
        end,
    }
)
Vector2:declare("normalized",
    {
        value = 0,
        get = function(self, value)
            local mag = self.magnitude
            local normX, normY = self.x / mag, self.y / mag
            local normVec = Vector2(normX, normY)

            return normVec
        end,
    }
)
Vector2:declare("sqrMagnitude",
    {
        value = 0,
        get = function(self, value)
            return self.x ^ 2 + self.y ^ 2
        end,
    }
)

-- Public Methods --

Vector2:declare("Equals",
    function(self, other)
        if other.x ~= self.x then return false end
        if other.y ~= self.y then return false end

        return true
    end
)
Vector2:declare("Normalize",
    function(self)
        -- TODO: check if this thing works
        local mag = self.magnitude
        self.x, self.y = self.x / mag, self.y / mag
    end
)
Vector2:declare("ToString",
    function(self, fmt)
        return string.format(fmt, self.x, self.y)
    end
)

-- Static Methods --

Vector2:declare("Angle",
    function(from, to)
        local magf, magt = from:magnitude(), to:magnitude()
        local dot = from.x * to.x + from.y * to.y

        return math.deg(math.acos(dot / (magf * magt)))
    end,
    "static"
)
Vector2:declare("ClampMagnitude",
    function(vec, maxLength)
        -- TODO: check if this thing works
        local mag = vec:magnitude()
        local scale = math.min(maxLength, mag) / mag
        local clampedX, clampedY = vec.x * scale, vec.y * scale

        return Vector2(clampedX, clampedY)
    end,
    "static"
)
Vector2:declare("Distance",
    function(a, b)
        local diffX, diffY = a.x - b.x, a.y - b.y

        return math.sqrt(diffX ^ 2 + diffY ^ 2)
    end,
    "static"
)
Vector2:declare("Dot",
    function(lhs, rhs)
        return lhs.x * rhs.x + lhs.y * rhs.y
    end,
    "static"
)
Vector2:declare("Max",
    function(lhs, rhs)
        local maxX, maxY = math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y)
        return Vector2(maxX, maxY)
    end,
    "static"
)
Vector2:declare("Min",
    function(lhs, rhs)
        local minX, minY = math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y)
        return Vector2(minX, minY)
    end,
    "static"
)
Vector2:declare("Perpendicular",
    function(inDirection)
        local mcos = math.cos
        local msin = math.sin
        local mrad = math.rad

        local xPer = mcos(mrad(90)) * inDirection.x - msin(mrad(90)) * inDirection.y
        local yPer = msin(mrad(90)) * inDirection.x + mcos(mrad(90)) * inDirection.y

        return Vector2(xPer, yPer)
    end,
    "static"
)
Vector2:declare("Rotate",
    function(vec, theta)
        local mcos = math.cos
        local msin = math.sin
        local mrad = math.rad

        local xRot = mcos(mrad(theta)) * vec.x - msin(mrad(theta)) * vec.y
        local yRot = msin(mrad(theta)) * vec.x + mcos(mrad(theta)) * vec.y

        return Vector2(xRot, yRot)
    end,
    "static"
)
Vector2:declare("Scale",
    function(a, b)
        return Vector2(a.x * b.x, a.y * b.y)
    end,
    "static"
)
Vector2:declare("SignedAngle",
    function(from, to)
        local unsignedAngle = Vector2.Angle(from, to)
        local crossMag = from.x * to.y - from.y * to.x
        local sign = mathSign(crossMag)

        return sign * unsignedAngle
    end,
    "static"
)

-- Operators --

Vector2:declare("__unm",
    function(self)
        return Vector2(
            -self.x,
            -self.y
        )
    end,
    "operator"
)
Vector2:declare("__sub",
    function(self, other)
        return Vector2(
            self.x - other.x,
            self.y - other.y
        )
    end,
    "operator"
)
Vector2:declare("__mul",
    function(self, num)
        if type(self) ~= "table" then
            local temp = self
            self = num
            num = temp
        end

        return Vector2(
            self.x * num,
            self.y * num
        )
    end,
    "operator"
)
Vector2:declare("__div",
    function(self, num)
        return Vector2(
            self.x / num,
            self.y / num
        )
    end,
    "operator"
)
Vector2:declare("__add",
    function(self, other)
        return Vector2(
            self.x + other.x,
            self.y + other.y
        )
    end,
    "operator"
)
Vector2:declare("__eq",
    function(self, other)
        local dx = self.x + other.x
        local dy = self.y + other.y

        if math.sqrt(dx ^ 2 + dy ^ 2) >= 1e-5 then
            return false
        end

        return true
    end,
    "operator"
)
Vector2:declare("__tostring",
    function(self)
        return string.format("Vector2(%f, %f)", self.x, self.y)
    end,
    "operator"
)

--=================================================================================================

---Vector3 with 3 components and useful methods
---@class Vector3:LuaClass
---@field public x number
---@field public y number
---@field public z number
---@field public magnitude number
---@field public normalized Vector3
---@field public sqrMagnitude number
---@field public Equals fun(self: Vector3, other: Vector3): boolean Returns true if the given vector is exactly equal to this vector.
---@field public Normalize fun(self: Vector3) Makes this vector have a magnitude of 1.
---@field public ToString fun(self: Vector3, fmt: string): string Returns a formatted string for this vector.
---@field public Angle fun(from: Vector3, to: Vector3): number Gets the unsigned angle in degrees between from and to.
---@field public ClampMagnitude fun(vec: Vector3, maxLength: number): Vector3 Returns a copy of vector with its magnitude clamped to maxLength.
---@field public Cross fun(fir: Vector3, sec: Vector3): Vector3 Cross Product of two vectors.
---@field public Distance fun(a: Vector3, b: Vector3): number Returns the distance between a and b.
---@field public Dot fun(lhs: Vector3, rhs: Vector3): number Dot Product of two vectors.
---@field public Max fun(lhs: Vector3, rhs: Vector3): Vector3 Returns a vector that is made from the largest components of two vectors.
---@field public Min fun(lhs: Vector3, rhs: Vector3): Vector3 Returns a vector that is made from the smallest components of two vectors.
---@field public Project fun(vector: Vector3, onNormal: Vector3): Vector3 Projects a vector onto another vector.
---@field public ProjectOnPlane fun(vector: Vector3, planeNormal: Vector3): Vector3 Projects a vector onto a plane defined by a normal orthogonal to the plane.
---@field public RotateX fun(vec: Vector3, theta: number): Vector3 intrinsic rotation about x axis, in degrees;
---@field public RotateY fun(vec: Vector3, theta: number): Vector3 intrinsic rotation about y axis, in degrees;
---@field public RotateZ fun(vec: Vector3, theta: number): Vector3 intrinsic rotation about z axis, in degrees;
---@field public Scale fun(a: Vector3, b: Vector3): Vector3 Multiplies two vectors component-wise.
---@field public SignedAngle fun(from: Vector3, to: Vector3, axis: Vector3): number Calculates the signed angle between vectors from and to in relation to axis.
---@field private __unm fun(self: Vector3): Vector3 negate the vector itself.
---@field private __sub fun(self: Vector3, other: Vector3): Vector3 Subtracts one vector from another.
---@field private __mul fun(self: Vector3, num: number): Vector3 Multiplies a vector by a number.
---@field private __div fun(self: Vector3, num: number): Vector3 Divides a vector by a number.
---@field private __add fun(self: Vector3, other: Vector3): Vector3 Adds two vectors.
---@field private __eq fun(self: Vector3, other: Vector3): boolean Returns true if two vectors are approximately equal.
---@field private __tostring fun(self: Vector3): string Convert to string for printing
---@operator unm(Vector3): Vector3
---@operator sub(Vector3): Vector3
---@operator mul(number): Vector3
---@operator div(number): Vector3
---@operator add(Vector3): Vector3
---@overload fun(): Vector3
---@overload fun(x: Vector2): Vector3
---@overload fun(x: number, y: number, z: number): Vector3
Vector3 = LuaClass:extend()

function Vector3:init(x, y, z)
    if x and y and z then
        self.x = x
        self.y = y
        self.z = z
    elseif x.class == Vector2 then
        self.x = x.x
        self.y = x.y
        self.z = 0
    end
end

-- fields --

Vector3:declare("x", 0)
Vector3:declare("y", 0)
Vector3:declare("z", 0)

-- Properties --

Vector3:declare("magnitude",
    {
        value = 0,
        get = function(self, value)
            return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2)
        end
    }
)
Vector3:declare("normalized",
    {
        value = 0,
        get = function(self, value)
            local mag = self.magnitude
            local normX, normY, normZ = self.x / mag, self.y / mag, self.z / mag
            local normVec = Vector3(normX, normY, normZ)

            return normVec
        end
    }
)
Vector3:declare("sqrMagnitude",
    {
        value = 0,
        get = function(self, value)
            return self.x ^ 2 + self.y ^ 2 + self.z ^ 2
        end
    }
)

-- Public Methods --

Vector3:declare("Equals",
    function(self, other)
        if other.x ~= self.x then return false end
        if other.y ~= self.y then return false end
        if other.z ~= self.z then return false end

        return true
    end
)
-- TODO: check if this thing works
Vector3:declare("Normalize",
    function(self)
        local mag = self.magnitude
        self.x, self.y, self.z = self.x / mag, self.y / mag, self.z / mag
    end
)
Vector3:declare("ToString",
    function(self, fmt)
        return string.format(fmt, self.x, self.y, self.z)
    end
)

-- Static Methods --

Vector3:declare("Angle",
    function(from, to)
        local magf, magt = from:magnitude(), to:magnitude()
        local dot = from.x * to.x + from.y * to.y + from.z * to.z

        return math.deg(math.acos(dot / (magf * magt)))
    end,
    "static"
)
--TODO: check if this thing works
Vector3:declare("ClampMagnitude",
    function(vec, maxLength)
        local mag = vec:magnitude()
        local scale = math.min(maxLength, mag) / mag
        local clampedX, clampedY, clampedZ = vec.x * scale, vec.y * scale, vec.z * scale

        return Vector3(clampedX, clampedY, clampedZ)
    end,
    "static"
)
Vector3:declare("Cross",
    function(fir, sec)
        local crossX = (fir.y * sec.z - fir.z * sec.y)
        local crossY = -(fir.x * sec.z - fir.z * sec.x)
        local crossZ = (fir.x * sec.y - fir.y * sec.x)

        return Vector3(crossX, crossY, crossZ)
    end,
    "static"
)
Vector3:declare("Distance",
    function(a, b)
        local diffX, diffY, diffZ = a.x - b.x, a.y - b.y, a.z - b.z

        return math.sqrt(diffX ^ 2 + diffY ^ 2 + diffZ ^ 2)
    end,
    "static"
)
Vector3:declare("Dot",
    function(lhs, rhs)
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
    end,
    "static"
)
Vector3:declare("Max",
    function(lhs, rhs)
        local maxX, maxY, maxZ = math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y), math.max(lhs.z, rhs.z)
        return Vector3(maxX, maxY, maxZ)
    end,
    "static"
)
Vector3:declare("Min",
    function(lhs, rhs)
        local minX, minY, minZ = math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y), math.min(lhs.z, rhs.z)
        return Vector3(minX, minY, minZ)
    end,
    "static"
)
Vector3:declare("Project",
    function(vector, onNormal)
        local dot = Vector3.Dot(vector, onNormal)
        local magSqr = onNormal:sqrMagnitude()
        local projFac = dot / magSqr

        return Vector3(onNormal.x * projFac, onNormal.y * projFac, onNormal.z * projFac)
    end,
    "static"
)
Vector3:declare("ProjectOnPlane",
    function(vector, planeNormal)
        local distToPlane = Vector3.Project(vector, planeNormal)

        return Vector3(vector.x - distToPlane.x, vector.y - distToPlane.y, vector.z - distToPlane.z)
    end,
    "static"
)
Vector3:declare("RotateX",
    function(vec, theta)
        local mcos = math.cos
        local msin = math.sin
        local mrad = math.rad

        local xRot = vec.x
        local yRot = mcos(mrad(theta)) * vec.y - msin(mrad(theta)) * vec.z
        local zRot = msin(mrad(theta)) * vec.y + mcos(mrad(theta)) * vec.z

        return Vector3(xRot, yRot, zRot)
    end,
    "static"
)
Vector3:declare("RotateY",
    function(vec, theta)
        local mcos = math.cos
        local msin = math.sin
        local mrad = math.rad

        local xRot = mcos(mrad(theta)) * vec.x + msin(mrad(theta)) * vec.z
        local yRot = vec.y
        local zRot = -msin(mrad(theta)) * vec.x + mcos(mrad(theta)) * vec.z

        return Vector3(xRot, yRot, zRot)
    end,
    "static"
)
Vector3:declare("RotateZ",
    function(vec, theta)
        local mcos = math.cos
        local msin = math.sin
        local mrad = math.rad

        local xRot = mcos(mrad(theta)) * vec.x - msin(mrad(theta)) * vec.y
        local yRot = msin(mrad(theta)) * vec.x + mcos(mrad(theta)) * vec.y
        local zRot = vec.z

        return Vector3(xRot, yRot, zRot)
    end,
    "static"
)
Vector3:declare("Scale",
    function(a, b)
        return Vector3(a.x * b.x, a.y * b.y, a.z * b.z)
    end,
    "static"
)
Vector3:declare("SignedAngle",
    function(from, to, axis)
        -- ((Va x Vb) . Vn) / (Va . Vb)
        -- frome https://stackoverflow.com/questions/5188561/signed-angle-between-two-3d-vectors-with-same-origin-within-the-same-plane
        local aCb = Vector3.Cross(from, to)
        local aCbDn = Vector3.Dot(aCb, axis)
        local aDb = Vector3.Dot(from, to)

        return math.deg(math.atan2(aCbDn, aDb))
    end,
    "static"
)


-- Operators --

Vector3:declare("__unm",
    function(self)
        return Vector3(
            -self.x,
            -self.y,
            -self.z
        )
    end,
    "operator"
)
Vector3:declare("__sub",
    function(self, other)
        return Vector3(
            self.x - other.x,
            self.y - other.y,
            self.z - other.z
        )
    end,
    "operator"
)
Vector3:declare("__mul",
    function(self, num)
        if type(self) ~= "table" then
            local temp = self
            self = num
            num = temp
        end

        return Vector3(
            self.x * num,
            self.y * num,
            self.z * num
        )
    end,
    "operator"
)
Vector3:declare("__div",
    function(self, num)
        return Vector3(
            self.x / num,
            self.y / num,
            self.z / num
        )
    end,
    "operator"
)
Vector3:declare("__add",
    function(self, other)
        return Vector3(
            self.x + other.x,
            self.y + other.y,
            self.z + other.z
        )
    end,
    "operator"
)
Vector3:declare("__eq",
    function(self, other)
        local dx = self.x + other.x
        local dy = self.y + other.y
        local dz = self.z + other.z

        if math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2) >= 1e-5 then
            return false
        end

        return true
    end,
    "operator"
)
Vector3:declare("__tostring",
    function(self)
        return string.format("Vector3(%f, %f, %f)", self.x, self.y, self.z)
    end,
    "operator"
)

--=================================================================================================

-- Vector4 = { x = 0, y = 0, z = 0, w = 0 }
-- Vector4.get = {} --getters
-- Vector4.set = {} --setters
-- Vector4.static = {}

-- function Vector4:new(o, y, z, w)
--     if o and y and z and w then
--         o = { x = o, y = y, z = z, w = w }
--     elseif getmetatable(o) == Vector2 then
--         o = { x = o.x, y = o.y }
--     elseif getmetatable(o) == Vector3 then
--         o = { x = o.x, y = o.y, z = o.z }
--     else
--         o = o or {}
--     end
--     setmetatable(o, self)

--     function self.__index(t, k)
--         if k == "new" then
--             print("please use other methods of class inheritance")
--             return error("Attempt to create an object of an object", 1)
--         end

--         if k == "get" or k == "set" then
--             return error("Attempt to access private methods", 1)
--         end

--         if Vector4.static[k] then
--             return error("Static function access via object", 1)
--         end

--         --call property getters
--         if Vector4.get[k] then
--             return Vector4.get[k](t)
--         end

--         return self[k]
--     end

--     function self.__newindex(t, k, v)
--         if k == "new" or k == "get" or k == "set" then
--             return error("Attempt to modify private methods", 1)
--         end

--         if Vector4.static[k] then
--             return error("Static function modification", 1)
--         end

--         --call property setters
--         if Vector4.set[k] then
--             Vector4.set[k](t, v)
--         end

--         rawset(t, k, v)
--     end

--     return o
-- end

-- -- Properties --

-- --- Returns the length of this vector
-- function Vector4.get:magnitude()
--     return math.sqrt(self.x ^ 2 + self.y ^ 2 + self.z ^ 2 + self.w ^ 2)
-- end

-- --- Returns this vector with a magnitude of 1
-- function Vector4.get:normalized()
--     local mag = self.magnitude
--     local normX, normY, normZ, normW = self.x / mag, self.y / mag, self.z / mag, self.w / mag
--     local normVec = Vector4:new { x = normX, y = normY, z = normZ, w = normW }

--     return normVec
-- end

-- --- Returns the squared length of this vector
-- function Vector4.get:sqrMagnitude()
--     return self.x ^ 2 + self.y ^ 2 + self.z ^ 2 + self.w ^ 2
-- end

-- -- Public Methods --

-- --- Returns true if the given vector is exactly equal to this vector.
-- function Vector4:Equals(other)
--     if other.x ~= self.x then return false end
--     if other.y ~= self.y then return false end
--     if other.z ~= self.z then return false end
--     if other.w ~= self.w then return false end

--     return true
-- end

-- --- Makes this vector have a magnitude of 1.
-- -- TODO: check if this thing worls
-- function Vector4:Normalize()
--     local mag = self.magnitude
--     self.x, self.y, self.z, self.w = self.x / mag, self.y / mag, self.z / mag, self.w / mag
-- end

-- --- Returns a formatted string for this vector.
-- function Vector4:ToString(fmt)
--     return string.format(fmt, self.x, self.y, self.z, self.w)
-- end

-- -- Static Methods --

-- Vector4.static.Distance = true
-- Vector4.static.Dot      = true
-- Vector4.static.Max      = true
-- Vector4.static.Min      = true
-- Vector4.static.Project  = true
-- Vector4.static.Scale    = true

-- --- Returns the distance between a and b.
-- function Vector4.Distance(a, b)
--     local diffX, diffY, diffZ, diffW = a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w

--     return math.sqrt(diffX ^ 2 + diffY ^ 2 + diffZ ^ 2 + diffW ^ 2)
-- end

-- --- Dot Product of two vectors.
-- function Vector4.Dot(lhs, rhs)
--     return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z + lhs.w * rhs.w
-- end

-- --- Returns a vector that is made from the largest components of two vectors.
-- function Vector4.Max(lhs, rhs)
--     local maxX, maxY, maxZ, maxW = math.max(lhs.x, rhs.x), math.max(lhs.y, rhs.y), math.max(lhs.z, rhs.z),
--         math.max(lhs.w, rhs.w)
--     return Vector4:new { x = maxX, y = maxY, z = maxZ, w = maxW }
-- end

-- --- Returns a vector that is made from the smallest components of two vectors.
-- function Vector4.Min(lhs, rhs)
--     local minX, minY, minZ, minW = math.min(lhs.x, rhs.x), math.min(lhs.y, rhs.y), math.min(lhs.z, rhs.z),
--         math.min(lhs.w, rhs.w)
--     return Vector4:new { x = minX, y = minY, z = minZ, w = minW }
-- end

-- --- Projects a vector onto another vector.
-- function Vector4.Project(vector, onNormal)
--     local dot = Vector4.Dot(vector, onNormal)
--     local magSqr = onNormal:sqrMagnitude()
--     local projFac = dot / magSqr

--     return Vector4:new { x = onNormal.x * projFac, y = onNormal.y * projFac, z = onNormal.z * projFac, w = onNormal.w *
--         projFac }
-- end

-- --- Multiplies two vectors component-wise.
-- function Vector4.Scale(a, b)
--     return Vector4:new { x = a.x * b.x, y = a.y * b.y, z = a.z * b.z, w = a.w * b.w }
-- end

-- -- Operators --

-- --- negate the vector itself.
-- function Vector4:__unm()
--     return Vector4:new {
--         x = -self.x,
--         y = -self.y,
--         z = -self.z,
--         w = -self.w,
--     }
-- end

-- --- Subtracts one vector from another.
-- function Vector4:__sub(other)
--     return Vector4:new {
--         x = self.x - other.x,
--         y = self.y - other.y,
--         z = self.z - other.z,
--         w = self.w - other.w,
--     }
-- end

-- --- Multiplies a vector by a number.
-- function Vector4:__mul(num)
--     if type(self) ~= "table" then
--         local temp = self
--         self = num
--         num = temp
--     end

--     return Vector4:new {
--         x = self.x * num,
--         y = self.y * num,
--         z = self.z * num,
--         w = self.w * num,
--     }
-- end

-- --- Divides a vector by a number.
-- function Vector4:__div(num)
--     return Vector4:new {
--         x = self.x / num,
--         y = self.y / num,
--         z = self.z / num,
--         w = self.w / num,
--     }
-- end

-- --- Adds two vectors.
-- function Vector4:__add(other)
--     return Vector4:new {
--         x = self.x + other.x,
--         y = self.y + other.y,
--         z = self.z + other.z,
--         w = self.w + other.w,
--     }
-- end

-- --- Returns true if two vectors are approximately equal.
-- function Vector4:__eq(other)
--     local dx = self.x + other.x
--     local dy = self.y + other.y
--     local dz = self.z + other.z
--     local dw = self.w + other.w

--     if math.sqrt(dx ^ 2 + dy ^ 2 + dz ^ 2 + dw ^ 2) >= 1e-5 then
--         return false
--     end

--     return true
-- end

-- --- Convert to string for printing
-- function Vector4:__tostring()
--     return string.format("Vector4(%f, %f, %f, %f)", self.x, self.y, self.z, self.w)
-- end