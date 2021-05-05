include('EWD_msgs/common.lua')

--------------------------------------------------------------------------------
-- CAUTION: ALTN LAW and DIRECT LAW
--------------------------------------------------------------------------------

local Message_ALTN_LAW = {
    text = function()
            return "      ALTN LAW"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW 
          or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW
    end
}

local Message_DIRECT_LAW = {
    text = function()
            return "      DIRECT LAW"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

local Message_PROT_LOST = {
    text = function()
            return "      (PROT LOST)"
    end,
    color = function()
            return COL_CAUTION
    end,
    is_active = function()
      return true
    end
}

local Message_FBW_DO_NOT_SPD_BRK = {
    text = function()
            return " SPD BRK.......DO NOT USE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

local Message_FBW_SPEED_LIMIT = {
    text = function()
        if get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW 
        or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW then
            return " MAX SPEED........320/.82"
        else
            return " MAX SPEED........320/.77"
        end
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return true
    end
}

local Message_FBW_MAN_PITCH_TRIM = {
    text = function()
            return " - MAN PITCH TRIM.....USE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

local Message_FBW_MANEUVER_WITH_CARE = {
    text = function()
            return " MANEUVER WITH CARE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}

local Message_SPDBRK_DO_NOT_USE_ELEV = {
    text = function()
            return " - SPD BRK.....DO NOT USE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return (get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW) and 
             (get(FAILURE_FCTL_LELEV) == 1 or get(FAILURE_FCTL_RELEV) == 1)
    end
}

local Message_SPDBRK_WITH_CARE = {
    text = function()
            return " USE SPD BRK WITH CARE"
    end,
    color = function()
            return COL_ACTIONS
    end,
    is_active = function()
      return get(FBW_total_control_law) == FBW_DIRECT_LAW
    end
}


MessageGroup_FBW_ALTN_DIRECT_LAW = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_ALTN_LAW,
        Message_DIRECT_LAW,
        Message_PROT_LOST,
        Message_FBW_DO_NOT_SPD_BRK,
        Message_FBW_SPEED_LIMIT,
        Message_FBW_MAN_PITCH_TRIM,
        Message_SPDBRK_DO_NOT_USE_ELEV,
        Message_FBW_MANEUVER_WITH_CARE

    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        return get(FBW_total_control_law) == FBW_ALT_REDUCED_PROT_LAW or get(FBW_total_control_law) == FBW_ALT_NO_PROT_LAW or get(FBW_total_control_law) == FBW_DIRECT_LAW
    end,

    is_inhibited = function()
        return is_active_in({PHASE_1ST_ENG_TO_PWR, PHASE_AIRBONE, PHASE_BELOW_80_KTS})
    end

}

--------------------------------------------------------------------------------
-- CAUTION: ELAC 1/2 FAULT
--------------------------------------------------------------------------------

local Message_FBW_ELAC_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_FCTL_ELAC_1) == 1 and get(FAILURE_FCTL_ELAC_2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_FCTL_ELAC_1) == 1 then
            N = "1"
        elseif get(FAILURE_FCTL_ELAC_2) == 1 then
            N = "2"
        end
        return "      ELAC " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

local Message_FBW_ELAC_1_OFF_THEN_ON = {
    text = function() return " - ELAC 1.....OFF THEN ON"  end,
    color = function() return COL_ACTIONS end,


    is_active = function()
        if PB.ovhd.flt_ctl_elac_1.status_bottom then
            -- PB is [off]
            if MessageGroup_FBW_ELAC_FAULT.has_1_reset == 0 then
                MessageGroup_FBW_ELAC_FAULT.has_1_reset = 1
            end
        elseif MessageGroup_FBW_ELAC_FAULT.has_1_reset == 1 then
            MessageGroup_FBW_ELAC_FAULT.has_1_reset = 2
        end
        return get(FAILURE_FCTL_ELAC_1) == 1 and 
              MessageGroup_FBW_ELAC_FAULT.has_1_reset ~= 2 and
              (MessageGroup_FBW_ELAC_FAULT.has_1_reset == 0 or PB.ovhd.flt_ctl_elac_1.status_bottom)
    end
}

local Message_FBW_ELAC_2_OFF_THEN_ON = {
    text = function() return " - ELAC 2.....OFF THEN ON"  end,
    color = function() return COL_ACTIONS end,


    is_active = function()
        if PB.ovhd.flt_ctl_elac_2.status_bottom then
            -- PB is [off]
            if MessageGroup_FBW_ELAC_FAULT.has_2_reset == 0 then
                MessageGroup_FBW_ELAC_FAULT.has_2_reset = 1
            end
        elseif MessageGroup_FBW_ELAC_FAULT.has_2_reset == 1 then
            MessageGroup_FBW_ELAC_FAULT.has_2_reset = 2
        end
        return get(FAILURE_FCTL_ELAC_2) == 1 and 
              MessageGroup_FBW_ELAC_FAULT.has_2_reset ~= 2 and
              (MessageGroup_FBW_ELAC_FAULT.has_2_reset == 0 or PB.ovhd.flt_ctl_elac_2.status_bottom)
    end
}


MessageGroup_FBW_ELAC_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_FBW_ELAC_FAULT,
        Message_FBW_ELAC_1_OFF_THEN_ON,
        Message_FBW_ELAC_2_OFF_THEN_ON,
        {
            text = function() return " . IF UNSUCCESSFUL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        {
            text = function() return " - ELAC 1.............OFF"  end,
            color = function() return COL_ACTIONS end,
            is_active = function()
                return get(FAILURE_FCTL_ELAC_1) == 1 and not PB.ovhd.flt_ctl_elac_1.status_bottom
            end
        },
        {
            text = function() return " - ELAC 2.............OFF"  end,
            color = function() return COL_ACTIONS end,
            is_active = function()
                return get(FAILURE_FCTL_ELAC_2) == 1 and not PB.ovhd.flt_ctl_elac_2.status_bottom
            end
        },
        {
            text = function() return " FUEL CONSUMPTION INCRSD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " FMS PRED UNRELIABLE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        }
    },

    has_1_reset = 0,    -- It says if you have already tried to reset ELAC 1
    has_2_reset = 0,    -- or ELAC 2 (0: nothing done, 1: on->off, 2:done)

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        -- First of all reset the booelans
        if get(FAILURE_FCTL_ELAC_1) == 0 then
            has_1_reset = 0
        end
        if get(FAILURE_FCTL_ELAC_2) == 0 then
            has_2_reset = 0
        end
        return get(FAILURE_FCTL_ELAC_1) == 1 or get(FAILURE_FCTL_ELAC_2) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, 
                             PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}


