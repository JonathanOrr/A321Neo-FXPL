get(Cockpit_throttle_lever_L)
get(Cockpit_throttle_lever_R)

local function GND_SPLR_ARM()
    set(Ground_spoilers_armed, BoolToNum(get(SPDBRK_HANDLE_RATIO) <= -0.25))
end

local function PLD()
    local one_or_more_thrust_lev_on_reverse = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local all_thrust_lev_lower_or_at_idle = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local one_MLG_pressed = get(Either_Aft_on_ground) == 1
    local RA_less_than_6 = RA_sys.all_RA_user() < 6

    if (one_or_more_thrust_lev_on_reverse and all_thrust_lev_lower_or_at_idle) and
       ((one_MLG_pressed and RA_less_than_6) or get(Ground_spoilers_mode) == 1) then
        set(Ground_spoilers_mode, 1)
    else
        set(Ground_spoilers_mode, 0)
    end
end

local function GIS()
    local GND_SPLR_armed = get(Ground_spoilers_armed) == 1
    local one_or_more_thrust_lev_on_reverse = (get(Cockpit_throttle_lever_L) < THR_IDLE_START or get(Cockpit_throttle_lever_R) < THR_IDLE_START)
    local all_thrust_lev_lower_or_at_idle = (get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)
    local both_MLG_pressed = get(Aft_wheel_on_ground) == 1
    local RA_less_than_6 = RA_sys.all_RA_user() < 6
    local LR_wheel_spd_72_and_more = get(Wheel_spd_kts_L) >= 72 or get(Wheel_spd_kts_R) >= 72

    if ((GND_SPLR_armed or one_or_more_thrust_lev_on_reverse) and
       all_thrust_lev_lower_or_at_idle)
       and
       (((both_MLG_pressed and RA_less_than_6) or LR_wheel_spd_72_and_more) or
       get(Ground_spoilers_mode) == 2) then
        set(Ground_spoilers_mode, 2)
    else
        set(Ground_spoilers_mode, 0)
    end
end

function update()
    GND_SPLR_ARM()
    PLD()
    GIS()
end