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
-- File: weights.lua 
-- Short description: Weight and CG computation
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------
local DEFAULT_CG_PERC = 22.2
local DEFAULT_CG_M    = 21.511
local EMPTY_WEIGHT    = 47776
local MAC_VALUE_M     = 4.1935

local CG_FWD_CARGO_M  =  8.869
local CG_AFT_CARGO_M  = 30.530
local CG_BULK_CARGO_M = 33.992
local CG_PASS_START   =  5.560
local CG_PASS_END     = 35.960

-------------------------------------------------------------------------------
-- Datarefs
-------------------------------------------------------------------------------
local dr_payload_weight = globalProperty ("sim/flightmodel/weight/m_fixed")
local dr_CG_pos         = globalProperty ("sim/flightmodel/misc/cgz_ref_to_default")

-------------------------------------------------------------------------------
-- Variables
-------------------------------------------------------------------------------

local curr_weights = {
    fwd_cargo       = 0,
    aft_cargo       = 0,
    bulk_cargo      = 0,
    passengers      = 0,
    passengers_perc = 0.5,
};

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

local function compute_cg(zero_fuel_weight)
    local default_cg = DEFAULT_CG_M * EMPTY_WEIGHT / zero_fuel_weight
    local cargo_fwd_cg  = CG_FWD_CARGO_M  * curr_weights.fwd_cargo  / zero_fuel_weight
    local cargo_aft_cg  = CG_AFT_CARGO_M  * curr_weights.aft_cargo  / zero_fuel_weight
    local cargo_bulk_cg = CG_BULK_CARGO_M * curr_weights.bulk_cargo / zero_fuel_weight

    local passengers_cg = Math_lerp(CG_PASS_START, CG_PASS_END, curr_weights.passengers_perc) * curr_weights.passengers / zero_fuel_weight

    return default_cg + cargo_fwd_cg + cargo_aft_cg + cargo_bulk_cg + passengers_cg
end

local function update_xplane_cg()

    -- First of all set the total payload
    local total_payload = curr_weights.fwd_cargo + curr_weights.aft_cargo + curr_weights.bulk_cargo + curr_weights.passengers
    set(dr_payload_weight, total_payload)

    local zero_fuel_weight = EMPTY_WEIGHT + total_payload

    -- Second, compute the CG and set it (as default with default CG)
    local cg = compute_cg(zero_fuel_weight)
    set(dr_CG_pos, cg - DEFAULT_CG_M)
end

WEIGHTS.set_fwd_cargo_weight = function(kgs)
    assert(kgs)
    assert(kgs >= 0)
    if kgs > 2400 then logWarning("FWD cargo overloaded") end

    curr_weights.fwd_cargo = kgs
    update_xplane_cg()
end

WEIGHTS.set_aft_cargo_weight = function(kgs)
    assert(kgs)
    assert(kgs >= 0)
    if kgs > 2400 then logWarning("AFT cargo overloaded") end

    curr_weights.aft_cargo = kgs
    update_xplane_cg()
end

WEIGHTS.set_bulk_cargo_weight = function(kgs)
    assert(kgs)
    assert(kgs >= 0)
    if kgs > 1497 then logWarning("Bulk cargo overloaded") end

    curr_weights.bulk_cargo = kgs
    update_xplane_cg()
end

WEIGHTS.set_passengers_weight = function(kgs, pos)
    -- pos: 0 full-fwd (all the passengers one over the other in the first row),
    --      1 full-aft  (all the passengers one over the other in the last row)
    assert(kgs and pos)
    assert(kgs >= 0)
    if kgs > 16000 then logWarning("Cabin overloaded") end

    assert(pos >= 0 and pos <= 1)

    curr_weights.passengers      = kgs
    curr_weights.passengers_perc = pos
    update_xplane_cg()
end


local function initialize()
    local payload = get(dr_payload_weight)
    local passengers = payload / 2
    local cargo_each = payload / 12
    
    WEIGHTS.set_passengers_weight(passengers, 0.5)
    WEIGHTS.set_bulk_cargo_weight(cargo_each)
    WEIGHTS.set_fwd_cargo_weight(cargo_each*3)
    WEIGHTS.set_aft_cargo_weight(cargo_each)
end

initialize()