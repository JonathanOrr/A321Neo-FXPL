local msin = function (x) return math.sin(math.rad(x)) end
local mcos = function (x) return math.cos(math.rad(x)) end
local mtan = function (x) return math.tan(math.rad(x)) end

--Class declarations-- ================================================= as separators
local angularRateCmp = {}

function angularRateCmp:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function angularRateCmp:getRate() end
function angularRateCmp:rad() return self:getRate() end
function angularRateCmp:deg() return (self:getRate() / math.pi) * 180 end
--====================================================================================

ThetaDot = angularRateCmp:new{
    getRate = function (self)
        local roll = get(Flightmodel_roll)

        return get(Flightmodel_q) * mcos(roll) + get(Flightmodel_r) * msin(roll)
    end
}
PhiDot = angularRateCmp:new{
    getRate = function (self)
        local roll = get(Flightmodel_roll)
        local pitch = get(Flightmodel_pitch)

        return get(Flightmodel_p) + (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) * mtan(pitch)
    end
}
PsiDot = angularRateCmp:new{
    getRate = function (self)
        local roll = get(Flightmodel_roll)
        local pitch = get(Flightmodel_pitch)

        return (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) / mcos(pitch)
    end
}