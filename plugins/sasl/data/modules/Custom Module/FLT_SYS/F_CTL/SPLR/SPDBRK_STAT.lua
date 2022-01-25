--PROPERTIES--
local SPLR_PER_WING = 5

local SPDBRK_MAX_GRD_DEF = {6, 25, 25, 25, 0}

local SPDBRK_GRD_SPD = {20, 20, 20, 20, 20}
local SPDBRK_AIR_SPD = {5, 5, 5, 5, 5}
local SPDBRK_HIGHSPD_AIR_SPD = {1, 1, 1, 1, 1}

FCTL.SPLR.COMMON = {
    SPLR_SPDBRK_MAX_DEF = {0, 25, 25, 25, 0},
    SPLR_SPDBRK_MAX_SPD = {5, 5, 5, 5, 5},

    Get_cmded_spdbrk_def = function (spdbrk_input)
        spdbrk_input = Math_clamp(spdbrk_input, 0, 1)

        local total_cmded_def = 0
        for i = 1, SPLR_PER_WING do
            total_cmded_def = total_cmded_def + FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_DEF[i] * spdbrk_input * 2
        end

        return total_cmded_def
    end,
}

local function COMPUTE_SPDBRK_MAX_SPD()
    if get(Aft_wheel_on_ground) == 1 then
        --speed up ground spoilers deflection
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD = SPDBRK_GRD_SPD
    else
        --slow down the spoilers for flight
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_SPD = SPDBRK_AIR_SPD
    end
end

local function COMPUTE_SPLR_1_GRD_DEF()
    if adirs_get_avg_gs() < 6 and
       adirs_get_avg_ias() >= -0.5 and adirs_get_avg_ias() <= 0.5 and
       get(ELAC_2_status) == 1 and
       get(Left_gear_on_ground) == 1 and get(Right_gear_on_ground) == 1 and
       ((get(Wheel_status_LGCIU_1) == 1 and get(Wheel_status_LGCIU_2) == 1) or
       (get(Capt_ra_alt_ft) < 10 and get(Fo_ra_alt_ft) < 10)) then
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_DEF[1] = 6
    else
        FCTL.SPLR.COMMON.SPLR_SPDBRK_MAX_DEF[1] = 0
    end
end

function update()
    COMPUTE_SPLR_1_GRD_DEF()
    COMPUTE_SPDBRK_MAX_SPD()
end