--------------------------------------------------------------------------------
-- CAUTION: FLAP SYS 1/2 FAULT
--------------------------------------------------------------------------------

local Message_FBW_FLAP_SYS_12_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_FCTL_SFCC_1) == 1 and get(FAILURE_FCTL_SFCC_2) == 1 then
            N = "1 + 2"
        elseif get(FAILURE_FCTL_SFCC_1) == 1 then
            N = "1"
        elseif get(FAILURE_FCTL_SFCC_2) == 1 then
            N = "2"
        end
        return "      FLAP SYS " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}



MessageGroup_FBW_FLAP_SYS_12_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_FBW_FLAP_SYS_12_FAULT
    },

    sd_page = nil,

    is_active = function()
        -- First of all reset the booelans
        return get(FAILURE_FCTL_SFCC_1) == 1 or get(FAILURE_FCTL_SFCC_2) == 1
    end,

    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, 
                             PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}


--------------------------------------------------------------------------------
-- CAUTION: FLAPS FAULT
--------------------------------------------------------------------------------

local function get_max_speed_with_flap_jammed()
    local flaps  = get(Flaps_deployed_angle)
    local slats = get(Slats) 

    if flaps == 0 and slats == 0 then
        return nil
    elseif slats <= 0.7 and flaps == 0 then
        return 230
    elseif slats <= 0.7 and flaps <= 10 then
        return 215
    elseif slats <= 0.8 and flaps <= 10 then
        return 200
    elseif slats <= 1 and flaps <= 10 then
        return 177
    elseif slats <= 0.8 and flaps <= 14 then
        return 200
    elseif slats <= 1 and flaps <= 14 then
        return 177
    elseif slats <= 0.8 and flaps <= 21 then
        return 185
    else
        return 177
    end
end

MessageGroup_FBW_FLAPS_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        {
            text = function() return "      FLAPS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - MAX SPEED......." .. get_max_speed_with_flap_jammed() .. " KT" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get_max_speed_with_flap_jammed() ~= nil end
        },
        {
            text = function() return " - FLAPS LEVER....RECYCLE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return true end
        },
        {
            text = function() return " FUEL CONSUMPT INCRSD" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return  get_max_speed_with_flap_jammed() ~= nil end
        },
        {
            text = function() return " FMS PRED UNRELIABLE" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get_max_speed_with_flap_jammed() ~= nil end
        },


    },

    sd_page = nil,

    is_active = function()
        -- First of all reset the booelans
        return get(Slats_ecam_amber) == 1 or get(Flaps_ecam_amber) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_ABOVE_80_KTS, PHASE_LIFTOFF, PHASE_TOUCHDOWN})
    end
}


--------------------------------------------------------------------------------
-- CAUTION: SEC 1/2/2 FAULT
--------------------------------------------------------------------------------

