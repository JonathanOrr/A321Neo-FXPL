include('EWD_msgs/common.lua')

--------------------------------------------------------------------------------
-- NORMAL: SEAT BELTS
--------------------------------------------------------------------------------

MessageGroup_SEAT_BELTS = {

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
                    return "SEAT BELTS"
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
        return get(Seatbelts) ~= 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}

--------------------------------------------------------------------------------
-- NORMAL: NO SMOKING
--------------------------------------------------------------------------------

MessageGroup_NO_SMOKING = {

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
                    return "NO PORTABLE DEVICES"
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
        return get(NoSmoking) ~= 0 and get(EWD_is_to_memo_showed) == 0 and get(EWD_is_ldg_memo_showed) == 0
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--------------------------------------------------------------------------------
-- NORMAL: NORMAL
-- This is used in some cases to show "NORMAL" on ECAM, e.g. when you press the
-- RCL button and no messages are available to be recalled
--------------------------------------------------------------------------------

MessageGroup_NORMAL = {

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
                    return "NORMAL"
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
        if (get(TIME) - get(EWD_show_normal)) < 5 then  -- Active for 5 seconds
            return true
        else
            return false
        end
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}


--------------------------------------------------------------------------------
-- NORMAL/CAUTION: IRS_ALIGN
--------------------------------------------------------------------------------

MessageGroup_IRS_ALIGN = {

    shown = false,

    text  = function(self)
                return ""
            end,
    color = function(self)
                return COL_INDICATION
            end,

    priority = PRIORITY_LEVEL_1,

    messages = {
        {
            text = function(self)
                local time_left_irs_1 = ADIRS_sys[ADIRS_1].ir_align_start_time + get(Adirs_total_time_to_align) - get(TIME) 
                local time_left_irs_2 = ADIRS_sys[ADIRS_2].ir_align_start_time + get(Adirs_total_time_to_align) - get(TIME) 
                local time_left_irs_3 = ADIRS_sys[ADIRS_3].ir_align_start_time + get(Adirs_total_time_to_align) - get(TIME) 
                local time_max = 0

                if ADIRS_sys[ADIRS_1].ir_align_start_time > 0 then
                    time_max = math.max(time_max, time_left_irs_1)
                end
                if ADIRS_sys[ADIRS_2].ir_align_start_time > 0 then
                    time_max = math.max(time_max, time_left_irs_2)
                end
                if ADIRS_sys[ADIRS_3].ir_align_start_time > 0 then
                    time_max = math.max(time_max, time_left_irs_3)
                end
            
                local minutes = math.floor(time_max / 60)
                if get(EWD_flight_phase) <= PHASE_1ST_ENG_ON then
                    return "IRS IN ALIGN " .. minutes .. " MN"
                else
                    return "IRS IN ALIGN"
                end
            end,
            color = function(self)
                if get(EWD_flight_phase) <= PHASE_ELEC_PWR then
                    return COL_INDICATION
                else
                    return COL_CAUTION                
                end
            end,
            is_active = function(self)
              return true
            end
        }
    },

    -- Method to check if this message group is active
    is_active = function(self)
        irs1_is_aligning = ADIRS_sys[ADIRS_1].ir_status == IR_STATUS_IN_ALIGN
        irs2_is_aligning = ADIRS_sys[ADIRS_2].ir_status == IR_STATUS_IN_ALIGN
        irs3_is_aligning = ADIRS_sys[ADIRS_3].ir_status == IR_STATUS_IN_ALIGN
        return irs1_is_aligning or irs2_is_aligning or irs3_is_aligning
    end,

    -- Method to check if this message is currently inhibithed
    is_inhibited = function(self)
        return false
    end

}

--------------------------------------------------------------------------------
-- CAUTION: AVIONICS SMOKE
--------------------------------------------------------------------------------

MessageGroup_AVIONICS_SMOKE= {

    shown = false,

    text  = function()
                return "AVIONICS SMOKE"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,
    
    sd_page = ECAM_PAGE_ELEC,
    
    messages = {
        {
            text = function() return "" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " AVNCS SMOKE PROC...APPLY" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }

    },

    land_asap = true,

    is_active = function()
        return get(FAILURE_AVIONICS_SMOKE) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_FINAL, PHASE_TOUCHDOWN})
    end
}


