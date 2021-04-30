include('EWD_msgs/common.lua')


----------------------------------------------------------------------------------------------------
-- CAUTION: AIRCOND DUCT OVERHEAT
----------------------------------------------------------------------------------------------------
-- DO NOT LOCAL
Message_AIRCOND_HOT_AIR_OFF_ON = {
    text = function() return " - HOT AIR....OFF THEN ON" end,

    color = function() return COL_ACTIONS end,

    was_off = false,

    is_active = function()
        if PB.ovhd.ac_hot_air.status_bottom then
            Message_AIRCOND_HOT_AIR_OFF_ON.was_off = true
        end
      return PB.ovhd.ac_hot_air.status_bottom or not Message_AIRCOND_HOT_AIR_OFF_ON.was_off
    end
}

MessageGroup_AIRCOND_CKPT_DUCT_OVHT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     CKPT DUCT OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRCOND_HOT_AIR_OFF_ON
    },
    is_active = function()
        return get(Aircond_injected_flow_temp,1) > 80
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

MessageGroup_AIRCOND_FWD_CAB_DUCT_OVHT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     FWD CAB DUCT OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRCOND_HOT_AIR_OFF_ON
    },
    is_active = function()
        return get(Aircond_injected_flow_temp,2) > 80
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

MessageGroup_AIRCOND_AFT_CAB_DUCT_OVHT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     AFT CAB DUCT OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRCOND_HOT_AIR_OFF_ON
    },
    is_active = function()
        return get(Aircond_injected_flow_temp,3) > 80
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

-- DO NOT LOCAL
Message_AIRCOND_HOT_AIR_CARGO_OFF_ON = {
    text = function() return " - C.HOT AIR..OFF THEN ON" end,

    color = function() return COL_ACTIONS end,

    was_off = false,

    is_active = function()
        if PB.ovhd.cargo_hot_air.status_bottom then
            Message_AIRCOND_HOT_AIR_CARGO_OFF_ON.was_off = true
        end
      return PB.ovhd.cargo_hot_air.status_bottom or not Message_AIRCOND_HOT_AIR_CARGO_OFF_ON.was_off
    end
}

MessageGroup_AIRCOND_CARGO_DUCT_OVHT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     AFT CARGO DUCT OVHT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        Message_AIRCOND_HOT_AIR_CARGO_OFF_ON
    },
    is_active = function()
        return get(Aircond_injected_flow_temp,4) > 80
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}

----------------------------------------------------------------------------------------------------
-- CAUTION: AFT CARGO VALVE STUCK
----------------------------------------------------------------------------------------------------


MessageGroup_AIRCOND_AFT_CARGO_VLV_STUCK = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     AFT CRG ISOL VALVE" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        }
    },
    is_active = function()
        return get(FAILURE_AIRCOND_ISOL_CARGO_IN_STUCK) == 1 or get(FAILURE_AIRCOND_ISOL_CARGO_OUT_STUCK) == 1
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}



----------------------------------------------------------------------------------------------------
-- CAUTION: L+R CAN FAN FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_AIRCOND_FANS_FAULT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     L+R CAB FAN FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " - ECON FLOW..........OFF" end,
            color = function() return COL_ACTIONS end,
            is_active = function() return PB.ovhd.ac_econ_flow.status_bottom end
        }
    },
    is_active = function()
        return get(FAILURE_AIRCOND_FAN_FWD) == 1 and get(FAILURE_AIRCOND_FAN_AFT) == 1
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}


----------------------------------------------------------------------------------------------------
-- CAUTION: TRIM AIR SYS FAULT
----------------------------------------------------------------------------------------------------

MessageGroup_AIRCOND_TRIM_AIR_SYS_FAULT = {

    shown = false,

    text  = function()
                return "COND"
            end,
    color = function()
                return COL_CAUTION
            end,

    priority = PRIORITY_LEVEL_2,

    sd_page = ECAM_PAGE_COND,

    messages = {
        {
            text = function() return "     TRIM AIR SYS FAULT" end,
            color = function() return COL_CAUTION end,
            is_active = function() return true end
        },
        {
            text = function() return " AFT CAB TRIM VALVE" end,
            color = function() return COL_CAUTION end,
            is_active = function() return get(FAILURE_AIRCOND_TRIM_CAB_AFT) == 1 end
        },
        {
            text = function() return " FWD CAB TRIM VALVE" end,
            color = function() return COL_CAUTION end,
            is_active = function() return get(FAILURE_AIRCOND_TRIM_CAB_FWD) == 1 end
        },
        {
            text = function() return " CKPT TRIM VALVE" end,
            color = function() return COL_CAUTION end,
            is_active = function() return get(FAILURE_AIRCOND_TRIM_CKPT) == 1 end
        },
        {
            text = function() return " AFT CRG TRIM VALVE" end,
            color = function() return COL_CAUTION end,
            is_active = function() return get(FAILURE_AIRCOND_TRIM_CARGO_AFT) == 1 end
        }

    },
    is_active = function()
        return get(FAILURE_AIRCOND_TRIM_CAB_AFT) == 1 or get(FAILURE_AIRCOND_TRIM_CAB_FWD) == 1  or get(FAILURE_AIRCOND_TRIM_CKPT) == 1  or get(FAILURE_AIRCOND_TRIM_CARGO_AFT) == 1
    end,
    is_inhibited = function()
        return is_active_in({PHASE_ELEC_PWR, PHASE_1ST_ENG_ON, PHASE_AIRBONE, PHASE_BELOW_80_KTS, PHASE_2ND_ENG_OFF})
    end
}
