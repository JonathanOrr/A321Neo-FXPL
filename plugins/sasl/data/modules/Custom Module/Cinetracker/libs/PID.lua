--Class declarations-- ================================================= as separators
PID = {
    kp = 0,
    ki = 0,
    kd = 0,

    P = 0,
    I = 0,
    D = 0,

    maxout = 1,
    minout = -1,

    PV = 0,
    error = 0,
    output = 0,
}

function PID:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function PID:integration()
    self.I = Math_clamp(self.I + self.ki * self.error * get(DELTA_TIME), self.minout, self.maxout)
end

function PID:getOutput()
    self.output = Math_clamp(self.P + self.I + self.D, self.minout, self.maxout)

    return self.output
end

function PID:computePID(SP, PV)
    if get(DELTA_TIME) == 0 then return 0 end

    local last_PV = self.PV
    self.PV = PV
    self.error = SP - self.PV

    --P--
    self.P = self.kp * self.error
    --I--
    self:integration()
    --D-- (dPVdt to avoid derivative bump)
    self.D = self.kd * (last_PV - self.PV) / get(DELTA_TIME)

    return self:getOutput()
end
--====================================================================================
BPPID = PID:new{
    kbp = 1,
    BP = 0,
    plantOutput = 0,
}

function BPPID:backPropagation(PO)
    self.plantOutput = PO
    self.BP = self.kbp * (self.plantOutput - self.output)
end

function BPPID:integration()
    self.I = Math_clamp(self.I + self.ki * self.error * get(DELTA_TIME) + self.BP, self.minout, self.maxout)
end

function BPPID:getOutput()
    local PIDsum = self.P + self.I + self.D

    if self.kbp < 1 then
        self.output = Math_clamp(PIDsum, self.minout, self.maxout)
    else
        self.output = Math_clamp(PIDsum, self.minout, self.maxout)
        self.I = self.I + self.kbp * (self.output - PIDsum)
    end

    return self.output
end
--====================================================================================
BPFFPID = BPPID:new{
    FF = 0,
}

function BPFFPID:backPropagation(PO)
    self.plantOutput = PO - self.FF
    self.BP = self.kbp * (self.plantOutput - self.output)

    --reset FF sum to begin the new FF cycle
    --remember there can be multiple FF inputs
    self.FF = 0
end

function BPFFPID:feedForward(kff, FFPV)
    self.FF = self.FF + kff * FFPV
end

function BPFFPID:getOutput()
    local PIDsum = self.P + self.I + self.D

    if self.kbp < 1 then
        self.output = Math_clamp(PIDsum, self.minout, self.maxout)
    else
        self.output = Math_clamp(PIDsum, self.minout, self.maxout)
        self.I = self.I + self.kbp * (self.output - PIDsum)
    end

    return self.output + self.FF
end
--====================================================================================