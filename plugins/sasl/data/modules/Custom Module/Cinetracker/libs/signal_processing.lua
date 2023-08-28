-------------------------------------------------------------------------------
-- A32NX Freeware Project
-- Copyright (C) 2020
-------------------------------------------------------------------------------
-- LICENSE: GNU General Public License v3.0
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Please check the LICENSE file in the root of the repository for further
--    details or check <https://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

function SmoothRescale(k, in1, out1, in2, out2, x)
    if out2 - out1 == 0 then return out1 end

    k = math.max(out1, out2) == out2 and k or -k

    x = Math_clamp(x, in1, in2)
    x = (x - in1) / (in2 - in1)

    local y = (math.tanh(k * (2*x - 1) / (2 * math.sqrt((1 - x) * x))) + 1) / 2
    y = y * math.abs(out2 - out1) + math.min(out1, out2)

    return y
end

---get the dominant / fastest moving frequency
---@param t table
---@param y table
---@return number f
function GetDominantFreq(t, y)
    -- check if the input data has the same size
    assert(#t == #y, "Input data dimensions do not match")

    local N = #t           -- number of data points
    local dt = t[2] - t[1] -- time step

    -- compute the FFT of the signal
    local y_fft_real = {}
    local y_fft_imag = {}
    for k = 1, N do
        y_fft_real[k] = 0
        y_fft_imag[k] = 0
        for n = 1, N do
            y_fft_real[k] = y_fft_real[k] + y[n] * math.cos(-2 * math.pi * (k - 1) * (n - 1) / N)
            y_fft_imag[k] = y_fft_imag[k] + y[n] * math.sin(-2 * math.pi * (k - 1) * (n - 1) / N)
        end
    end

    -- compute the absolute values of the FFT
    local y_fft_abs = {}
    for k = 1, N / 2 do
        y_fft_abs[k] = math.sqrt(y_fft_real[k] ^ 2 + y_fft_imag[k] ^ 2)
    end

    -- find the index of the maximum FFT value
    local max_idx = 1
    local max_val = y_fft_abs[1]
    for i = 2, N / 2 do
        if y_fft_abs[i] > max_val then
            max_idx = i
            max_val = y_fft_abs[i]
        end
    end

    -- compute the frequency corresponding to the maximum FFT value
    local f = (max_idx - 1) / (N * dt)

    return f
end

---get all the frequencys that makes up the signal, and their coresponding transform amplitude
---@param t table
---@param y table
---@return table freq, table y_fft_abs, table y_fft_real, table y_fft_imag
function FFT_frequencies(t, y)
    -- check if the input data has the same size
    assert(#t == #y, "Input data dimensions do not match")

    local N = #t                   -- number of data points
    local dt = (t[N] - t[1]) / (N - 1) -- average time step

    -- compute the FFT of the signal
    local y_fft_real = {}
    local y_fft_imag = {}
    for k = 1, N do
        y_fft_real[k] = 0
        y_fft_imag[k] = 0
        for n = 1, N do
            y_fft_real[k] = y_fft_real[k] + y[n] * math.cos(-2 * math.pi * (k - 1) * (n - 1) / N)
            y_fft_imag[k] = y_fft_imag[k] + y[n] * math.sin(-2 * math.pi * (k - 1) * (n - 1) / N)
        end
    end

    -- compute the absolute values of the FFT
    local y_fft_abs = {}
    for k = 1, N / 2 do
        y_fft_abs[k] = math.sqrt(y_fft_real[k] ^ 2 + y_fft_imag[k] ^ 2)
    end

    -- compute the frequencies corresponding to each FFT component
    local freqs = {}
    for k = 1, N / 2 do
        freqs[k] = (k - 1) / (N * dt)
    end

    return freqs, y_fft_abs, y_fft_real, y_fft_imag
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- RATE COMPUTATION
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
RateCmp = {lastTime = 0, lastVal = 0, rate = 0}

function RateCmp:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function RateCmp:getRate(currVal)
    self.rate = (currVal - self.lastVal) / (get(TIME) - self.lastTime)
    self.lastTime = get(TIME)
    self.lastVal = currVal
    return self.rate
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- FILTERS
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--
-- ** Instructions **
-- Create a table with two parameters: the current x value and the cut frequency in Hz:
--
-- data = {
--    x = 0,
--    cut_frequency = 10
-- }
--
-- Then, set data.x to the proper value and call the filter (e.g. y = high_pass_filter(data)) to get
-- the filtered value (y). The next time, set again data.x and recall the filter funciton.
--
-- VERY IMPORTANT (1): the variable you pass to the filter function must be preserved across filter
--                     invocations. (The filter writes stuffs inside data!)
-- VERY IMPORTANT (2): the filter function expects data FOR EACH frame after the first invocation,
--                     otherwise garbage will be computed.

LowPass = {freq = 10}

function LowPass:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function LowPass:filterOut(x)
    local dt = get(DELTA_TIME)
    local RC = 1 / (2*math.pi * self.freq)
    local a = dt / (RC + dt)

    if self.prev_y == nil then
        self.prev_y = a * x
    else
        self.prev_y = a * x + (1-a) * self.prev_y
    end

    return self.prev_y
end

HighPass = LowPass:new()

function HighPass:filterOut(x)
    local dt = get(DELTA_TIME)
    local RC = 1/(2*math.pi * self.freq)
    local a = RC / (RC + dt)

    if self.prev_x == nil then
        self.prev_x = x
        self.prev_y = x
        return x
    else
        self.prev_y = a * (self.prev_y + x - self.prev_x)
        self.prev_x = x
    end

    return self.prev_y
end