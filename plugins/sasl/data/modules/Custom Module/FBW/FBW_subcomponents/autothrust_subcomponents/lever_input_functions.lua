--THROTTLE CONTROL PROPERTIES--
local wait_for_detent = 0.8
local wait_for_reverse_toggle = 0
local FLEX_MCT_interval = {0.85, 0.8}
local CL_interval = {0.7, 0.65}

local thrust_in_reverse = false -- Switch
local manual_reverse_L = false  -- Manual hw throttle reverse
local manual_reverse_R = false  -- Manual hw throttle reverse

local prev_joy_L = 0    -- Throttle joystick previous value
local prev_joy_R = 0    -- Throttle joystick previous value
local max_alt_rev = 0

local L_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[0]")  -- DO NOT USE if you need to know the throttle position see Cockpit_throttle_lever_L
local R_sim_throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio[1]")  -- DO NOT USE if you need to know the throttle position see Cockpit_throttle_lever_R

--overriding callback functions
function Lever_fwd(phase)
    if phase == SASL_COMMAND_BEGIN then
        --sync throttle (avg)--
        local avg_lever_pos = 0
        if thrust_in_reverse == false then
            avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, 0, 1)
        else
            avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, -1, 0)
        end
        set(Cockpit_throttle_lever_L, avg_lever_pos)
        set(Cockpit_throttle_lever_R, avg_lever_pos)

        if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
            set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
            set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
        elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
            set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
            set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
        end

        wait_for_reverse_toggle = 0
        if get(Cockpit_throttle_lever_L) == 0 and get(Cockpit_throttle_lever_R) == 0 and thrust_in_reverse == true then
            thrust_in_reverse = false
            wait_for_reverse_toggle = 0.15
        end
    end

    if phase == SASL_COMMAND_CONTINUE then
        local avg_lever_pos = (get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2

        if wait_for_reverse_toggle <= 0 then
            if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
                if wait_for_detent > 0 then
                    set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2)
                    set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
                    set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
                if wait_for_detent > 0 then
                    set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2)
                    set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
                    set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            else
                if thrust_in_reverse == false then
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) + 0.4 * get(DELTA_TIME), 0, 1))
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) + 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) + 0.4 * get(DELTA_TIME), -1, 0))
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) + 0.4 * get(DELTA_TIME), -1, 0))
                end
            end

        else
            wait_for_reverse_toggle = wait_for_reverse_toggle - 1 * get(DELTA_TIME)
        end
    end

    if phase == SASL_COMMAND_END then
        wait_for_detent = 0.8
        wait_for_reverse_toggle = 0
    end

    return 0--inhibites the x-plane original command
end

function Lever_revs(phase)
    if phase == SASL_COMMAND_BEGIN then
        --sync throttle (avg)--
        local avg_lever_pos = 0
        if thrust_in_reverse == false then
            avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, 0, 1)
        else
            avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, -1, 0)
        end
        set(Cockpit_throttle_lever_L, avg_lever_pos)
        set(Cockpit_throttle_lever_R, avg_lever_pos)

        if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
            set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
            set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
        elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
            set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
            set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
        end

        wait_for_reverse_toggle = 0
        if get(Cockpit_throttle_lever_L) == 0 and get(Cockpit_throttle_lever_R) == 0 and thrust_in_reverse == false then
            thrust_in_reverse = true
            wait_for_reverse_toggle = 0.15
        end
    end

    if phase == SASL_COMMAND_CONTINUE then
        local avg_lever_pos = (get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2

        if wait_for_reverse_toggle <= 0 then
            if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
                if wait_for_detent > 0 then
                    set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2)
                    set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(Cockpit_throttle_lever_L, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
                    set(Cockpit_throttle_lever_R, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
                if wait_for_detent > 0 then
                    set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2)
                    set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(Cockpit_throttle_lever_L, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
                    set(Cockpit_throttle_lever_R, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            else
                if thrust_in_reverse == false then
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) - 0.4 * get(DELTA_TIME), 0, 1))
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) - 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) - 0.4 * get(DELTA_TIME), -1, 0))
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) - 0.4 * get(DELTA_TIME), -1, 0))
                end
            end

        else
            wait_for_reverse_toggle = wait_for_reverse_toggle - 1 * get(DELTA_TIME)
        end
    end

    if phase == SASL_COMMAND_END then
        wait_for_detent = 0.8
        wait_for_reverse_toggle = 0
    end

    return 0--inhibites the x-plane original command
