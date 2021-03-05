local index = 0
local cgmac_percent = 0
local calculation_weight = 0
local k = 0
local cg_default = 25
local fwd_cargo_max = 5670
local aft_cargo_max = 7054

local tank_index_center = {
    {500,   -1},
    {1000 , -1},
    {1500 , -2},
    {2000 , -3},
    {2500 , -4},
    {3000 , -4},
    {3500 , -5},
    {4000 , -6},
    {4500 , -7},
    {5000 , -7},
    {5500 , -8},
    {6000 , -9},
    {FUEL_C_MAX , -10},
}

local tank_index_wing = {
    {500,   -1},
    {1000 , -1},
    {1500 , -2},
    {2000 , -2},
    {2500 , -2},
    {3000 , -3},
    {3500 , -3},
    {4000 , -3},
    {4500 , -3},
    {5000 , -3},
    {5500 , -2},
    {6000 , -2},
    {FUEL_LR_MAX, -1},
}

local tank_index_act = {
    {0,     0},
    {2450 , -16},
    {FUEL_RCT_MAX , -17},
}

local tank_index_rct = {
    {0,     0},
    {2450 , 22},
    {FUEL_RCT_MAX , 22},
}

--Index formula: I = ( (CG% - 25) * Weight * 0.000042 ) + K
--See FCOM page 6814 Onwards

function update()
    calculation_weight = get(Gross_weight)
end

function draw()
    sasl.gl.drawTexture (LOADSHEET_bgd, 0 , 0 , 1700 , 900 , EFB_WHITE )
end