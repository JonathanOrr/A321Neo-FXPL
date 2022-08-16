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

local msin = function (x) return math.sin(math.rad(x)) end
local mcos = function (x) return math.cos(math.rad(x)) end
local mtan = function (x) return math.tan(math.rad(x)) end


FBW.angular_rates ={
    Theta = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)

           return get(Flightmodel_q) * mcos(roll) + get(Flightmodel_r) * msin(roll)
        end
    },
    Phi = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)
            local pitch = get(Flightmodel_pitch)

           return get(Flightmodel_p) + (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) * mtan(pitch)
        end
    },
    Psi = {
        deg = 0,
        rad = 0,
        compute = function ()
            local roll = get(Flightmodel_roll)
            local pitch = get(Flightmodel_pitch)

           return (get(Flightmodel_q) * msin(roll) + get(Flightmodel_r) * mcos(roll)) / mcos(pitch)
        end
    },
}

local function update_angular_rates(table)
    for key, value in pairs(table) do
        -- Ignore non-dataref based rates
        value.rad = value.compute()
        value.deg = (value.rad / math.pi) * 180
    end
end

--[[local function yaw_rate_computation()
    local curr_x  = get(Flightmodel_local_x)
    local curr_z  = get(Flightmodel_local_z)

    local l = math.sqrt(curr_x * curr_x + curr_z * curr_z)

    -- Step 1: compute delta
    local delta_x, delta_z, delta_l
    if FBW.rates.XP_YAW.prev_x then
        delta_x = curr_x - FBW.rates.XP_YAW.prev_x
        delta_z = curr_z - FBW.rates.XP_YAW.prev_z
    else
        delta_x = 0
        delta_z = 0
        FBW.rates.XP_YAW.prev_x = curr_x
        FBW.rates.XP_YAW.prev_z = curr_z
    end

    -- Step 2: compute theta
    local pi = math.pi
    local theta = math.atan2(delta_z, delta_x) + pi

    if FBW.rates.XP_YAW.prev_theta == nil then
        FBW.rates.XP_YAW.prev_theta = theta
    end

    local prev_theta = FBW.rates.XP_YAW.prev_theta

    -- Step 3:
    if get(DELTA_TIME) > 0 then
        if prev_theta > pi and theta < pi and (prev_theta - theta) > pi then
            FBW.rates.XP_YAW.x = (2*pi + theta - prev_theta) / get(DELTA_TIME)
        elseif prev_theta < pi and theta > pi and (theta - prev_theta) > pi then
            FBW.rates.XP_YAW.x = (theta - prev_theta - 2*pi) / get(DELTA_TIME)
        else
            FBW.rates.XP_YAW.x = (theta - prev_theta) / get(DELTA_TIME)
        end
        FBW.rates.XP_YAW.x = math.deg(FBW.rates.XP_YAW.x)

        FBW.rates.XP_YAW.prev_x = curr_x
        FBW.rates.XP_YAW.prev_z = curr_z
        FBW.rates.XP_YAW.prev_theta = theta
    end


end]]--

function update()
    update_angular_rates(FBW.angular_rates)
end