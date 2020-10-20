--THROTTLE CONTROL PROPERTIES--
local wait_for_detent = 0.8
local wait_for_reverse_toggle = 0
local FLEX_MCT_interval = {0.85, 0.8}
local CL_interval = {0.7, 0.65}
local thrust_in_reverse = false

--overriding callback functions
function Lever_fwd(phase)
    if phase == SASL_COMMAND_BEGIN then
        --sync throttle (avg)--
        local avg_lever_pos = 0
        if thrust_in_reverse == false then
            avg_lever_pos = Math_clamp((get(L_sim_throttle) + get(R_sim_throttle)) / 2, 0, 1)
        else
            avg_lever_pos = Math_clamp((get(L_sim_throttle) + get(R_sim_throttle)) / 2, -1, 0)
        end
        set(L_sim_throttle, avg_lever_pos)
        set(R_sim_throttle, avg_lever_pos)

        if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
            set(L_sim_throttle, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
            set(R_sim_throttle, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
        elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
            set(L_sim_throttle, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
            set(R_sim_throttle, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
        end

        wait_for_reverse_toggle = 0
        if get(L_sim_throttle) == 0 and get(R_sim_throttle) == 0 and thrust_in_reverse == true then
            thrust_in_reverse = false
            wait_for_reverse_toggle = 0.15
        end
    end

    if phase == SASL_COMMAND_CONTINUE then
        local avg_lever_pos = (get(L_sim_throttle) + get(R_sim_throttle)) / 2

        if wait_for_reverse_toggle <= 0 then
            if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
                if wait_for_detent > 0 then
                    set(L_sim_throttle, (0.85 + 0.8) / 2)
                    set(R_sim_throttle, (0.85 + 0.8) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(L_sim_throttle, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
                    set(R_sim_throttle, (0.85 + 0.8) / 2 + (0.85 - 0.8) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
                if wait_for_detent > 0 then
                    set(L_sim_throttle, (0.7 + 0.65) / 2)
                    set(R_sim_throttle, (0.7 + 0.65) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(L_sim_throttle, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
                    set(R_sim_throttle, (0.7 + 0.65) / 2 + (0.7 - 0.65) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            else
                if thrust_in_reverse == false then
                    set(L_sim_throttle, Math_clamp(get(L_sim_throttle) + 0.4 * get(DELTA_TIME), 0, 1))
                    set(R_sim_throttle, Math_clamp(get(R_sim_throttle) + 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(L_sim_throttle, Math_clamp(get(L_sim_throttle) + 0.4 * get(DELTA_TIME), -1, 0))
                    set(R_sim_throttle, Math_clamp(get(R_sim_throttle) + 0.4 * get(DELTA_TIME), -1, 0))
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
            avg_lever_pos = Math_clamp((get(L_sim_throttle) + get(R_sim_throttle)) / 2, 0, 1)
        else
            avg_lever_pos = Math_clamp((get(L_sim_throttle) + get(R_sim_throttle)) / 2, -1, 0)
        end
        set(L_sim_throttle, avg_lever_pos)
        set(R_sim_throttle, avg_lever_pos)

        if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
            set(L_sim_throttle, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
            set(R_sim_throttle, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
        elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
            set(L_sim_throttle, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
            set(R_sim_throttle, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
        end

        wait_for_reverse_toggle = 0
        if get(L_sim_throttle) == 0 and get(R_sim_throttle) == 0 and thrust_in_reverse == false then
            thrust_in_reverse = true
            wait_for_reverse_toggle = 0.15
        end
    end

    if phase == SASL_COMMAND_CONTINUE then
        local avg_lever_pos = (get(L_sim_throttle) + get(R_sim_throttle)) / 2

        if wait_for_reverse_toggle <= 0 then
            if FLEX_MCT_interval[1] >= avg_lever_pos and avg_lever_pos >= FLEX_MCT_interval[2] then
                if wait_for_detent > 0 then
                    set(L_sim_throttle, (0.85 + 0.8) / 2)
                    set(R_sim_throttle, (0.85 + 0.8) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(L_sim_throttle, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
                    set(R_sim_throttle, (0.85 + 0.8) / 2 - (0.85 - 0.8) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            elseif CL_interval[1] >= avg_lever_pos and avg_lever_pos >= CL_interval[2] then
                if wait_for_detent > 0 then
                    set(L_sim_throttle, (0.7 + 0.65) / 2)
                    set(R_sim_throttle, (0.7 + 0.65) / 2)
                    wait_for_detent = wait_for_detent - 1 * get(DELTA_TIME)
                else
                    set(L_sim_throttle, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
                    set(R_sim_throttle, (0.7 + 0.65) / 2 - (0.7 - 0.65) / 2 * 1.02)
                    wait_for_detent = 0.8
                end
            else
                if thrust_in_reverse == false then
                    set(L_sim_throttle, Math_clamp(get(L_sim_throttle) - 0.4 * get(DELTA_TIME), 0, 1))
                    set(R_sim_throttle, Math_clamp(get(R_sim_throttle) - 0.4 * get(DELTA_TIME), 0, 1))
                else
                    set(L_sim_throttle, Math_clamp(get(L_sim_throttle) - 0.4 * get(DELTA_TIME), -1, 0))
                    set(R_sim_throttle, Math_clamp(get(R_sim_throttle) - 0.4 * get(DELTA_TIME), -1, 0))
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
            if get(L_sim_throttle) <= 0.15 and get(R_sim_throttle) <= 0.15 then
                thrust_in_reverse = true
                set(L_sim_throttle, 0)
                set(R_sim_throttle, 0)
            end
        elseif thrust_in_reverse == true then
            thrust_in_reverse = false
            set(L_sim_throttle, 0)
            set(R_sim_throttle, 0)
        end
    end

    return 0--inhibites the x-plane original command
end