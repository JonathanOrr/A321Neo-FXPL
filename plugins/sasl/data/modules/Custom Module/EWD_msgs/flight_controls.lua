--------------------------------------------------------------------------------
-- NORMAL: GND SPLRS ARMED
--------------------------------------------------------------------------------

MessageGroup_GND_SPEEDBRAKES = {

    shown = false,

    text  = function(self)
                return ""
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_MEMO,

    messages = {
        {
            text = function(self)
                    return "GND SPLRS ARMED"
            end,
            color = function(self)
                    return COL_INDICATION
            end,
            is_active = function(self)
              return true
            end
        }
    },

    -- Method to check if this message group is active
    is_active = function(self)
        -- Not showed when any memo is active
        return get(Speedbrake_handle_ratio) < 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--    if get(FBW_status) == 1 then
--        list_left:put(LEVEL_1, {COL_CAUTION, "F/CTL ALTN LAW"})
--        list_left:put(LEVEL_1, {COL_CAUTION, "      (PROT LOST)"})
--        list_left:put(LEVEL_1, {COL_ACTIONS, "MAX SPEED.........330/.82"})
--    end 
--    if get(FBW_status) == 0 then
--        list_left:put(LEVEL_1, {COL_CAUTION, "F/CTL DIRECT LAW"})
--        list_left:put(LEVEL_1, {COL_CAUTION, "      (PROT LOST)"})
--        list_left:put(LEVEL_1, {COL_ACTIONS, "SPD BRK........DO NOT USE"})
--        list_left:put(LEVEL_1, {COL_ACTIONS, "MAX SPEED.........305/.80"})
--        list_left:put(LEVEL_1, {COL_ACTIONS, "MAN PITCH TRIM........USE"})
--        list_left:put(LEVEL_1, {COL_ACTIONS, "MANEUVER WITH CARE"})
--    end
    
    -- Takeoff phase warning and cautions
--    if (get(EWD_flight_phase) == PHASE_1ST_ENG_TO_PWR or get(EWD_flight_phase) == PHASE_ABOVE_80_KTS) then
    
--        if get(Speedbrake_handle_ratio) > 0 then
--            list_left:put(LEVEL_1, {COL_WARNING, "SPD BRK NOT RETRACTED"})
--        end
    
--        if get(Actual_brake_ratio) > 0 then
--            list_left:put(LEVEL_1, {COL_WARNING, "CONFIG PARK BRK ON"})
--        end

--    end