end

function Toggle_reverse(phase)
    if phase == SASL_COMMAND_BEGIN then
        if thrust_in_reverse == false then
            if get(Cockpit_throttle_lever_L) <= 0.15 and get(Cockpit_throttle_lever_R) <= 0.15 then
                thrust_in_reverse = true
                set(Cockpit_throttle_lever_L, 0)
                set(Cockpit_throttle_lever_R, 0)
            end
        elseif thrust_in_reverse == true then
            thrust_in_reverse = false
            set(Cockpit_throttle_lever_L, 0)
            set(Cockpit_throttle_lever_R, 0)
        end
    end

    return 1--inhibites the x-plane original command
end

local function can_reverse_open(eng)
    
    -- Ok here we need a de-bouncing behavior: if the aircraft bounces a little bit,
    -- let's keep the reversers open. This is not the real behavior, but it would surprise
    -- a pilot using the manual button. This doesn't apply before bounce or above 10 ft AGL
    if get(Either_Aft_on_ground) == 1 then
        max_alt_rev = 0
    end
    if get(Capt_ra_alt_ft) > max_alt_rev then
        max_alt_rev = get(Capt_ra_alt_ft)
    end

    -- TODO FAILURES

    return get(Either_Aft_on_ground) == 1 or max_alt_rev < 10
end

local function update_prop_mode(manual_reverse_L, manual_reverse_R)
    if (manual_reverse_L or thrust_in_reverse) and can_reverse_open(1) then
        set(Override_eng_1_prop_mode, 3)
    else
        set(Override_eng_1_prop_mode, 1)
        if manual_reverse_L then
            prev_joy_L = 0
            set(L_sim_throttle, 0)
        end
    end

    if (manual_reverse_R or thrust_in_reverse) and can_reverse_open(2) then
        set(Override_eng_2_prop_mode, 3)
    else
        set(Override_eng_2_prop_mode, 1)
        if manual_reverse_R then
            prev_joy_R = 0
            set(R_sim_throttle, 0)
        end
    end
end

local function update_reverse_datarefs()
    Set_dataref_linear_anim(Eng_1_reverser_deployment, get(Override_eng_1_prop_mode) == 3 and 1 or 0, 0, 1, 0.5)
    Set_dataref_linear_anim(Eng_2_reverser_deployment, get(Override_eng_2_prop_mode) == 3 and 1 or 0, 0, 1, 0.5)
end

function update_levers()

    local L_hw_throttle_curr = get(L_sim_throttle) * (thrust_in_reverse and -1 or 1)
    local R_hw_throttle_curr = get(R_sim_throttle) * (thrust_in_reverse and -1 or 1)

    if prev_joy_L ~= L_hw_throttle_curr then
        prev_joy_L = L_hw_throttle_curr
        set(Cockpit_throttle_lever_L, prev_joy_L )
        if prev_joy_L < 0 then
            manual_reverse_L = true
        else
            manual_reverse_L = false
        end
    end
    if prev_joy_R ~= R_hw_throttle_curr then
        prev_joy_R = R_hw_throttle_curr
        set(Cockpit_throttle_lever_R, prev_joy_R)
        if prev_joy_R < 0 then
            manual_reverse_R = true
        else
            manual_reverse_R = false
        end
    end

    update_prop_mode(manual_reverse_L, manual_reverse_R)
    update_reverse_datarefs()
end
