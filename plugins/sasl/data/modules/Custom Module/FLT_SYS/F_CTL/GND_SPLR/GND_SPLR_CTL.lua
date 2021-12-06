local Both_MLG_on_ground_prev = 1
local Thrust_levers_idled_prev = 0

local function GND_SPLR_CTL()
    --[[full extention with rejected takefoff: above 72kts, retard both throttles, if not armed one engine in reverse
    Full extesion landing: if armed all extends to full when both main gears touch down, if not armed when both main gear has touched down and one reverese selected then full extension,
    if speedbrakes are not retracted in config 3 or Full and all engine at idle, when both main gears touch down --> full extension

    partial extention: the ground spoilers extends to 10 degrees when reverse is selected in one or more engine, and one main landing gear struct is compressed

    retraction: if armed, disarm the lever, if not armed return the throttles to idle, if during a touch and go advance throttle lever beyond 20 degrees

    **thrust lever travel is 40 degrees**
    **if the aircraft bounces the spoilers remains deployed**
    **the roll spoiler functions are inhibited when ground spoilers are active**
    ]]

    --Ground_spoilers_act_method 0 = no action, 1 = unarmed activation, 2 armed activation

    --properties--
    local thrust_lever_1_fwd_def = Math_clamp_lower(get(Cockpit_throttle_lever_L) * 40, 0)
    local thrust_lever_2_fwd_def = Math_clamp_lower(get(Cockpit_throttle_lever_R) * 40, 0)

    --DELTAs--
    local Both_MLG_on_ground_delta = get(Aft_wheel_on_ground) - Both_MLG_on_ground_prev
    local Thrust_levers_idled_delta = BoolToNum(get(Cockpit_throttle_lever_L) >= THR_IDLE_START and get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) >= THR_IDLE_START and get(Cockpit_throttle_lever_R) <= THR_IDLE_END) - Thrust_levers_idled_prev

    Both_MLG_on_ground_prev = get(Aft_wheel_on_ground)
    Thrust_levers_idled_prev = BoolToNum(get(Cockpit_throttle_lever_L) >= THR_IDLE_START and get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) >= THR_IDLE_START and get(Cockpit_throttle_lever_R) <= THR_IDLE_END)

    --check if ground spoilers are armed
    set(Ground_spoilers_armed, BoolToNum(get(Speedbrake_handle_ratio) <= -0.25))

    --partial extension--
    if get(Either_Aft_on_ground) == 1 and get(Aft_wheel_on_ground) == 0 and (get(Cockpit_throttle_lever_L) <= -0.1 or get(Cockpit_throttle_lever_R) == -0.1) then
        set(Ground_spoilers_mode, 1)
    end

    --armed activations--
    if get(Ground_spoilers_armed) == 1 then
        if get(All_on_ground) == 1 and get(IAS) >= 72 then
            --idling thrust levers (rejected takeoff)
            if Thrust_levers_idled_delta == 1 then
                set(Ground_spoilers_mode, 2)
                set(Ground_spoilers_act_method, 2)
            end
        end

        if Both_MLG_on_ground_delta == 1 then
            set(Ground_spoilers_mode, 2)
            set(Ground_spoilers_act_method, 2)
        end
    end

    --unarmed activations--
    if get(Ground_spoilers_armed) == 0 then
        if get(All_on_ground) == 1 and get(IAS) >= 72 then
            --or or more reverse selected(rejected takoff)
            if get(Cockpit_throttle_lever_L) <= -0.1 or get(Cockpit_throttle_lever_R) == -0.1 then
                set(Ground_spoilers_mode, 2)
                set(Ground_spoilers_act_method, 1)
            end
        end

        if Both_MLG_on_ground_delta == 1 and (get(Cockpit_throttle_lever_L) <= -0.1 or get(Cockpit_throttle_lever_R) == -0.1) then
            set(Ground_spoilers_mode, 2)
            set(Ground_spoilers_act_method, 1)
        end

        --speedbrake handle in extended position and flaps is larger and equal to config 3
        if Both_MLG_on_ground_delta == 1 and get(Speedbrake_handle_ratio) > 0.1 and get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) <= THR_IDLE_END and get(Flaps_internal_config) >= 4 then
            set(Ground_spoilers_mode, 2)
            set(Ground_spoilers_act_method, 2)--a special case
        end
    end

    --RETRACTION--
    if get(Ground_spoilers_mode) == 1 then
        if get(Either_Aft_on_ground) == 0 or (get(Cockpit_throttle_lever_L) > -0.1 and get(Cockpit_throttle_lever_R) > -0.1) then
            set(Ground_spoilers_mode, 0)
        end
    end

    if get(Ground_spoilers_act_method) == 2 then
        if get(Speedbrake_handle_ratio) > -0.25 and get(Speedbrake_handle_ratio) <= 0.1 then
            set(Ground_spoilers_mode, 0)
            set(Ground_spoilers_act_method, 0)
        end
    elseif get(Ground_spoilers_act_method) == 1 then
        if get(Cockpit_throttle_lever_L) >= THR_IDLE_START and get(Cockpit_throttle_lever_L) <= THR_IDLE_END and get(Cockpit_throttle_lever_R) >= THR_IDLE_START and get(Cockpit_throttle_lever_R) <= THR_IDLE_END then
            set(Ground_spoilers_mode, 0)
            set(Ground_spoilers_act_method, 0)
        end
    end

    --go around reset--
    if thrust_lever_1_fwd_def >= 20 and thrust_lever_2_fwd_def >= 20 then
        set(Ground_spoilers_mode, 0)
        set(Ground_spoilers_act_method, 0)
    end
end

function update()
    GND_SPLR_CTL()
end