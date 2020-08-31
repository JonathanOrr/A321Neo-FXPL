include('constants.lua')
include('EWD_msgs/adirs.lua')
include('ECAM_status/max_speed_fl.lua')
include('ECAM_status/appr_procedures.lua')
include('ECAM_status/procedures.lua')
include('ECAM_status/information.lua')
include('ECAM_status/inop_sys.lua')

ecam_sts = {
    
    -- LEFT PART --
    
    get_max_speed = ECAM_status_get_max_speed,
    get_max_fl = ECAM_status_get_max_fl,
    
    get_appr_proc = ECAM_status_get_appr_procedures,
    
    get_procedures = ECAM_status_get_procedures,
    
    get_information = ECAM_status_get_information,
    
    get_cancelled_cautions = function()
        local messages = {}
        
        for i, m in ipairs(_G.ewd_left_messages_list_cancelled) do
            table.insert(messages, {title = m.text(), text = m.messages[1].text() })
        end
    
        return messages
    end,

    -- RIGHT PART --
  
    get_inop_sys = ECAM_status_get_inop_sys,
    
    get_maintenance = function()
        return {  } -- TODO
    end,
    
    -- MISC --
  
    is_normal = function()
        local spd_1, spd_2 = ecam_sts:get_max_speed()
        local max_fl = ecam_sts:get_max_fl()

        return spd_1 == 0 and spd_2 == 0 and max_fl == 0 and #ecam_sts:get_appr_proc() == 0 and
               #ecam_sts:get_information() == 0 and #ecam_sts:get_cancelled_cautions() == 0 and
               #ecam_sts:get_inop_sys() == 0
    end,
    
    is_normal_maintenance = function()
        return #ecam_sts:get_maintenance() == 0
    end
    
}

