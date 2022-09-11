local one_MLG_prev = 0
local both_MLG_prev = 0

local one_MLG_delta = 0
local both_MLG_delta = 0

local wheelspd_inhibited = false

local function compute_MLG_deltas()
    one_MLG_delta  = get(Either_Aft_on_ground) - one_MLG_prev
    both_MLG_delta = get(Aft_wheel_on_ground) - both_MLG_prev

    one_MLG_prev  = get(Either_Aft_on_ground)
    both_MLG_prev = get(Aft_wheel_on_ground)
end

local function GND_SPLR_ARM()
    set(Ground_spoilers_armed, BoolToNum(get(SPDBRK_HANDLE_RATIO) <= -0.25))
end

local function PLD()
    local A_1   = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local A_2   = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local B_1_1 = one_MLG_delta == 1
    local B_1_2 = RA_sys.all_RA_user() < 6
    local B_2   = get(Ground_spoilers_mode) == 1

    if A_1 and A_2 and
       ((B_1_1 and B_1_2) or B_2) then
        return true
    else
        return false
    end
end

local function GIS()
    if get(Aft_wheel_on_ground) == 0 then wheelspd_inhibited = true end
    if wheelspd_inhibited and get(Wheel_spd_kts_L) < 23 and get(Wheel_spd_kts_R) < 23 then wheelspd_inhibited = false end

    local A_1_1   = get(Ground_spoilers_armed) == 1
    local A_1_2   = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local A_2     = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local B_1_1_1 = both_MLG_delta == 1
    local B_1_1_2 = RA_sys.all_RA_user() < 6
    local B_1_2   = get(Wheel_spd_kts_L) >= 72 or get(Wheel_spd_kts_R) >= 72
    local B_2     = get(Ground_spoilers_mode) == 2 and not wheelspd_inhibited

    if (A_1_1 or A_1_2) and A_2
       and
       ((B_1_1_1 and B_1_1_2) or B_1_2 or B_2) then
        return true
    else
        return false
    end
end

local function GND_SPLR_CTL()
    if PLD() then
        set(Ground_spoilers_mode, 1)
    elseif GIS() then
        set(Ground_spoilers_mode, 2)
    else
        set(Ground_spoilers_mode, 0)
    end
end

function update()
    compute_MLG_deltas()
    GND_SPLR_ARM()
    GND_SPLR_CTL()
end