local Message_FBW_SEC_123_FAULT = {
    text = function()
        local N = ""
        if get(FAILURE_FCTL_SEC_1) == 1 and get(FAILURE_FCTL_SEC_2) == 1 and get(FAILURE_FCTL_SEC_3) == 1 then
            N = "1+2+3"
        elseif get(FAILURE_FCTL_SEC_1) == 1 and get(FAILURE_FCTL_SEC_2) == 1 then
            N = "1+2"
        elseif get(FAILURE_FCTL_SEC_3) == 1 and get(FAILURE_FCTL_SEC_2) == 1 then
            N = "2+3"
        elseif get(FAILURE_FCTL_SEC_3) == 1 and get(FAILURE_FCTL_SEC_1) == 1 then
            N = "1+3"
        elseif get(FAILURE_FCTL_SEC_1) == 1 then
            N = "1"
        elseif get(FAILURE_FCTL_SEC_2) == 1 then
            N = "2"
        elseif get(FAILURE_FCTL_SEC_3) == 1 then
            N = "3"
        end
        return "      SEC " .. N .. " FAULT"
    end,

    color = function()
        return COL_CAUTION
    end,

    is_active = function()
      return true -- Always active when group is active
    end
}

Message_FBW_SEC_1_RESET = {
    status = 0,
    text = function() return " - SEC 1......OFF THEN ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function()
        if Message_FBW_SEC_1_RESET.status == 0 and PB.ovhd.flt_ctl_sec_1.status_bottom then
            Message_FBW_SEC_1_RESET.status = 1
        end
        if Message_FBW_SEC_1_RESET.status == 1 and not PB.ovhd.flt_ctl_sec_1.status_bottom then
            Message_FBW_SEC_1_RESET.status = 2
        end
        return Message_FBW_SEC_1_RESET.status < 2 and get(FAILURE_FCTL_SEC_1) == 1
    end
}

Message_FBW_SEC_2_RESET = {
    status = 0,
    text = function() return " - SEC 2......OFF THEN ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function()
        if Message_FBW_SEC_2_RESET.status == 0 and PB.ovhd.flt_ctl_sec_2.status_bottom then
            Message_FBW_SEC_2_RESET.status = 1
        end
        if Message_FBW_SEC_2_RESET.status == 1 and not PB.ovhd.flt_ctl_sec_2.status_bottom then
            Message_FBW_SEC_2_RESET.status = 2
        end
        return Message_FBW_SEC_2_RESET.status < 2 and get(FAILURE_FCTL_SEC_2) == 1
    end
}

Message_FBW_SEC_3_RESET = {
    status = 0,
    text = function() return " - SEC 3......OFF THEN ON" end,
    color = function() return COL_ACTIONS end,
    is_active = function()
        if Message_FBW_SEC_3_RESET.status == 0 and PB.ovhd.flt_ctl_sec_3.status_bottom then
            Message_FBW_SEC_3_RESET.status = 1
        end
        if Message_FBW_SEC_3_RESET.status == 1 and not PB.ovhd.flt_ctl_sec_3.status_bottom then
            Message_FBW_SEC_3_RESET.status = 2
        end
        return Message_FBW_SEC_3_RESET.status < 2 and get(FAILURE_FCTL_SEC_3) == 1
    end
}


MessageGroup_FBW_SEC_123_FAULT = {

    shown = false,

    text  = function()
                return "F/CTL"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    messages = {
        Message_FBW_SEC_123_FAULT,
        Message_FBW_SEC_1_RESET,
        Message_FBW_SEC_2_RESET,
        Message_FBW_SEC_3_RESET,
        {
            text = function() return " . IF UNSUCCESSFUL:" end,
            color = function() return COL_REMARKS end,
            is_active = function() return true end
        },
        {
            text = function() return "   - SEC 1............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_FCTL_SEC_1) == 1 and not PB.ovhd.flt_ctl_sec_1.status_bottom end
        },
        {
            text = function() return "   - SEC 2............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_FCTL_SEC_2) == 1 and not PB.ovhd.flt_ctl_sec_2.status_bottom end
        },
        {
            text = function() return "   - SEC 3............OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return get(FAILURE_FCTL_SEC_3) == 1 and not PB.ovhd.flt_ctl_sec_3.status_bottom end
        }
    },

    sd_page = ECAM_PAGE_FCTL,

    is_active = function()
        -- First of all reset the booelans
        return get(FAILURE_FCTL_SEC_1) == 1 or get(FAILURE_FCTL_SEC_2) == 1 or get(FAILURE_FCTL_SEC_3) == 1
    end,

    is_inhibited = function()
        return is_inibithed_in({PHASE_1ST_ENG_TO_PWR, PHASE_ABOVE_80_KTS, PHASE_LIFTOFF})
    end
}


