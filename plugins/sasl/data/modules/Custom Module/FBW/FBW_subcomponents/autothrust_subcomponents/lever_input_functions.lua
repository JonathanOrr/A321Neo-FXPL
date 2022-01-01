--THROTTLE CONTROL PROPERTIES--
local wait_for_detent = 0.8
local wait_for_reverse_toggle = 0
local FLEX_MCT_interval = {0.85, 0.8}
local CL_interval = {0.7, 0.65}

local thrust_in_reverse_L = false -- Toggle / Hold
local thrust_in_reverse_R = false -- Toggle / Hold
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
        avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, -1, 1)
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
        if get(Cockpit_throttle_lever_L) == 0 and get(Cockpit_throttle_lever_R) == 0 and (thrust_in_reverse_L == true or thrust_in_reverse_R == true) then
            thrust_in_reverse_L = false
            thrust_in_reverse_R = false
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
                if thrust_in_reverse_L == false then
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) + 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) + 0.4 * get(DELTA_TIME), -1, 0))
                end

                if thrust_in_reverse_R == false then
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) + 0.4 * get(DELTA_TIME), 0, 1))
                else
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
        avg_lever_pos = Math_clamp((get(Cockpit_throttle_lever_L) + get(Cockpit_throttle_lever_R)) / 2, -1, 1)
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
        if get(Cockpit_throttle_lever_L) == 0 and get(Cockpit_throttle_lever_R) == 0 and (thrust_in_reverse_R == false or thrust_in_reverse_L == false) then
            thrust_in_reverse_L = true
            thrust_in_reverse_R = true
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
                if thrust_in_reverse_L == false then
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) - 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(Cockpit_throttle_lever_L, Math_clamp(get(Cockpit_throttle_lever_L) - 0.4 * get(DELTA_TIME), -1, 0))
                end
                if thrust_in_reverse_R == false then
                    set(Cockpit_throttle_lever_R, Math_clamp(get(Cockpit_throttle_lever_R) - 0.4 * get(DELTA_TIME), 0, 1))
                else
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
        if thrust_in_reverse_L == false or thrust_in_reverse_R == false then
            if get(Cockpit_throttle_lever_L) <= 0.15 and get(Cockpit_throttle_lever_R) <= 0.15 then
                thrust_in_reverse_L = true
                thrust_in_reverse_R = true
                set(Cockpit_throttle_lever_L, 0)
                set(Cockpit_throttle_lever_R, 0)
            end
        else
            thrust_in_reverse_L = false
            thrust_in_reverse_R = false
            set(Cockpit_throttle_lever_L, 0)
            set(Cockpit_throttle_lever_R, 0)
        end
    end

    return 1--inhibites the x-plane original command
end

function Hold_reverse_all(phase)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        thrust_in_reverse_L = true
        thrust_in_reverse_R = true
        set(Cockpit_throttle_lever_L, -1)
        set(Cockpit_throttle_lever_R, -1)
    elseif phase == SASL_COMMAND_END then
        thrust_in_reverse_L = false
        thrust_in_reverse_R = false
        set(Cockpit_throttle_lever_L, 0.01)
        set(Cockpit_throttle_lever_R, 0.01)
    end
    
    return 1--inhibites the x-plane original command
end

function Hold_reverse_single(phase, n)
    if phase == SASL_COMMAND_BEGIN or phase == SASL_COMMAND_CONTINUE then
        if n == 1 then
            thrust_in_reverse_L = true
            set(Cockpit_throttle_lever_L, -1)
        end
        if n == 2 then
            thrust_in_reverse_R = true
            set(Cockpit_throttle_lever_R, -1)
        end
    elseif phase == SASL_COMMAND_END then
        if n == 1 then
            thrust_in_reverse_L = false
            set(Cockpit_throttle_lever_L, 0.01)
        end
        if n == 2 then
            thrust_in_reverse_R = false
            set(Cockpit_throttle_lever_R, 0.01)
        end
    end

    return 1--inhibites the x-plane original command
end

local function can_reverse_open(eng)

    -- We need fadec elec power to open the reverser
    if (eng == 1 and not ENG.dyn[1].is_fadec_pwrd) or (eng == 2 and not ENG.dyn[2].is_fadec_pwrd) then
        return false
    end

    -- And the fadec must not be completely failed
    if get(FAILURE_ENG_FADEC_CH1, eng) == 1 and get(FAILURE_ENG_FADEC_CH2, eng) == 1 then
        return false
    end

    if (eng == 1 and get(Hydraulic_G_press) < 1000) or (eng == 2 and get(Hydraulic_Y_press) < 1000) then
        return false
    end

    if get(FAILURE_ENG_REV_FAULT, eng) == 1 then
        return false
    end

    -- Ok here we need a de-bouncing behavior: if the aircraft bounces a little bit,
    -- let's keep the reversers open. This is not the real behavior, but it would surprise
    -- a pilot using the manual button. This doesn't apply before bounce or above 10 ft AGL
    if get(Either_Aft_on_ground) == 1 then
        max_alt_rev = 0
    end
    if get(Capt_ra_alt_ft) > max_alt_rev then
        max_alt_rev = get(Capt_ra_alt_ft)
    end

    return get(Either_Aft_on_ground) == 1 or max_alt_rev < 10
end

local function update_prop_mode(manual_reverse_L, manual_reverse_R)
    if ((manual_reverse_L or thrust_in_reverse_L) and can_reverse_open(1)) or get(FAILURE_ENG_REV_UNLOCK, 1) == 1 then
        set(Override_eng_1_prop_mode, 3)
    else
        set(Override_eng_1_prop_mode, 1)
        if manual_reverse_L then
            prev_joy_L = 0
            set(L_sim_throttle, 0)
        end
    end

    if ((manual_reverse_R or thrust_in_reverse_R) and can_reverse_open(2)) or get(FAILURE_ENG_REV_UNLOCK, 2) == 1 then
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

    local L_hw_throttle_curr = get(L_sim_throttle) * (thrust_in_reverse_L and -1 or 1)
    local R_hw_throttle_curr = get(R_sim_throttle) * (thrust_in_reverse_R and -1 or 1)

    if prev_joy_L ~= L_hw_throttle_curr then
        prev_joy_L = L_hw_throttle_curr
        set(Cockpit_throttle_lever_L, prev_joy_L*(thrust_in_reverse_L and -1 or 1) )
        if prev_joy_L < 0 then
            manual_reverse_L = true
        else
            manual_reverse_L = false
        end
    end
    if prev_joy_R ~= R_hw_throttle_curr then
        prev_joy_R = R_hw_throttle_curr
        set(Cockpit_throttle_lever_R, prev_joy_R *(thrust_in_reverse_R and -1 or 1))
        if prev_joy_R < 0 then
            manual_reverse_R = true
        else
            manual_reverse_R = false
        end
    end

    update_prop_mode(manual_reverse_L, manual_reverse_R)
    update_reverse_datarefs()
end
